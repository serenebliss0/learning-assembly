# monitor.s - Simple RISC-V Monitor/Debugger
# A basic interactive monitor for debugging and system control

.section .data

# === Strings and Messages ===
banner:
    .string "\n=== RISC-V Monitor v1.0 ===\n"
banner_len = . - banner

info:
    .string "Type 'help' for commands, 'quit' to exit\n\n"
info_len = . - info

prompt:
    .string "> "
prompt_len = . - prompt

msg_unknown:
    .string "Unknown command. Type 'help' for list.\n"
msg_unknown_len = . - msg_unknown

msg_invalid_addr:
    .string "Invalid address\n"
msg_invalid_addr_len = . - msg_invalid_addr

msg_invalid_arg:
    .string "Invalid argument\n"
msg_invalid_arg_len = . - msg_invalid_arg

newline:
    .string "\n"

hex_digits:
    .string "0123456789abcdef"

# === Help Messages ===
help_text:
    .string "Available commands:\n"
    .string "  dump <addr> [len]   - Display memory contents (default: 64 bytes)\n"
    .string "  examine <addr>      - Examine single memory location\n"
    .string "  write <addr> <val>  - Write value to memory\n"
    .string "  get <reg>           - Display register value\n"
    .string "  set <reg> <val>     - Set register value\n"
    .string "  regs                - Display all registers\n"
    .string "  run <addr>          - Execute code at address\n"
    .string "  step                - Single-step one instruction\n"
    .string "  help                - Show this help\n"
    .string "  quit                - Exit monitor\n\n"
help_len = . - help_text

# === Buffers ===
.align 4
input_buffer:
    .space 256              # Command input buffer

.align 4
tokens:
    .space 512              # Token pointers (64 tokens × 8 bytes)

token_count:
    .word 0

# === Saved Register State ===
.align 4
saved_registers:
    .space 128              # 32 registers × 4 bytes

saved_pc:
    .word 0

# === Memory Display Buffers ===
line_buffer:
    .space 128              # For formatting output

ascii_buffer:
    .space 17               # 16 chars + null

.section .text
.globl _start

# === Entry Point ===
_start:
    # Setup stack
    la sp, stack_top
    
    # Save initial state
    call save_state
    
    # Print banner
    li a7, 64               # sys_write
    li a0, 1                # stdout
    la a1, banner
    li a2, banner_len
    ecall
    
    # Print info
    li a7, 64
    li a0, 1
    la a1, info
    li a2, info_len
    ecall
    
    # Enter main loop
    j monitor_loop

# === Main Monitor Loop ===
monitor_loop:
    # Print prompt
    li a7, 64
    li a0, 1
    la a1, prompt
    li a2, prompt_len
    ecall
    
    # Read command line
    li a7, 63               # sys_read
    li a0, 0                # stdin
    la a1, input_buffer
    li a2, 255
    ecall
    
    # Check for EOF or error
    blez a0, cmd_quit
    
    # Null-terminate input (replace newline)
    la t0, input_buffer
    add t1, t0, a0
    addi t1, t1, -1
    sb zero, 0(t1)
    
    # Tokenize input
    la a0, input_buffer
    call tokenize
    
    # Empty line?
    la t0, token_count
    lw t1, 0(t0)
    beqz t1, monitor_loop
    
    # Get first token (command)
    la a0, tokens
    lw a0, 0(a0)
    
    # Find and execute command
    call find_command
    beqz a0, cmd_unknown
    
    # Execute command handler
    jalr a0
    
    j monitor_loop

# === Command: Unknown ===
cmd_unknown:
    li a7, 64
    li a0, 1
    la a1, msg_unknown
    li a2, msg_unknown_len
    ecall
    ret

# === Save Register State ===
save_state:
    la t0, saved_registers
    sw x1, 0(t0)
    sw x2, 4(t0)
    sw x3, 8(t0)
    sw x4, 12(t0)
    sw x5, 16(t0)
    sw x6, 20(t0)
    sw x7, 24(t0)
    sw x8, 28(t0)
    sw x9, 32(t0)
    sw x10, 36(t0)
    sw x11, 40(t0)
    sw x12, 44(t0)
    sw x13, 48(t0)
    sw x14, 52(t0)
    sw x15, 56(t0)
    sw x16, 60(t0)
    sw x17, 64(t0)
    sw x18, 68(t0)
    sw x19, 72(t0)
    sw x20, 76(t0)
    sw x21, 80(t0)
    sw x22, 84(t0)
    sw x23, 88(t0)
    sw x24, 92(t0)
    sw x25, 96(t0)
    sw x26, 100(t0)
    sw x27, 104(t0)
    sw x28, 108(t0)
    sw x29, 112(t0)
    sw x30, 116(t0)
    sw x31, 120(t0)
    ret

# === Tokenize Input ===
# Input: a0 = input string
# Output: tokens array filled, token_count set
tokenize:
    addi sp, sp, -16
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    
    mv s0, a0               # s0 = input pointer
    la s1, tokens           # s1 = token array
    li t2, 0                # t2 = token count
    
tokenize_loop:
    # Skip whitespace
skip_space:
    lbu t0, 0(s0)
    beqz t0, tokenize_done
    li t1, ' '
    beq t0, t1, next_space
    li t1, '\t'
    beq t0, t1, next_space
    li t1, '\n'
    beq t0, t1, next_space
    j found_token
    
next_space:
    addi s0, s0, 1
    j skip_space
    
found_token:
    # Save token start
    sw s0, 0(s1)
    addi s1, s1, 4
    addi t2, t2, 1
    
    # Find token end
find_end:
    lbu t0, 0(s0)
    beqz t0, tokenize_done
    li t1, ' '
    beq t0, t1, token_end
    li t1, '\t'
    beq t0, t1, token_end
    li t1, '\n'
    beq t0, t1, token_end
    addi s0, s0, 1
    j find_end
    
token_end:
    # Null-terminate token
    sb zero, 0(s0)
    addi s0, s0, 1
    j tokenize_loop
    
tokenize_done:
    # Save token count
    la t0, token_count
    sw t2, 0(t0)
    
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    addi sp, sp, 16
    ret

# === Find Command Handler ===
# Input: a0 = command string
# Output: a0 = handler address (or 0 if not found)
find_command:
    addi sp, sp, -16
    sw ra, 0(sp)
    sw s0, 4(sp)
    
    mv s0, a0               # Save command string
    
    # Try each command
    la a1, cmd_name_dump
    call strcmp
    beqz a0, found_dump
    
    mv a0, s0
    la a1, cmd_name_examine
    call strcmp
    beqz a0, found_examine
    
    mv a0, s0
    la a1, cmd_name_write
    call strcmp
    beqz a0, found_write
    
    mv a0, s0
    la a1, cmd_name_get
    call strcmp
    beqz a0, found_get
    
    mv a0, s0
    la a1, cmd_name_set
    call strcmp
    beqz a0, found_set
    
    mv a0, s0
    la a1, cmd_name_regs
    call strcmp
    beqz a0, found_regs
    
    mv a0, s0
    la a1, cmd_name_help
    call strcmp
    beqz a0, found_help
    
    mv a0, s0
    la a1, cmd_name_quit
    call strcmp
    beqz a0, found_quit
    
    # Not found
    li a0, 0
    j find_done
    
found_dump:
    la a0, cmd_dump
    j find_done
found_examine:
    la a0, cmd_examine
    j find_done
found_write:
    la a0, cmd_write
    j find_done
found_get:
    la a0, cmd_get
    j find_done
found_set:
    la a0, cmd_set
    j find_done
found_regs:
    la a0, cmd_regs
    j find_done
found_help:
    la a0, cmd_help
    j find_done
found_quit:
    la a0, cmd_quit
    
find_done:
    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 16
    ret

# === String Compare ===
# Input: a0 = str1, a1 = str2
# Output: a0 = 0 if equal, non-zero otherwise
strcmp:
    lbu t0, 0(a0)
    lbu t1, 0(a1)
    bne t0, t1, strcmp_diff
    beqz t0, strcmp_equal
    addi a0, a0, 1
    addi a1, a1, 1
    j strcmp
    
strcmp_equal:
    li a0, 0
    ret
    
strcmp_diff:
    sub a0, t0, t1
    ret

# === Command Names ===
.section .rodata
cmd_name_dump:    .string "dump"
cmd_name_examine: .string "examine"
cmd_name_write:   .string "write"
cmd_name_get:     .string "get"
cmd_name_set:     .string "set"
cmd_name_regs:    .string "regs"
cmd_name_help:    .string "help"
cmd_name_quit:    .string "quit"

.section .text

# === Command: dump ===
# Display memory contents in hex + ASCII
cmd_dump:
    addi sp, sp, -32
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    
    # Check argument count
    la t0, token_count
    lw t0, 0(t0)
    li t1, 2
    blt t0, t1, dump_arg_error
    
    # Parse address (token 1)
    la t0, tokens
    lw a0, 4(t0)
    call parse_hex
    bnez a1, dump_parse_error
    mv s0, a0               # s0 = address
    
    # Parse length (token 2, optional)
    la t0, token_count
    lw t0, 0(t0)
    li t1, 3
    blt t0, t1, dump_default_len
    
    la t0, tokens
    lw a0, 8(t0)
    call parse_hex
    bnez a1, dump_parse_error
    mv s1, a0               # s1 = length
    j dump_start
    
dump_default_len:
    li s1, 64               # Default: 64 bytes
    
dump_start:
    # Display memory
    li s2, 0                # s2 = offset
    
dump_line_loop:
    bge s2, s1, dump_done
    
    # Print address at start of line
    andi t0, s2, 0xf
    bnez t0, dump_skip_addr
    
    add a0, s0, s2
    call print_hex32
    
    li a0, ':'
    call print_char
    li a0, ' '
    call print_char
    
dump_skip_addr:
    # Print byte as hex
    add t0, s0, s2
    lbu a0, 0(t0)
    call print_hex8
    
    li a0, ' '
    call print_char
    
    # Check if end of line
    addi s2, s2, 1
    andi t0, s2, 0xf
    bnez t0, dump_line_loop
    
    # Print ASCII representation
    addi t0, s2, -16
    add a0, s0, t0
    li a1, 16
    call print_ascii
    
    # Print newline
    li a0, '\n'
    call print_char
    
    j dump_line_loop
    
dump_done:
    # Handle partial line
    andi t0, s2, 0xf
    beqz t0, dump_exit
    
    # Print remaining ASCII
    sub t1, s2, t0
    add a0, s0, t1
    mv a1, t0
    call print_ascii
    
    li a0, '\n'
    call print_char
    
dump_exit:
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    addi sp, sp, 32
    ret
    
dump_arg_error:
    li a7, 64
    li a0, 1
    la a1, msg_invalid_arg
    li a2, msg_invalid_arg_len
    ecall
    j dump_exit
    
dump_parse_error:
    li a7, 64
    li a0, 1
    la a1, msg_invalid_addr
    li a2, msg_invalid_addr_len
    ecall
    j dump_exit

# === Command: examine ===
# Examine single memory location
cmd_examine:
    addi sp, sp, -16
    sw ra, 0(sp)
    sw s0, 4(sp)
    
    # Check argument count
    la t0, token_count
    lw t0, 0(t0)
    li t1, 2
    blt t0, t1, examine_error
    
    # Parse address
    la t0, tokens
    lw a0, 4(t0)
    call parse_hex
    bnez a1, examine_error
    mv s0, a0
    
    # Print address
    mv a0, s0
    call print_hex32
    li a0, ':'
    call print_char
    li a0, ' '
    call print_char
    
    # Read and print value
    lw a0, 0(s0)
    call print_hex32
    
    # Print as ASCII if printable
    li a0, ' '
    call print_char
    li a0, '['
    call print_char
    
    lw t0, 0(s0)
    li t1, 4
examine_ascii_loop:
    andi a0, t0, 0xff
    call is_printable
    beqz a0, examine_dot
    andi a0, t0, 0xff
    j examine_print_char
examine_dot:
    li a0, '.'
examine_print_char:
    call print_char
    srli t0, t0, 8
    addi t1, t1, -1
    bnez t1, examine_ascii_loop
    
    li a0, ']'
    call print_char
    li a0, '\n'
    call print_char
    
    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 16
    ret
    
examine_error:
    li a7, 64
    li a0, 1
    la a1, msg_invalid_arg
    li a2, msg_invalid_arg_len
    ecall
    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 16
    ret

# === Command: write ===
# Write value to memory
cmd_write:
    addi sp, sp, -16
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    
    # Check argument count
    la t0, token_count
    lw t0, 0(t0)
    li t1, 3
    blt t0, t1, write_error
    
    # Parse address
    la t0, tokens
    lw a0, 4(t0)
    call parse_hex
    bnez a1, write_error
    mv s0, a0
    
    # Parse value
    la t0, tokens
    lw a0, 8(t0)
    call parse_hex
    bnez a1, write_error
    mv s1, a0
    
    # Write to memory
    sw s1, 0(s0)
    
    # Confirm
    mv a0, s0
    call print_hex32
    li a0, ' '
    call print_char
    li a0, '='
    call print_char
    li a0, ' '
    call print_char
    mv a0, s1
    call print_hex32
    li a0, '\n'
    call print_char
    
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    addi sp, sp, 16
    ret
    
write_error:
    li a7, 64
    li a0, 1
    la a1, msg_invalid_arg
    li a2, msg_invalid_arg_len
    ecall
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    addi sp, sp, 16
    ret

# === Command: get ===
# Display register value (stub - would need saved state)
cmd_get:
    addi sp, sp, -16
    sw ra, 0(sp)
    
    # For now, just print a message
    la a0, msg_not_implemented
    call print_string
    
    lw ra, 0(sp)
    addi sp, sp, 16
    ret

# === Command: set ===
# Set register value (stub)
cmd_set:
    addi sp, sp, -16
    sw ra, 0(sp)
    
    la a0, msg_not_implemented
    call print_string
    
    lw ra, 0(sp)
    addi sp, sp, 16
    ret

# === Command: regs ===
# Display all registers
cmd_regs:
    addi sp, sp, -16
    sw ra, 0(sp)
    
    la a0, msg_not_implemented
    call print_string
    
    lw ra, 0(sp)
    addi sp, sp, 16
    ret

# === Command: help ===
cmd_help:
    li a7, 64
    li a0, 1
    la a1, help_text
    li a2, help_len
    ecall
    ret

# === Command: quit ===
cmd_quit:
    li a7, 93               # sys_exit
    li a0, 0
    ecall

# === Parse Hexadecimal String ===
# Input: a0 = string (e.g., "0x1234" or "1234")
# Output: a0 = number, a1 = 0 if success, -1 if error
parse_hex:
    addi sp, sp, -16
    sw s0, 0(sp)
    sw s1, 4(sp)
    
    mv s0, a0               # s0 = input string
    li s1, 0                # s1 = accumulator
    
    # Skip "0x" prefix if present
    lbu t0, 0(s0)
    li t1, '0'
    bne t0, t1, parse_hex_loop
    lbu t0, 1(s0)
    li t1, 'x'
    bne t0, t1, parse_hex_loop
    addi s0, s0, 2
    
parse_hex_loop:
    lbu t0, 0(s0)
    beqz t0, parse_hex_done
    
    # Convert hex digit to value
    call hex_char_to_value
    bltz a0, parse_hex_error
    
    # Accumulate: result = (result << 4) | digit
    slli s1, s1, 4
    or s1, s1, a0
    
    addi s0, s0, 1
    j parse_hex_loop
    
parse_hex_done:
    mv a0, s1
    li a1, 0                # Success
    lw s0, 0(sp)
    lw s1, 4(sp)
    addi sp, sp, 16
    ret
    
parse_hex_error:
    li a1, -1               # Error
    lw s0, 0(sp)
    lw s1, 4(sp)
    addi sp, sp, 16
    ret

# === Convert Hex Character to Value ===
# Input: t0 = character
# Output: a0 = value (0-15) or -1 if invalid
hex_char_to_value:
    # Check '0'-'9'
    li t1, '0'
    blt t0, t1, hex_invalid
    li t1, '9'
    ble t0, t1, hex_digit
    
    # Check 'a'-'f'
    li t1, 'a'
    blt t0, t1, hex_upper
    li t1, 'f'
    bgt t0, t1, hex_invalid
    addi a0, t0, -'a'
    addi a0, a0, 10
    ret
    
hex_upper:
    # Check 'A'-'F'
    li t1, 'A'
    blt t0, t1, hex_invalid
    li t1, 'F'
    bgt t0, t1, hex_invalid
    addi a0, t0, -'A'
    addi a0, a0, 10
    ret
    
hex_digit:
    addi a0, t0, -'0'
    ret
    
hex_invalid:
    li a0, -1
    ret

# === Print Functions ===

# Print 32-bit hex value
print_hex32:
    addi sp, sp, -16
    sw ra, 0(sp)
    sw s0, 4(sp)
    
    mv s0, a0
    
    # Print "0x"
    li a0, '0'
    call print_char
    li a0, 'x'
    call print_char
    
    # Print 8 hex digits
    li t0, 28               # Start with bits 31:28
print_hex32_loop:
    srl a0, s0, t0
    andi a0, a0, 0xf
    call print_hex_digit
    
    addi t0, t0, -4
    bgez t0, print_hex32_loop
    
    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 16
    ret

# Print 8-bit hex value
print_hex8:
    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)
    
    mv s0, a0
    
    # High nibble
    srli a0, s0, 4
    andi a0, a0, 0xf
    call print_hex_digit
    
    # Low nibble
    andi a0, s0, 0xf
    call print_hex_digit
    
    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 8
    ret

# Print single hex digit (0-15)
print_hex_digit:
    addi sp, sp, -8
    sw ra, 0(sp)
    
    la t0, hex_digits
    add t0, t0, a0
    lbu a0, 0(t0)
    call print_char
    
    lw ra, 0(sp)
    addi sp, sp, 8
    ret

# Print single character
print_char:
    addi sp, sp, -16
    sw ra, 0(sp)
    sw a0, 4(sp)
    
    # Write to buffer
    la t0, line_buffer
    sb a0, 0(t0)
    
    # System call
    li a7, 64               # sys_write
    li a0, 1                # stdout
    la a1, line_buffer
    li a2, 1
    ecall
    
    lw ra, 0(sp)
    lw a0, 4(sp)
    addi sp, sp, 16
    ret

# Print ASCII representation of memory
# Input: a0 = address, a1 = length
print_ascii:
    addi sp, sp, -16
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    
    mv s0, a0               # s0 = address
    mv s1, a1               # s1 = length
    
    # Print separator
    li a0, ' '
    call print_char
    li a0, '|'
    call print_char
    
    # Print characters
    li t0, 0
print_ascii_loop:
    bge t0, s1, print_ascii_done
    
    add t1, s0, t0
    lbu a0, 0(t1)
    call is_printable
    beqz a0, print_ascii_dot
    
    add t1, s0, t0
    lbu a0, 0(t1)
    j print_ascii_char
    
print_ascii_dot:
    li a0, '.'
    
print_ascii_char:
    call print_char
    addi t0, t0, 1
    j print_ascii_loop
    
print_ascii_done:
    li a0, '|'
    call print_char
    
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    addi sp, sp, 16
    ret

# Check if character is printable
# Input: a0 = character
# Output: a0 = 1 if printable, 0 otherwise
is_printable:
    li t0, 0x20
    blt a0, t0, not_printable
    li t0, 0x7e
    bgt a0, t0, not_printable
    li a0, 1
    ret
not_printable:
    li a0, 0
    ret

# Print null-terminated string
print_string:
    addi sp, sp, -16
    sw ra, 0(sp)
    sw s0, 4(sp)
    
    mv s0, a0
    
    # Find string length
    mv t0, a0
    li t1, 0
strlen_loop:
    lbu t2, 0(t0)
    beqz t2, strlen_done
    addi t0, t0, 1
    addi t1, t1, 1
    j strlen_loop
    
strlen_done:
    # Print string
    li a7, 64
    li a0, 1
    mv a1, s0
    mv a2, t1
    ecall
    
    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 16
    ret

# === Additional Messages ===
.section .rodata
msg_not_implemented:
    .string "Command not yet implemented\n"

# === Stack ===
.section .bss
.align 4
stack:
    .space 4096
stack_top:
