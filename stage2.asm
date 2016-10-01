; stage2
;

[BITS 16]

; entry point
	jmp 	main

; data segment
term: 	db	"system haulted", 0

main:
	xchg 	bx, bx

.init:
	cli
	push 	cs
	pop 	ds

	mov 	si, term
	call 	puts16

	cli
	hlt

%include "inc/puts16.inc"
