#ifndef __PROC__
#define __PROC__

#include "x86/memory.h"
#define MAX_OPEN_FILE 32

typedef struct proc {
  int pid;                // Process ID
  int intena;             // Interrupt enable flag
  int noff;               // Nested push_off() count
  int exit_code;          // Exit code for the process
  int killed;             // Flag indicating if the process has been killed
  enum {UNUSED = 0, UNINIT, RUNNING, RUNNABLE, SLEEPING, ZOMBIE} status; // Process status
  void *chan;             // Channel on which the process is sleeping (if any)
  void *kstack;           // Kernel stack for the process
  TrapFrame *ctx;         // Trap frame (CPU state) for context switching
  struct proc *parent;    // Pointer to the parent process
  struct file *files[MAX_OPEN_FILE]; // Array of file descriptors
  struct icache *pwd;     // Pointer to the current working directory
  uint32_t brk;           // End of the process's data segment (for memory allocation)
} proc_t;

void yield();
void sleep(void *chan);
void wakeup(void *chan);
void load_proc(TrapFrame *ctx, PDE *pgtbl, uint32_t entry, uint32_t ustack_top);

void sys_fork(TrapFrame *tf);
void sys_wait(TrapFrame *tf);
void sys_exit(TrapFrame *tf);
void sys_sleep(TrapFrame *tf);
void sys_exec(TrapFrame *tf);
void sys_kill(TrapFrame *tf);
void sys_brk(TrapFrame *tf);
void sys_getpid(TrapFrame *tf);

#endif
