;
;

[BITS 16]
[ORG 0]

;
start:
	jmp		short	main
	nop

; OEM parameter block

bpbOEM								db "My OS   "
bpbBytesPerSector:		dw 512
bpbSectorsPerCluster:	db 1
bpbReservedSectors:		dw 1
bpbNumberOfFATs:			db 2
bpbRootEntries:				dw 224
bpbTotalSectors:			dw 2880
bpbMedia:							db 0xF0
bpbSectorsPerFAT:			dw 9
bpbSectorsPerTrack:		dw 18
bpbHeadsPerCylinder:	dw 2
bpbHiddenSectors:			dd 0
bpbTotalSectorsBig:		dd 0
bsDriveNumber:				db 0
bsUnused:							db 0
bsExtBootSignature:		db 0x29
bsSerialNumber:				dd 0xa0a1a2a3
bsVolumeLabel:				db "NO NAME   ", 0
bsFileSystem:					db "FAT12   "

; main
main:

	; setup our segment
	mov 	ax, 0x7c0
	mov 	ds, ax
	mov 	ax, 0x7c0
	mov 	es, ax

	; setup stack
	cli
	mov 	ax, 0x7000
	mov 	ss, ax
	mov 	sp, 0xFFFF
	sti

	;
	mov 	si, op_start
	call 	prints

	; read FAT0 table
	mov 	BYTE [driveAbs], dl

	mov 	cx, WORD [bpbSectorsPerFAT]
	mov 	ax, WORD [bpbReservedSectors]
	mov 	bx, 0x0200

	mov 	WORD [FAT0addr], bx
	call 	readSectors

	mov 	si, op_fat
	call 	prints

	; calculate root directory
	mov 	ax, 0x20
	mul 	WORD [bpbRootEntries]
	div 	WORD [bpbBytesPerSector]
	xchg 	ax, cx
	;mov 	BYTE [entryidx], cl

	mov 	al, BYTE [bpbNumberOfFATs]
	mul 	WORD [bpbSectorsPerFAT]
	mov 	bx, ax

	mul		WORD [bpbBytesPerSector]
	add		ax, 0x0200
	xchg	bx, ax

	add 	ax, WORD [bpbReservedSectors]

	mov 	WORD [rootaddr], bx

	; load root directory
	call 	readSectors

	mov 	si, op_ok
	call 	prints

	; locate and load kernel
	call 	find_kernel

	cmp 	dx, 1
	je 		.error

	mov 	si, op_ok
	call 	prints

	xchg bx,bx
	jmp 	7c0h:4200h

.error:
	; term
	mov 	si, op_fail
	call 	prints

	cli
	hlt

	; find kernel
find_kernel:
	xor 	cx, cx
	mov 	bx, [rootaddr]
.next:
	mov 	al, [bx]
	cmp 	al, 0xE5
	je 		.nomatch
	cmp   al, 0x00
	je 		.error

	mov 	si, op_krnl
	mov 	di, bx
	mov 	cx, 6
	rep 	cmpsb
	jne 	.nomatch

.match:
	call 	load_kernel
	ret

.nomatch:
	add		bx, 32
	jmp 	.next

.error:
	mov 	si, op_fail
	call 	prints
	cli
	hlt

load_kernel:
	mov 	ax, WORD [bx + 26]	; starting cluster
	mov 	bx, 0x4200			; memory offset for readSectors

.fetch_cluster:
	push 	ax

	xor 	cx, cx
	add 	ax, 31

	mov 	cl, BYTE [bpbSectorsPerCluster]	; CX = sectors to read

	call 	readSectors

	pop 	ax
	push 	bx

.lookupFATentry:
	; calculate starting pos (1.5 bytes per entry)
	mov 	cx, ax
	mov 	dx, ax
	shr 	dx, 1
	add   dx, cx

	; find position in FAT0 table
	mov		bx, [FAT0addr]
	add 	bx, dx

	; adjust read if even or odd
	mov 	dx, WORD [bx]
	test  ax, 1
	jnz 	.odd

.even:
	and 	dx, 0xFFF
	jmp 	.check

.odd:
	shr 	dx, 4

.check:
	mov 	ax, dx
	cmp   ax, 0xFF7		; bad cluster
	jz    .error
	cmp   ax, 0xFF8 	; last cluster
	jge   .done

	; fetch next cluster
	pop 	bx
	jmp 	.fetch_cluster

.error:
	; handle error
	pop 	bx
	mov 	dx, 1

.done:
	; setup return
	pop 	bx
	ret

; data
op_ok			db "OK", 13, 10, 0
op_start  db "BOOT", 13, 10, 0
op_fat		db "FAT", 13, 10, 0
op_fail   db "FAIL", 13, 10, 0
op_prog		db ".", 0
op_krnl 	db "STAGE2", 0

FAT0addr	dw 0
rootaddr	dw 0
entryidx  db 0

sectorAbs	db 0
headAbs		db 0
trackAbs 	db 0
driveAbs  db 0

%include "inc/boot/prints.inc"
%include "inc/boot/disk.inc"

; term
times 510-($-$$) db 0
dw 0xAA55
