# Debugging Tips for Assembly

Debugging assembly can be challenging, but with the right approach and tools, you can find and fix issues efficiently!

## General Debugging Philosophy

1. **Start simple** - Test with minimal code first
2. **One thing at a time** - Change one thing, test it
3. **Verify assumptions** - Don't assume registers/memory contain what you think
4. **Use tools** - Debuggers are your friends
5. **Be systematic** - Work through logically, don't guess randomly

## Using GDB (x86)

GDB (GNU Debugger) is essential for x86 assembly debugging.

### Basic GDB Commands

```bash
# Compile with debug info
nasm -f elf64 -g -F dwarf program.asm
ld program.o -o program

# Start GDB
gdb ./program
```

**Essential commands:**
```
(gdb) break _start          # Set breakpoint at _start
(gdb) run                   # Run the program
(gdb) stepi                 # Step one instruction (si)
(gdb) nexti                 # Step over calls (ni)
(gdb) continue              # Continue to next breakpoint (c)
(gdb) info registers        # Show all registers (i r)
(gdb) info registers rax    # Show specific register
(gdb) x/10x $rsp           # Examine memory at stack pointer (hex)
(gdb) x/s 0x400000         # Examine memory as string
(gdb) print $rax           # Print register value
(gdb) quit                 # Exit GDB (q)
```

### Examining Memory

```
(gdb) x/nfu address

n = how many units
f = format (x=hex, d=decimal, s=string, i=instruction)
u = unit (b=byte, h=halfword, w=word, g=giant/8 bytes)
```

Examples:
```
(gdb) x/10xb 0x601000      # 10 bytes in hex
(gdb) x/4xw 0x601000       # 4 words in hex
(gdb) x/s msg              # String at label 'msg'
(gdb) x/10i $rip           # 10 instructions at current location
```

### Useful GDB Tricks

**Watch for changes:**
```
(gdb) watch variable       # Break when variable changes
(gdb) watch *0x601000      # Break when memory location changes
```

**Display on every step:**
```
(gdb) display/i $rip       # Show next instruction
(gdb) display/x $rax       # Show rax register
```

**Conditional breakpoints:**
```
(gdb) break loop if $rax == 5    # Break only when rax is 5
```

## Using py65mon (W65C02)

For 6502/65C02, py65mon is a great emulator/debugger.

```bash
# Start emulator
py65mon

# Load program
> load program.bin 8000

# Set start address
> goto 8000

# Single step
> step

# Show registers
> registers

# Examine memory
> mem 8000:8010

# Run until breakpoint
> run
```

## Debugging Strategies

### 1. Print/Output Debugging

Add code to output values:

**x86:**
```asm
; Print a register value (simple)
mov rax, 1              ; sys_write
mov rdi, 1              ; stdout
lea rsi, [debug_msg]    ; message
mov rdx, 20             ; length
syscall
```

**6502:**
```asm
LDA #'X'                ; Print 'X' to show you reached here
JSR print_char
```

### 2. Breakpoint Method

Start at beginning, step through:

```
1. Set breakpoint at start
2. Run to breakpoint
3. Check registers - are they what you expect?
4. Step one instruction
5. Check registers again
6. Repeat until you find the problem
```

### 3. Binary Search Debugging

For large programs:

```
1. Put breakpoint in middle
2. Check if bug occurred before or after
3. Put breakpoint in middle of that half
4. Repeat until you narrow it down
```

### 4. Simplification

Can't find the bug? Simplify!

```
1. Comment out half the code
2. Does it still break?
3. If yes, bug is in remaining half
4. If no, bug is in commented half
5. Uncomment/comment to narrow down
```

## Common Issues and How to Debug

### Segmentation Fault

**Symptoms:** Program crashes with "Segmentation fault"

**Causes:**
- Accessing invalid memory
- Stack overflow/underflow
- Writing to read-only memory
- Null pointer dereference

**Debug approach:**
```
1. Run in GDB: gdb ./program
2. Run: run
3. It will stop at crash
4. Check: where (shows where it crashed)
5. Check: info registers (what were registers?)
6. Check: x/10x $rsp (what's on stack?)
```

### Wrong Output

**Symptoms:** Program runs but output is wrong

**Debug approach:**
```
1. Add print statements showing intermediate values
2. Use GDB to step through and verify each operation
3. Check: Are flags set correctly?
4. Check: Are you using right addressing mode?
5. Verify: Math operations work as expected?
```

### Infinite Loop

**Symptoms:** Program never exits

**Debug approach:**
```
1. Press Ctrl+C in GDB
2. Check where it stopped
3. Look at that code - what's the loop condition?
4. Check loop counter: is it changing?
5. Check flags: are they set right for condition?
```

### Program Does Nothing

**Symptoms:** Runs but produces no output

**Debug approach:**
```
1. Check exit code: echo $?
2. Is your syscall number correct?
3. Are parameters in right registers?
4. Use GDB to verify syscall is executed
5. Check file descriptors (stdout = 1)
```

## Hardware Debugging (W65C02)

Debugging physical hardware is different!

### Tools You Need

1. **Multimeter** - Check voltage and continuity
2. **Logic probe** - Check digital signals
3. **Logic analyzer** (optional) - See multiple signals
4. **LED indicators** - Visual debugging

### Hardware Debug Steps

**1. Check Power:**
```
- Measure VCC: Should be ~5V
- Check ground connections
- Verify no shorts
```

**2. Check Clock:**
```
- Oscilloscope or logic probe on clock pin
- Should see regular pulses
- Frequency correct?
```

**3. Check Reset:**
```
- Should go low briefly at power-on
- Then stay high
```

**4. Check Address Lines:**
```
- Use logic analyzer or LED on address pins
- Should see activity
- Are patterns sensible?
```

**5. Check Data Lines:**
```
- Should show data being transferred
- Both read and write cycles
```

### Common Hardware Issues

**Nothing happens:**
- Check power
- Check clock signal
- Check reset circuit

**Erratic behavior:**
- Check all ground connections
- Add decoupling capacitors
- Check for loose wires

**Works sometimes:**
- Timing issue - check clock
- Bad connection - check all wires
- Intermittent short

## Debugging Checklist

Before asking for help, check:

- [ ] Does it assemble without errors?
- [ ] Does it link without errors?
- [ ] Have you tried running it in debugger?
- [ ] Have you checked register values?
- [ ] Have you verified memory contents?
- [ ] Have you checked flags?
- [ ] Have you read error messages carefully?
- [ ] Have you checked syntax (Intel vs AT&T)?
- [ ] Have you tried simplifying the code?
- [ ] Have you checked the instruction reference?

## Getting Help

When asking for help, provide:

1. **What you're trying to do**
2. **What happens instead**
3. **Complete code** (minimal example)
4. **Error messages** (exact text)
5. **What you've tried**
6. **Platform/OS/assembler version**

Good question:
```
I'm trying to print "Hello" on x86 Linux with NASM. The program
assembles and links but outputs nothing. I've verified the syscall
number (1 for write) and registers in GDB. Here's my code:
[code]
Exit code is 0. What am I missing?
```

## Advanced Debugging

### Using strace (Linux)

See all system calls:
```bash
strace ./program
```

### Using objdump

Disassemble to verify:
```bash
objdump -d program
objdump -M intel -d program    # Intel syntax
```

### Using hexdump

Check binary files:
```bash
hexdump -C program.bin
```

## Debug-Friendly Coding

Make your code easier to debug:

**1. Use meaningful labels:**
```asm
calculate_sum:          ; Good
loop1:                  ; Bad
```

**2. Add comments:**
```asm
mov rax, 60            ; sys_exit
mov rdi, 0             ; exit code 0
```

**3. Separate concerns:**
```asm
; Don't:
; ... everything in one huge block

; Do:
call read_input
call process_data
call write_output
```

**4. Use constants:**
```asm
SYS_WRITE equ 1
STDOUT equ 1

mov rax, SYS_WRITE     ; Clear intent
mov rdi, STDOUT
```

## Remember

- **Debugging is a skill** - You'll get better with practice
- **Be patient** - Sometimes it takes time
- **Take breaks** - Fresh eyes spot bugs easier
- **Learn from mistakes** - Each bug teaches you something

---

*"Debugging is twice as hard as writing the code in the first place."* - Brian Kernighan

But you can do it! 🔍
