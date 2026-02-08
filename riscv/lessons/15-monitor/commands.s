# commands.s - Advanced command parser for RISC-V monitor
# Demonstrates more sophisticated parsing techniques
# REQUIRES: -march=rv32im (uses M extension for division/modulo)

.section .data

# === Command Table ===
# Format: command_name, handler_address, min_args, max_args, help_text
.align 4
command_table:
    .word cmd_str_dump, cmd_handler_dump, 1, 2
    .word cmd_help_dump
    
    .word cmd_str_examine, cmd_handler_examine, 1, 1
    .word cmd_help_examine
    
    .word cmd_str_write, cmd_handler_write, 2, 2
    .word cmd_help_write
    
    .word cmd_str_fill, cmd_handler_fill, 3, 3
    .word cmd_help_fill
    
    .word cmd_str_compare, cmd_handler_compare, 3, 3
    .word cmd_help_compare
    
    .word cmd_str_copy, cmd_handler_copy, 3, 3
    .word cmd_help_copy
    
    .word cmd_str_search, cmd_handler_search, 3, 3
    .word cmd_help_search
    
    .word cmd_str_disasm, cmd_handler_disasm, 1, 2
    .word cmd_help_disasm
    
    .word 0                 # End marker

# === Command Strings ===
cmd_str_dump:       .string "dump"
cmd_str_examine:    .string "examine"
cmd_str_write:      .string "write"
cmd_str_fill:       .string "fill"
cmd_str_compare:    .string "compare"
cmd_str_copy:       .string "copy"
cmd_str_search:     .string "search"
cmd_str_disasm:     .string "disasm"

# === Help Strings ===
cmd_help_dump:
    .string "dump <addr> [len] - Display memory in hex+ASCII (default: 64 bytes)\n"
cmd_help_examine:
    .string "examine <addr> - Examine single location with detail\n"
cmd_help_write:
    .string "write <addr> <value> - Write 32-bit value to memory\n"
cmd_help_fill:
    .string "fill <addr> <len> <value> - Fill memory region with value\n"
cmd_help_compare:
    .string "compare <addr1> <addr2> <len> - Compare two memory regions\n"
cmd_help_copy:
    .string "copy <src> <dst> <len> - Copy memory region\n"
cmd_help_search:
    .string "search <addr> <len> <value> - Search for 32-bit value in memory\n"
cmd_help_disasm:
    .string "disasm <addr> [count] - Disassemble instructions (default: 10)\n"

# === Messages ===
msg_found:      .string "Found at: 0x"
msg_not_found:  .string "Not found\n"
msg_match:      .string "Memory regions match\n"
msg_mismatch:   .string "Mismatch at offset: 0x"
msg_filled:     .string "Filled "
msg_bytes:      .string " bytes\n"
msg_copied:     .string "Copied "

# === Instruction Mnemonics ===
# R-type instructions
mnem_add:   .string "add"
mnem_sub:   .string "sub"
mnem_sll:   .string "sll"
mnem_slt:   .string "slt"
mnem_sltu:  .string "sltu"
mnem_xor:   .string "xor"
mnem_srl:   .string "srl"
mnem_sra:   .string "sra"
mnem_or:    .string "or"
mnem_and:   .string "and"

# I-type instructions
mnem_addi:  .string "addi"
mnem_slti:  .string "slti"
mnem_sltiu: .string "sltiu"
mnem_xori:  .string "xori"
mnem_ori:   .string "ori"
mnem_andi:  .string "andi"
mnem_slli:  .string "slli"
mnem_srli:  .string "srli"
mnem_srai:  .string "srai"

# Load/Store
mnem_lb:    .string "lb"
mnem_lh:    .string "lh"
mnem_lw:    .string "lw"
mnem_lbu:   .string "lbu"
mnem_lhu:   .string "lhu"
mnem_sb:    .string "sb"
mnem_sh:    .string "sh"
mnem_sw:    .string "sw"

# Branch
mnem_beq:   .string "beq"
mnem_bne:   .string "bne"
mnem_blt:   .string "blt"
mnem_bge:   .string "bge"
mnem_bltu:  .string "bltu"
mnem_bgeu:  .string "bgeu"

# Jump
mnem_jal:   .string "jal"
mnem_jalr:  .string "jalr"

# Upper immediate
mnem_lui:   .string "lui"
mnem_auipc: .string "auipc"

# System
mnem_ecall: .string "ecall"
mnem_ebreak: .string "ebreak"

mnem_unknown: .string "???"

# Register names - fixed 5-byte entries for easy lookup
# Each entry is padded to 5 bytes for aligned access
# Index by: reg_names + (register_number * 5)
.align 2
reg_names:
    .string "zero\0"  # x0  (5 bytes: z e r o \0)
    .string "ra\0\0\0"  # x1  (5 bytes: r a \0 \0 \0)
    .string "sp\0\0\0"  # x2
    .string "gp\0\0\0"  # x3
    .string "tp\0\0\0"  # x4
    .string "t0\0\0\0"  # x5
    .string "t1\0\0\0"  # x6
    .string "t2\0\0\0"  # x7
    .string "s0\0\0\0"  # x8
    .string "s1\0\0\0"  # x9
    .string "a0\0\0\0"  # x10
    .string "a1\0\0\0"  # x11
    .string "a2\0\0\0"  # x12
    .string "a3\0\0\0"  # x13
    .string "a4\0\0\0"  # x14
    .string "a5\0\0\0"  # x15
    .string "a6\0\0\0"  # x16
    .string "a7\0\0\0"  # x17
    .string "s2\0\0\0"  # x18
    .string "s3\0\0\0"  # x19
    .string "s4\0\0\0"  # x20
    .string "s5\0\0\0"  # x21
    .string "s6\0\0\0"  # x22
    .string "s7\0\0\0"  # x23
    .string "s8\0\0\0"  # x24
    .string "s9\0\0\0"  # x25
    .string "s10\0\0"  # x26 (4 bytes + \0)
    .string "s11\0\0"  # x27
    .string "t3\0\0\0"  # x28
    .string "t4\0\0\0"  # x29
    .string "t5\0\0\0"  # x30
    .string "t6\0\0\0"  # x31
# To lookup: address = reg_names + (register_num * 5)

.section .text

# === Advanced Command Lookup ===
# Input: a0 = command string, a1 = argc
# Output: a0 = handler address, a1 = 0 if success, -1 if error
lookup_command:
    addi sp, sp, -16
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    
    mv s0, a0               # s0 = command string
    mv s1, a1               # s1 = argc
    
    la t0, command_table
    
lookup_loop:
    lw t1, 0(t0)            # Load command name pointer
    beqz t1, lookup_not_found
    
    # Compare command name
    mv a0, s0
    mv a1, t1
    call strcmp_nocase      # Case-insensitive compare
    bnez a0, lookup_next
    
    # Found! Check argument count
    lw t2, 4(t0)            # Handler address
    lw t3, 8(t0)            # Min args
    lw t4, 12(t0)           # Max args
    
    # Check min args
    blt s1, t3, lookup_args_error
    
    # Check max args
    bgt s1, t4, lookup_args_error
    
    # Success
    mv a0, t2
    li a1, 0
    j lookup_done
    
lookup_next:
    addi t0, t0, 20         # Next entry (5 words)
    j lookup_loop
    
lookup_not_found:
    li a0, 0
    li a1, -1
    j lookup_done
    
lookup_args_error:
    li a0, 0
    li a1, -2
    
lookup_done:
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    addi sp, sp, 16
    ret

# === Case-Insensitive String Compare ===
# Input: a0 = str1, a1 = str2
# Output: a0 = 0 if equal, non-zero otherwise
strcmp_nocase:
    lbu t0, 0(a0)
    lbu t1, 0(a1)
    
    # Convert both to lowercase
    call to_lower_t0
    call to_lower_t1
    
    bne t0, t1, strcmp_nc_diff
    beqz t0, strcmp_nc_equal
    addi a0, a0, 1
    addi a1, a1, 1
    j strcmp_nocase
    
strcmp_nc_equal:
    li a0, 0
    ret
    
strcmp_nc_diff:
    sub a0, t0, t1
    ret

# Convert character to lowercase
to_lower_t0:
    li t2, 'A'
    blt t0, t2, tolower_t0_done
    li t2, 'Z'
    bgt t0, t2, tolower_t0_done
    addi t0, t0, 32
tolower_t0_done:
    ret

to_lower_t1:
    li t2, 'A'
    blt t1, t2, tolower_t1_done
    li t2, 'Z'
    bgt t1, t2, tolower_t1_done
    addi t1, t1, 32
tolower_t1_done:
    ret

# === Command Handler: fill ===
# Fill memory region with value
cmd_handler_fill:
    addi sp, sp, -32
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    
    # Parse address (arg 1)
    la t0, tokens
    lw a0, 4(t0)
    call parse_hex
    bnez a1, fill_error
    mv s0, a0               # s0 = address
    
    # Parse length (arg 2)
    la t0, tokens
    lw a0, 8(t0)
    call parse_hex
    bnez a1, fill_error
    mv s1, a0               # s1 = length
    
    # Parse value (arg 3)
    la t0, tokens
    lw a0, 12(t0)
    call parse_hex
    bnez a1, fill_error
    mv s2, a0               # s2 = value
    
    # Fill memory
    li t0, 0
fill_loop:
    bge t0, s1, fill_done
    add t1, s0, t0
    sb s2, 0(t1)
    addi t0, t0, 1
    j fill_loop
    
fill_done:
    # Print confirmation
    la a0, msg_filled
    call print_string
    
    mv a0, s1
    call print_hex32
    
    la a0, msg_bytes
    call print_string
    
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    addi sp, sp, 32
    ret
    
fill_error:
    la a0, msg_invalid_arg
    call print_string
    j fill_done

# === Command Handler: compare ===
# Compare two memory regions
cmd_handler_compare:
    addi sp, sp, -32
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    
    # Parse addr1 (arg 1)
    la t0, tokens
    lw a0, 4(t0)
    call parse_hex
    bnez a1, compare_error
    mv s0, a0
    
    # Parse addr2 (arg 2)
    la t0, tokens
    lw a0, 8(t0)
    call parse_hex
    bnez a1, compare_error
    mv s1, a0
    
    # Parse length (arg 3)
    la t0, tokens
    lw a0, 12(t0)
    call parse_hex
    bnez a1, compare_error
    mv s2, a0
    
    # Compare memory
    li t0, 0
compare_loop:
    bge t0, s2, compare_match
    
    add t1, s0, t0
    add t2, s1, t0
    lbu t3, 0(t1)
    lbu t4, 0(t2)
    
    bne t3, t4, compare_mismatch
    
    addi t0, t0, 1
    j compare_loop
    
compare_match:
    la a0, msg_match
    call print_string
    j compare_done
    
compare_mismatch:
    la a0, msg_mismatch
    call print_string
    
    mv a0, t0
    call print_hex32
    
    li a0, '\n'
    call print_char
    
compare_done:
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    addi sp, sp, 32
    ret
    
compare_error:
    la a0, msg_invalid_arg
    call print_string
    j compare_done

# === Command Handler: copy ===
# Copy memory region
cmd_handler_copy:
    addi sp, sp, -32
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    
    # Parse src (arg 1)
    la t0, tokens
    lw a0, 4(t0)
    call parse_hex
    bnez a1, copy_error
    mv s0, a0
    
    # Parse dst (arg 2)
    la t0, tokens
    lw a0, 8(t0)
    call parse_hex
    bnez a1, copy_error
    mv s1, a0
    
    # Parse length (arg 3)
    la t0, tokens
    lw a0, 12(t0)
    call parse_hex
    bnez a1, copy_error
    mv s2, a0
    
    # Check for overlap
    add t0, s0, s2          # src_end
    ble t0, s1, no_overlap  # src_end <= dst
    add t0, s1, s2          # dst_end
    ble t0, s0, no_overlap  # dst_end <= src
    
    # Overlapping - copy backwards
    add s0, s0, s2
    add s1, s1, s2
    li t0, 0
copy_back_loop:
    bge t0, s2, copy_done_msg
    addi s0, s0, -1
    addi s1, s1, -1
    lbu t1, 0(s0)
    sb t1, 0(s1)
    addi t0, t0, 1
    j copy_back_loop
    
no_overlap:
    # No overlap - copy forward
    li t0, 0
copy_loop:
    bge t0, s2, copy_done_msg
    add t1, s0, t0
    add t2, s1, t0
    lbu t3, 0(t1)
    sb t3, 0(t2)
    addi t0, t0, 1
    j copy_loop
    
copy_done_msg:
    la a0, msg_copied
    call print_string
    
    mv a0, s2
    call print_hex32
    
    la a0, msg_bytes
    call print_string
    
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    addi sp, sp, 32
    ret
    
copy_error:
    la a0, msg_invalid_arg
    call print_string
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    addi sp, sp, 32
    ret

# === Command Handler: search ===
# Search for value in memory
cmd_handler_search:
    addi sp, sp, -32
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    
    # Parse address (arg 1)
    la t0, tokens
    lw a0, 4(t0)
    call parse_hex
    bnez a1, search_error
    mv s0, a0
    
    # Parse length (arg 2)
    la t0, tokens
    lw a0, 8(t0)
    call parse_hex
    bnez a1, search_error
    mv s1, a0
    
    # Parse value (arg 3) - required
    la t0, token_count
    lw t0, 0(t0)
    li t1, 4
    blt t0, t1, search_error
    
    la t0, tokens
    lw a0, 12(t0)
    call parse_hex
    bnez a1, search_error
    mv s2, a0               # s2 = search value
    
    # Search memory
    li t0, 0
search_loop:
    bge t0, s1, search_not_found
    
    add t1, s0, t0
    lw t2, 0(t1)
    beq t2, s2, search_found
    
    addi t0, t0, 1
    j search_loop
    
search_found:
    la a0, msg_found
    call print_string
    
    add a0, s0, t0
    call print_hex32
    
    li a0, '\n'
    call print_char
    j search_done
    
search_not_found:
    la a0, msg_not_found
    call print_string
    
search_done:
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    addi sp, sp, 32
    ret
    
search_error:
    la a0, msg_invalid_arg
    call print_string
    j search_done

# === Command Handler: disasm ===
# Disassemble instructions
cmd_handler_disasm:
    addi sp, sp, -32
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    
    # Parse address (arg 1)
    la t0, tokens
    lw a0, 4(t0)
    call parse_hex
    bnez a1, disasm_error
    mv s0, a0
    
    # Parse count (arg 2, optional)
    la t0, token_count
    lw t0, 0(t0)
    li t1, 3
    blt t0, t1, disasm_default_count
    
    la t0, tokens
    lw a0, 8(t0)
    call parse_hex
    bnez a1, disasm_error
    mv s1, a0
    j disasm_start
    
disasm_default_count:
    li s1, 10               # Default: 10 instructions
    
disasm_start:
    li t0, 0
disasm_loop:
    bge t0, s1, disasm_done
    
    # Print address
    add a0, s0, t0
    call print_hex32
    
    li a0, ':'
    call print_char
    li a0, ' '
    call print_char
    
    # Load instruction
    add t1, s0, t0
    lw a0, 0(t1)
    
    # Print hex
    call print_hex32
    
    li a0, ' '
    call print_char
    li a0, ' '
    call print_char
    
    # Disassemble
    add t1, s0, t0
    lw a0, 0(t1)
    call disassemble_inst
    
    li a0, '\n'
    call print_char
    
    addi t0, t0, 4
    j disasm_loop
    
disasm_done:
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    addi sp, sp, 32
    ret
    
disasm_error:
    la a0, msg_invalid_arg
    call print_string
    j disasm_done

# === Disassemble Single Instruction ===
# Input: a0 = instruction word
disassemble_inst:
    addi sp, sp, -16
    sw ra, 0(sp)
    sw s0, 4(sp)
    
    mv s0, a0               # s0 = instruction
    
    # Extract opcode (bits 6:0)
    andi t0, s0, 0x7f
    
    # Check opcode type
    li t1, 0x33             # R-type (ALU)
    beq t0, t1, disasm_r_type
    
    li t1, 0x13             # I-type (ALU immediate)
    beq t0, t1, disasm_i_type
    
    li t1, 0x03             # I-type (load)
    beq t0, t1, disasm_load
    
    li t1, 0x23             # S-type (store)
    beq t0, t1, disasm_store
    
    li t1, 0x63             # B-type (branch)
    beq t0, t1, disasm_branch
    
    li t1, 0x6f             # J-type (jal)
    beq t0, t1, disasm_jal
    
    li t1, 0x67             # I-type (jalr)
    beq t0, t1, disasm_jalr
    
    li t1, 0x37             # U-type (lui)
    beq t0, t1, disasm_lui
    
    li t1, 0x17             # U-type (auipc)
    beq t0, t1, disasm_auipc
    
    li t1, 0x73             # System
    beq t0, t1, disasm_system
    
    # Unknown instruction
    la a0, mnem_unknown
    call print_string
    j disasm_inst_done
    
disasm_r_type:
    # Extract funct3 and funct7
    srli t1, s0, 12
    andi t1, t1, 0x7        # funct3
    
    srli t2, s0, 25
    andi t2, t2, 0x7f       # funct7
    
    # Determine instruction
    # (Simplified - would need full decode)
    la a0, mnem_add
    call print_string
    j disasm_r_operands
    
disasm_i_type:
    # Extract funct3
    srli t1, s0, 12
    andi t1, t1, 0x7
    
    la a0, mnem_addi
    call print_string
    j disasm_i_operands
    
disasm_load:
    la a0, mnem_lw
    call print_string
    j disasm_i_operands
    
disasm_store:
    la a0, mnem_sw
    call print_string
    j disasm_s_operands
    
disasm_branch:
    la a0, mnem_beq
    call print_string
    j disasm_b_operands
    
disasm_jal:
    la a0, mnem_jal
    call print_string
    j disasm_j_operands
    
disasm_jalr:
    la a0, mnem_jalr
    call print_string
    j disasm_i_operands
    
disasm_lui:
    la a0, mnem_lui
    call print_string
    j disasm_u_operands
    
disasm_auipc:
    la a0, mnem_auipc
    call print_string
    j disasm_u_operands
    
disasm_system:
    # Check if ecall or ebreak
    li t0, 0x73
    beq s0, t0, disasm_ecall
    
    li t0, 0x100073
    beq s0, t0, disasm_ebreak
    
    la a0, mnem_unknown
    call print_string
    j disasm_inst_done
    
disasm_ecall:
    la a0, mnem_ecall
    call print_string
    j disasm_inst_done
    
disasm_ebreak:
    la a0, mnem_ebreak
    call print_string
    j disasm_inst_done
    
disasm_r_operands:
    # Format: rd, rs1, rs2
    li a0, ' '
    call print_char
    
    # rd (bits 11:7)
    srli a0, s0, 7
    andi a0, a0, 0x1f
    call print_reg_name
    
    li a0, ','
    call print_char
    li a0, ' '
    call print_char
    
    # rs1 (bits 19:15)
    srli a0, s0, 15
    andi a0, a0, 0x1f
    call print_reg_name
    
    li a0, ','
    call print_char
    li a0, ' '
    call print_char
    
    # rs2 (bits 24:20)
    srli a0, s0, 20
    andi a0, a0, 0x1f
    call print_reg_name
    
    j disasm_inst_done
    
disasm_i_operands:
    # Format: rd, rs1, imm
    li a0, ' '
    call print_char
    
    # rd
    srli a0, s0, 7
    andi a0, a0, 0x1f
    call print_reg_name
    
    li a0, ','
    call print_char
    li a0, ' '
    call print_char
    
    # rs1
    srli a0, s0, 15
    andi a0, a0, 0x1f
    call print_reg_name
    
    li a0, ','
    call print_char
    li a0, ' '
    call print_char
    
    # imm (bits 31:20)
    srli a0, s0, 20
    # Sign extend
    slli a0, a0, 20
    srai a0, a0, 20
    call print_decimal
    
    j disasm_inst_done
    
disasm_s_operands:
    # Format: rs2, imm(rs1)
    # (Simplified)
    j disasm_inst_done
    
disasm_b_operands:
    # Format: rs1, rs2, offset
    # (Simplified)
    j disasm_inst_done
    
disasm_j_operands:
    # Format: rd, offset
    # (Simplified)
    j disasm_inst_done
    
disasm_u_operands:
    # Format: rd, imm
    li a0, ' '
    call print_char
    
    # rd
    srli a0, s0, 7
    andi a0, a0, 0x1f
    call print_reg_name
    
    li a0, ','
    call print_char
    li a0, ' '
    call print_char
    
    # imm (bits 31:12)
    srli a0, s0, 12
    call print_hex32
    
    j disasm_inst_done
    
disasm_inst_done:
    lw ra, 0(sp)
    lw s0, 4(sp)
    addi sp, sp, 16
    ret

# === Print Register Name ===
# Input: a0 = register number (0-31)
print_reg_name:
    addi sp, sp, -8
    sw ra, 0(sp)
    
    # For simplicity, just print "x<n>"
    li t0, 'x'
    mv t1, a0
    
    la t2, line_buffer
    sb t0, 0(t2)
    
    # Convert number to decimal
    li t3, 10
    divu t4, t1, t3
    remu t5, t1, t3
    
    beqz t4, single_digit
    
    addi t4, t4, '0'
    sb t4, 1(t2)
    addi t5, t5, '0'
    sb t5, 2(t2)
    sb zero, 3(t2)
    j print_reg_done
    
single_digit:
    addi t5, t5, '0'
    sb t5, 1(t2)
    sb zero, 2(t2)
    
print_reg_done:
    la a0, line_buffer
    call print_string
    
    lw ra, 0(sp)
    addi sp, sp, 8
    ret

# === Print Decimal Number ===
# Input: a0 = number (signed)
print_decimal:
    addi sp, sp, -8
    sw ra, 0(sp)
    
    # For now, just print as hex
    call print_hex32
    
    lw ra, 0(sp)
    addi sp, sp, 8
    ret

# === Required External Functions ===
# These would be defined in monitor.s or utility.s
.extern print_string
.extern print_char
.extern print_hex32
.extern parse_hex
.extern msg_invalid_arg
.extern tokens
.extern token_count
.extern line_buffer
