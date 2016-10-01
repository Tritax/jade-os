; stage2
;

[BITS 16]
[ORG 0x4200]
	jmp 	main

; includes
%include "inc/16bit/puts16.inc"
%include "inc/16bit/gdt.inc"
%include "inc/16bit/a20.inc"

; entry point
main:
	cli
	push 	cs
	pop 	ds
	push  cs
	pop   es

	xor 	ax, ax
	mov   ax, 0x9000
	mov   ss, ax
	mov   sp, 0xFFFF
	sti

.init:
	; install GDT
	call 	install_gdt

	; enable A20
	call 	enable_a20

	; prepare to load
	mov 	si, load_msg
	call 	puts16

	; enter PMode
	cli
	mov 	eax, cr0
	or 		eax, 1
	mov 	cr0, eax

	; far jmp to 32bit
	jmp		8:stage3

halt_sys:
	cli
	hlt

; data
load_msg	db "Preparing to load the system ... ", 13, 10, 0
sys_halt 	db "System Halted", 13, 10, 0


; ***************
; stage 3

bits		32

%include "inc/32bit/stdio.inc"

stage3:

	; setup registers
	mov 	ax, 0x10		; data descriptor
	mov   ds, ax
	mov   ss, ax
	mov   es, ax
	mov   esp, 0x90000

	; clear screen
	call 	clear_screen

	; print a test character
	mov 	ebx, 'H'
	call  putch

	; halt
	cli
	hlt
