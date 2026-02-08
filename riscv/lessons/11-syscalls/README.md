# Lesson 11: System Calls and I/O - Talking to the Kernel

Welcome to one of the most practical lessons in assembly programming! System calls are your gateway to interacting with the operating system - reading files, writing to the screen, opening network connections, and much more.

## Learning Objectives

By the end of this lesson, you'll:
- Understand what system calls are and why they're necessary
- Master the RISC-V Linux syscall calling convention
- Perform file I/O operations (open, read, write, close)
- Handle standard streams (stdin, stdout, stderr)
- Implement proper error handling for syscalls
- Work with file descriptors
- Understand syscall numbers and their meanings

## What are System Calls?

**System calls** (syscalls) are the interface between user programs and the operating system kernel. They allow your program to:
- Read and write files
- Allocate memory
- Create processes
- Communicate over networks
- Access hardware devices

Think of syscalls as the "API" of the operating system. Your program runs in **user mode** with limited privileges, but syscalls allow you to request services from the kernel running in **privileged mode**.

### Why Can't We Just Access Hardware Directly?

Modern operating systems use **protection rings** to prevent programs from:
1. Crashing the system
2. Accessing other programs' memory
3. Breaking security boundaries
4. Corrupting hardware state

System calls provide a **safe, controlled interface** to these protected resources.

## RISC-V Linux Syscall Convention

In RISC-V Linux, syscalls follow this convention:

1. **Syscall number** goes in register `a7`
2. **Arguments** go in registers `a0` through `a5` (up to 6 arguments)
3. Execute the `ecall` instruction
4. **Return value** comes back in `a0` (typically -1 on error)
5. **Error code** is in `a0` as a negative errno value

### Common Syscall Numbers (RISC-V Linux)

| Syscall | Number | Arguments | Description |
|---------|--------|-----------|-------------|
| read | 63 | fd, buf, count | Read from file descriptor |
| write | 64 | fd, buf, count | Write to file descriptor |
| open | 56 | filename, flags, mode | Open/create a file |
| openat | 56 | dirfd, filename, flags, mode | Open file relative to directory |
| close | 57 | fd | Close file descriptor |
| exit | 93 | status | Terminate process |
| brk | 214 | addr | Change data segment size |
| lseek | 62 | fd, offset, whence | Reposition file offset |
| fstat | 80 | fd, statbuf | Get file status |
| unlink | 35 | pathname | Delete a file |

**Note:** RISC-V uses different syscall numbers than x86! Always check the architecture-specific syscall table.

## Standard File Descriptors

Every process starts with three open file descriptors:

| FD | Name | Description |
|----|------|-------------|
| 0 | stdin | Standard input (keyboard) |
| 1 | stdout | Standard output (screen) |
| 2 | stderr | Standard error (screen, unbuffered) |

These are already open and ready to use - no need to call `open`!

## The Code: Basic System Calls

Create a file called `syscalls.s`:

```asm
# syscalls.s - Demonstrating Linux system calls on RISC-V
# Shows read, write, open, close operations

.section .data
prompt:
    .string "Enter your name: "
prompt_len = . - prompt

hello_msg:
    .string "Hello, "
hello_len = . - hello_msg

newline:
    .string "!\n"
newline_len = . - newline

input_buffer:
    .space 64              # Buffer for user input

file_msg:
    .string "Writing to file...\n"
file_msg_len = . - file_msg

filename:
    .string "output.txt"

file_content:
    .string "Hello from RISC-V assembly!\n"
file_content_len = . - file_content

success_msg:
    .string "File written successfully!\n"
success_len = . - success_msg

error_msg:
    .string "Error occurred!\n"
error_len = . - error_msg

.section .text
.globl _start

_start:
    # === Write prompt to stdout ===
    # write(1, prompt, prompt_len)
    li a7, 64              # syscall: write
    li a0, 1               # fd: stdout
    la a1, prompt          # buffer address
    li a2, prompt_len      # buffer length
    ecall                  # make the syscall
    
    # === Read from stdin ===
    # read(0, input_buffer, 64)
    li a7, 63              # syscall: read
    li a0, 0               # fd: stdin
    la a1, input_buffer    # buffer address
    li a2, 64              # max bytes to read
    ecall                  # make the syscall
    
    # Save the number of bytes read
    mv t0, a0              # t0 = bytes read
    
    # === Write "Hello, " to stdout ===
    li a7, 64              # syscall: write
    li a0, 1               # fd: stdout
    la a1, hello_msg       # buffer address
    li a2, hello_len       # buffer length
    ecall
    
    # === Write user's input to stdout ===
    li a7, 64              # syscall: write
    li a0, 1               # fd: stdout
    la a1, input_buffer    # buffer address
    mv a2, t0              # bytes to write (from read)
    ecall
    
    # === Write newline ===
    li a7, 64              # syscall: write
    li a0, 1               # fd: stdout
    la a1, newline         # buffer address
    li a2, newline_len     # buffer length
    ecall
    
    # === File operations demonstration ===
    # Write message about file operation
    li a7, 64              # syscall: write
    li a0, 1               # fd: stdout
    la a1, file_msg
    li a2, file_msg_len
    ecall
    
    # === Open file for writing ===
    # open(filename, O_WRONLY | O_CREAT | O_TRUNC, 0644)
    li a7, 56              # syscall: openat (used for open in modern Linux)
    li a0, -100            # AT_FDCWD (current directory)
    la a1, filename        # filename
    li a2, 0x241           # O_WRONLY (0x01) | O_CREAT (0x40) | O_TRUNC (0x200)
    li a3, 0644            # mode: rw-r--r--
    ecall
    
    # Check for error
    li t1, 0
    blt a0, t1, error      # if fd < 0, error occurred
    
    # Save file descriptor
    mv s0, a0              # s0 = file descriptor
    
    # === Write to file ===
    # write(fd, file_content, file_content_len)
    li a7, 64              # syscall: write
    mv a0, s0              # fd: our opened file
    la a1, file_content    # buffer address
    li a2, file_content_len # buffer length
    ecall
    
    # Check for error
    li t1, 0
    blt a0, t1, error      # if return < 0, error occurred
    
    # === Close file ===
    # close(fd)
    li a7, 57              # syscall: close
    mv a0, s0              # fd to close
    ecall
    
    # === Write success message ===
    li a7, 64              # syscall: write
    li a0, 1               # fd: stdout
    la a1, success_msg
    li a2, success_len
    ecall
    
    # === Exit successfully ===
    li a7, 93              # syscall: exit
    li a0, 0               # status: 0 (success)
    ecall

error:
    # === Write error message ===
    li a7, 64              # syscall: write
    li a0, 2               # fd: stderr
    la a1, error_msg
    li a2, error_len
    ecall
    
    # === Exit with error ===
    li a7, 93              # syscall: exit
    li a0, 1               # status: 1 (error)
    ecall
```

## Breaking It Down

### The Write Syscall

```asm
li a7, 64              # syscall number for write
li a0, 1               # file descriptor (1 = stdout)
la a1, prompt          # pointer to data
li a2, prompt_len      # number of bytes to write
ecall                  # invoke the syscall
```

The `write` syscall takes three arguments:
1. **fd** (a0): File descriptor to write to
2. **buf** (a1): Pointer to data buffer
3. **count** (a2): Number of bytes to write

Returns: Number of bytes written (or -errno on error)

### The Read Syscall

```asm
li a7, 63              # syscall number for read
li a0, 0               # file descriptor (0 = stdin)
la a1, input_buffer    # buffer to read into
li a2, 64              # maximum bytes to read
ecall                  # invoke the syscall
mv t0, a0              # save bytes read
```

The `read` syscall takes three arguments:
1. **fd** (a0): File descriptor to read from
2. **buf** (a1): Pointer to buffer to store data
3. **count** (a2): Maximum bytes to read

Returns: Number of bytes read (0 = EOF, -errno on error)

### The Openat Syscall

```asm
li a7, 56              # syscall: openat
li a0, -100            # AT_FDCWD (current directory)
la a1, filename        # path to file
li a2, 0x241           # flags: O_WRONLY | O_CREAT | O_TRUNC
li a3, 0644            # mode: permissions (octal)
ecall
```

**Flags** (can be combined with OR):
- `O_RDONLY` (0x00): Read only
- `O_WRONLY` (0x01): Write only
- `O_RDWR` (0x02): Read and write
- `O_CREAT` (0x40): Create if doesn't exist
- `O_TRUNC` (0x200): Truncate to zero length
- `O_APPEND` (0x400): Append to end

**Mode** (permissions in octal):
- First digit: user permissions
- Second digit: group permissions
- Third digit: other permissions
- Each digit: 4=read, 2=write, 1=execute

Returns: File descriptor (or -errno on error)

### Error Handling

```asm
li t1, 0
blt a0, t1, error      # if return value < 0, error occurred
```

System calls return negative errno values on error. Common errno values:
- `-1` (EPERM): Operation not permitted
- `-2` (ENOENT): No such file or directory
- `-9` (EBADF): Bad file descriptor
- `-13` (EACCES): Permission denied
- `-22` (EINVAL): Invalid argument

## The Code: File I/O Operations

Create a file called `fileio.s`:

```asm
# fileio.s - Comprehensive file I/O operations
# Demonstrates file creation, reading, writing, and seeking

.section .data
# File to create and write to
out_filename:
    .string "testfile.txt"

# File to read from
in_filename:
    .string "testfile.txt"

# Data to write
write_data:
    .string "Line 1: Hello from RISC-V!\n"
    .string "Line 2: System calls are powerful!\n"
    .string "Line 3: File I/O in assembly!\n"
write_len = . - write_data

# Buffer for reading
read_buffer:
    .space 256

# Messages
create_msg:
    .string "Creating and writing file...\n"
create_msg_len = . - create_msg

read_msg:
    .string "\nReading file back:\n"
read_msg_len = . - read_msg

separator:
    .string "---\n"
sep_len = . - separator

seek_msg:
    .string "\nSeeking and reading partial:\n"
seek_msg_len = . - seek_msg

done_msg:
    .string "\nAll operations completed!\n"
done_msg_len = . - done_msg

error_open_msg:
    .string "Error: Could not open file\n"
error_open_len = . - error_open_msg

error_write_msg:
    .string "Error: Could not write to file\n"
error_write_len = . - error_write_msg

error_read_msg:
    .string "Error: Could not read file\n"
error_read_len = . - error_read_msg

.section .text
.globl _start

_start:
    # === Part 1: Create and write file ===
    # Print status message
    li a7, 64
    li a0, 1
    la a1, create_msg
    li a2, create_msg_len
    ecall
    
    # Open file for writing (create if doesn't exist, truncate)
    li a7, 56              # openat
    li a0, -100            # AT_FDCWD
    la a1, out_filename
    li a2, 0x241           # O_WRONLY | O_CREAT | O_TRUNC
    li a3, 0644            # rw-r--r--
    ecall
    
    # Check for error
    bltz a0, error_open
    mv s0, a0              # s0 = output file descriptor
    
    # Write data to file
    li a7, 64              # write
    mv a0, s0
    la a1, write_data
    li a2, write_len
    ecall
    
    # Check for error
    bltz a0, error_write
    
    # Close output file
    li a7, 57              # close
    mv a0, s0
    ecall
    
    # === Part 2: Read entire file ===
    # Print status message
    li a7, 64
    li a0, 1
    la a1, read_msg
    li a2, read_msg_len
    ecall
    
    # Print separator
    li a7, 64
    li a0, 1
    la a1, separator
    li a2, sep_len
    ecall
    
    # Open file for reading
    li a7, 56              # openat
    li a0, -100            # AT_FDCWD
    la a1, in_filename
    li a2, 0               # O_RDONLY
    li a3, 0
    ecall
    
    # Check for error
    bltz a0, error_open
    mv s1, a0              # s1 = input file descriptor
    
    # Read from file
    li a7, 63              # read
    mv a0, s1
    la a1, read_buffer
    li a2, 256             # max bytes to read
    ecall
    
    # Check for error
    bltz a0, error_read
    mv s2, a0              # s2 = bytes read
    
    # Write read data to stdout
    li a7, 64              # write
    li a0, 1               # stdout
    la a1, read_buffer
    mv a2, s2              # bytes to write
    ecall
    
    # Print separator
    li a7, 64
    li a0, 1
    la a1, separator
    li a2, sep_len
    ecall
    
    # === Part 3: Seek and read partial ===
    # Print status message
    li a7, 64
    li a0, 1
    la a1, seek_msg
    li a2, seek_msg_len
    ecall
    
    # Seek to position 10
    li a7, 62              # lseek
    mv a0, s1              # fd
    li a1, 10              # offset
    li a2, 0               # SEEK_SET (from beginning)
    ecall
    
    # Read 30 bytes from new position
    li a7, 63              # read
    mv a0, s1
    la a1, read_buffer
    li a2, 30
    ecall
    
    # Check for error
    bltz a0, error_read
    mv s2, a0              # bytes read
    
    # Write to stdout
    li a7, 64
    li a0, 1
    la a1, read_buffer
    mv a2, s2
    ecall
    
    # Print newline
    li a7, 64
    li a0, 1
    la a1, separator
    li a2, sep_len
    ecall
    
    # Close input file
    li a7, 57              # close
    mv a0, s1
    ecall
    
    # === Success! ===
    li a7, 64
    li a0, 1
    la a1, done_msg
    li a2, done_msg_len
    ecall
    
    # Exit
    li a7, 93
    li a0, 0
    ecall

# Error handlers
error_open:
    li a7, 64
    li a0, 2               # stderr
    la a1, error_open_msg
    li a2, error_open_len
    ecall
    li a7, 93
    li a0, 1
    ecall

error_write:
    li a7, 64
    li a0, 2
    la a1, error_write_msg
    li a2, error_write_len
    ecall
    # Close file before exiting
    li a7, 57
    mv a0, s0
    ecall
    li a7, 93
    li a0, 2
    ecall

error_read:
    li a7, 64
    li a0, 2
    la a1, error_read_msg
    li a2, error_read_len
    ecall
    # Close file before exiting
    li a7, 57
    mv a0, s1
    ecall
    li a7, 93
    li a0, 3
    ecall
```

## Building and Running

### Compile and Link

```bash
# Compile syscalls.s
riscv64-linux-gnu-as -march=rv32i -mabi=ilp32 -o syscalls.o syscalls.s
riscv64-linux-gnu-ld -m elf32lriscv -o syscalls syscalls.o

# Compile fileio.s
riscv64-linux-gnu-as -march=rv32i -mabi=ilp32 -o fileio.o fileio.s
riscv64-linux-gnu-ld -m elf32lriscv -o fileio fileio.o
```

### Run with QEMU

```bash
# Run syscalls example
qemu-riscv32 ./syscalls
# Enter your name when prompted

# Run fileio example
qemu-riscv32 ./fileio

# Check the created file
cat testfile.txt
cat output.txt
```

### Expected Output

**syscalls:**
```
Enter your name: Alice
Hello, Alice!
Writing to file...
File written successfully!
```

**fileio:**
```
Creating and writing file...

Reading file back:
---
Line 1: Hello from RISC-V!
Line 2: System calls are powerful!
Line 3: File I/O in assembly!
---

Seeking and reading partial:
llo from RISC-V!
Line 2: Sys
---

All operations completed!
```

## Experiments to Try

### 1. **Echo Program**
Create a program that reads from stdin and echoes to stdout until EOF (Ctrl+D):

```asm
loop:
    li a7, 63
    li a0, 0
    la a1, buffer
    li a2, 64
    ecall
    
    beqz a0, done          # if bytes read == 0, EOF
    
    mv t0, a0              # save bytes read
    
    li a7, 64
    li a0, 1
    la a1, buffer
    mv a2, t0
    ecall
    
    j loop

done:
    # exit...
```

### 2. **File Copy**
Write a program that copies one file to another. Handle errors properly!

### 3. **Read from stderr**
Try reading from file descriptor 2. What happens? Why?

### 4. **Large File Handling**
Modify fileio.s to handle files larger than your buffer by reading in chunks.

### 5. **Append Mode**
Modify the file operations to append to a file instead of truncating it.

## Deep Dive: The ecall Instruction

The `ecall` instruction is fascinating:

1. **Triggers an exception** - specifically an "environment call" exception
2. **Switches to supervisor/machine mode** - depending on current privilege level
3. **Jumps to trap handler** - OS kernel takes control
4. **Kernel examines registers** - reads a7 to determine which syscall
5. **Executes syscall** - kernel performs the requested operation
6. **Returns to user code** - via an `sret` or `mret` instruction

This context switch is **expensive** (hundreds of CPU cycles), which is why:
- Libraries buffer I/O (stdio.h's buffering)
- Batching operations is better than many small syscalls
- Some operations use memory mapping (mmap) instead

## Deep Dive: File Descriptors

A file descriptor is just an **integer index** into the process's file descriptor table:

```
Process File Descriptor Table:
[0] -> stdin  -> Terminal input
[1] -> stdout -> Terminal output
[2] -> stderr -> Terminal error
[3] -> (your opened file)
[4] -> (another opened file)
...
```

When you call `open`, the kernel:
1. Creates an entry in the file descriptor table
2. Returns the smallest available FD number
3. Stores file state (position, flags, etc.) in kernel memory

When you call `close`:
1. Kernel frees the resources
2. FD number becomes available for reuse

**Important:** Always close files! Each process has a limit on open FDs (typically 1024).

## Common Mistakes

### 1. **Wrong Syscall Number**
```asm
# WRONG - This is x86-64's write syscall number!
li a7, 1               # x86-64 write is 1, RISC-V is 64!
```

Always use RISC-V syscall numbers. They're different from x86!

### 2. **Forgetting to Close Files**
```asm
# WRONG - File never closed!
li a7, 56
la a1, filename
# ... open file ...
mv s0, a0
# ... use file ...
# exit without closing!
```

Always close file descriptors when done.

### 3. **Not Checking Return Values**
```asm
# WRONG - Ignoring errors!
li a7, 56
la a1, filename
ecall
# Just assuming it worked...
mv s0, a0
```

Always check if a0 < 0 after syscalls!

### 4. **Buffer Overflow**
```asm
buffer: .space 10      # Only 10 bytes!

# WRONG - Reading 100 bytes into 10-byte buffer!
li a7, 63
li a0, 0
la a1, buffer
li a2, 100             # OVERFLOW!
ecall
```

Ensure buffer is large enough for read operation.

### 5. **Wrong Flag Combinations**
```asm
# WRONG - Can't be read-only AND write-only!
li a2, 0x01            # O_WRONLY
ori a2, a2, 0x00       # O_RDONLY
```

Understand file open flags before combining them.

## Complete Syscall Reference (RISC-V Linux)

### File Operations
| Syscall | Number | Prototype |
|---------|--------|-----------|
| read | 63 | `ssize_t read(int fd, void *buf, size_t count)` |
| write | 64 | `ssize_t write(int fd, const void *buf, size_t count)` |
| openat | 56 | `int openat(int dirfd, const char *pathname, int flags, mode_t mode)` |
| close | 57 | `int close(int fd)` |
| lseek | 62 | `off_t lseek(int fd, off_t offset, int whence)` |
| fstat | 80 | `int fstat(int fd, struct stat *statbuf)` |

### Process Operations
| Syscall | Number | Prototype |
|---------|--------|-----------|
| exit | 93 | `void exit(int status)` |
| exit_group | 94 | `void exit_group(int status)` |
| getpid | 172 | `pid_t getpid(void)` |
| getppid | 173 | `pid_t getppid(void)` |
| clone | 220 | `long clone(...)` (complex) |

### Memory Operations
| Syscall | Number | Prototype |
|---------|--------|-----------|
| brk | 214 | `int brk(void *addr)` |
| mmap | 222 | `void *mmap(void *addr, size_t length, ...)` |
| munmap | 215 | `int munmap(void *addr, size_t length)` |

### Time Operations
| Syscall | Number | Prototype |
|---------|--------|-----------|
| nanosleep | 101 | `int nanosleep(const struct timespec *req, ...)` |
| clock_gettime | 113 | `int clock_gettime(clockid_t clk_id, struct timespec *tp)` |

## Exercises

### Exercise 1: Character Counter
Write a program that reads from stdin and counts the number of characters, words, and lines (like `wc`).

**Solution:**
```asm
.section .data
buffer: .space 4096
char_count: .word 0
word_count: .word 0
line_count: .word 0
in_word: .byte 0

.section .text
.globl _start

_start:
read_loop:
    # Read chunk
    li a7, 63
    li a0, 0
    la a1, buffer
    li a2, 4096
    ecall
    
    beqz a0, print_results
    bltz a0, error
    
    # Process each character
    mv t0, a0              # bytes read
    la t1, buffer          # buffer pointer
    la t2, char_count
    lw t3, 0(t2)           # load char_count
    
process_char:
    beqz t0, read_loop
    
    lbu t4, 0(t1)          # load character
    addi t3, t3, 1         # char_count++
    
    # Check for newline
    li t5, '\n'
    bne t4, t5, check_space
    la t6, line_count
    lw t5, 0(t6)
    addi t5, t5, 1
    sw t5, 0(t6)
    
check_space:
    # Check if space/tab/newline
    li t5, ' '
    beq t4, t5, is_space
    li t5, '\t'
    beq t4, t5, is_space
    li t5, '\n'
    beq t4, t5, is_space
    
    # Not a space - check if starting new word
    la t6, in_word
    lbu t5, 0(t6)
    bnez t5, next_char     # already in word
    
    # Starting new word
    li t5, 1
    sb t5, 0(t6)
    la t6, word_count
    lw t5, 0(t6)
    addi t5, t5, 1
    sw t5, 0(t6)
    j next_char
    
is_space:
    # Mark not in word
    la t6, in_word
    sb zero, 0(t6)
    
next_char:
    addi t1, t1, 1
    addi t0, t0, -1
    j process_char

print_results:
    # Save char_count back
    la t2, char_count
    sw t3, 0(t2)
    
    # Print results (implementation left as exercise)
    # Convert numbers to strings and print
    
    li a7, 93
    li a0, 0
    ecall

error:
    li a7, 93
    li a0, 1
    ecall
```

### Exercise 2: Simple Cat
Implement a simple version of `cat` that displays file contents. Take filename from command line args (advanced!).

### Exercise 3: File Comparison
Write a program that compares two files byte-by-byte and reports if they're identical.

## Key Takeaways

1. **System calls are your interface to the OS** - they let you do I/O, manage processes, and more
2. **RISC-V uses a7 for syscall number** - load it before `ecall`
3. **Arguments go in a0-a5** - up to 6 arguments
4. **Return value in a0** - negative values indicate errors
5. **Always check for errors** - syscalls can fail!
6. **Close your file descriptors** - don't leak resources
7. **Standard FDs (0,1,2)** - stdin, stdout, stderr are pre-opened
8. **Buffer carefully** - prevent overflows
9. **File descriptors are just integers** - indexes into kernel table
10. **ecall is expensive** - batch operations when possible

## Additional Resources

- [RISC-V Linux Syscall Table](https://github.com/westerndigitalcorporation/RISC-V-Linux/blob/master/linux/arch/riscv/include/uapi/asm/unistd.h)
- [Linux System Call Reference](https://man7.org/linux/man-pages/man2/syscalls.2.html)
- [RISC-V Privileged Specification](https://riscv.org/technical/specifications/)
- [Understanding File Descriptors](https://www.bottomupcs.com/file_descriptors.xhtml)

## What's Next?

In **Lesson 12: RISC-V Extensions**, we'll explore the powerful extensions to the base ISA including:
- **M Extension**: Hardware multiplication and division
- **A Extension**: Atomic operations for multi-threading
- **F/D Extensions**: Floating-point arithmetic
- **C Extension**: Compressed 16-bit instructions

These extensions add significant capabilities while maintaining RISC-V's clean design!

---

**Practice makes perfect!** System calls are fundamental to real-world programming. Experiment with different syscalls, handle errors gracefully, and build your intuition for when to use them. Next, we'll level up with powerful ISA extensions! 🚀
