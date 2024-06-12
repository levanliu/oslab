### List of multi-threads to support


**Spin Lock**:
```c
  #include <stdatomic.h>
  
  typedef atomic_flag spinlock_t;
  
  void spinlock_init(spinlock_t *lock) {
      atomic_flag_clear(lock);
  }
  
  void spinlock_lock(spinlock_t *lock) {
      while (atomic_flag_test_and_set(lock)) {}
  }
  
  void spinlock_unlock(spinlock_t *lock) {
      atomic_flag_clear(lock);
  }
```
**Mutex Lock**

```c
  #include <pthread.h>
  
  pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
  
  void mutex_lock() {
      pthread_mutex_lock(&mutex);
  }
  
  void mutex_unlock() {
      pthread_mutex_unlock(&mutex);
  }
```
**Read-Write Lock:**

```c
  #include <pthread.h>

  pthread_rwlock_t rwlock = PTHREAD_RWLOCK_INITIALIZER;

  void read_lock() {
      pthread_rwlock_rdlock(&rwlock);
  }

  void write_lock() {
      pthread_rwlock_wrlock(&rwlock);
  }

  void unlock() {
      pthread_rwlock_unlock(&rwlock);
  }
```
**Semaphore Lock:**
```c
  #include <semaphore.h>
  
  sem_t semaphore;
  
  void init_semaphore() {
      sem_init(&semaphore, 0, 1);
  }
  
  void wait_semaphore() {
      sem_wait(&semaphore);
  }
  
  void post_semaphore() {
      sem_post(&semaphore);
  }
```

**Condition Varibales**
```c
  #include <pthread.h>
  
  pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
  pthread_cond_t cond = PTHREAD_COND_INITIALIZER;
  
  void* thread_function(void* arg) {
      pthread_mutex_lock(&mutex);
      // Wait for a condition to be met
      pthread_cond_wait(&cond, &mutex);
      // Do something after condition is met
      pthread_mutex_unlock(&mutex);
      return NULL;
  }
  
  int main() {
      pthread_t thread;
      pthread_create(&thread, NULL, thread_function, NULL);
  
      // Signal the condition
      pthread_mutex_lock(&mutex);
      pthread_cond_signal(&cond);
      pthread_mutex_unlock(&mutex);
  
      pthread_join(thread, NULL);
      return 0;
  }
```
**Atomic Operations:**
```c
  #include <stdatomic.h>
  
  _Atomic int value = ATOMIC_VAR_INIT(0);
  
  // Example of atomic increment
  void increment_value() {
      atomic_fetch_add(&value, 1);
  }
```
**Futex (Fast Userspace Mutex):**
```c
  #include <linux/futex.h>
  #include <sys/syscall.h>
  
  void futex_wait(volatile int* futex_addr, int val) {
      syscall(SYS_futex, futex_addr, FUTEX_WAIT, val, NULL, NULL, 0);
  }
  
  void futex_wake(volatile int* futex_addr) {
      syscall(SYS_futex, futex_addr, FUTEX_WAKE, 1, NULL, NULL, 0);
  }
```


**Example Code**
```c
#include <stdio.h>
#include <pthread.h>

pthread_cond_t condition = PTHREAD_COND_INITIALIZER;
pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
int sharedData = 0;

void* producer(void* arg){
    while(1){
        pthread_mutex_lock(&mutex);
        sharedData++;
        printf("Produced: %d\n", sharedData);
        pthread_cond_signal(&condition);
        pthread_mutex_unlock(&mutex);
        sleep(1);
    }
}

void* consumer(void* arg){
    while(1){
        pthread_mutex_lock(&mutex);
        while(sharedData == 0){
            pthread_cond_wait(&condition,&mutex);
        }
        printf("Consumed: %d\n",sharedData);
        sharedData = 0;
        pthread_mutex_unlock(&mutex);
        sleep(1);
    }
}

int main(){
    pthread_t producerThread,consumerThread;
    pthread_create(&producerThread,NULL,producer,NULL);
    pthread_create(&consumerThread,NULL,consumer,NULL);

    pthread_join(producerThread,NULL);
    pthread_join(consumerThread,NULL);

    return 0;
}
```
### Current process introduction

```c
typedef struct proc {
  int pid, intena, noff, exit_code, killed;
  enum {UNUSED = 0, UNINIT, RUNNING, RUNNABLE, SLEEPING, ZOMBIE} status;
  void *chan;
  void *kstack;
  TrapFrame *ctx;
  struct proc *parent;
  struct file *files[MAX_OPEN_FILE];
  struct icache *pwd;
  uint32_t brk;
} proc_t;
```

pid: the process identifier number
intean: is interrupt enable
noff: file offset
exit_code:
killed:
status: enum of process status.
chan: conditional varible for inter process communication.
kstack: kernal stack, work for interrupts, traps, system calls, and context switches.store local variables, function call information, and other data without interfering with the user stack. 
ctx: interrupt handle, OS switch between different processes.
parent: parent process
files: 
pwd: inode cache (store the current working directory.).
brk: end of the data segment.(program's heap)


### The differences between kernel stack and user stack

**Privilege Levels:**
The user stack is used for executing user-space code at the application level, operating within user mode privileges.
The kernel stack is dedicated to executing and handling kernel-level operations, running in a more privileged kernel mode.

**Context:**
The user stack contains function call information, local variables, and other user-space data used during application execution.
The kernel stack stores information related to kernel operations such as interrupt handling, system calls, and context switches, providing a separate area for kernel code to execute safely without interference from user-space activities.

**Protection:**
User stack memory is typically protected to prevent unauthorized access by kernel code, promoting security and ensuring that user processes cannot directly modify or corrupt kernel data.
Kernel stack memory is similarly protected from user mode access. This isolation ensures that critical kernel operations are shielded from unintended interference or corruption by user applications.

**Size and Management:**
User stacks are typically smaller in size and are managed dynamically as the application makes function calls and allocates local variables.
Kernel stacks are often pre-allocated with a fixed size, as they need to support a variety of kernel operations, including handling hardware interrupts, exceptions, and executing kernel-level procedures.

**Switching:**
When transitioning between user space and kernel space (such as when a system call occurs), the architecture performs a switch in stack usage, moving from the user stack to the kernel stack to handle kernel-level operations effectively.

