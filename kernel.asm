; faux kernel (for testing)
;

bits  32
org   0x100000

jmp   main

;data
msg   db "Welcome to the kernel.", 0

%include "inc/32bit/stdio.inc"

main:
  call  clear_screen

  mov   ebx, msg
  call  puts

  cli
  hlt

;
