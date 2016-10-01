; stage2
;

[BITS 16]
[ORG 0x4200]

; entry point
main:
	xchg 	bx, bx

.init:
	cli
	push 	cs
	pop 	ds

	mov 	si, load_msg
	call 	puts16

; term
	mov 	si, sys_halt
	call 	puts16

	cli
	hlt

%include "inc/16bit/puts16.inc"
%include "inc/16bit/gdt.inc"

; data
load_msg	db "Preparing to load the system ... ", 13, 10, 0
sys_halt 	db "System Halted", 13, 10, 0
