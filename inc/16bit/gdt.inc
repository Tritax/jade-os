; GDT

%ifndef __GDT_H_
%define __GDT_H_

bits    16

install_gdt:
  cli
  pusha
  lgdt  [toc + kBootSegment]
  sti
  popa
  ret

gdt_data:
; null descriptor
  dd  0
  dd  0

; code descriptor
  dw  0FFFFh
  dw  0
  db  0
  db  10011010b
  db  11001111b
  db  0

; data descriptor
  dw  0FFFFh
  dw  0
  db  0
  db  10010010b
  db  11001111b
  db  0

end_of_gdt:
toc:
  dw  end_of_gdt - gdt_data - 1
  dd  kBootSegment + gdt_data

%endif ;__GDT_H_
