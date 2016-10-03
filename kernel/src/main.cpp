/*

*/

#define VIDEO_MEM   0xB8000
#define COLS        80
#define ROWS        25

static unsigned int xPos = 0, yPos = 0;

void cls();

void __attribute__((cdecl)) _main()
{
  //
  cls();

  for (;;);
}

void cls()
{
  unsigned char *ptr = (unsigned char *)VIDEO_MEM;

  int n = ROWS * (COLS * 2);
  for (int i = 0; i < n; i += 2) {
      ptr[i] = ' ';
      ptr[i + 1] = 0x07;
  }
}
