; A20 enabling
;

bits    16

enable_a20:
  cli
  pusha

  ; wait till KB is ready
  call  wait_input

  ; disable kb
  mov   al, 0xAD
  out   0x64, al
  call  wait_input

  ; issue cmd to read output (0xD0)
  mov   al, 0xD0
  out   0x64, al
  call  wait_output

  ; read the output
  in    al, 0x60
  push  eax
  call  wait_input

  ; issue cmd to write output (0xD1)
  mov   al, 0xD1
  out   0x64, al
  call  wait_input

  ; write updated output
  pop   eax
  or    al, 2   ; flag to enable A20
  out   0x60, al
  call  wait_input

  ; enable kb
  mov   al, 0xAE
  out   0x64, al
  call  wait_input

  popa
  sti
  ret


; wait routines
; keyboard controller is much slower than the cpu
wait_input:
  in    al, 0x64
  test  al, 2
  jnz   wait_input
  ret

wait_output:
  in    al, 0x64
  test  al, 1
  jz   wait_output
  ret
