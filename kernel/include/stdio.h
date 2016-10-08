//
//
//

#ifndef __STDIO_H_
#define __STDIO_H_


#define VIDEO_MEM   0xB8000
#define COLS        80
#define ROWS        25


void clear_screen();

void cursor_xy(int x, int y);

void putch(char cb);

void puts(const char *str);

#endif//__STDIO_H_
