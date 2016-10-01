; puts16
;

%ifndef __PUTS_16_
%define __PUTS_16_

[BITS 16]

puts16:
  push  ax
  push  bx

  mov   bx, 7
.loop:
  lodsb
  or    al, al
  jz    .done

  mov   ah, 0x0E
  int   10h
  jmp   .loop

.done:
  pop   bx
  pop   ax
  ret

%endif ;__PUTS_16_
