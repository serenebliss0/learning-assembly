/* Linker script for GD32VF103 (Longan Nano) */

MEMORY
{
    FLASH (rx)  : ORIGIN = 0x08000000, LENGTH = 128K
    RAM (rwx)   : ORIGIN = 0x20000000, LENGTH = 32K
}

ENTRY(_start)

SECTIONS
{
    .text :
    {
        KEEP(*(.text._start))
        *(.text)
        *(.text*)
        *(.rodata)
        *(.rodata*)
    } > FLASH
    
    .data :
    {
        _data_start = .;
        *(.data)
        *(.data*)
        _data_end = .;
    } > RAM AT > FLASH
    
    .bss :
    {
        _bss_start = .;
        *(.bss)
        *(.bss*)
        *(COMMON)
        _bss_end = .;
    } > RAM
    
    _stack_top = ORIGIN(RAM) + LENGTH(RAM);
}
