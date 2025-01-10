#ifndef __SERIAL_H__
#define __SERIAL_H__
#include "common/types.h"

void initSerial(void);
void putChar(char);
void putStr(char *);
void putNum(uint32_t num);
void printk(const char *fmt, ...);
#define SERIAL_PORT  0x3F8

#endif
