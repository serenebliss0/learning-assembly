# Bare Metal LED Blink for Longan Nano (GD32VF103)
# This code runs directly on hardware without an OS

.section .text
.globl _start

_start:
    # Initialize stack pointer
    la sp, _stack_top
    
    # Initialize GPIO for LED
    jal ra, gpio_init
    
    # Main loop: blink LED forever
main_loop:
    jal ra, led_on
    jal ra, delay
    jal ra, led_off
    jal ra, delay
    j main_loop

# Initialize GPIO for LED (PB5 on Longan Nano)
gpio_init:
    # GPIOB base address: 0x40010C00
    # Configure PB5 as push-pull output, 50MHz
    li t0, 0x40010C00      # GPIOB base
    li t1, 0x00300000      # CNF=00 (push-pull), MODE=11 (50MHz) for pin 5
    sw t1, 0x00(t0)        # Write to CTL0 register
    ret

# Turn LED on
led_on:
    li t0, 0x40010C00      # GPIOB base
    li t1, 0x00000020      # Bit 5 for PB5
    sw t1, 0x0C(t0)        # Write to OCTL register
    ret

# Turn LED off
led_off:
    li t0, 0x40010C00      # GPIOB base
    li t1, 0x00200000      # Bit 21 to clear bit 5
    sw t1, 0x10(t0)        # Write to BC register (bit clear)
    ret

# Delay function (approximately 500ms at 8MHz)
delay:
    li t0, 1000000         # Delay counter
delay_loop:
    addi t0, t0, -1
    bnez t0, delay_loop
    ret

# Stack (defined in linker script)
.section .bss
.align 4
_stack:
    .space 1024
_stack_top:
