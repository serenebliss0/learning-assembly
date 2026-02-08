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
