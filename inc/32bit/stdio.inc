; stdio
;

%ifndef   __STD_IO_H_
%define   __STD_IO_H_

bits    32

; defines
%define VIDEOMEM  0xB8000
%define COLS      80
%define ROWS      25

_vid_x    db 0
_vid_y    db 0

; puts
puts:
  pusha
  push    ebx
  pop     edi

.loop:
  mov   bl, byte[edi]
  cmp   bl, 0
  je    .done

  call  putch

  inc   edi
  jmp   .loop

.done:
  ; todo : update the cursor

  popa
  ret

; putch
;   output charatecr to video buffer
;   EBX => character to output
putch:
  pusha

  ; init
  xor     eax, eax
  xor     ecx, ecx

  ; position in video memory is (y * ROW_SIZE) + x
  ; ROW_SIZE is COLS * bytes_per_column (2 in Mode7)
  ; addr = Vptr + yOff + xOff
  ;     yOff = Y * (COLS * 2)
  ;     xOff = X * 2
  mov   ecx, COLS * 2
  mov   al, BYTE [_vid_y]
  mul   ecx
  push  eax                 ; yoff

  mov   al, BYTE [_vid_x]
  shl   eax, 1
  mov   ecx, eax            ; xoff
  pop   eax
  add   eax, ecx            ; addr offset

  ; move to appropriate positionin video memory
  mov   edi, VIDEOMEM
  add   edi, eax

  xor   ecx, ecx

  ; check for special characters
  cmp   bl, 0x0A
  je    .newLine

  cmp   bl, 0x0D
  je    .crgReturn

  ; print character
  ; DX = [ATTR][CHAR]
  mov   dl, bl
  mov   dh, 7   ; fg RGB all on, low intensity (light gray), bg off (black)
  mov   word [edi], dx

  ; update position
  inc   byte [_vid_x]
  cmp   byte [_vid_x], COLS
  je    .crlf

  ; done
  jmp   .done

.crlf:
  inc   byte [_vid_y]
  mov   byte [_vid_x], 0
  jmp   .done

.newLine:
xchg bx, bx
  inc   byte [_vid_y]
  jmp   .done

.crgReturn:
xchg bx, bx
  mov   byte [_vid_x], 0
  jmp   .done

.done:
  popa
  ret

clear_screen:
  pusha

  xor   eax, eax
  xor   ecx, ecx

  ; loop through all 80x25 cells of Mode7 and replace the WORD for each
  mov   edi, VIDEOMEM
  mov   cx, 2000
  mov   ah, 7
  mov   al, ' '
  rep   stosw

  ; move cursor position
  mov   byte [_vid_x], 0
  mov   byte [_vid_y], 0

  popa
  ret

%endif  ;__STD_IO_H_
