# What is Assembly Language?

## Introduction

Assembly language is a low-level programming language that's one step above machine code. It's the most direct way to communicate with a computer's CPU.

## The Hierarchy of Languages

Let's see where assembly fits:

```
High Level:    Python, JavaScript, Java
                ↓ (compiler/interpreter)
Mid Level:     C, C++, Rust
                ↓ (compiler)
Assembly:      mov, add, jmp
                ↓ (assembler)
Machine Code:  01010011 01000001
                ↓
Hardware:      Actual CPU circuits
```

## What Makes Assembly Different?

### 1. **Direct Hardware Control**
- Each instruction directly corresponds to CPU operations
- You control registers, memory, and I/O explicitly
- No abstractions hiding what's happening

### 2. **Architecture-Specific**
- x86 assembly is different from ARM assembly
- Different from 6502, MIPS, RISC-V, etc.
- Learn one, easier to learn others

### 3. **Very Explicit**
In Python:
```python
result = x + y
```

In Assembly (x86):
```asm
mov eax, [x]    ; Load x into register
add eax, [y]    ; Add y to register
mov [result], eax ; Store result
```

Everything is explicit!

## Why Learn Assembly?

### ✅ Reasons to Learn

1. **Understand computers deeply** - You'll know what your code really does
2. **Debug better** - Understand stack traces and crashes
3. **Optimize critical code** - Sometimes assembly is fastest
4. **Reverse engineering** - Analyze how programs work
5. **Embedded systems** - Many require assembly knowledge
6. **Operating systems** - OS dev needs assembly
7. **Security** - Understanding exploits and vulnerabilities
8. **Career** - Unique and valuable skill

### ⚠️ When NOT to Use Assembly

1. **Normal application development** - Use high-level languages
2. **Rapid prototyping** - Assembly is slow to write
3. **Cross-platform code** - Assembly is architecture-specific
4. **When compiler is good enough** - Modern compilers are amazing

## Key Concepts

### Registers
Think of registers as the CPU's workspace - tiny, super-fast storage locations.

```
In x86:
- EAX, EBX, ECX, EDX: General purpose
- ESP: Stack pointer
- EIP: Instruction pointer

In 6502:
- A: Accumulator (main register)
- X, Y: Index registers
- PC: Program counter
```

### Instructions
Commands the CPU can execute:

- **Data Movement**: `mov`, `ld`, `st`
- **Arithmetic**: `add`, `sub`, `inc`, `dec`
- **Logic**: `and`, `or`, `xor`, `not`
- **Control Flow**: `jmp`, `jne`, `call`, `ret`

### Memory
Assembly gives you direct memory access:

```asm
mov eax, [address]    ; Read from memory
mov [address], eax    ; Write to memory
```

### Flags
Special status bits that track conditions:

- **Zero flag (Z)**: Result was zero
- **Carry flag (C)**: Overflow/underflow occurred
- **Negative flag (N)**: Result was negative
- **Overflow flag (V)**: Signed overflow

## Assembly Syntax Flavors

### Intel Syntax (used in this repo for x86)
```asm
mov eax, 5          ; destination, source
add eax, ebx        ; eax = eax + ebx
```

### AT&T Syntax (alternative for x86)
```asm
movl $5, %eax       ; source, destination (note reversed!)
addl %ebx, %eax     ; eax = eax + ebx
```

We use Intel syntax because it's more readable!

## Example: Simple Program

### x86 Assembly (Linux)
```asm
section .data
    msg db 'Hello, World!', 10
    len equ $ - msg

section .text
    global _start

_start:
    ; Write message
    mov eax, 4          ; sys_write
    mov ebx, 1          ; stdout
    mov ecx, msg        ; message
    mov edx, len        ; length
    int 0x80            ; syscall

    ; Exit
    mov eax, 1          ; sys_exit
    xor ebx, ebx        ; exit code 0
    int 0x80            ; syscall
```

### 6502 Assembly
```asm
    ; Initialize
    LDX #0              ; X = 0

loop:
    LDA message,X       ; Load character
    BEQ done            ; If zero, we're done
    JSR print_char      ; Print it
    INX                 ; X++
    JMP loop            ; Continue

done:
    RTS                 ; Return

message:
    .asciiz "Hello, World!"
```

## The Learning Curve

```
Difficulty
    ▲
    │     ╱╲
    │    ╱  ╲___________  (Gets easier!)
    │   ╱
    │  ╱
    └─────────────────────► Time
      Start    Few weeks
```

Assembly seems hard at first, but it follows logical patterns. Once you understand the basics, it becomes intuitive!

## Common Misconceptions

❌ **"Assembly is too hard"**
→ It's unfamiliar, not hard. Take it step by step.

❌ **"No one uses assembly anymore"**
→ Used in OS kernels, embedded systems, performance-critical code, security.

❌ **"Assembly is dead"**
→ Still very much alive and relevant!

❌ **"I need to memorize all instructions"**
→ You'll naturally remember the common ones. References exist for the rest.

## Next Steps

Now that you know what assembly is:

1. Choose your path:
   - [x86 Assembly](../x86/README.md) - Modern PCs
   - [W65C02 Assembly](../w65c02/README.md) - Simple, elegant, hardware-friendly

2. Set up your environment

3. Start with Lesson 1!

## Further Reading

- [How CPUs Execute Instructions](./how-cpus-work.md)
- [Assembly vs Other Languages](./assembly-comparison.md)
- [History of Assembly](./history.md)
- [Glossary](./glossary.md)

---

*Remember: Every expert started as a beginner. You've got this!* 💪
