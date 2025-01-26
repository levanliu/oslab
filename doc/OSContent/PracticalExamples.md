# Practical Examples in HVM

## Code snippets and scenarios where OS skills solve problems

### Example 1: Optimizing Process Scheduling
Efficient process scheduling is crucial for maximizing CPU utilization and ensuring that high-priority tasks are executed in a timely manner. The following example demonstrates how to create and manage threads using POSIX threads (pthreads) in C.

```c
// Example code for optimizing process scheduling
#include <stdio.h>
#include <pthread.h>

void *task(void *arg) {
    // Task implementation
    printf("Task executed\n");
    return NULL;
}

int main() {
    pthread_t thread1, thread2;
    pthread_create(&thread1, NULL, task, NULL);
    pthread_create(&thread2, NULL, task, NULL);
    pthread_join(thread1, NULL);
    pthread_join(thread2, NULL);
    return 0;
}
```

### Example 2: Handling Resource Contention
Resource contention occurs when multiple threads or processes attempt to access shared resources simultaneously. Proper synchronization mechanisms, such as mutexes, can help prevent race conditions and ensure data integrity. The following example demonstrates how to use a mutex to protect a critical section.

```c
// Example code for handling resource contention using mutex
#include <stdio.h>
#include <pthread.h>
#include <stdlib.h>

pthread_mutex_t lock;

void *task(void *arg) {
    pthread_mutex_lock(&lock);
    // Critical section
    printf("Critical section accessed by thread\n");
    pthread_mutex_unlock(&lock);
    return NULL;
}

int main() {
    pthread_t thread1, thread2;
    pthread_mutex_init(&lock, NULL);
    pthread_create(&thread1, NULL, task, NULL);
    pthread_create(&thread2, NULL, task, NULL);
    pthread_join(thread1, NULL);
    pthread_join(thread2, NULL);
    pthread_mutex_destroy(&lock);
    return 0;
}
```
