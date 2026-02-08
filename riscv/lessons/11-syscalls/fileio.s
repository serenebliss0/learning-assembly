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
