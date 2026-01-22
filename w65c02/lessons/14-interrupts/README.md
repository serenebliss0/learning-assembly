# Lesson 14: Interrupts - Event-Driven Programming

Interrupts are the 6502's way of handling asynchronous events. They let your CPU respond immediately to hardware events without constantly checking (polling). This lesson covers IRQ, NMI, and building robust interrupt handlers.

## Learning Objectives

By the end of this lesson, you'll:
- Understand what interrupts are and why they're important
- Know the difference between IRQ and NMI
- Be able to write interrupt service routines (ISRs)
- Understand interrupt vectors and priority
- Use VIA interrupts for timer and I/O events
- Build interrupt-driven applications

## What Are Interrupts?

**Interrupt:** A signal that causes the CPU to suspend normal execution and jump to a special handler routine.

### Polling vs Interrupts

**Polling** (what we've done so far):
```asm
wait_for_button:
    LDA BUTTON_PORT
    AND #$01
    BNE wait_for_button   ; Waste CPU cycles waiting!
    ; Button pressed
```

**Interrupts** (better way):
```asm
; Main program does useful work
main_loop:
    ; ... do something ...
    JMP main_loop

; Button press triggers interrupt
button_isr:
    ; Handle button press
    RTI
```

**Advantages:**
- CPU free to do other work
- Immediate response to events
- Cleaner code architecture

## 6502 Interrupt Types

The W65C02 has two interrupt inputs:

### IRQ̅ (Interrupt Request) - Maskable

- External hardware pulls IRQ̅ low
- Can be disabled with SEI (set interrupt disable flag)
- Can be enabled with CLI (clear interrupt disable flag)
- For general-purpose interrupts
- Checks IRQ̅ at end of each instruction

### NMI̅ (Non-Maskable Interrupt) - Non-Maskable

- External hardware pulls NMI̅ low
- **Cannot be disabled** (hence "non-maskable")
- Higher priority than IRQ̅
- For critical events (power failure, reset button)
- Triggered on falling edge (not level)

## Interrupt Vectors

When an interrupt occurs, the 6502 reads an address from a fixed location:

```
$FFFA-$FFFB: NMI vector (address of NMI handler)
$FFFC-$FFFD: Reset vector (address of reset handler)
$FFFE-$FFFF: IRQ/BRK vector (address of IRQ handler)
```

### Setting Vectors

```asm
.segment "VECTORS"
.org $FFFA
.word nmi_handler     ; NMI vector
.word reset           ; Reset vector
.word irq_handler     ; IRQ vector
```

**Important:** Reset is also a type of interrupt!

## The Interrupt Sequence

When IRQ̅ (or NMI̅) is triggered:

1. **Finish current instruction**
2. **Push PC high byte** to stack
3. **Push PC low byte** to stack
4. **Push status register (P)** to stack
5. **Set I flag** (disable further IRQs) - only for IRQ, not NMI
6. **Load PC from vector** ($FFFE-$FFFF for IRQ)
7. **Execute ISR**
8. **RTI instruction:**
   - Pull P from stack
   - Pull PC from stack
   - Continue where we left off

### Stack After Interrupt

```
S-2: PC high byte
S-1: PC low byte
S-0: Status register (P)
     ↑ Stack pointer here
```

## Writing an Interrupt Service Routine (ISR)

### Basic ISR Structure

```asm
irq_handler:
    ; Save registers we'll use
    PHA                   ; Save A
    TXA
    PHA                   ; Save X
    TYA
    PHA                   ; Save Y
    
    ; Handle interrupt
    ; ... your code here ...
    
    ; Restore registers
    PLA
    TAY                   ; Restore Y
    PLA
    TAX                   ; Restore X
    PLA                   ; Restore A
    
    RTI                   ; Return from interrupt
```

**Critical:** Always save/restore registers! The main program doesn't expect them to change.

## Simple Example: Timer Interrupt

```asm
; timer_interrupt.s - Blink LED with timer interrupt

.segment "CODE"
.org $8000

; VIA registers
VIA_BASE = $8000
PORTB  = VIA_BASE + $00
DDRB   = VIA_BASE + $02
T1CL   = VIA_BASE + $04
T1CH   = VIA_BASE + $05
T1LL   = VIA_BASE + $06
T1LH   = VIA_BASE + $07
ACR    = VIA_BASE + $0B
IFR    = VIA_BASE + $0D
IER    = VIA_BASE + $0E

reset:
    ; Initialize stack
    LDX #$FF
    TXS
    
    ; Setup Port B for LED
    LDA #$FF
    STA DDRB
    LDA #$00
    STA PORTB             ; LED off initially
    
    ; Configure Timer 1 for continuous interrupts
    LDA #%01000000        ; Free-run mode
    STA ACR
    
    ; Set timer period (0.5 seconds at 1MHz)
    LDA #<(500000-2)      ; Low byte
    STA T1LL
    LDA #>(500000-2)      ; High byte
    STA T1LH
    STA T1CH              ; Start timer
    
    ; Enable Timer 1 interrupts
    LDA #%11000000        ; Bit 7=1 (set), Bit 6=1 (Timer 1)
    STA IER
    
    ; Enable interrupts in CPU
    CLI                   ; Clear interrupt disable flag
    
    ; Main loop does nothing!
    ; All work done in ISR
main_loop:
    NOP                   ; Could do useful work here
    JMP main_loop

; Interrupt handler
irq_handler:
    PHA                   ; Save A
    
    ; Check if Timer 1 caused interrupt
    LDA IFR
    AND #%01000000        ; Timer 1 flag?
    BEQ irq_exit          ; No, not our interrupt
    
    ; Clear Timer 1 interrupt
    LDA T1CL              ; Reading T1CL clears flag
    
    ; Toggle LED
    LDA PORTB
    EOR #$FF              ; Invert all bits
    STA PORTB
    
irq_exit:
    PLA                   ; Restore A
    RTI

; NMI handler (not used, but must exist)
nmi_handler:
    RTI

; Interrupt vectors
.segment "VECTORS"
.org $FFFA
.word nmi_handler
.word reset
.word irq_handler
```

## Breaking It Down

### Enabling Interrupts

Three steps required:

```asm
; 1. Enable source (VIA Timer 1)
LDA #%11000000
STA IER               ; VIA enables Timer 1 interrupt

; 2. Configure source
LDA #%01000000
STA ACR               ; Timer in free-run mode

; 3. Enable CPU interrupt processing
CLI                   ; Clear I flag in status register
```

**All three must be done!**

### Checking Interrupt Source

Multiple devices can trigger IRQ̅, so check which one:

```asm
irq_handler:
    ; Check VIA
    LDA VIA_IFR
    AND #%01000000        ; Timer 1?
    BNE handle_timer
    
    ; Check other devices...
    ; (Add more checks here)
    
    RTI                   ; Unknown source, ignore

handle_timer:
    ; Handle timer interrupt
    LDA T1CL              ; Clear flag
    ; ... do work ...
    RTI
```

### The I Flag

The **I flag** (bit 2 in P register) controls IRQ̅ masking:

```asm
SEI                   ; Set I flag - disable IRQs
CLI                   ; Clear I flag - enable IRQs
```

**Important:**
- Hardware automatically sets I flag when IRQ occurs (prevents nested interrupts)
- RTI restores I flag from stack (re-enables interrupts)
- NMI ignores I flag (non-maskable!)

## Advanced Example: Button Interrupt

```asm
; button_interrupt.s - Respond to button press via interrupt

.segment "CODE"
.org $8000

VIA_BASE = $8000
PORTA  = VIA_BASE + $01
PORTB  = VIA_BASE + $00
DDRA   = VIA_BASE + $03
DDRB   = VIA_BASE + $02
PCR    = VIA_BASE + $0C
IFR    = VIA_BASE + $0D
IER    = VIA_BASE + $0E

; Variables
counter = $00             ; Zero page counter

reset:
    ; Initialize stack
    LDX #$FF
    TXS
    
    ; Setup ports
    LDA #$FF
    STA DDRB              ; Port B output (LEDs)
    LDA #$00
    STA DDRA              ; Port A input (button on PA0/CA1)
    
    ; Configure CA1 for interrupt on negative edge
    LDA #%00000000        ; CA1 negative edge
    STA PCR
    
    ; Enable CA1 interrupt
    LDA #%10000010        ; Bit 7=1 (set), Bit 1=1 (CA1)
    STA IER
    
    ; Initialize counter
    LDA #$00
    STA counter
    STA PORTB
    
    ; Enable interrupts
    CLI
    
    ; Main loop
main_loop:
    ; Could do other work here
    JMP main_loop

; IRQ handler
irq_handler:
    PHA
    
    ; Check CA1 (button)
    LDA IFR
    AND #%00000010        ; CA1 flag (bit 1)?
    BEQ irq_done
    
    ; Clear CA1 interrupt by reading/writing Port A
    LDA PORTA             ; Clears CA1 flag
    
    ; Increment counter
    INC counter
    LDA counter
    STA PORTB             ; Display on LEDs
    
irq_done:
    PLA
    RTI

nmi_handler:
    RTI

.segment "VECTORS"
.org $FFFA
.word nmi_handler
.word reset
.word irq_handler
```

## Interrupt Priorities

What if multiple interrupts happen?

### Priority Order (highest to lowest)

1. **Reset** - Highest priority, stops everything
2. **NMI̅** - Non-maskable, checked every instruction
3. **IRQ̅** - Maskable, checked if I=0

### Simultaneous Interrupts

If NMI and IRQ both active:
- NMI serviced first
- After RTI from NMI, IRQ serviced (if still active and I=0)

### Nested Interrupts

**By default:** Not nested (I flag set during ISR)

**To allow nesting:** Use CLI in ISR (careful - complex!)

```asm
irq_handler:
    PHA
    CLI                   ; Re-enable interrupts (dangerous!)
    ; ... critical section must be short ...
    SEI                   ; Disable again
    PLA
    RTI
```

**Warning:** Nested interrupts can cause stack overflow. Rarely needed!

## BRK Instruction

The **BRK** instruction triggers a software interrupt:

```asm
BRK                   ; Causes IRQ interrupt
```

**Differences from hardware IRQ:**
- PC pushed points to BRK + 2 (skips BRK and signature byte)
- B flag set in pushed status register
- Useful for debugging and system calls

### Distinguishing BRK from IRQ

```asm
irq_handler:
    PHA
    TSX                   ; Get stack pointer
    LDA $0104,X           ; Read pushed status register
    AND #%00010000        ; Check B flag (bit 4)
    BNE brk_handler       ; If set, it was BRK
    
    ; Handle hardware IRQ
    ; ...
    PLA
    RTI

brk_handler:
    ; Handle BRK instruction
    ; ...
    PLA
    RTI
```

## Real-World Example: Keyboard Scanner

```asm
; keyboard_scanner.s - Scan keyboard matrix on timer interrupt

.segment "CODE"
.org $8000

VIA_BASE = $8000
PORTA  = VIA_BASE + $01   ; Keyboard rows (input)
PORTB  = VIA_BASE + $00   ; Keyboard columns (output)
DDRA   = VIA_BASE + $03
DDRB   = VIA_BASE + $02
T1CL   = VIA_BASE + $04
T1CH   = VIA_BASE + $05
T1LL   = VIA_BASE + $06
T1LH   = VIA_BASE + $07
ACR    = VIA_BASE + $0B
IFR    = VIA_BASE + $0D
IER    = VIA_BASE + $0E

; Key buffer
KEY_BUFFER = $0200
key_read_ptr = $10
key_write_ptr = $11

reset:
    LDX #$FF
    TXS
    
    ; Setup ports for keyboard matrix
    LDA #$00
    STA DDRA              ; Port A input (rows)
    LDA #$FF
    STA DDRB              ; Port B output (columns)
    
    ; Setup timer for 10ms keyboard scan
    LDA #%01000000
    STA ACR
    
    LDA #<(10000-2)
    STA T1LL
    LDA #>(10000-2)
    STA T1LH
    STA T1CH
    
    ; Enable Timer 1 interrupt
    LDA #%11000000
    STA IER
    
    ; Initialize key buffer pointers
    LDA #$00
    STA key_read_ptr
    STA key_write_ptr
    
    CLI
    
    ; Main loop processes keys
main_loop:
    JSR get_key           ; Check if key available
    BEQ main_loop         ; No key, continue
    
    ; Process key in A
    JSR handle_key
    JMP main_loop

; Get key from buffer
; Returns: A = key code (0 if none)
get_key:
    LDA key_read_ptr
    CMP key_write_ptr     ; Any keys in buffer?
    BEQ no_key
    
    ; Get key from buffer
    TAX
    LDA KEY_BUFFER,X
    PHA
    
    ; Advance read pointer
    INX
    STX key_read_ptr
    
    PLA
    RTS

no_key:
    LDA #$00
    RTS

; Handle key press
handle_key:
    ; Display ASCII on LEDs or LCD
    ; (Add your key handling here)
    RTS

; ISR: Scan keyboard matrix
irq_handler:
    PHA
    PHX
    PHY
    
    ; Check Timer 1
    LDA IFR
    AND #%01000000
    BEQ irq_done
    
    LDA T1CL              ; Clear flag
    
    ; Scan keyboard matrix
    ; This is simplified - real version needs debouncing!
    LDY #$08              ; 8 columns
    LDA #$FE              ; Start with column 0 low
    
scan_loop:
    STA PORTB             ; Select column
    LDA PORTA             ; Read rows
    BEQ no_key_this_col   ; All high = no key
    
    ; Key detected! Convert to key code
    ; (Add key code calculation here)
    ; Store in buffer
    LDX key_write_ptr
    STA KEY_BUFFER,X
    INX
    STX key_write_ptr
    
no_key_this_col:
    LDA PORTB
    SEC
    ROL A                 ; Shift to next column
    DEY
    BNE scan_loop

irq_done:
    PLY
    PLX
    PLA
    RTI

nmi_handler:
    RTI

.segment "VECTORS"
.org $FFFA
.word nmi_handler
.word reset
.word irq_handler
```

## Experiments

### Experiment 1: Measure Interrupt Latency

Toggle a pin at start and end of ISR:

```asm
irq_handler:
    PHA
    LDA #$01
    STA PORTB             ; Set pin high
    
    ; ISR work here...
    
    LDA #$00
    STA PORTB             ; Set pin low
    PLA
    RTI
```

Measure pulse width with oscilloscope.

### Experiment 2: Priority Test

Set up both timer and CA1 interrupts. Trigger both simultaneously. Which is handled first?

### Experiment 3: Interrupt Load

Gradually reduce timer interval. At what point does system spend all time in ISR?

## Exercises

**Exercise 1:** Create a real-time clock using Timer 1 interrupt. Maintain hours, minutes, seconds in RAM. Display on LCD.

**Exercise 2:** Implement a buffered serial transmitter - main program adds data to buffer, ISR sends via shift register.

**Exercise 3:** Build a waveform generator - use Timer 1 to generate audio waveforms (square, triangle, sawtooth) on a speaker.

<details>
<summary>Solution to Exercise 1</summary>

```asm
.segment "CODE"
.org $8000

VIA_BASE = $8000
T1CL   = VIA_BASE + $04
T1CH   = VIA_BASE + $05
T1LL   = VIA_BASE + $06
T1LH   = VIA_BASE + $07
ACR    = VIA_BASE + $0B
IFR    = VIA_BASE + $0D
IER    = VIA_BASE + $0E

; Time variables
seconds = $20
minutes = $21
hours   = $22

reset:
    LDX #$FF
    TXS
    
    ; Initialize time
    LDA #$00
    STA seconds
    STA minutes
    LDA #12
    STA hours
    
    ; Setup timer for 1 second interrupts
    ; 1,000,000 cycles at 1MHz = 1 second
    LDA #%01000000
    STA ACR
    
    LDA #<(1000000-2)
    STA T1LL
    LDA #>(1000000-2)
    STA T1LH
    STA T1CH
    
    LDA #%11000000
    STA IER
    
    CLI
    
    JSR lcd_init

main_loop:
    ; Display time on LCD
    JSR display_time
    JMP main_loop

irq_handler:
    PHA
    
    LDA IFR
    AND #%01000000
    BEQ irq_done
    
    LDA T1CL
    
    ; Increment seconds
    INC seconds
    LDA seconds
    CMP #60
    BNE irq_done
    
    ; Reset seconds, increment minutes
    LDA #$00
    STA seconds
    INC minutes
    LDA minutes
    CMP #60
    BNE irq_done
    
    ; Reset minutes, increment hours
    LDA #$00
    STA minutes
    INC hours
    LDA hours
    CMP #24
    BNE irq_done
    
    ; Reset hours
    LDA #$00
    STA hours

irq_done:
    PLA
    RTI

display_time:
    ; Set cursor to line 1
    LDA #$80
    JSR lcd_command
    
    ; Display hours
    LDA hours
    JSR display_2digit
    
    LDA #':'
    JSR lcd_data
    
    ; Display minutes
    LDA minutes
    JSR display_2digit
    
    LDA #':'
    JSR lcd_data
    
    ; Display seconds
    LDA seconds
    JSR display_2digit
    
    RTS

display_2digit:
    PHA
    ; Tens digit
    LDA #$00
    STA $30
    LDA $01,S             ; Get value from stack
dd_tens:
    CMP #10
    BCC dd_ones
    SEC
    SBC #10
    INC $30
    JMP dd_tens
dd_ones:
    PHA                   ; Save ones
    LDA $30
    CLC
    ADC #'0'
    JSR lcd_data
    PLA                   ; Get ones
    CLC
    ADC #'0'
    JSR lcd_data
    PLA                   ; Clean stack
    RTS

; (Include lcd_init, lcd_command, lcd_data from Lesson 13)

nmi_handler:
    RTI

.segment "VECTORS"
.org $FFFA
.word nmi_handler
.word reset
.word irq_handler
```
</details>

## Deep Dive: Interrupt Latency

**Latency:** Time from interrupt signal to first ISR instruction.

### 6502 Interrupt Latency

Maximum latency:
- **7 cycles** (instruction completion) +
- **7 cycles** (push PC, push P, load vector) =
- **14 cycles** = 14μs at 1MHz

Compare to modern CPUs: nanoseconds!

But remember: 6502 is simple and predictable.

### Reducing Latency

1. **Keep I flag clear** (enable interrupts)
2. **Use NMI for critical events** (can't be masked)
3. **Keep ISRs short** (faster return to main code)
4. **Consider polling for ultra-fast response** (if timing known)

## Deep Dive: The Stack

Interrupts use the stack heavily:

### Stack Usage

```
Before interrupt:
$01FF: (free)
$01FE: (free)
$01FD: (free)
S = $FF

After interrupt (before ISR):
$01FF: PC high
$01FE: PC low
$01FD: Status (P)
S = $FC

In ISR after PHA:
$01FF: PC high
$01FE: PC low
$01FD: Status (P)
$01FC: A register
S = $FB
```

**Critical:** Don't overflow stack! Each interrupt uses 3 bytes + ISR usage.

### Stack Size

6502 stack:
- Fixed at $0100-$01FF (256 bytes)
- Grows downward
- No protection - overflow wraps around!

**Safe nesting depth:**
- Assume 10 bytes per interrupt level
- ~20 nested interrupts maximum
- In practice: avoid nesting!

## Common Errors

### Forgot CLI
```asm
; Interrupts configured but nothing happens...
; Forgot: CLI
```

**Always remember CLI after setup!**

### Didn't save registers
```asm
irq_handler:
    ; Modify A, X, Y without saving
    LDA #$00          ; Destroys main program's A!
    RTI
```

**Always save/restore registers!**

### Forgot to clear interrupt flag
```asm
irq_handler:
    ; Forgot to read T1CL
    ; Interrupt flag still set
    RTI               ; Immediately re-interrupts!
```

**Always clear the source!**

### Stack not initialized
```asm
reset:
    ; Forgot: LDX #$FF / TXS
    CLI               ; Interrupts with random stack pointer!
```

**Initialize stack early in reset!**

## Key Takeaways

✅ **Interrupts** enable event-driven programming

✅ **IRQ̅** is maskable (controlled by I flag)

✅ **NMI̅** is non-maskable (highest priority)

✅ **ISR must save/restore** all registers used

✅ **RTI** returns from interrupt (not RTS!)

✅ **Clear interrupt source** in ISR to prevent re-trigger

✅ **Stack must be initialized** before enabling interrupts

✅ **Keep ISRs short** for best system response

## Next Lesson

Ready to build a complete system? Continue to:
**[Lesson 15: Building a Monitor - Your Own OS →](../15-monitor/)**

Learn to create a machine code monitor for debugging and development!

---

## Quick Reference

**Enable Interrupts:**
```asm
; 1. Configure source
LDA #%11000000
STA VIA_IER       ; Enable Timer 1

; 2. Enable CPU
CLI               ; Clear I flag
```

**ISR Template:**
```asm
irq_handler:
    PHA               ; Save registers
    TXA
    PHA
    TYA
    PHA
    
    ; Check source
    LDA IFR
    AND #mask
    BEQ not_mine
    
    ; Clear flag
    ; ... source-specific ...
    
    ; Handle interrupt
    ; ... your code ...
    
not_mine:
    PLY               ; Restore registers
    PLX
    PLA
    RTI
```

**Vectors:**
```asm
.segment "VECTORS"
.org $FFFA
.word nmi_handler
.word reset
.word irq_handler
```

**Interrupt Control:**
```asm
SEI               ; Disable IRQs
CLI               ; Enable IRQs
```

---

*Interrupts: The power of immediate response!* ⚡
