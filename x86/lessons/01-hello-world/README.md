# Lesson 01: Hello World - Your First x86 Program

Welcome to your first x86 assembly program! We'll write a simple "Hello, World!" program that runs on Linux.

## Learning Objectives

By the end of this lesson, you'll:
- Understand the basic structure of an x86 assembly program
- Know how to use system calls to output text
- Understand sections: `.data`, `.text`
- Be able to assemble, link, and run a program

## The Code

Create a file called `hello.asm`:

```asm
; hello.asm - Your first x86 assembly program
; This program prints "Hello, World!" and exits

section .data
    ; Define our message
    msg db 'Hello, World!', 10    ; 10 is newline character
    len equ $ - msg                ; Calculate length of message

section .text
    global _start

_start:
    ; Write message to stdout
    mov rax, 1          ; System call number for sys_write
    mov rdi, 1          ; File descriptor 1 = stdout
    mov rsi, msg        ; Address of message
    mov rdx, len        ; Length of message
    syscall             ; Call the kernel

    ; Exit program
    mov rax, 60         ; System call number for sys_exit
    xor rdi, rdi        ; Exit code 0 (success)
    syscall             ; Call the kernel
```

## Breaking It Down

### Section Declarations

```asm
section .data
```

This declares the data section where we store constants and initialized variables.

```asm
section .text
```

This declares the code section where our instructions live.

### Defining Data

```asm
msg db 'Hello, World!', 10
```

- `msg` - Label (name) for this data
- `db` - "Define Byte" - we're defining byte-sized data
- `'Hello, World!'` - Our string
- `10` - ASCII code for newline (`\n`)

```asm
len equ $ - msg
```

- `len` - Label for the length
- `equ` - "Equate" - defines a constant
- `$` - Current position
- `$ - msg` - Current position minus start of msg = length!

### Entry Point

```asm
global _start
```

Tells the linker that `_start` is the entry point (where execution begins).

```asm
_start:
```

The label where our program starts executing.

### System Call: Write

```asm
mov rax, 1          ; System call number for sys_write
mov rdi, 1          ; File descriptor 1 = stdout
mov rsi, msg        ; Address of message
mov rdx, len        ; Length of message
syscall             ; Call the kernel
```

A **system call** is how we ask the operating system to do something for us (like printing to screen).

On 64-bit Linux, system calls work like this:
- Put system call number in `rax`
- Put arguments in `rdi`, `rsi`, `rdx`, `r10`, `r8`, `r9`
- Execute `syscall` instruction

For `sys_write`:
- `rax = 1` (write system call number)
- `rdi = 1` (stdout file descriptor)
- `rsi = address` (pointer to data)
- `rdx = length` (how many bytes)

### System Call: Exit

```asm
mov rax, 60         ; System call number for sys_exit
xor rdi, rdi        ; Exit code 0
syscall             ; Call the kernel
```

We must exit cleanly! Otherwise the CPU keeps executing whatever's in memory (garbage) and crashes.

- `rax = 60` (exit system call number)
- `rdi = 0` (exit code - 0 means success)

**Note:** `xor rdi, rdi` is a trick to set `rdi` to 0. It's faster than `mov rdi, 0`!

## Building and Running

### Step 1: Assemble

```bash
nasm -f elf64 hello.asm
```

This creates `hello.o` (object file).

- `-f elf64` - Format: ELF 64-bit (Linux)
- `hello.asm` - Input file

### Step 2: Link

```bash
ld hello.o -o hello
```

This creates `hello` (executable).

- `hello.o` - Input object file
- `-o hello` - Output file name

### Step 3: Run

```bash
./hello
```

You should see:
```
Hello, World!
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
msg db 'Hello, World!', 10
```

To:
```asm
msg db 'I am learning assembly!', 10
```

Reassemble and run. Does it work?

### Experiment 2: Multiple Lines

Try:
```asm
msg db 'Line 1', 10, 'Line 2', 10, 'Line 3', 10
```

What happens?

### Experiment 3: Different Exit Code

Change:
```asm
xor rdi, rdi        ; Exit code 0
```

To:
```asm
mov rdi, 42         ; Exit code 42
```

Run and check: `echo $?`

### Experiment 4: Remove the Exit

Comment out the exit code:
```asm
; mov rax, 60
; xor rdi, rdi
; syscall
```

What happens when you run it? (Hint: segmentation fault!)

**Why?** The CPU keeps executing memory, hits invalid instructions, and crashes!

## Exercises

Now try these on your own:

**Exercise 1:** Write a program that prints your name.

**Exercise 2:** Write a program that prints three different messages on three lines.

**Exercise 3:** Modify the program to exit with code 5. Verify with `echo $?`.

**Exercise 4:** Add a second message in the `.data` section and print both messages.

<details>
<summary>Solution to Exercise 4</summary>

```asm
section .data
    msg1 db 'First message', 10
    len1 equ $ - msg1
    msg2 db 'Second message', 10
    len2 equ $ - msg2

section .text
    global _start

_start:
    ; Print first message
    mov rax, 1
    mov rdi, 1
    mov rsi, msg1
    mov rdx, len1
    syscall

    ; Print second message
    mov rax, 1
    mov rdi, 1
    mov rsi, msg2
    mov rdx, len2
    syscall

    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall
```
</details>

## Deep Dive: Registers

You used these registers:

- **RAX** - Accumulator, used for return values and syscall numbers
- **RDI** - First argument to functions/syscalls
- **RSI** - Second argument
- **RDX** - Third argument

These are **general-purpose registers**. We'll learn about all the registers in the next lesson!

## Deep Dive: Why Syscall?

You might wonder: "Why can't I just write to the screen directly?"

In modern operating systems, user programs can't access hardware directly. This is for:
- **Security** - Prevent malicious programs
- **Stability** - Prevent crashes from bad hardware access
- **Abstraction** - Same code works on different hardware

So we ask the **kernel** (operating system core) to do it for us via system calls!

## Common Errors

### Error: "nasm: command not found"
**Solution:** Install NASM. See [setup guide](../../setup.md).

### Error: "cannot find entry symbol _start"
**Solution:** Make sure you have `global _start` in your code.

### Error: "Segmentation fault"
**Solution:** Did you forget to exit cleanly? Add the exit syscall.

### Output appears but with garbage
**Solution:** Check your length calculation. Is `len` correct?

## Key Takeaways

✅ Assembly programs have **sections** (`.data`, `.text`)

✅ Use **system calls** to interact with the OS

✅ Must **exit cleanly** or program will crash

✅ **Registers** hold values temporarily

✅ Assembly is **explicit** - you control everything!

## Next Lesson

Ready for more? Continue to:
**[Lesson 02: Registers and Data →](../02-registers/)**

Or practice more with these programs before moving on!

---

## Quick Reference

**Assemble:**
```bash
nasm -f elf64 program.asm
```

**Link:**
```bash
ld program.o -o program
```

**Run:**
```bash
./program
```

**Check exit code:**
```bash
echo $?
```

**Debug:**
```bash
gdb ./program
(gdb) break _start
(gdb) run
(gdb) stepi
```

---

*Great job completing your first x86 assembly program!* 🎉
