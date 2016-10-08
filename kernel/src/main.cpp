/*

*/

#include "stdio.h"



void __attribute__((cdecl)) _main()
{
  //
  clear_screen();

  cursor_xy(0, 0);
  puts("JADE-OS v0.1\r\n");

  cursor_xy(5, 5);
  putch(':');
  putch(')');

  for (;;);
}
