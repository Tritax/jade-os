/*

*/

#include "stdio.h"
#include "stdarg.h"
#include "math.h"
#include "string.h"



static unsigned int xPos = 0, yPos = 0;



void _increment_cursor()
{
  xPos++;
  if (xPos >= COLS) {
    xPos = 0;
    yPos++;
    if (yPos >= ROWS) {
      // shove existing terminal content 'up' and reduce y by 1
      // TODO
      yPos--;
    }
  }
}

void cursor_xy (int x, int y)
{
  xPos = CLAMP(x, 0, COLS - 1);
  yPos = CLAMP(y, 0, ROWS - 1);
}

int getVideoIndexForCursor()
{
  return (yPos * COLS * 2) + (xPos * 2);
}

void putch(char cb)
{
  unsigned char *ptr = (unsigned char *)VIDEO_MEM;
  int idx = getVideoIndexForCursor();

  switch (cb) {
    default:
      ptr[idx] = cb;
      ptr[idx + 1] = 0x07;
      _increment_cursor();
      break;
  }
}

void puts(const char *str)
{
  if (!str) return;

  for (size_t i = 0; i < strlen(str); i++) {
    putch(str[i]);
  }
}

int printf (const char *fmt, ...)
{
  if (!fmt) return 0;

  //va_list   args;
  //va_start(args, fmt);

  for (size_t i = 0; i < strlen(fmt); i++) {
    switch (fmt[i]) {
      default:
        break;
    };
  }

  //va_end(args);

  return 1;
}

void clear_screen()
{
  unsigned char *ptr = (unsigned char *)VIDEO_MEM;

  int n = ROWS * (COLS * 2);
  for (int i = 0; i < n; i += 2) {
      ptr[i] = ' ';
      ptr[i + 1] = 0x07;
  }
}
