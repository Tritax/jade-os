; FAT12
;

%ifndef __FAT12_H_
%define __FAT12_H_

bits 16

%include "inc/16bit/floppy.inc"

%define kRootAddr     0xa200

; data

; LoadRoot
load_fat12_root:
  pusha

  xor   cx, cx
  xor   dx, dx

  ; calculate size of root directory
  mov 	ax, 0x20 * kRootEntries
	mov   cx, kBytesPerSector
	div 	cx
	xchg 	ax, cx

  ; calculate location of root (LBA)
  xor   ax, ax
  mov   al, kNumberOfFATs
  mov   cl, kSectorsPerFAT
	mul   cl
	add   ax, kReservedSectors

  ; read root directory
  mov   bx, kRootAddr
  call 	readSectors

  popa
  ret

; findFile
; si => filename
; set dx, 0 if fails, addr otherwise
find_fat12_file:
  push  cx
  push  bx
  push  ax

  xor   cx, cx
  mov   bx, kRootAddr
.next:
  mov   al, byte [bx]
  cmp   al, 0xE5
  je    .nomatch
  cmp   al, 0x00
  je    .error

  push  si
  mov   di, bx
  mov   cx, 11
  rep   cmpsb
  pop   si
  jne   .nomatch

.match:
  mov   dx, bx
  jmp   .finish

.nomatch:
  add   bx, 0x20
  jmp   .next

.error:
  mov   dx, 0

.finish:
  pop   ax
  pop   bx
  pop   cx
  ret

; loadFile
; si => filename
; bx => location in memory to read data into
; returns
;     dx = 1 = fail, 0 = success
;     ecx = # of sectors in kernel data
load_fat12_file:
  xor   ecx, ecx
  push  ecx

  call  find_fat12_file
  cmp   dx, 0
  jne   .readdata

  mov   dx, 1
  ret

.readdata:
  push  bx
  mov   bx, dx
  xor   dx, dx
  mov   ax, word [bx + 26]
  pop   bx

.fetch_cluster:
  push  ax

  xor   cx, cx
  add 	ax, 31

	mov 	cl, kSectorsPerCluster
	call 	readSectors

	pop 	ax

  pop   ecx
  inc   ecx
  push  ecx

  push  bx

.lookupFATentry:
  ; calculate starting pos (1.5 bytes per entry)
  mov 	cx, ax
  mov 	dx, ax
  shr 	dx, 1
  add   dx, cx

  ; find position in FAT0 table
  mov		bx, kFAT0Addr
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
  jz    .clustererror
  cmp   ax, 0xFF8 	; last cluster
  jge   .done

  ; fetch next cluster
  pop 	bx
  jmp 	.fetch_cluster

.clustererror:
  ; handle error
  pop 	bx
  pop   ecx
  mov 	dx, 1
  ret

.done:
  ; setup return
  pop 	bx
  pop   ecx
  xor   dx, dx

.finished_load:
  ret

%endif ;__FAT12_H_
