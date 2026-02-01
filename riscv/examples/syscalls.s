# RISC-V System Call Examples
# Demonstrates various Linux RISC-V system calls

.data
str1:       .string "Hello, World!\n"
str2:       .string "Enter your name: "
str3:       .string "Hello, "
str4:       .string "!\n"
filename:   .string "test.txt"
file_content: .string "This is test content\n"
buffer:     .space 64
newline:    .string "\n"

.text
.globl main

main:
    # ========================================
    # Example 1: Print string (write syscall)
    # ========================================
    # syscall number 64: write(fd, buf, count)
    # a0 = file descriptor (1 = stdout)
    # a1 = buffer address
    # a2 = count (bytes to write)
    
    li a0, 1              # stdout
    la a1, str1           # string address
    li a2, 14             # length
    li a7, 64             # write syscall
    ecall
    
    # ========================================
    # Example 2: Read string (read syscall)
    # ========================================
    # syscall number 63: read(fd, buf, count)
    
    # Print prompt
    li a0, 1
    la a1, str2
    li a2, 17
    li a7, 64
    ecall
    
    # Read input
    li a0, 0              # stdin
    la a1, buffer         # buffer address
    li a2, 64             # max bytes
    li a7, 63             # read syscall
    ecall
    
    mv s0, a0             # Save bytes read
    
    # Echo back
    li a0, 1
    la a1, str3
    li a2, 7
    li a7, 64
    ecall
    
    li a0, 1
    la a1, buffer
    mv a2, s0
    li a7, 64
    ecall
    
    # ========================================
    # Example 3: Open file
    # ========================================
    # syscall number 1024: openat(dirfd, pathname, flags, mode)
    # flags: O_CREAT | O_WRONLY = 0x41
    # mode: 0644 = 0x1A4
    
    li a0, -100           # AT_FDCWD (current directory)
    la a1, filename       # filename
    li a2, 0x241          # O_CREAT | O_WRONLY | O_TRUNC
    li a3, 0x1A4          # mode 0644
    li a7, 56             # openat syscall
    ecall
    
    mv s1, a0             # Save file descriptor
    
    # ========================================
    # Example 4: Write to file
    # ========================================
    mv a0, s1             # file descriptor
    la a1, file_content   # content to write
    li a2, 21             # length
    li a7, 64             # write syscall
    ecall
    
    # ========================================
    # Example 5: Close file
    # ========================================
    # syscall number 57: close(fd)
    
    mv a0, s1             # file descriptor
    li a7, 57             # close syscall
    ecall
    
    # ========================================
    # Example 6: Get current time
    # ========================================
    # syscall number 169: gettimeofday(tv, tz)
    
    addi sp, sp, -16      # Allocate space for timeval struct
    mv a0, sp             # timeval pointer
    li a1, 0              # timezone (NULL)
    li a7, 169            # gettimeofday syscall
    ecall
    
    # Print seconds
    lw a0, 0(sp)
    li a7, 1              # print_int
    ecall
    
    la a0, newline
    li a7, 4
    ecall
    
    addi sp, sp, 16       # Clean up stack
    
    # ========================================
    # Example 7: Exit program
    # ========================================
    # syscall number 93: exit(status)
    
    li a0, 0              # exit code 0
    li a7, 93             # exit syscall
    ecall

# ========================================
# Additional System Call Examples
# ========================================

# brk - allocate memory
example_brk:
    li a0, 0              # Get current break
    li a7, 214            # brk syscall
    ecall
    
    mv s0, a0             # Save current break
    addi a0, a0, 1024     # Request 1KB more
    li a7, 214
    ecall
    ret

# getpid - get process ID
example_getpid:
    li a7, 172            # getpid syscall
    ecall
    # a0 now contains PID
    ret

# sleep - sleep for seconds
example_sleep:
    # Create timespec struct on stack
    addi sp, sp, -16
    li t0, 2              # 2 seconds
    sw t0, 0(sp)          # tv_sec
    sw zero, 4(sp)        # tv_nsec
    sw zero, 8(sp)        # remainder (optional)
    
    mv a0, sp             # timespec pointer
    addi a1, sp, 8        # remainder pointer
    li a7, 101            # nanosleep syscall
    ecall
    
    addi sp, sp, 16
    ret

# ========================================
# RISC-V Linux System Call Numbers
# ========================================
# Common syscalls:
# 
# File I/O:
#   56  openat(dirfd, pathname, flags, mode)
#   57  close(fd)
#   63  read(fd, buf, count)
#   64  write(fd, buf, count)
#   62  lseek(fd, offset, whence)
#   80  fstat(fd, statbuf)
#
# Process:
#   93  exit(status)
#   172 getpid()
#   174 getuid()
#   220 clone() - create process/thread
#
# Memory:
#   214 brk(addr)
#   222 mmap(addr, length, prot, flags, fd, offset)
#   215 munmap(addr, length)
#
# Time:
#   169 gettimeofday(tv, tz)
#   101 nanosleep(req, rem)
#
# See: /usr/include/asm-generic/unistd.h
