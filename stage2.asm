; stage2
;

[BITS 16]
[ORG 0x4200]

; entry point
main:
	xchg 	bx, bx

.init:
	; welcome to stage 2
	mov 	si, load_msg
	call 	puts16

	; install GDT
	xchg bx, bx
	call 	install_gdt

	; enter PMode
	cli
	mov 	eax, cr0
	or 		eax, 1
	mov 	cr0, eax

	;

halt_sys:
	cli
	hlt

%include "inc/16bit/puts16.inc"
%include "inc/16bit/gdt.inc"

; data
load_msg	db "Preparing to load the system ... ", 13, 10, 0
sys_halt 	db "System Halted", 13, 10, 0
