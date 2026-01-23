# W65C02 Memory Map Reference

Standard memory organization and layout for W65C02 systems.

## Memory Architecture Overview

The W65C02 has a 16-bit address bus, providing 64KB of addressable memory ($0000-$FFFF).

```
    $FFFF ┌─────────────────┐
          │  ROM/Vectors    │  Reset/IRQ/NMI vectors
    $FFFA ├─────────────────┤
          │                 │
          │      ROM        │  Program code & data
          │   (typical)     │  Often $8000-$FFF9
    $8000 ├─────────────────┤
          │                 │
          │   RAM/ROM       │  Varies by system
          │   I/O Space     │  Hardware dependent
          │                 │
    $0200 ├─────────────────┤
          │     Stack       │  Hardware stack
    $0100 ├─────────────────┤
          │   Zero Page     │  Fast access variables
    $0000 └─────────────────┘
```

---

## Zero Page ($0000-$00FF)

**Size:** 256 bytes  
**Access Speed:** Fastest (2-byte instructions, fewer cycles)  
**Addressing:** 8-bit addresses

### Overview
Zero page is the most important memory area for 6502 programming. Instructions using zero page addressing are both shorter and faster than absolute addressing.

### Typical Layout

```
$00FF ┌─────────────────┐
      │ System/Monitor  │  Reserved for system use
$0080 ├─────────────────┤
      │                 │
      │  User Variables │  Your program's fast access
      │  Temp Storage   │  Temporary values
      │  Loop Counters  │  Performance-critical data
      │  Pointers       │  Indirect addressing
      │                 │
$0000 └─────────────────┘
```

### Recommended Allocation

| Range | Purpose | Notes |
|-------|---------|-------|
| $00-$01 | System | Often reserved by OS/monitor |
| $02-$7F | User program | Your variables, pointers |
| $80-$FF | System/Monitor | Reserved by many systems |

### Common Uses

**Variables:**
```asm
counter     = $10       ; Loop counter
temp        = $11       ; Temporary storage
result      = $12       ; Calculation result
flags       = $13       ; Status flags
```

**16-bit Pointers:**
```asm
ptr_lo      = $20       ; Pointer low byte
ptr_hi      = $21       ; Pointer high byte

string_ptr  = $22       ; String pointer (2 bytes)
data_ptr    = $24       ; Data pointer (2 bytes)
screen_ptr  = $26       ; Screen pointer (2 bytes)
```

**Commonly Reserved Addresses (System Dependent):**
- `$00-$01`: Often used by monitors/OS
- `$FA-$FF`: Sometimes used for indirect jump vectors
- `$FE-$FF`: Common temporary pointer location

### Performance Benefits

```asm
; Zero Page - 3 cycles, 2 bytes
LDA $10         ; Fast!

; Absolute - 4 cycles, 3 bytes
LDA $0010       ; Same data, slower and larger
```

**Savings per access:**
- 1 cycle faster
- 1 byte smaller
- Critical in tight loops

### Best Practices

1. **Most-used data in zero page** - Keep frequently accessed variables here
2. **Reserve space for pointers** - Need 2 consecutive bytes per pointer
3. **Document your layout** - Comment which addresses are used for what
4. **Avoid system areas** - Check your platform's documentation
5. **Group related data** - Keep related variables together

---

## Stack ($0100-$01FF)

**Size:** 256 bytes  
**Fixed Location:** Hardware mandated  
**Grows:** Downward (from $01FF toward $0100)

### Overview
The hardware stack is used for subroutine calls, interrupts, and temporary data storage. The Stack Pointer (SP) register holds only the low byte; high byte is always $01.

### Stack Pointer
```
Stack Address = $0100 + SP

Initial SP = $FF → Stack at $01FF (empty stack)
After push = $FE → Top at $01FE (1 byte on stack)
After push = $FD → Top at $01FD (2 bytes on stack)
```

### Stack Operations

**Push Operations (SP decrements):**
- PHA - Push Accumulator
- PHP - Push Processor Status
- PHX - Push X Register (W65C02)
- PHY - Push Y Register (W65C02)
- JSR - Pushes return address (2 bytes)

**Pull Operations (SP increments):**
- PLA - Pull Accumulator
- PLP - Pull Processor Status
- PLX - Pull X Register (W65C02)
- PLY - Pull Y Register (W65C02)
- RTS - Pulls return address (2 bytes)
- RTI - Pulls status + address (3 bytes)

### Stack Layout Example

```
$01FF ┌────┐ ← SP = $FF (empty stack)
$01FE ├────┤
$01FD ├────┤
      │    │
      ⋮    ⋮
      │    │
$0101 ├────┤
$0100 └────┘ ← Stack bottom

After JSR $C000:
$01FF ┌────┐
$01FE │$12 │ ← Return address high byte
$01FD │$34 │ ← Return address low byte (SP now $FD)
$01FC ├────┤ ← Next push goes here
      │    │
```

### Stack Depth Considerations

**JSR/RTS uses 2 bytes per call**
- Nested subroutine depth × 2 bytes
- 5 levels deep = 10 bytes
- 10 levels deep = 20 bytes

**Interrupts use 3 bytes (status + address)**
- Can occur during normal execution
- Reserve space for at least one interrupt

**Manual stack usage** (PHA/PLA, etc.)

### Stack Size Planning

```
Total stack need = 
    (Max subroutine depth × 2) +
    (Interrupt overhead × 3) +
    (Manual push/pull usage) +
    (Safety margin)

Example:
    10 levels deep     = 20 bytes
    1 interrupt        = 3 bytes
    Temp storage       = 10 bytes
    Safety margin      = 20 bytes
    ----------------------------
    Total              = 53 bytes
```

**256 bytes is usually plenty!** But be aware in recursive or deeply nested code.

### Stack Overflow

**What happens:** SP wraps around ($00 → $FF), overwriting stack data.  
**Result:** Crashes, corrupted returns, impossible to debug.

**Prevention:**
- Track maximum nesting depth
- Avoid deep recursion
- Use TSX to check SP in development
- Balance push/pull operations

### Stack Underflow

**What happens:** SP wraps around ($FF → $00) when pulling from empty stack.  
**Prevention:** Never PLA/PLX/PLY without matching PHA/PHX/PHY.

### Best Practices

1. **Initialize SP on reset** - `LDX #$FF; TXS`
2. **Balance push/pull** - Every push needs a pull
3. **Minimize stack usage** - Use zero page for temp storage when possible
4. **Watch nesting depth** - Track maximum call depth
5. **Reserve for interrupts** - Leave room for at least one interrupt frame
6. **Use TSX for debugging** - Check stack pointer when debugging crashes

---

## Main RAM ($0200-$7FFF typical)

**Size:** ~30KB (system dependent)  
**Purpose:** Program variables, buffers, data structures

### Typical Allocation

```
$7FFF ┌─────────────────┐
      │                 │
      │   Free RAM      │  Available for program use
      │   Heap          │  Dynamic allocation
      │   Data          │  Arrays, strings, tables
      │   Buffers       │  I/O buffers
      │                 │
$0200 └─────────────────┘
```

### Common Uses

**Data Storage:**
```asm
; Buffers
screen_buffer:  .res 256    ; Screen data
input_buffer:   .res 80     ; User input
line_buffer:    .res 40     ; Text line

; Arrays
sprite_x:       .res 8      ; Sprite X positions
sprite_y:       .res 8      ; Sprite Y positions
palette:        .res 16     ; Color palette
```

**Strings and Text:**
```asm
message:    .byte "Hello, World!", $00
title:      .byte "W65C02 System", $00
```

**Lookup Tables:**
```asm
sine_table:     .res 256    ; Sine wave values
multiply_lo:    .res 256    ; Multiplication table low
multiply_hi:    .res 256    ; Multiplication table high
```

**Data Structures:**
```asm
; Linked list node
node_data:      .res 1
node_next_lo:   .res 1
node_next_hi:   .res 1
```

### Memory Management Strategies

**Static Allocation:**
- Pre-defined addresses for all data
- Simple and predictable
- Wastes memory for variable-size data

**Simple Heap:**
- Track "next free byte" pointer
- Allocate by incrementing pointer
- No deallocation (or very simple)

**Free List:**
- Linked list of free blocks
- More complex but efficient
- Allows reuse of freed memory

---

## I/O Space (System Dependent)

**Location:** Varies by system  
**Typical Range:** $C000-$CFFF or memory-mapped addresses  
**Purpose:** Hardware device registers

### Common I/O Areas

```
Example Apple II-style system:

$CFFF ┌─────────────────┐
      │ Expansion Cards │  Slot I/O
$C100 ├─────────────────┤
      │ Soft Switches   │  Display/hardware control
$C000 └─────────────────┘

Example Memory-mapped I/O:

$7FFF ┌─────────────────┐
      │ RAM/ROM         │
$6000 ├─────────────────┤
      │ VIA #2          │  Versatile Interface Adapter
$5000 ├─────────────────┤
      │ VIA #1          │  I/O ports, timers
$4000 ├─────────────────┤
      │ ACIA            │  Serial communication
$3000 ├─────────────────┤
      │ RAM             │
$0200 └─────────────────┘
```

### Common I/O Chips

**6522 VIA (Versatile Interface Adapter):**
- Base + $00: Port B data
- Base + $01: Port A data
- Base + $02: Port B direction
- Base + $03: Port A direction
- Base + $04-$0F: Timers and control

**6551 ACIA (Asynchronous Communications Interface Adapter):**
- Base + $00: Data
- Base + $01: Status/reset
- Base + $02: Command
- Base + $03: Control

**Memory-mapped Video:**
- Text screen buffer
- Graphics bitmap
- Color/attribute RAM
- Sprite registers

### Accessing I/O

```asm
; Reading status
LDA VIA_STATUS      ; Check status register
AND #$80            ; Check busy bit
BEQ not_busy

; Writing data
LDA #$42
STA ACIA_DATA       ; Send byte to serial

; Polling
wait_ready:
    LDA VIA_STATUS
    AND #$01        ; Check ready bit
    BEQ wait_ready
```

---

## ROM ($8000-$FFFF typical)

**Size:** 32KB typical (can be 8KB, 16KB, 32KB)  
**Purpose:** Program code, constant data, system firmware

### Typical ROM Layout

```
$FFFF ┌─────────────────┐
      │ Vectors         │  $FFFA-$FFFF (6 bytes)
$FFFA ├─────────────────┤
      │                 │
      │ Monitor/BIOS    │  System routines
      │ I/O Routines    │  Hardware drivers
      │                 │
$F000 ├─────────────────┤
      │                 │
      │ User Program    │  Application code
      │ Const Data      │  Lookup tables, strings
      │                 │
$8000 └─────────────────┘
```

### Common ROM Sizes

**8KB ROM ($E000-$FFFF):**
- Small systems, bootloaders
- Vectors at $FFFA-$FFFF

**16KB ROM ($C000-$FFFF):**
- Medium systems
- Includes basic I/O and monitor

**32KB ROM ($8000-$FFFF):**
- Full systems
- Complete OS/monitor/BASIC
- Upper ROM for critical code

### ROM Content

**System Code:**
```asm
; Typically at higher addresses
$F000:  ; Monitor entry
$F100:  ; Character I/O
$F200:  ; Block I/O
$F300:  ; Utilities
```

**Constant Data:**
```asm
; Character set
charset:    .incbin "charset.bin"   ; 2KB character data

; Tables
hex_to_ascii:   .byte "0123456789ABCDEF"
```

**Library Routines:**
```asm
; Standard functions available to programs
print_char  = $F100
print_str   = $F110
read_char   = $F120
delay       = $F200
```

---

## Hardware Vectors ($FFFA-$FFFF)

**Size:** 6 bytes  
**Location:** Fixed by hardware  
**Purpose:** CPU startup and interrupt handling

### Vector Table

```
$FFFF ┌──────┐
$FFFE │ RES  │  RESET vector (high byte)
$FFFD │ RES  │  RESET vector (low byte)
$FFFC │ IRQ  │  IRQ/BRK vector (high byte)
$FFFB │ IRQ  │  IRQ/BRK vector (low byte)
$FFFA │ NMI  │  NMI vector (high byte)
$FFF9 │ NMI  │  NMI vector (low byte)
      └──────┘
```

### Vector Definitions

**NMI - Non-Maskable Interrupt ($FFFA-$FFFB):**
```asm
.org $FFFA
.word nmi_handler       ; NMI vector

nmi_handler:
    ; Save registers
    PHA
    ; Handle NMI
    ; ...
    PLA
    RTI
```

**RESET ($FFFC-$FFFD):**
```asm
.org $FFFC
.word reset_handler     ; RESET vector

reset_handler:
    ; Initialize system
    SEI                 ; Disable interrupts
    CLD                 ; Clear decimal mode
    LDX #$FF
    TXS                 ; Initialize stack
    ; ... more init ...
    JMP main            ; Start program
```

**IRQ/BRK ($FFFE-$FFFF):**
```asm
.org $FFFE
.word irq_handler       ; IRQ/BRK vector

irq_handler:
    ; Check if BRK (B flag set)
    ; Handle IRQ or BRK
    RTI
```

### Vector Programming

**Assembly:**
```asm
; At end of ROM
.org $FFFA
.word nmi_handler
.word reset_handler
.word irq_handler
```

**Binary ROM:**
```
Address: $FFFA $FFFB $FFFC $FFFD $FFFE $FFFF
Values:  $00   $F1   $00   $F0   $00   $F2

Vectors:
NMI   = $F100
RESET = $F000
IRQ   = $F200
```

---

## Memory Map Examples

### Minimal System (8KB RAM, 8KB ROM)

```
$FFFF ┌─────────────────┐
      │ ROM + Vectors   │  Code and vectors
$E000 ├─────────────────┤
      │ (unmapped)      │
$2000 ├─────────────────┤
      │ RAM (8KB)       │  All RAM here
$0000 └─────────────────┘
```

### Standard System (32KB RAM, 16KB ROM)

```
$FFFF ┌─────────────────┐
      │ ROM + Vectors   │  System firmware
$C000 ├─────────────────┤
      │ I/O Space       │  $8000-$BFFF
$8000 ├─────────────────┤
      │ RAM (32KB)      │  Main memory
$0000 └─────────────────┘
```

### Large System (48KB RAM, 16KB ROM)

```
$FFFF ┌─────────────────┐
      │ ROM + Vectors   │  System firmware
$C000 ├─────────────────┤
      │ RAM (48KB)      │  Maximum RAM
$0000 └─────────────────┘
```

### Apple II-style System

```
$FFFF ┌─────────────────┐
      │ ROM Monitor     │  System ROM
$D000 ├─────────────────┤
      │ ROM/RAM Bank    │  Switchable
$C000 ├─────────────────┤
      │ I/O & Slots     │  Hardware I/O
$C000 ├─────────────────┤
      │ RAM             │
$0000 └─────────────────┘
```

### Commodore 64-style System

```
$FFFF ┌─────────────────┐
      │ KERNAL ROM      │  OS routines
$E000 ├─────────────────┤
      │ BASIC ROM       │  BASIC interpreter
$A000 ├─────────────────┤
      │ RAM (banked)    │  Can bank out ROMs
$0000 └─────────────────┘
```

---

## Memory Planning Worksheet

### 1. Define Memory Ranges
- ROM size and location: ________________
- RAM size and location: ________________
- I/O ranges: ________________

### 2. Zero Page ($00-$FF)
```
$00-$0F: System reserved
$10-$1F: [Your allocation]
$20-$2F: [Your allocation]
$30-$7F: [Your allocation]
$80-$FF: System reserved
```

### 3. Stack ($0100-$01FF)
- Max subroutine depth: ______ (× 2 bytes)
- Interrupt frames: ______ (× 3 bytes)
- Manual stack use: ______ bytes
- Total needed: ______ bytes

### 4. Main RAM ($0200+)
```
$0200-$02FF: [Purpose]
$0300-$03FF: [Purpose]
...
```

### 5. I/O Space
```
$____-$____: [Device 1]
$____-$____: [Device 2]
```

### 6. ROM
```
$____-$____: Program code
$____-$____: Constants/tables
$FFFA-$FFFF: Vectors
```

---

## Special Considerations

### Bank Switching
Some systems use bank switching to access more than 64KB:
- Switch ROM banks
- Switch RAM banks
- Switch between RAM and ROM

**Example:**
```asm
; Switch to bank 1
LDA #$01
STA BANK_REGISTER

; Access banked memory
LDA $C000           ; Different data per bank

; Switch back to bank 0
LDA #$00
STA BANK_REGISTER
```

### Memory Protection
W65C02 has no memory protection. Your program can:
- Write to ROM (no effect, but wastes cycles)
- Corrupt stack
- Overwrite code (in RAM)
- Crash system by writing to I/O

**Best Practices:**
- Careful pointer usage
- Validate array bounds
- Check stack depth
- Test thoroughly

### Memory Testing

```asm
; Simple RAM test
ram_test:
    LDX #$00
    LDA #$55        ; Test pattern
test_loop:
    STA $0200,X     ; Write pattern
    CMP $0200,X     ; Read back
    BNE test_fail
    INX
    BNE test_loop
    RTS

test_fail:
    ; Handle error
    BRK
```

---

## Quick Reference

| Region | Address | Size | Purpose |
|--------|---------|------|---------|
| Zero Page | $0000-$00FF | 256 | Fast variables, pointers |
| Stack | $0100-$01FF | 256 | Hardware stack (downward) |
| RAM | $0200-$7FFF | ~30KB | Program data (typical) |
| I/O | Varies | Varies | Hardware registers |
| ROM | $8000-$FFFF | ~32KB | Code, data (typical) |
| Vectors | $FFFA-$FFFF | 6 | NMI, RESET, IRQ vectors |

**Key Points:**
- Zero page is fastest and smallest addressing
- Stack is fixed at $0100-$01FF
- ROM typically in upper memory
- Vectors must be at $FFFA-$FFFF
- I/O location is system-specific

---

## Platform-Specific Resources

Consult your specific system documentation:
- **Apple II**: $D000-$FFFF ROM, I/O at $C000-$CFFF
- **Commodore 64**: Banked memory, $A000-$FFFF ROMs
- **BBC Micro**: $8000-$FFFF sideways ROM/RAM
- **Custom systems**: Check schematic and address decoding

---

## References

- WDC W65C02S Datasheet
- Your system's technical reference
- Hardware schematic (for I/O mapping)
- Monitor/BIOS source code (for ROM routines)
