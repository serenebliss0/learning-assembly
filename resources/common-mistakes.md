# Common Mistakes When Learning Assembly

Learning from mistakes is part of the process! Here are the most common pitfalls and how to avoid them.

## General Mistakes

### 1. Trying to Run the Source File

❌ **Wrong:**
```bash
./program.asm
```

✅ **Right:**
```bash
nasm -f elf64 program.asm
ld program.o -o program
./program
```

**Why:** Assembly code must be assembled into machine code first!

### 2. Forgetting to Link

❌ **Wrong:**
```bash
nasm -f elf64 program.asm
./program.o
```

✅ **Right:**
```bash
nasm -f elf64 program.asm
ld program.o -o program
./program
```

**Why:** The assembler creates an object file (.o), not an executable. You need the linker!

### 3. Using the Wrong Syntax

Different assemblers use different syntax. Don't mix them!

**Intel Syntax (NASM):**
```asm
mov eax, 5          ; destination, source
```

**AT&T Syntax (GAS):**
```asm
movl $5, %eax       ; source, destination (backwards!)
```

Pick one and stick with it!

## x86-Specific Mistakes

### 4. Mixing 32-bit and 64-bit

❌ **Wrong:**
```asm
section .text
global _start
_start:
    mov eax, 1      ; 32-bit register
    mov rdi, 2      ; 64-bit register (mixed!)
    syscall
```

✅ **Right:**
```bash
; Either use all 32-bit or all 64-bit
mov rax, 1          ; 64-bit
mov rdi, 2          ; 64-bit
syscall
```

### 5. Wrong System Call Numbers

System call numbers differ between 32-bit and 64-bit!

**32-bit Linux:**
- sys_write = 4
- sys_exit = 1

**64-bit Linux:**
- sys_write = 1
- sys_exit = 60

Always check the correct syscall table for your platform!

### 6. Stack Alignment Issues (macOS)

On macOS, stack must be 16-byte aligned before calls.

❌ **Wrong:**
```asm
push rax            ; Stack now misaligned!
call function
```

✅ **Right:**
```asm
sub rsp, 8          ; Maintain alignment
push rax
call function
add rsp, 16
```

### 7. Forgetting to Preserve Registers

❌ **Wrong:**
```asm
my_function:
    mov rax, 5      ; Overwrites caller's rax!
    ; ... more code
    ret
```

✅ **Right:**
```asm
my_function:
    push rax        ; Save it
    mov rax, 5
    ; ... more code
    pop rax         ; Restore it
    ret
```

Or better, follow calling conventions!

## 6502/W65C02 Mistakes

### 8. Forgetting Addressing Mode Syntax

❌ **Wrong:**
```asm
LDA $1234           ; This is absolute addressing!
```

If you want immediate:
```asm
LDA #$1234          ; This loads the VALUE $1234
```

**Remember:** `#` means immediate value!

### 9. Not Setting the Carry Flag for Subtraction

❌ **Wrong:**
```asm
LDA value1
SBC value2          ; Carry flag state unknown!
```

✅ **Right:**
```asm
LDA value1
SEC                 ; Set carry before subtract!
SBC value2
```

### 10. Forgetting Decimal Mode

The 6502 has decimal mode (BCD arithmetic). Make sure it's clear!

```asm
CLD                 ; Clear decimal mode at start
```

### 11. Branch Out of Range

Branches can only go ±127 bytes!

❌ **Wrong:**
```asm
    BEQ far_label   ; Too far away!
    ; ... 200 bytes of code
far_label:
```

✅ **Right:**
```asm
    BNE skip
    JMP far_label   ; Use absolute jump
skip:
    ; ... continues
```

## Memory and Addressing Mistakes

### 12. Confusing Value and Address

❌ **Wrong:**
```asm
mov eax, value      ; Loads the ADDRESS, not the value!
```

✅ **Right:**
```asm
mov eax, [value]    ; Loads the VALUE at that address
```

### 13. Writing to ROM

ROM is Read-Only Memory! You can't write to it.

❌ **Wrong:**
```asm
section .rodata
    counter db 0

section .text
    mov byte [counter], 1   ; ERROR: Can't write to .rodata!
```

✅ **Right:**
```asm
section .bss
    counter resb 1          ; Use .bss or .data for writable

section .text
    mov byte [counter], 1   ; Now it works!
```

### 14. Uninitialized Memory

❌ **Wrong:**
```asm
section .bss
    buffer resb 10

section .text
    mov eax, [buffer]       ; Contains garbage!
```

✅ **Right:**
```asm
; Either initialize it first, or use .data
section .data
    buffer db 10 dup(0)     ; Initialized to zeros
```

## Logic Mistakes

### 15. Confusing Signed and Unsigned

Different jump instructions for signed vs unsigned!

**Unsigned comparisons:**
- JA (jump if above)
- JB (jump if below)

**Signed comparisons:**
- JG (jump if greater)
- JL (jump if less)

```asm
cmp eax, ebx
jg signed_greater       ; Treats as signed
ja unsigned_greater     ; Treats as unsigned
```

### 16. Not Understanding Flags

Forgetting that operations affect flags!

❌ **Wrong:**
```asm
cmp eax, ebx
mov ecx, 5          ; Doesn't affect flags
je equal            ; Still based on cmp!
```

But this DOES affect flags:
```asm
cmp eax, ebx
add ecx, 5          ; AFFECTS flags! Cmp result lost!
je equal            ; Won't work as expected!
```

### 17. Infinite Loops

❌ **Wrong:**
```asm
loop_start:
    ; ... code but no loop counter change
    jmp loop_start      ; Loops forever!
```

✅ **Right:**
```asm
    mov ecx, 10
loop_start:
    ; ... code
    dec ecx
    jnz loop_start      ; Stops when ecx = 0
```

## Debugging Mistakes

### 18. Not Using a Debugger

Don't just stare at code! Use GDB:

```bash
gdb ./program
(gdb) break _start
(gdb) run
(gdb) stepi            # Step one instruction
(gdb) info registers   # See all registers
```

### 19. Not Checking Return Values

```bash
echo $?     # Check exit code after running
```

### 20. Not Reading Error Messages

Error messages tell you exactly what's wrong!

```
program.asm:5: error: invalid combination of opcode and operands
```

This tells you:
- Line 5
- What's wrong: invalid instruction/operands
- Where to look!

## Best Practices to Avoid Mistakes

1. **Start simple** - Get "Hello World" working first
2. **Test incrementally** - Don't write 100 lines then test
3. **Use comments** - Future you will thank present you
4. **Check registers often** - Use debugger to verify
5. **Read datasheets** - When in doubt, check the manual
6. **Follow conventions** - Use standard calling conventions
7. **Write tests** - Test your functions individually

## When Stuck

1. Read the error message carefully
2. Check syntax (Intel vs AT&T)
3. Verify addressing modes
4. Use the debugger
5. Print/check register values
6. Simplify - make smallest test case
7. Ask for help (GitHub issues!)

## Common Error Messages Decoded

**"Segmentation fault"**: Accessed invalid memory
- Check your pointers
- Stack overflow/underflow?
- Writing to ROM?

**"Invalid combination of opcode and operands"**: Wrong instruction syntax
- Check your addressing mode
- Right size? (byte/word/dword)
- Check the instruction reference

**"Undefined reference"**: Linker can't find something
- Forgot `global _start`?
- Missing library?
- Typo in label?

---

Remember: Mistakes are learning opportunities! Everyone makes these. The key is learning from them! 🚀
