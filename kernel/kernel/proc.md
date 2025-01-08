kernel module for process management. It includes functions for file descriptor management and interrupt handling, as well as a function to allocate a new process. 

### `fd_close(int fd)`
This function closes a file descriptor `fd` for the current process.
- It checks if `fd` is within the valid range and if the file descriptor is not `NULL`.
- If valid, it calls `fs_close` to close the file and sets the file descriptor to `NULL`.

### `push_off()`
This function disables interrupts and updates the current process's interrupt state.
- It checks if interrupts are currently enabled.
- Disables interrupts.
- Asserts that the current process (`curr`) is valid.
- If this is the first time interrupts are being disabled (`noff` is 0), it saves the interrupt state.
- Increments the `noff` counter to track nested calls.

### `pop_off()`
This function re-enables interrupts if they were enabled before the corresponding `push_off` call.
- Asserts that the current process is valid and that interrupts are currently disabled.
- Decrements the `noff` counter.
- If `noff` reaches 0 and interrupts were previously enabled, it re-enables interrupts.

### `alloc_proc()`
This function allocates a new process from the process pool.
- It uses a static variable `pid` to assign unique process IDs.
- Iterates through the process pool to find an unused process slot.
- Calls `push_off()` to disable interrupts while accessing the process pool.
- If an unused slot is found, it initializes the process structure, assigns a new `pid`, and sets the status to `UNINIT`.


### `sys_fork(TrapFrame *tf)`
This function handles the `fork` system call, which creates a new process by duplicating the current process.

1. **Allocate a new process**:
   ```c
   proc_t *p = alloc_proc();
   ```
   - Calls `alloc_proc()` to allocate a new process structure. If allocation fails, it sets the return value to `-1` and exits.

2. **Initialize the new process**:
   ```c
   p->parent = curr;
   tf->eax = p->pid;
   ```
   - Sets the parent of the new process to the current process.
   - Sets the return value of the `fork` system call in the parent process to the new process's PID.

3. **Set up the new process's address space**:
   ```c
   upgdir = uvm_protect();
   uvm_copy(upgdir, (void*)read_cr3());
   ```
   - Creates a new page directory for the new process.
   - Copies the current process's address space to the new process.

4. **Copy the trap frame**:
   ```c
   *(p->ctx) = *tf;
   p->ctx->cr3 = (uint32_t)upgdir;
   p->ctx->eax = 0;
   ```
   - Copies the trap frame (CPU state) from the parent to the child.
   - Sets the new process's page directory.
   - Sets the return value of the `fork` system call in the child process to `0`.

5. **Duplicate file descriptors**:
   ```c
   p->pwd = idup(curr->pwd);
   p->brk = curr->brk;
   for (int i = 0; i < MAX_OPEN_FILE; ++i) {
     if (curr->files[i]) {
       p->files[i] = fs_dup(curr->files[i]);
     }
   }
   ```
   - Duplicates the current working directory and the break (end of the data segment).
   - Duplicates the open file descriptors from the parent to the child.

6. **Set the new process's status to `RUNNABLE`**:
   ```c
   push_off();
   p->status = RUNNABLE;
   pop_off();
   ```
   - Disables interrupts, sets the new process's status to `RUNNABLE`, and re-enables interrupts.
