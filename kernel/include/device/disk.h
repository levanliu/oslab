#ifndef __DISK_H__
#define __DISK_H__

void waitDisk(void);
void readSect(void *dst, int offset);
void writeSect(const void *src, int offset);

#endif
