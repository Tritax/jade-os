; prints.io
;

; prints
; si => nil terminated string
prints:
	mov 	bx, 7
.loop:
	lodsb
	or 		al, al
	jz 		.done
	mov 	ah, 0x0E
	int 	10h
	jmp 	.loop

.done:
	ret
