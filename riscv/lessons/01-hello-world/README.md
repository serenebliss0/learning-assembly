# Lesson 01: Hello World - Your First RISC-V Program

Welcome to your first RISC-V assembly program! We'll write a simple "Hello, World!" program.

## Learning Objectives

By the end of this lesson, you'll:
- Understand the basic structure of a RISC-V assembly program
- Know how to use system calls to output text
- Understand sections: `.data`, `.text`
- Be able to assemble, link, and run a program
- Learn about RISC-V registers and basic instructions

## The Code

Create a file called `hello.s`:

```asm
# hello.s - Your first RISC-V assembly program
# This program prints "Hello, RISC-V!" and exits

.section .data
msg:
    .string "Hello, RISC-V!\n"
    
.section .text
.globl _start

_start:
    # Write message to stdout
    li a0, 1           # file descriptor (1 = stdout)
    la a1, msg         # address of message
    li a2, 15          # length of message
    li a7, 64          # syscall number for write
    ecall              # make system call

    # Exit program
    li a0, 0           # exit code 0 (success)
    li a7, 93          # syscall number for exit
    ecall              # make system call
```

## Breaking It Down

### Section Declarations

```asm
.section .data
```

This declares the data section where we store constants and initialized variables.

```asm
.section .text
```

This declares the code section where our instructions live.

### Defining Data

```asm
msg:
    .string "Hello, RISC-V!\n"
```

- `msg:` - Label (name) for this data
- `.string` - Defines a null-terminated string
- `"Hello, RISC-V!\n"` - Our message with newline

### Entry Point

```asm
.globl _start
```

Tells the linker that `_start` is the entry point (where execution begins).

```asm
_start:
```

The label where our program starts executing.

### System Call: Write

```asm
li a0, 1           # file descriptor (1 = stdout)
la a1, msg         # address of message
li a2, 15          # length of message
li a7, 64          # syscall number for write
ecall              # make system call
```

A **system call** is how we ask the operating system to do something for us.

In RISC-V, system calls work like this:
- Put syscall number in `a7`
- Put arguments in `a0`, `a1`, `a2`, etc.
- Execute `ecall` instruction

For `write` syscall (number 64):
- `a0` = file descriptor (1 for stdout)
- `a1` = pointer to data
- `a2` = number of bytes to write
- `a7` = 64 (write syscall number)

### Understanding the Instructions

**li (Load Immediate)**
```asm
li a0, 1           # a0 = 1
```
Loads a constant value into a register. This is a pseudo-instruction that expands to `addi a0, zero, 1`.

**la (Load Address)**
```asm
la a1, msg         # a1 = address of msg
```
Loads the address of a label into a register. Another pseudo-instruction.

**ecall (Environment Call)**
```asm
ecall              # Call the operating system
```
Transfers control to the OS to perform the system call specified in `a7`.

### System Call: Exit

```asm
li a0, 0           # exit code 0
li a7, 93          # syscall number for exit
ecall              # make system call
```

We must exit cleanly!

- `a7 = 93` (exit syscall number)
- `a0 = 0` (exit code - 0 means success)

## RISC-V Registers Quick Reference

RISC-V has 32 registers. Here are the ones we used:

- **a0-a7 (x10-x17)**: Function arguments and return values
  - For syscalls, these hold the arguments
- **a7 (x17)**: Also used for syscall number
- **zero (x0)**: Always contains 0 (used implicitly by `li`)

## Building and Running

### Step 1: Assemble

```bash
riscv64-unknown-elf-as -march=rv32i -mabi=ilp32 hello.s -o hello.o
```

This creates `hello.o` (object file).

- `-march=rv32i` - Target architecture: 32-bit base RISC-V
- `-mabi=ilp32` - ABI: 32-bit integer, long, and pointer
- `hello.s` - Input file
- `-o hello.o` - Output file

### Step 2: Link

```bash
riscv64-unknown-elf-ld hello.o -o hello
```

This creates `hello` (executable).

- `hello.o` - Input object file
- `-o hello` - Output executable

### Step 3: Run

```bash
qemu-riscv32 ./hello
```

You should see:
```
Hello, RISC-V!
```

### Check Exit Code

```bash
echo $?
```

Should show `0` (our exit code).

## Experiments

Try modifying the program:

### Experiment 1: Change the Message

Change:
```asm
.string "Hello, RISC-V!\n"
```

To:
```asm
.string "I am learning RISC-V!\n"
```

**Don't forget** to update the length in `li a2, ...`!

### Experiment 2: Multiple Lines

Try:
```asm
.string "Line 1\nLine 2\nLine 3\n"
```

What's the new length? Count the characters!

### Experiment 3: Different Exit Code

Change:
```asm
li a0, 0           # exit code 0
```

To:
```asm
li a0, 42          # exit code 42
```

Run and check: `echo $?`

### Experiment 4: Remove the Exit

Comment out the exit code:
```asm
# li a0, 0
# li a7, 93
# ecall
```

What happens when you run it? You'll likely get an illegal instruction error because the CPU tries to execute whatever's after your code!

## Exercises

Now try these on your own:

**Exercise 1:** Write a program that prints your name.

**Exercise 2:** Write a program that prints three different messages. (Hint: You'll need three write syscalls.)

**Exercise 3:** Modify the program to exit with code 5. Verify with `echo $?`.

**Exercise 4:** Add a second message in the `.data` section and print both messages.

<details>
<summary>Solution to Exercise 4</summary>

```asm
.section .data
msg1:
    .string "First message\n"
msg2:
    .string "Second message\n"

.section .text
.globl _start

_start:
    # Print first message
    li a0, 1
    la a1, msg1
    li a2, 14          # Length of "First message\n"
    li a7, 64
    ecall

    # Print second message
    li a0, 1
    la a1, msg2
    li a2, 15          # Length of "Second message\n"
    li a7, 64
    ecall

    # Exit
    li a0, 0
    li a7, 93
    ecall
```
</details>

## Deep Dive: Why RISC-V?

**Simple and Regular:**
- All instructions are 32-bit (in base ISA)
- Regular instruction formats
- Easy to decode

**Open Standard:**
- No licensing fees
- Anyone can implement
- Growing ecosystem

**Modern Design:**
- Learns from decades of CPU evolution
- Avoids mistakes of past architectures
- Designed for extensibility

## Deep Dive: Pseudo-Instructions

Some instructions aren't "real" RISC-V instructions - they're **pseudo-instructions** that the assembler converts:

**li (load immediate):**
```asm
li a0, 100
```
Becomes:
```asm
addi a0, zero, 100     # a0 = 0 + 100
```

**la (load address):**
```asm
la a1, msg
```
Becomes (simplified):
```asm
lui a1, %hi(msg)       # Load upper 20 bits
addi a1, a1, %lo(msg)  # Add lower 12 bits
```

Pseudo-instructions make code more readable!

## Deep Dive: System Call Numbers

System call numbers vary by OS:

**Linux RISC-V:**
- write = 64
- exit = 93

These are different from x86 Linux! Each architecture has its own syscall numbers.

## Common Errors

### Error: "command not found"
**Solution:** Install RISC-V toolchain. See [setup guide](../../setup.md).

### Error: "cannot find entry symbol _start"
**Solution:** Make sure you have `.globl _start` in your code.

### Error: "Illegal instruction"
**Solution:** 
- Check architecture matches: use `-march=rv32i` 
- Make sure QEMU is using `qemu-riscv32`
- Verify you have exit syscall

### Wrong output or crash
**Solution:** 
- Check message length is correct
- Verify syscall numbers (64 for write, 93 for exit)
- Make sure you exit cleanly

## Key Takeaways

✅ RISC-V programs have **sections** (`.data`, `.text`)

✅ Use **system calls** (`ecall`) to interact with the OS

✅ Must **exit cleanly** or program will crash

✅ **Registers** hold values temporarily (`a0-a7` for syscalls)

✅ RISC-V is **simple and regular** - consistent design!

## Next Lesson

Ready for more? Continue to:
**[Lesson 02: Registers and Data →](../02-registers/)**

Or practice more with these programs before moving on!

---

## Quick Reference

**Assemble:**
```bash
riscv64-unknown-elf-as -march=rv32i -mabi=ilp32 program.s -o program.o
```

**Link:**
```bash
riscv64-unknown-elf-ld program.o -o program
```

**Run:**
```bash
qemu-riscv32 ./program
```

**Check exit code:**
```bash
echo $?
```

**Disassemble:**
```bash
riscv64-unknown-elf-objdump -d program
```

---

*Great job completing your first RISC-V assembly program!* 🎉
