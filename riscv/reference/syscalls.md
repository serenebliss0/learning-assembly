# RISC-V Linux System Calls

Reference for RISC-V Linux system calls (syscalls).

## How System Calls Work

System calls are the interface between user programs and the operating system kernel.

### Syscall Convention

1. **Load syscall number** into `a7`
2. **Load arguments** into `a0-a6` (up to 7 arguments)
3. **Execute** `ecall` instruction
4. **Result** returned in `a0` (and `a1` for some calls)
5. **Error**: `a0` contains negative error code

### Basic Example

```assembly
# write(1, "Hello\n", 6)
li a0, 1              # fd = stdout
la a1, message        # buf = address of string
li a2, 6              # count = 6 bytes
li a7, 64             # syscall number for write
ecall                 # invoke syscall
# a0 now contains bytes written or negative error
```

## Common System Calls

### File I/O

#### write (64)
Write to a file descriptor.

```assembly
# ssize_t write(int fd, const void *buf, size_t count)
li a0, 1              # fd (1 = stdout)
la a1, buffer         # buf
li a2, length         # count
li a7, 64
ecall
# Returns: bytes written or -errno
```

**File Descriptors:**
- 0 = stdin
- 1 = stdout
- 2 = stderr

#### read (63)
Read from a file descriptor.

```assembly
# ssize_t read(int fd, void *buf, size_t count)
li a0, 0              # fd (0 = stdin)
la a1, buffer         # buf
li a2, 100            # count (max bytes)
li a7, 63
ecall
# Returns: bytes read, 0 for EOF, or -errno
```

#### openat (56)
Open a file.

```assembly
# int openat(int dirfd, const char *pathname, int flags, mode_t mode)
li a0, -100           # dirfd (AT_FDCWD = current dir)
la a1, filename       # pathname
li a2, 0x241          # flags (O_CREAT | O_WRONLY | O_TRUNC)
li a3, 0x1A4          # mode (0644)
li a7, 56
ecall
# Returns: file descriptor or -errno
```

**Common flags:**
- O_RDONLY = 0
- O_WRONLY = 1
- O_RDWR = 2
- O_CREAT = 0x40
- O_TRUNC = 0x200
- O_APPEND = 0x400

#### close (57)
Close a file descriptor.

```assembly
# int close(int fd)
mv a0, s0             # fd to close
li a7, 57
ecall
# Returns: 0 on success, -errno on error
```

#### lseek (62)
Reposition file offset.

```assembly
# off_t lseek(int fd, off_t offset, int whence)
mv a0, s0             # fd
li a1, 0              # offset
li a2, 0              # whence (SEEK_SET)
li a7, 62
ecall
# Returns: new offset or -errno
```

**whence values:**
- SEEK_SET = 0 (from beginning)
- SEEK_CUR = 1 (from current)
- SEEK_END = 2 (from end)

### Process Management

#### exit (93)
Terminate the calling process.

```assembly
# void exit(int status)
li a0, 0              # exit status
li a7, 93
ecall
# Does not return
```

#### getpid (172)
Get process ID.

```assembly
# pid_t getpid(void)
li a7, 172
ecall
# Returns: PID in a0
```

#### getuid (174)
Get user ID.

```assembly
# uid_t getuid(void)
li a7, 174
ecall
# Returns: UID in a0
```

#### fork (220 - clone)
Create a child process.

```assembly
# pid_t fork(void)
# Implemented via clone syscall
li a0, 0x11           # SIGCHLD
li a1, 0              # NULL stack
li a7, 220            # clone
ecall
# Returns: 0 in child, child PID in parent, or -errno
```

#### execve (221)
Execute a program.

```assembly
# int execve(const char *pathname, char *const argv[], char *const envp[])
la a0, program        # pathname
la a1, argv_array     # argv
la a2, envp_array     # envp
li a7, 221
ecall
# Returns: -errno (only on error; doesn't return on success)
```

### Memory Management

#### brk (214)
Change data segment size.

```assembly
# int brk(void *addr)
li a0, 0              # Get current break
li a7, 214
ecall
# Returns: new break value

# Allocate 1024 bytes
mv t0, a0             # Save current break
addi a0, a0, 1024     # Request new break
li a7, 214
ecall
# t0 now points to allocated memory
```

#### mmap (222)
Map memory.

```assembly
# void *mmap(void *addr, size_t length, int prot, int flags, int fd, off_t offset)
li a0, 0              # addr (NULL = kernel chooses)
li a1, 4096           # length (4KB)
li a2, 3              # prot (PROT_READ | PROT_WRITE)
li a3, 0x22           # flags (MAP_PRIVATE | MAP_ANONYMOUS)
li a4, -1             # fd (-1 for anonymous)
li a5, 0              # offset
li a7, 222
ecall
# Returns: address or -errno
```

**Protection flags (prot):**
- PROT_READ = 1
- PROT_WRITE = 2
- PROT_EXEC = 4

**Mapping flags:**
- MAP_SHARED = 0x01
- MAP_PRIVATE = 0x02
- MAP_ANONYMOUS = 0x20

#### munmap (215)
Unmap memory.

```assembly
# int munmap(void *addr, size_t length)
mv a0, s0             # addr
li a1, 4096           # length
li a7, 215
ecall
# Returns: 0 on success, -errno on error
```

### Time

#### gettimeofday (169)
Get current time.

```assembly
# int gettimeofday(struct timeval *tv, struct timezone *tz)
addi sp, sp, -16      # Allocate space
mv a0, sp             # tv
li a1, 0              # tz (NULL)
li a7, 169
ecall
# tv->tv_sec at 0(sp), tv->tv_usec at 4(sp)
lw t0, 0(sp)          # seconds
lw t1, 4(sp)          # microseconds
addi sp, sp, 16
```

#### clock_gettime (113)
Get time from specific clock.

```assembly
# int clock_gettime(clockid_t clk_id, struct timespec *tp)
li a0, 0              # CLOCK_REALTIME
addi sp, sp, -16
mv a1, sp             # tp
li a7, 113
ecall
lw t0, 0(sp)          # tv_sec
lw t1, 4(sp)          # tv_nsec
addi sp, sp, 16
```

#### nanosleep (101)
Sleep for specified time.

```assembly
# int nanosleep(const struct timespec *req, struct timespec *rem)
addi sp, sp, -16
li t0, 2              # 2 seconds
sw t0, 0(sp)          # tv_sec
sw zero, 4(sp)        # tv_nsec
mv a0, sp             # req
li a1, 0              # rem (NULL)
li a7, 101
ecall
addi sp, sp, 16
```

### File System

#### stat (80) / fstat (80)
Get file status.

```assembly
# int fstat(int fd, struct stat *statbuf)
mv a0, s0             # fd
la a1, stat_buffer    # statbuf
li a7, 80
ecall
# Returns: 0 on success, -errno on error
```

#### unlinkat (35)
Delete a file.

```assembly
# int unlinkat(int dirfd, const char *pathname, int flags)
li a0, -100           # AT_FDCWD
la a1, filename       # pathname
li a2, 0              # flags
li a7, 35
ecall
```

#### mkdirat (34)
Create a directory.

```assembly
# int mkdirat(int dirfd, const char *pathname, mode_t mode)
li a0, -100           # AT_FDCWD
la a1, dirname        # pathname
li a2, 0x1ED          # mode (0755)
li a7, 34
ecall
```

### Network (Sockets)

#### socket (198)
Create a socket.

```assembly
# int socket(int domain, int type, int protocol)
li a0, 2              # AF_INET
li a1, 1              # SOCK_STREAM
li a2, 0              # protocol (0 = default)
li a7, 198
ecall
# Returns: socket fd or -errno
```

#### bind (200)
Bind socket to address.

```assembly
# int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen)
mv a0, s0             # sockfd
la a1, sockaddr       # addr
li a2, 16             # addrlen
li a7, 200
ecall
```

#### listen (201)
Listen for connections.

```assembly
# int listen(int sockfd, int backlog)
mv a0, s0             # sockfd
li a1, 5              # backlog
li a7, 201
ecall
```

#### accept (202)
Accept a connection.

```assembly
# int accept(int sockfd, struct sockaddr *addr, socklen_t *addrlen)
mv a0, s0             # sockfd
la a1, client_addr    # addr
la a2, addrlen        # addrlen
li a7, 202
ecall
# Returns: new socket fd or -errno
```

## Complete Syscall Number Reference

| Number | Name | Arguments |
|--------|------|-----------|
| 35 | unlinkat | dirfd, pathname, flags |
| 34 | mkdirat | dirfd, pathname, mode |
| 56 | openat | dirfd, pathname, flags, mode |
| 57 | close | fd |
| 62 | lseek | fd, offset, whence |
| 63 | read | fd, buf, count |
| 64 | write | fd, buf, count |
| 78 | readlinkat | dirfd, pathname, buf, bufsiz |
| 79 | fstatat | dirfd, pathname, statbuf, flags |
| 80 | fstat | fd, statbuf |
| 93 | exit | status |
| 94 | exit_group | status |
| 101 | nanosleep | req, rem |
| 113 | clock_gettime | clk_id, tp |
| 169 | gettimeofday | tv, tz |
| 172 | getpid | - |
| 173 | getppid | - |
| 174 | getuid | - |
| 175 | geteuid | - |
| 176 | getgid | - |
| 177 | getegid | - |
| 198 | socket | domain, type, protocol |
| 200 | bind | sockfd, addr, addrlen |
| 201 | listen | sockfd, backlog |
| 202 | accept | sockfd, addr, addrlen |
| 203 | connect | sockfd, addr, addrlen |
| 214 | brk | addr |
| 215 | munmap | addr, length |
| 220 | clone | flags, stack, ptid, tls, ctid |
| 221 | execve | pathname, argv, envp |
| 222 | mmap | addr, length, prot, flags, fd, offset |
| 260 | wait4 | pid, wstatus, options, rusage |
| 261 | prlimit64 | pid, resource, new_limit, old_limit |

**Note**: RISC-V uses the "generic" syscall numbers. See `/usr/include/asm-generic/unistd.h` for complete list.

## Error Handling

System calls return negative error codes on failure:

```assembly
li a7, 56             # openat
ecall
bltz a0, error_handler # If negative, error occurred

# Get positive error number
neg a0, a0            # a0 = -a0

# Common errors:
# EACCES = 13
# EEXIST = 17
# ENOENT = 2
# ENOMEM = 12
```

## Complete Example

```assembly
.data
filename: .string "output.txt"
content:  .string "Hello from RISC-V!\n"
.equ content_len, 19

.text
.globl main

main:
    # Open file
    li a0, -100           # AT_FDCWD
    la a1, filename
    li a2, 0x241          # O_CREAT | O_WRONLY | O_TRUNC
    li a3, 0x1A4          # 0644
    li a7, 56
    ecall
    bltz a0, error        # Check for error
    mv s0, a0             # Save fd
    
    # Write content
    mv a0, s0
    la a1, content
    li a2, content_len
    li a7, 64
    ecall
    bltz a0, error
    
    # Close file
    mv a0, s0
    li a7, 57
    ecall
    
    # Exit success
    li a0, 0
    li a7, 93
    ecall

error:
    # Exit with error code
    li a0, 1
    li a7, 93
    ecall
```

## Resources

- [Linux syscall table](https://marcin.juszkiewicz.com.pl/download/tables/syscalls.html)
- [RISC-V syscall ABI](https://github.com/riscv/riscv-elf-psabi-doc)
- [Example: System Calls](../examples/syscalls.s)

---

*System calls are your gateway to OS services. Master them to build real applications!*
