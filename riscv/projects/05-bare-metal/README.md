# Project 5: Bare Metal LED Blinker 💡

## Overview

Write a bare metal program that runs directly on RISC-V hardware (no operating system) to blink an LED. This is the "Hello World" of embedded systems! This project teaches:
- Bare metal programming
- Hardware registers and memory-mapped I/O
- GPIO (General Purpose Input/Output) control
- Timing and delays
- Real hardware interaction
- Startup code and linker scripts

## What is Bare Metal Programming?

**Bare metal** means running code directly on the hardware without an operating system. You have:
- ✅ Complete control over the hardware
- ✅ Minimal overhead and maximum performance
- ✅ Direct access to all registers and peripherals
- ❌ No OS services (no `printf`, `malloc`, file I/O)
- ❌ Must handle everything yourself

## Hardware Requirements

### Recommended Boards (Budget-Friendly)

1. **Sipeed Longan Nano** (~$5-$10)
   - RISC-V GD32VF103 @ 108 MHz
   - 32KB SRAM, 128KB Flash
   - Built-in RGB LED
   - USB-C programming
   - Arduino-compatible headers

2. **Seeed XIAO ESP32C3** (~$5-$10)
   - RISC-V ESP32-C3 @ 160 MHz
   - WiFi + Bluetooth
   - 400KB SRAM, 4MB Flash
   - Built-in LED
   - USB-C programming

3. **SparkFun RED-V** (~$60)
   - SiFive FE310 RISC-V @ 320 MHz
   - 16KB SRAM, 4MB Flash
   - Arduino-compatible
   - Professional quality

4. **HiFive1 Rev B** (~$60)
   - SiFive FE310 RISC-V
   - Official SiFive board
   - Excellent documentation

### What You'll Need

- RISC-V development board with LED
- USB cable (usually USB-C or Micro-USB)
- Computer with development tools installed
- (Optional) Breadboard and external LED

## Implementation Guide

### Step 1: Understanding Memory-Mapped I/O

In embedded systems, hardware peripherals are controlled through **memory-mapped registers**. Writing to specific memory addresses controls the hardware.

Example for a typical RISC-V microcontroller:

```
GPIO Port A Base: 0x40010800
├─ Mode Register:    0x40010800 (Configure pin as input/output)
├─ Output Register:  0x4001080C (Set pin high/low)
└─ Input Register:   0x40010808 (Read pin state)
```

### Step 2: Basic Blink Program Structure

```assembly
# bare_metal_blink.s
# Blinks an LED on a RISC-V microcontroller

.section .text
.globl _start

_start:
    # 1. Initialize stack pointer
    la sp, _stack_top
    
    # 2. Configure GPIO pin as output
    jal ra, gpio_init
    
    # 3. Main loop: blink forever
main_loop:
    # Turn LED on
    jal ra, led_on
    jal ra, delay
    
    # Turn LED off
    jal ra, led_off
    jal ra, delay
    
    j main_loop

# Initialize GPIO for LED
gpio_init:
    # Configure pin as output (board-specific)
    # Example for GD32VF103 (Longan Nano):
    li t0, 0x40010C00      # GPIOB base
    li t1, 0x00300000      # Configure PB5 as output
    sw t1, 0(t0)           # Write to mode register
    ret

# Turn LED on
led_on:
    li t0, 0x40010C0C      # GPIOB output register
    li t1, 0x00000020      # Set bit 5 (PB5)
    sw t1, 0(t0)
    ret

# Turn LED off
led_off:
    li t0, 0x40010C0C      # GPIOB output register
    sw zero, 0(t0)         # Clear all bits
    ret

# Simple delay loop
delay:
    li t0, 1000000         # Delay count
delay_loop:
    addi t0, t0, -1
    bnez t0, delay_loop
    ret
```

### Step 3: Linker Script

You need a **linker script** to tell the toolchain where to place code in memory:

```ld
/* linker.ld - Memory layout for RISC-V microcontroller */

MEMORY
{
    FLASH (rx) : ORIGIN = 0x08000000, LENGTH = 128K
    RAM (rwx)  : ORIGIN = 0x20000000, LENGTH = 32K
}

SECTIONS
{
    .text : {
        *(.text)
        *(.text*)
    } > FLASH
    
    .rodata : {
        *(.rodata)
        *(.rodata*)
    } > FLASH
    
    .data : {
        *(.data)
        *(.data*)
    } > RAM AT > FLASH
    
    .bss : {
        *(.bss)
        *(.bss*)
        *(COMMON)
    } > RAM
    
    _stack_top = ORIGIN(RAM) + LENGTH(RAM);
}
```

### Step 4: Building and Flashing

#### For Longan Nano (GD32VF103):

```bash
# 1. Assemble the code
riscv64-unknown-elf-as -march=rv32imac -mabi=ilp32 -o blink.o bare_metal_blink.s

# 2. Link
riscv64-unknown-elf-ld -T linker.ld -o blink.elf blink.o

# 3. Create binary
riscv64-unknown-elf-objcopy -O binary blink.elf blink.bin

# 4. Flash to board using dfu-util
dfu-util -a 0 -s 0x08000000:leave -D blink.bin
```

#### For ESP32-C3:

```bash
# 1. Assemble and link
riscv32-esp-elf-as -march=rv32imc -o blink.o bare_metal_blink.s
riscv32-esp-elf-ld -T linker.ld -o blink.elf blink.o

# 2. Flash using esptool
esptool.py --chip esp32c3 write_flash 0x0 blink.bin
```

#### For HiFive1/RED-V:

```bash
# Use Freedom E SDK tools
riscv64-unknown-elf-gcc -march=rv32imac -mabi=ilp32 -o blink.elf bare_metal_blink.s
# Flash using JLink or OpenOCD
```

## Board-Specific Examples

### Longan Nano (GD32VF103)

```assembly
# LED is on PB5, active high
.equ GPIOB_BASE,  0x40010C00
.equ GPIOB_CTL0,  0x00        # Control register
.equ GPIOB_OCTL,  0x0C        # Output control
.equ LED_PIN,     5

gpio_init:
    li t0, GPIOB_BASE
    li t1, 0x00300000      # Configure PB5 as push-pull output, 50MHz
    sw t1, GPIOB_CTL0(t0)
    ret

led_on:
    li t0, GPIOB_BASE
    li t1, (1 << LED_PIN)
    sw t1, GPIOB_OCTL(t0)
    ret

led_off:
    li t0, GPIOB_BASE
    sw zero, GPIOB_OCTL(t0)
    ret
```

### ESP32-C3

```assembly
# LED is on GPIO8, active high
.equ GPIO_BASE,     0x60004000
.equ GPIO_ENABLE,   0x0020
.equ GPIO_OUT,      0x0004
.equ LED_PIN,       8

gpio_init:
    li t0, GPIO_BASE
    li t1, (1 << LED_PIN)
    sw t1, GPIO_ENABLE(t0)   # Enable GPIO8 as output
    ret

led_on:
    li t0, GPIO_BASE
    li t1, (1 << LED_PIN)
    sw t1, GPIO_OUT(t0)
    ret

led_off:
    li t0, GPIO_BASE
    sw zero, GPIO_OUT(t0)
    ret
```

### HiFive1 Rev B (FE310)

```assembly
# LED is on GPIO5 (green), active low
.equ GPIO_BASE,     0x10012000
.equ GPIO_OUTPUT_EN, 0x008
.equ GPIO_OUTPUT_VAL, 0x00C
.equ LED_PIN,       5

gpio_init:
    li t0, GPIO_BASE
    li t1, (1 << LED_PIN)
    sw t1, GPIO_OUTPUT_EN(t0)  # Enable as output
    ret

led_on:
    # Active low - clear bit to turn on
    li t0, GPIO_BASE
    lw t1, GPIO_OUTPUT_VAL(t0)
    li t2, ~(1 << LED_PIN)
    and t1, t1, t2
    sw t1, GPIO_OUTPUT_VAL(t0)
    ret

led_off:
    # Active low - set bit to turn off
    li t0, GPIO_BASE
    lw t1, GPIO_OUTPUT_VAL(t0)
    li t2, (1 << LED_PIN)
    or t1, t1, t2
    sw t1, GPIO_OUTPUT_VAL(t0)
    ret
```

## Complete Workflow: From Code to Blinking LED

### 1. Install Toolchain

```bash
# Ubuntu/Debian
sudo apt-get install gcc-riscv64-unknown-elf

# macOS with Homebrew
brew install riscv-gnu-toolchain

# Or download from SiFive/RISC-V organization
```

### 2. Install Flash Tools

For **Longan Nano**:
```bash
sudo apt-get install dfu-util
```

For **ESP32-C3**:
```bash
pip install esptool
```

For **HiFive1**:
```bash
# Install Freedom E SDK or use OpenOCD
git clone https://github.com/sifive/freedom-e-sdk
```

### 3. Write Your Code

Create `blink.s` with your LED blinking code (see examples above).

### 4. Create Linker Script

Create `linker.ld` with your board's memory map (see examples above).

### 5. Build

```bash
# Assemble
riscv64-unknown-elf-as -march=rv32imac -mabi=ilp32 -o blink.o blink.s

# Link
riscv64-unknown-elf-ld -T linker.ld -o blink.elf blink.o

# Convert to binary
riscv64-unknown-elf-objcopy -O binary blink.elf blink.bin
```

### 6. Flash to Board

```bash
# Put board in DFU mode (for Longan Nano: hold BOOT button, press RESET)
dfu-util -a 0 -s 0x08000000:leave -D blink.bin
```

### 7. Watch Your LED Blink! 🎉

## Troubleshooting

### LED Doesn't Blink
- ✓ Check pin number matches your board
- ✓ Verify memory addresses are correct
- ✓ Check if LED is active high or active low
- ✓ Ensure delay is long enough
- ✓ Verify code was flashed successfully

### Can't Flash Board
- ✓ Check USB cable (must support data, not just power)
- ✓ Install correct drivers
- ✓ Put board in bootloader mode
- ✓ Check permissions (may need `sudo`)
- ✓ Try different USB port

### Board Not Recognized
- ✓ Install board-specific drivers
- ✓ Check `lsusb` (Linux) or Device Manager (Windows)
- ✓ Try different cable
- ✓ Check board has power

## Skills Practiced

- ✅ Bare metal programming
- ✅ Memory-mapped I/O
- ✅ Hardware datasheets
- ✅ Linker scripts
- ✅ Flash programming
- ✅ Real hardware debugging
- ✅ Timing and delays

## Tips

1. **Read the datasheet** - Your board's datasheet has all register addresses
2. **Start simple** - Get one LED working before trying more
3. **Use a logic analyzer** - Super helpful for debugging
4. **Check examples** - Board vendor usually provides examples
5. **Join communities** - RISC-V Discord, forums are helpful
6. **Be patient** - Hardware can be tricky!

## Extensions

- Add button input (read GPIO)
- Implement PWM for LED brightness
- Create patterns (morse code, animations)
- Add UART communication
- Use hardware timers instead of delay loops
- Implement interrupts
- Add multiple LEDs
- Create a light show

## Provided Code

Complete working examples for popular boards:
- `longan_nano_blink.s` - For Sipeed Longan Nano
- `esp32c3_blink.s` - For ESP32-C3
- `hifive1_blink.s` - For HiFive1 Rev B

Each includes:
- Fully commented source code
- Linker script
- Build script
- Flash instructions

## Resources

- [Lesson 15: Bare Metal Programming](../../lessons/15-bare-metal/)
- Board datasheets (check vendor website)
- [RISC-V Privileged Spec](https://riscv.org/technical/specifications/)
- Vendor SDKs and examples

## Next Steps

After blinking an LED:
- Read sensor data
- Implement serial communication
- Create a real project (weather station, robot, etc.)
- Learn about interrupts and DMA
- Explore RTOS (FreeRTOS for RISC-V)

---

There's nothing quite like seeing your code run on real hardware! 🚀💡
