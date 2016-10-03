/*

*/

extern void _main();

extern "C" void __attribute__((stdcall)) kernel_entry()
{
  __asm__ ("cli");

  __asm__ ("movw    $16, %ax");
  __asm__ ("movw    %ax, %ds");
  __asm__ ("movw    %ax, %es");
  __asm__ ("movw    %ax, %fs");
  __asm__ ("movw    %ax, %gs");
  __asm__ ("movw    %ax, %ss");
  __asm__ ("movl    0x90000, %esp");
  __asm__ ("movl    %esp, %ebp");
  __asm__ ("pushl   %ebp");

  _main();

  __asm__ ("cli \r");

  for (;;);
}
