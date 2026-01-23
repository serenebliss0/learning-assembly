# Lesson 15: Building a Monitor - Your Own Operating System

A machine code monitor is a simple operating system that lets you examine memory, edit bytes, and execute code. In this lesson, we'll build a complete monitor - the foundation of any 6502 development system!

## Learning Objectives

By the end of this lesson, you'll:
- Understand what a machine code monitor is
- Build a command parser and executor
- Implement memory examination and modification
- Create a simple debugger with single-step capability
- Understand the basics of operating system design
- Have a complete development tool for your W65C02

## What is a Monitor?

A **monitor** (or **machine code monitor**) is a program that:
- Accepts commands from a user (via keyboard)
- Displays output (on LCD or terminal)
- Examines and modifies memory
- Loads and executes programs
- Provides debugging features

Famous examples:
- Apple II Monitor
- Commodore 64 KERNAL
- WOZMON (Steve Wozniak's monitor)
- py65mon (our emulator!)

## Monitor Commands

We'll implement these essential commands:

```
Command  Format        Description
-------  ------------  ------------------------
R        R             Show registers
M        M addr        Memory dump at address
:        :addr bb bb   Write bytes to address
G        G addr        Go (execute at address)
S        S             Single step one instruction
?        ?             Help
```

## Hardware Setup

Our monitor needs:
- LCD display (16×2 or larger)
- PS/2 keyboard or serial input
- VIA for I/O
- At least 8K RAM, 8K ROM

### Memory Map

```
$0000-$00FF   Zero page (variables, stack)
$0100-$01FF   Stack
$0200-$7FFF   User RAM (30K)
$8000-$9FFF   I/O (VIA, LCD)
$A000-$FFFF   Monitor ROM (24K)
```

## The Code: Basic Monitor

```asm
; monitor.s - Simple machine code monitor for W65C02
; Commands: R (registers), M (memory), : (write), G (go)

.segment "CODE"
.org $A000

; VIA registers
VIA_BASE = $8000
PORTA  = VIA_BASE + $01
PORTB  = VIA_BASE + $00
DDRA   = VIA_BASE + $03
DDRB   = VIA_BASE + $02

; Zero page variables
cmd_buffer = $10          ; Command buffer (16 bytes)
cmd_length = $20
parse_ptr  = $21
parse_addr = $22          ; 2 bytes
parse_val  = $24

; Saved registers for debugging
saved_a  = $30
saved_x  = $31
saved_y  = $32
saved_p  = $33
saved_pc = $34            ; 2 bytes

;--------------------------------------
; Reset - Monitor entry point
;--------------------------------------
reset:
    ; Initialize system
    LDX #$FF
    TXS                   ; Initialize stack
    
    ; Initialize hardware
    JSR via_init
    JSR lcd_init
    JSR keyboard_init
    
    ; Display welcome message
    LDX #$00
welcome_loop:
    LDA welcome_msg,X
    BEQ welcome_done
    JSR lcd_data
    INX
    JMP welcome_loop

welcome_done:
    JSR lcd_newline
    
    ; Enter command loop
    JMP command_loop

welcome_msg:
    .byte "W65C02 Monitor", $00

;--------------------------------------
; Main command loop
;--------------------------------------
command_loop:
    ; Display prompt
    LDA #'>'
    JSR lcd_data
    LDA #' '
    JSR lcd_data
    
    ; Get command line
    JSR get_command_line
    
    ; Parse and execute command
    JSR parse_command
    
    ; Repeat
    JMP command_loop

;--------------------------------------
; Get command line from keyboard
;--------------------------------------
get_command_line:
    LDY #$00              ; Buffer index

get_char:
    JSR keyboard_read     ; Get character in A
    BEQ get_char          ; Wait for character
    
    ; Check for Enter
    CMP #$0D              ; Carriage return
    BEQ cmd_complete
    
    ; Check for Backspace
    CMP #$08
    BEQ cmd_backspace
    
    ; Regular character
    CPY #15               ; Buffer full?
    BEQ get_char          ; Ignore if full
    
    ; Store character
    STA cmd_buffer,Y
    INY
    
    ; Echo to display
    JSR lcd_data
    
    JMP get_char

cmd_backspace:
    CPY #$00              ; At start?
    BEQ get_char          ; Ignore
    DEY                   ; Remove character
    ; (Add LCD backspace here)
    JMP get_char

cmd_complete:
    STY cmd_length        ; Save length
    LDA #$00
    STA cmd_buffer,Y      ; Null terminate
    JSR lcd_newline
    RTS

;--------------------------------------
; Parse and execute command
;--------------------------------------
parse_command:
    ; Check for empty command
    LDA cmd_length
    BEQ parse_done
    
    ; Get first character (command)
    LDA cmd_buffer
    
    ; Compare with commands
    CMP #'R'
    BEQ cmd_registers
    CMP #'M'
    BEQ cmd_memory
    CMP #':'
    BEQ cmd_write
    CMP #'G'
    BEQ cmd_go
    CMP #'S'
    BEQ cmd_step
    CMP #'?'
    BEQ cmd_help
    
    ; Unknown command
    LDX #$00
unknown_loop:
    LDA unknown_msg,X
    BEQ parse_done
    JSR lcd_data
    INX
    JMP unknown_loop

parse_done:
    RTS

unknown_msg:
    .byte "Unknown cmd", $00

;--------------------------------------
; Command: R - Display registers
;--------------------------------------
cmd_registers:
    ; Display register values
    ; Format: A=XX X=XX Y=XX P=XX PC=XXXX
    
    LDX #$00
reg_msg_loop:
    LDA reg_msg,X
    BEQ reg_show_a
    JSR lcd_data
    INX
    JMP reg_msg_loop

reg_show_a:
    LDA saved_a
    JSR print_hex
    
    LDA #' '
    JSR lcd_data
    LDA #'X'
    JSR lcd_data
    LDA #'='
    JSR lcd_data
    
    LDA saved_x
    JSR print_hex
    
    LDA #' '
    JSR lcd_data
    LDA #'Y'
    JSR lcd_data
    LDA #'='
    JSR lcd_data
    
    LDA saved_y
    JSR print_hex
    
    JSR lcd_newline
    
    ; Show P and PC on second line
    LDA #'P'
    JSR lcd_data
    LDA #'='
    JSR lcd_data
    LDA saved_p
    JSR print_hex
    
    LDA #' '
    JSR lcd_data
    LDA #'P'
    JSR lcd_data
    LDA #'C'
    JSR lcd_data
    LDA #'='
    JSR lcd_data
    
    LDA saved_pc+1        ; High byte
    JSR print_hex
    LDA saved_pc          ; Low byte
    JSR print_hex
    
    JSR lcd_newline
    RTS

reg_msg:
    .byte "A=", $00

;--------------------------------------
; Command: M - Memory dump
; Format: M addr
;--------------------------------------
cmd_memory:
    ; Parse address from command line
    JSR parse_hex_addr
    BCC mem_error
    
    ; Display 4 lines of 8 bytes each
    LDY #$00              ; Line counter
    
mem_line_loop:
    ; Display address
    LDA parse_addr+1      ; High byte
    JSR print_hex
    LDA parse_addr        ; Low byte
    JSR print_hex
    LDA #':'
    JSR lcd_data
    LDA #' '
    JSR lcd_data
    
    ; Display 8 bytes
    LDX #$00
mem_byte_loop:
    LDA (parse_addr),X    ; Read byte
    JSR print_hex
    LDA #' '
    JSR lcd_data
    
    INX
    CPX #$08
    BNE mem_byte_loop
    
    JSR lcd_newline
    
    ; Advance address
    LDA parse_addr
    CLC
    ADC #$08
    STA parse_addr
    LDA parse_addr+1
    ADC #$00
    STA parse_addr+1
    
    ; Next line
    INY
    CPY #$04
    BNE mem_line_loop
    
    RTS

mem_error:
    LDX #$00
mem_err_loop:
    LDA addr_error_msg,X
    BEQ mem_err_done
    JSR lcd_data
    INX
    JMP mem_err_loop
mem_err_done:
    JSR lcd_newline
    RTS

;--------------------------------------
; Command: : - Write memory
; Format: :addr bb bb bb...
;--------------------------------------
cmd_write:
    ; Parse address
    LDA #$01              ; Skip ':'
    STA parse_ptr
    JSR parse_hex_addr
    BCC write_error
    
    ; Parse and write bytes
    LDY #$00
write_loop:
    JSR parse_hex_byte
    BCC write_done        ; No more bytes
    
    ; Write byte to memory
    STA (parse_addr),Y
    INY
    JMP write_loop

write_done:
    LDX #$00
write_ok_loop:
    LDA write_ok_msg,X
    BEQ write_exit
    JSR lcd_data
    INX
    JMP write_ok_loop
write_exit:
    JSR lcd_newline
    RTS

write_error:
    LDX #$00
write_err_loop:
    LDA addr_error_msg,X
    BEQ write_err_done
    JSR lcd_data
    INX
    JMP write_err_loop
write_err_done:
    JSR lcd_newline
    RTS

write_ok_msg:
    .byte "Written", $00

addr_error_msg:
    .byte "Bad address", $00

;--------------------------------------
; Command: G - Go (execute)
; Format: G addr
;--------------------------------------
cmd_go:
    ; Parse address
    JSR parse_hex_addr
    BCC go_error
    
    ; Display message
    LDX #$00
go_msg_loop:
    LDA go_msg,X
    BEQ go_jump
    JSR lcd_data
    INX
    JMP go_msg_loop

go_jump:
    LDA parse_addr+1
    JSR print_hex
    LDA parse_addr
    JSR print_hex
    JSR lcd_newline
    
    ; Jump to address
    ; Setup registers from saved values
    LDA saved_a
    LDX saved_x
    LDY saved_y
    
    JMP (parse_addr)      ; Jump indirect!

go_error:
    LDX #$00
go_err_loop:
    LDA addr_error_msg,X
    BEQ go_err_done
    JSR lcd_data
    INX
    JMP go_err_loop
go_err_done:
    JSR lcd_newline
    RTS

go_msg:
    .byte "Run @ $", $00

;--------------------------------------
; Command: S - Single step
;--------------------------------------
cmd_step:
    ; This is complex - simplified version
    ; Would need to decode instruction at saved_pc
    ; Execute it, then save new state
    ; For now, just display message
    
    LDX #$00
step_msg_loop:
    LDA step_msg,X
    BEQ step_done
    JSR lcd_data
    INX
    JMP step_msg_loop
step_done:
    JSR lcd_newline
    RTS

step_msg:
    .byte "Not impl", $00

;--------------------------------------
; Command: ? - Help
;--------------------------------------
cmd_help:
    LDX #$00
help_loop:
    LDA help_msg,X
    BEQ help_done
    JSR lcd_data
    INX
    CPX #16               ; Line length
    BNE not_line_end
    JSR lcd_newline
    LDX #$00
not_line_end:
    JMP help_loop
help_done:
    JSR lcd_newline
    RTS

help_msg:
    .byte "R-regs M-mem   "
    .byte ":addr-write    "
    .byte "G-go S-step    "
    .byte $00

;--------------------------------------
; Parse hexadecimal address from command buffer
; Returns: Carry set if success, address in parse_addr
;--------------------------------------
parse_hex_addr:
    ; Skip command and spaces
    LDX parse_ptr
    BEQ pha_start
pha_skip_space:
    LDA cmd_buffer,X
    CMP #' '
    BNE pha_start
    INX
    JMP pha_skip_space

pha_start:
    ; Parse 4 hex digits
    LDA #$00
    STA parse_addr
    STA parse_addr+1
    
    LDY #$04              ; 4 digits
pha_loop:
    LDA cmd_buffer,X
    BEQ pha_error         ; End of string
    
    JSR hex_to_bin        ; Convert char to value
    BCC pha_error         ; Invalid hex digit
    
    ; Shift existing value left 4 bits
    ASL parse_addr
    ROL parse_addr+1
    ASL parse_addr
    ROL parse_addr+1
    ASL parse_addr
    ROL parse_addr+1
    ASL parse_addr
    ROL parse_addr+1
    
    ; Add new digit
    ORA parse_addr
    STA parse_addr
    
    INX
    DEY
    BNE pha_loop
    
    ; Success
    STX parse_ptr
    SEC
    RTS

pha_error:
    CLC
    RTS

;--------------------------------------
; Parse hexadecimal byte from command buffer
; Returns: Carry set if success, value in A
;--------------------------------------
parse_hex_byte:
    ; Skip spaces
    LDX parse_ptr
phb_skip:
    LDA cmd_buffer,X
    BEQ phb_error         ; End of string
    CMP #' '
    BNE phb_start
    INX
    JMP phb_skip

phb_start:
    ; Parse 2 hex digits
    LDA cmd_buffer,X
    JSR hex_to_bin
    BCC phb_error
    
    ASL A                 ; Shift to high nibble
    ASL A
    ASL A
    ASL A
    STA parse_val
    
    INX
    LDA cmd_buffer,X
    JSR hex_to_bin
    BCC phb_error
    
    ORA parse_val
    STA parse_val
    
    INX
    STX parse_ptr
    
    LDA parse_val
    SEC
    RTS

phb_error:
    CLC
    RTS

;--------------------------------------
; Convert hex character to binary
; Input: A = character
; Output: A = value (0-15), Carry set if valid
;--------------------------------------
hex_to_bin:
    ; Check '0'-'9'
    CMP #'0'
    BCC htb_error
    CMP #'9'+1
    BCS htb_check_af
    
    SEC
    SBC #'0'
    SEC
    RTS

htb_check_af:
    ; Check 'A'-'F'
    CMP #'A'
    BCC htb_error
    CMP #'F'+1
    BCS htb_error
    
    SEC
    SBC #'A'-10
    SEC
    RTS

htb_error:
    CLC
    RTS

;--------------------------------------
; Print byte as hex
; Input: A = byte to print
;--------------------------------------
print_hex:
    PHA
    LSR A                 ; High nibble
    LSR A
    LSR A
    LSR A
    JSR print_hex_digit
    
    PLA
    AND #$0F              ; Low nibble
    JSR print_hex_digit
    RTS

print_hex_digit:
    CMP #$0A
    BCC phd_digit
    
    ; A-F
    CLC
    ADC #'A'-10
    JSR lcd_data
    RTS

phd_digit:
    ; 0-9
    CLC
    ADC #'0'
    JSR lcd_data
    RTS

;--------------------------------------
; Hardware interface routines
;--------------------------------------

via_init:
    ; Initialize VIA for LCD and keyboard
    ; (Configure DDRA, DDRB, etc.)
    RTS

lcd_newline:
    ; Move to next line or scroll
    ; (Implementation depends on LCD size)
    RTS

keyboard_init:
    ; Initialize keyboard interface
    RTS

keyboard_read:
    ; Read character from keyboard
    ; Returns: A = character (0 if none)
    LDA #$00              ; Stub - return no character
    RTS

; (Include lcd_init, lcd_command, lcd_data from Lesson 13)

lcd_init:
    RTS

lcd_command:
    RTS

lcd_data:
    RTS

;--------------------------------------
; Interrupt vectors
;--------------------------------------

nmi_handler:
    ; Save state and return to monitor
    STA saved_a
    STX saved_x
    STY saved_y
    PHP
    PLA
    STA saved_p
    
    ; Get return address from stack
    TSX
    LDA $0102,X           ; PC low
    STA saved_pc
    LDA $0103,X           ; PC high
    STA saved_pc+1
    
    ; Display NMI message
    ; Then return to command loop
    JMP command_loop

irq_handler:
    ; Handle interrupts (keyboard, etc.)
    RTI

.segment "VECTORS"
.org $FFFA
.word nmi_handler
.word reset
.word irq_handler
```

## Breaking It Down

### Command Parser

```asm
parse_command:
    LDA cmd_buffer        ; Get first character
    CMP #'R'
    BEQ cmd_registers     ; Branch to handler
    CMP #'M'
    BEQ cmd_memory
    ; ... more commands ...
```

Simple but effective: check first character, dispatch to handler.

### Hex Parsing

Converting ASCII hex to binary:

```asm
hex_to_bin:
    ; '0'-'9' → 0-9
    CMP #'0'
    BCC error
    CMP #'9'+1
    BCS check_letters
    SEC
    SBC #'0'              ; Convert to value
    RTS
    
check_letters:
    ; 'A'-'F' → 10-15
    CMP #'A'
    BCC error
    CMP #'F'+1
    BCS error
    SEC
    SBC #'A'-10           ; Convert to value
    RTS
```

### Memory Examination

```asm
LDA (parse_addr),X    ; Indirect indexed read
JSR print_hex
```

Uses indirect indexed addressing to read any memory location.

### Executing User Code

```asm
JMP (parse_addr)      ; Indirect jump!
```

Transfers control to user program. User can return with `JMP $A000` (monitor entry).

## Advanced Features

### Breakpoints

To add breakpoint support:

1. **Store breakpoint addresses** in table
2. **Save original instruction** at breakpoint
3. **Write BRK instruction** to breakpoint location
4. **In BRK handler:** Check if PC matches breakpoint
5. **Restore instruction** temporarily
6. **Single-step**, then re-insert BRK

```asm
; Simplified breakpoint implementation
set_breakpoint:
    ; A = breakpoint number (0-7)
    ; parse_addr = address
    
    ASL A                 ; Multiply by 2 (word size)
    TAX
    
    ; Save address
    LDA parse_addr
    STA breakpoint_table,X
    LDA parse_addr+1
    STA breakpoint_table+1,X
    
    ; Save original instruction
    LDY #$00
    LDA (parse_addr),Y
    STA breakpoint_orig,X
    
    ; Write BRK
    LDA #$00              ; BRK opcode
    STA (parse_addr),Y
    
    RTS

breakpoint_table:
    .res 16               ; 8 breakpoints × 2 bytes
breakpoint_orig:
    .res 8                ; Original instructions
```

### Disassembler

A disassembler shows code as assembly:

```
A000: A9 00    LDA #$00
A002: 8D 00 80 STA $8000
A005: 4C 00 A0 JMP $A000
```

Implementation needs:
1. **Opcode table** with mnemonics
2. **Address mode decoder**
3. **Operand size** per instruction

This is complex but invaluable for debugging!

### Single Stepping

True single-stepping requires:
1. **Decode instruction** at PC
2. **Calculate next PC** (PC + instruction length)
3. **Set breakpoint** at next instruction
4. **Execute** (will hit breakpoint immediately)
5. **Remove breakpoint**

## Experiments

### Experiment 1: Add Command History

Store last 4 commands, allow recall with up arrow:

```asm
history_buffer:
    .res 64               ; 4 commands × 16 bytes
history_ptr:
    .byte $00
```

### Experiment 2: Add Checksums

Add a checksum command to verify memory:

```asm
; C addr len - Checksum from addr for len bytes
cmd_checksum:
    ; Sum all bytes
    ; Display result
```

### Experiment 3: Memory Test

Add memory test command:

```asm
; T start end - Test memory from start to end
cmd_test_memory:
    ; Write patterns
    ; Read back
    ; Report errors
```

## Exercises

**Exercise 1:** Add a register modify command: `A=XX`, `X=XX`, etc.

**Exercise 2:** Implement a simple disassembler for the most common instructions (LDA, STA, JMP, etc.)

**Exercise 3:** Add a "fill memory" command: `:start-end bb` fills range with byte value.

<details>
<summary>Solution to Exercise 3</summary>

```asm
; Command: F - Fill memory
; Format: F start end bb

cmd_fill:
    ; Parse start address
    JSR parse_hex_addr
    BCC fill_error
    LDA parse_addr
    STA fill_start
    LDA parse_addr+1
    STA fill_start+1
    
    ; Parse end address
    JSR parse_hex_addr
    BCC fill_error
    LDA parse_addr
    STA fill_end
    LDA parse_addr+1
    STA fill_end+1
    
    ; Parse fill byte
    JSR parse_hex_byte
    BCC fill_error
    STA fill_byte
    
    ; Fill memory
    LDY #$00
fill_loop:
    LDA fill_byte
    STA (fill_start),Y
    
    ; Increment address
    INC fill_start
    BNE fill_check
    INC fill_start+1
    
fill_check:
    ; Compare with end
    LDA fill_start+1
    CMP fill_end+1
    BCC fill_loop
    BNE fill_done
    LDA fill_start
    CMP fill_end
    BCC fill_loop

fill_done:
    ; Display message
    LDX #$00
fill_msg_loop:
    LDA fill_msg,X
    BEQ fill_exit
    JSR lcd_data
    INX
    JMP fill_msg_loop
fill_exit:
    JSR lcd_newline
    RTS

fill_error:
    ; Error message
    RTS

fill_start:   .res 2
fill_end:     .res 2
fill_byte:    .res 1

fill_msg:
    .byte "Filled", $00
```
</details>

## Deep Dive: Making it Production-Ready

A real monitor needs:

### 1. Serial I/O

Instead of LCD/keyboard, use serial port (ACIA 6551):

```asm
serial_read:
    LDA ACIA_STATUS
    AND #$08              ; RX data available?
    BEQ serial_read
    LDA ACIA_DATA
    RTS

serial_write:
    PHA
sw_wait:
    LDA ACIA_STATUS
    AND #$10              ; TX ready?
    BEQ sw_wait
    PLA
    STA ACIA_DATA
    RTS
```

### 2. XMODEM Transfer

Add file transfer protocol for loading programs:

```asm
xmodem_receive:
    ; Send NAK to start
    ; Receive 128-byte packets
    ; Send ACK for each
    ; Verify checksums
    RTS
```

### 3. Symbolic Debugging

Store symbol table in RAM:

```
Symbol    Address
------    -------
main      $2000
loop      $2010
buffer    $0200
```

Allow commands like: `G main` instead of `G 2000`

### 4. Persistent Storage

Save/load to EEPROM or SD card:

```asm
; S filename start end - Save to file
; L filename addr - Load to address
```

## Real-World Example: WOZMON

Steve Wozniak's monitor (Apple I, 256 bytes!):

```
Commands:
addr          - Examine memory at addr
addr: bb bb   - Write bytes
addr.end      - Examine range
addr R        - Run from addr
```

Extremely compact but powerful. Brilliant design!

## Common Errors

### Stack overflow in monitor
**Problem:** Deep call nesting
**Solution:** Keep monitor calls shallow, use tail calls

### Corrupting monitor RAM
**Problem:** User program overwrites monitor variables
**Solution:** Put monitor in ROM, variables in protected area

### Infinite loop in user program
**Problem:** Can't break out
**Solution:** Use NMI button to return to monitor

### Can't re-enter monitor
**Problem:** Interrupts disabled, stack corrupted
**Solution:** NMI handler always works, resets stack

## Key Takeaways

✅ **Monitor** is a simple OS for development

✅ **Command parser** dispatches to handlers

✅ **Hex parsing** converts ASCII to binary

✅ **Memory examination** uses indirect addressing

✅ **Register preservation** critical for debugging

✅ **NMI** provides emergency return to monitor

✅ **Real monitors** add: disassembly, breakpoints, I/O

✅ **Keep it simple** - even 256 bytes is useful!

## Next Steps

Congratulations! You've completed the W65C02 hardware lessons!

### Continue Learning

- **Build projects:** Calculator, game, music player
- **Optimize:** Learn speed optimization techniques
- **Expand:** Add more peripherals (SD card, audio, etc.)
- **Create:** Design your own computer architecture

### Resources

- **6502.org** - Forums and projects
- **Visual 6502** - See the actual silicon!
- **Ben Eater videos** - Building a 6502 computer
- **Easy 6502** - Interactive tutorial

---

## Quick Reference

**Monitor Commands:**
```
R                 - Show registers
M addr            - Memory dump
:addr bb bb bb    - Write bytes
G addr            - Execute at address
S                 - Single step
?                 - Help
```

**Parsing Pattern:**
```asm
parse_command:
    LDA cmd_buffer
    CMP #'X'
    BEQ cmd_x
    ; ... more commands ...
    RTS

cmd_x:
    ; Handle command X
    RTS
```

**Hex to Binary:**
```asm
; '0'-'9' → subtract '0' = 0-9
; 'A'-'F' → subtract 'A'-10 = 10-15
```

**Binary to Hex:**
```asm
; 0-9 → add '0' = '0'-'9'
; 10-15 → add 'A'-10 = 'A'-'F'
```

---

*You now have the foundation to build anything on the 6502!* 🎓🚀

**Happy hacking!**
