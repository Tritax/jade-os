; stage2
;

%define kBootSegment				0x7c00
%define kFAT0Addr						0x7e00
%define kSelfSegment 				0xBE00
%define kKernelRModeAddr		0x500
%define kKernelPModeAddr    0x100000

[BITS 16]
[ORG 0x4200]
	jmp 	main

; includes
%include "inc/16bit/puts16.inc"
%include "inc/16bit/gdt.inc"
%include "inc/16bit/a20.inc"
%include "inc/16bit/floppy.inc"
%include "inc/16bit/fat12.inc"

; data
load_msg				db "Preparing to load the system ... ", 13, 10, 0
kernel_failed 	db "Unable to locate Kernel!", 13, 10, 0
sys_halt 				db "System Halted", 13, 10, 0
kernel_img			db "KERNEL  SYS"

kernel_size		dd 0

; entry point
main:
	cli

	xor 	ax, ax
	mov   ds, ax
	mov   es, ax
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
	mov 	si, load_msg + kBootSegment
	call 	puts16

	; load root directory
	;xchg bx, bx
	;call 	load_fat12_root


	; load kernel
	mov 	ebx, 0
	mov 	bx, kKernelRModeAddr
	mov 	si, kernel_img + kBootSegment
	call  load_fat12_file

	cmp 	dx, 1
	jne 	.pmode

	; failed to locate kernel
	mov 	si, kernel_failed + kBootSegment
	call 	puts16
	jmp 	.syshlt

.syshlt:
	mov 	si, sys_halt + kBootSegment
	call puts16

	cli
	hlt

.pmode:
	mov dword [kernel_size + kBootSegment], ecx
	; enter PMode
	cli
	mov 	eax, cr0
	or 		eax, 1
	mov 	cr0, eax

	; far jmp to 32bit
	jmp		8:stage3 + kBootSegment

halt_sys:
	cli
	hlt


; ***************
; stage 3

bits		32

%include "inc/32bit/stdio.inc"

; ELF Header
; 0 - 3 		7F,E,L,F
; 4					1 = 32bit, 2 = 64bit
; 5         1 = little, 2 = big (Endien)
; 6         ELF ver
; 7         OS
; 8 - 15		padding
; 16 - 17		1 - relocatable, 2 - exe, 3 - shared, 4 - core
; 18 - 19		Arch (3 = x86)
; 20 - 23   ELF ver
; 24 - 27   program entry point
; 28 - 31   program header table position
; 32 - 35   section header table position
; 36 - 39   flags (architecture dep)
; 40 - 41   header size
; 42 - 43   size of an entry in prog header table
; 44 - 45   # of entries in prog header table
; 46 - 47   size of an entry in sec header table
; 48 - 49   # of entries in sec header table
; 50 - 51   index in sec header table /w sec names

; data
org_addr		dd 0
prog_hdr		dd 0
sec_hdr   	dd 0
prog_size		dw 0
prog_count	dw 0
sec_size 		dw 0
sec_count   dw 0

stage3:

	; setup registers
	mov 	ax, 0x10		; data descriptor
	mov   ds, ax
	mov   ss, ax
	mov   es, ax
	mov   esp, 0x90000

validate_elf:
	; validate kernel file format
	; copy program blocks to proper positions in memory
	mov 	esi, kKernelRModeAddr
	push 	esi

	mov 	edi, ELFMagic + kBootSegment
	mov 	ecx, 4
	rep		cmpsb
	jne   .nomatch

	; read ELF header
	mov 	al, byte [esi]
	cmp   al, 1							; verify 32bit
	jne		.nomatch

	add   esi, 2
	mov   al, byte [esi]		; ELF ver

	add   esi, 10						; skip OS and 8 bytes of padding
	mov   ax, word [esi]		; elf type
	cmp		ax, 2
	jne 	.nomatch

	add   esi, 2
	mov   ax, word [esi]		; architecture type (shoudl be 3)
	cmp   ax, 3
	jne 	.nomatch

	add   esi, 2
	mov   eax, dword [esi]	; ELF ver

	add 	esi, 4
	mov   eax, dword [esi]
	mov 	dword [org_addr + kBootSegment], eax

	add 	esi, 4
	mov   eax, dword [esi]
	mov 	dword [prog_hdr + kBootSegment], eax

	add  	esi, 4
	mov   eax, dword [esi]
	mov   dword [sec_hdr + kBootSegment], eax

	add		esi, 4
	mov   eax, dword [esi]				; architecture specific flags

	add 	esi, 4
	mov 	ax, word [esi]					; ELF header size

	add 	esi, 2
	mov   ax, word [esi]
	mov 	word [prog_size + kBootSegment], ax		; size of entry in prog table

	add		esi, 2
	mov   ax, word [esi]
	mov   word [prog_count + kBootSegment], ax	; # of entries in prog table

	add 	esi, 2
	mov   ax, word [esi]
	mov 	word [sec_size + kBootSegment], ax		; size of entry in sec table

	add		esi, 2
	mov   ax, word [esi]
	mov   word [sec_count + kBootSegment], ax	; # of entries in sec table

	; finished ELF header
	pop 	esi

	; move to program headers table offset
	; find .text and .data sections in program headers table
	; map to appropriate locations (org + offset)
	; jmp far into entry point

	xor   eax, eax
	xor   ebx, ebx
	xor   ecx, ecx
	xor   edx, edx

	mov 	ax, word [prog_hdr + kBootSegment]
	add   esi, eax
	mov 	bx, word [prog_size + kBootSegment]
	mov 	cx, word [prog_count + kBootSegment]
.prog_table_parse:
	push	ecx

	; determine type of prog frame
	mov   eax, dword [esi]
	cmp   eax, 1
	jne		.next

	; 1 = LOAD, pull info from header
	mov   eax, dword [esi + 4]		; p_offset
	mov   edi, dword [esi + 8]		; p_vaddr
	mov   ecx, dword [esi + 16]		; p_filesz
	mov 	edx, dword [esi + 20]		; p_memsz
	;mov 	xxx, dword [esi + 28]		; align

	; copy frame into memory at (org + p_vaddr)
	push 	esi
	mov 	esi, kKernelRModeAddr
	add 	esi, eax
	rep 	movsd
	pop 	esi

.next:
	pop 	ecx
	add   esi, ebx
	loop 	.prog_table_parse

.done:
	jmp 	.success

	; failed
.nomatch:
	mov 	ebx, formatFail + kBootSegment
	call 	puts
	cli
	hlt

.success:
	xchg bx, bx
	mov 	edi, [org_addr + kBootSegment]
	jmp 	edi

	; copy kernel image to 1MB addr
	; loaded into memory in real mode at 0xB000
copy_image:
	; calculate size in DWORDs to copy
	mov 	eax, dword [kernel_size + kBootSegment]
	mov 	ebx, kBytesPerSector
	mul   ebx																			; # of bytes to copy
	mov   ebx, 4
	div   ebx																			; # of DWORDs to copy

	; copy image to PMode location
	cld
	mov 	esi, kKernelRModeAddr
	mov 	edi, kKernelPModeAddr
	mov   ecx, eax
	rep 	movsd

	; parse ELF format

	; jmp to kernel
	jmp 	0x8:kKernelPModeAddr

	; halt
	cli
	hlt

; data
ELFMagic				db 0x7F, 'E', 'L', 'F'
formatFail 			db "invalid kernel format", 13, 10, 0
