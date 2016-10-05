/*

*/

#include "stdio.h"
#include "common.h"



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
  x = CLAMP(x, 0, COLS - 1);
  y = CLAMP(y, 0, ROWS - 1);
}

void putch(char cb)
{
  unsigned char *ptr = (unsigned char *)VIDEO_MEM;
  int idx = (yPos * COLS) + xPos;

  switch (cb) {
    default:
      ptr[idx] = cb;
      ptr[idx + 1] = 0x07;
      _increment_cursor();
      break;
  }
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
