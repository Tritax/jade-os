ENTRY(kernel_entry)

SECTIONS
{
    . = 0x100000;
    .text : { *(.text) }
    .data : { *(.data) }
    .rodata  : { *(.rodata) }
    .bss  : { *(.bss) }
}
