/*

*/

#include "common.h"
#include "stdio.h"



void __attribute__((cdecl)) _main()
{
  //
  clear_screen();

  cursor_xy(5, 5);
  putch('A');

  for (;;);
}
