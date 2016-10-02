; stage2
;

%define kBootSegment				0x7c00
%define kFAT0Addr						0x7e00
%define kSelfSegment 				0xBE00
%define kKernelRModeAddr		0xB000
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
	mov 	si, load_msg
	call 	puts16

	; load root directory
	call 	load_fat12_root

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

stage3:

	; setup registers
	mov 	ax, 0x10		; data descriptor
	mov   ds, ax
	mov   ss, ax
	mov   es, ax
	mov   esp, 0x90000

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

	; jmp to kernel
	jmp 	0x8:kKernelPModeAddr

	; halt
	cli
	hlt

; data
msg			db "Welcome from 32bit land!", 13, 10, 0
