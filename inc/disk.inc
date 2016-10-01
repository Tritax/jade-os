; disk.io
;

; LBACHS
; AX => [sectorAbs], [headAbs], [trackAbs]
;
; [AX] = Sector #
; [sector] = (sec % bpbSectorsPerTrack) + 1
; [head]   = sec / bpbSectorsPerTrack % bpbHeadsPerCylinder
; [track]  = sec / (bpbSectorsPerTrack * bpbHeadsPerCylinder)

lbachs:
	push 	bx
	push 	ax

	; (sector % sectorsPerTrack) + 1
	xor		dx, dx
	div 	WORD [bpbSectorsPerTrack]
	inc		dl
	mov 	BYTE [sectorAbs], dl
	
	; sector / sectorsPerTrack % headCount
	; ax == sector / sectorPerTrack 
	xor 	dx, dx
	div 	WORD [bpbHeadsPerCylinder]
	mov		BYTE [headAbs], dl
	
	; sector / (sectorsPerTrack * headCount)
	xor 	dx, dx
	mov		ax, WORD [bpbHeadsPerCylinder]
	mul 	WORD [bpbSectorsPerTrack]
	xchg	bx, ax 		; put mul in BX, 

	pop 	ax 			; reload orig sector from 'params'

	mov 	dx, 0
	div  	bx 			; perform div
	
	mov 	BYTE [trackAbs], al

	; clean up
	xor 	dx, dx
	pop 	bx

	ret

; read sector
readSectors:
.main:
	mov		di, 5

.secloop:
	push 	ax
	push 	bx
	push    cx

	call 	lbachs 		; calculate position

	mov		ah, 2 		; int 13h operation: read sectors 
	mov 	al, 0x01 	; # of sectors to read 
	mov 	ch, BYTE [trackAbs]
	mov 	cl, BYTE [sectorAbs]
	mov 	dh, BYTE [headAbs]
	mov 	dl, BYTE [driveAbs]
	int 	13h

	jnc		.success
	
	; reset drive
	xor		ax, ax
	int 	13h

	; decrement attempt counter and prepare to retry
	dec 	di
	pop 	cx
	pop     bx
	pop     ax
	jnz 	.secloop

.die:
	jmp 	.die

.success:
	mov 	si, op_prog
	call 	prints

	; reset
	pop 	cx
	pop 	bx
	pop 	ax

	; move pointer past read data
	; increment sector # to read 
	add 	bx, WORD [bpbBytesPerSector]
	inc 	ax

	; loop to read more while cx > 0
	loop 	.main

	;call 	printcrlf
	ret
