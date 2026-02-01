# RISC-V Mini Emulator
# A simple emulator for a subset of RISC-V instructions

.data
# Register file (32 registers)
registers:    .space 128

# Simulated memory (16KB for simplicity)
memory:       .space 16384

# Program counter
pc:           .word 0

# Messages
reg_msg:      .string "Register x"
eq_msg:       .string " = "
newline:      .string "\n"
exec_msg:     .string "Executing instruction: 0x"

# Test program (hardcoded instructions)
# addi x1, x0, 5    -> 0x00500093
# addi x2, x0, 10   -> 0x00A00113
# add  x3, x1, x2   -> 0x002081B3
# sub  x4, x2, x1   -> 0x40110233
test_program:
    .word 0x00500093
    .word 0x00A00113
    .word 0x002081B3
    .word 0x40110233
    .word 0x00000000  # halt (all zeros)

.text
.globl main

main:
    # Initialize: Load test program into memory
    jal ra, load_test_program
    
    # Reset PC to start of memory
    la t0, pc
    sw zero, 0(t0)
    
    # Emulation loop
emulation_loop:
    # Fetch instruction
    jal ra, fetch_instruction
    mv s0, a0             # s0 = current instruction
    
    # Check for halt (0x00000000)
    beqz s0, emulation_done
    
    # Print instruction
    la a0, exec_msg
    jal ra, print_string
    mv a0, s0
    jal ra, print_hex
    la a0, newline
    jal ra, print_string
    
    # Decode and execute
    mv a0, s0
    jal ra, decode_and_execute
    
    # Continue loop
    j emulation_loop
    
emulation_done:
    # Print final register state
    la a0, newline
    jal ra, print_string
    jal ra, print_registers
    
    # Exit
    li a7, 10
    ecall

# ========================================
# Emulator Functions
# ========================================

# Load test program into memory
load_test_program:
    la t0, test_program
    la t1, memory
    li t2, 5              # 5 words to copy
    
load_loop:
    beqz t2, load_done
    lw t3, 0(t0)
    sw t3, 0(t1)
    addi t0, t0, 4
    addi t1, t1, 4
    addi t2, t2, -1
    j load_loop
    
load_done:
    ret

# Fetch instruction from memory
fetch_instruction:
    la t0, pc
    lw t1, 0(t0)          # t1 = PC
    
    la t2, memory
    add t3, t2, t1
    lw a0, 0(t3)          # Load instruction
    
    # Increment PC
    addi t1, t1, 4
    sw t1, 0(t0)
    
    ret

# Decode and execute instruction
decode_and_execute:
    mv t6, a0             # Save instruction
    
    # Extract opcode (bits 6:0)
    andi t0, a0, 0x7F
    
    # Check opcode
    li t1, 0x13           # I-type (addi, etc.)
    beq t0, t1, execute_i_type
    
    li t1, 0x33           # R-type (add, sub, etc.)
    beq t0, t1, execute_r_type
    
    # Unknown opcode - skip
    ret

execute_i_type:
    # Extract fields
    srli t1, t6, 7
    andi t1, t1, 0x1F     # rd
    
    srli t2, t6, 15
    andi t2, t2, 0x1F     # rs1
    
    srli t3, t6, 20       # immediate (12 bits)
    
    # Sign extend immediate
    li t4, 0x800
    and t5, t3, t4
    beqz t5, imm_positive
    ori t3, t3, 0xFFFFF000  # Sign extend
imm_positive:
    
    # Get rs1 value
    jal ra, read_register
    mv t4, a0             # t4 = registers[rs1]
    
    # Perform operation (addi)
    add t5, t4, t3        # result = rs1 + imm
    
    # Write to rd
    mv a0, t1             # rd
    mv a1, t5             # value
    jal ra, write_register
    
    ret

execute_r_type:
    # Extract fields
    srli t1, t6, 7
    andi t1, t1, 0x1F     # rd
    
    srli t2, t6, 15
    andi t2, t2, 0x1F     # rs1
    
    srli t3, t6, 20
    andi t3, t3, 0x1F     # rs2
    
    srli t4, t6, 25       # funct7
    srli t5, t6, 12
    andi t5, t5, 0x7      # funct3
    
    # Read rs1 and rs2
    mv a0, t2
    jal ra, read_register
    mv s1, a0             # s1 = registers[rs1]
    
    mv a0, t3
    jal ra, read_register
    mv s2, a0             # s2 = registers[rs2]
    
    # Check funct7 and funct3 for operation
    # funct3=0, funct7=0 -> ADD
    # funct3=0, funct7=32 -> SUB
    
    beqz t5, r_type_func0
    j execute_r_done
    
r_type_func0:
    beqz t4, do_add
    li t0, 0x20
    beq t4, t0, do_sub
    j execute_r_done
    
do_add:
    add s3, s1, s2
    j store_r_result
    
do_sub:
    sub s3, s1, s2
    j store_r_result
    
store_r_result:
    mv a0, t1             # rd
    mv a1, s3             # result
    jal ra, write_register
    
execute_r_done:
    ret

# Read register value
# Input: a0 = register number
# Output: a0 = value
read_register:
    beqz a0, read_x0      # x0 is always 0
    
    la t0, registers
    slli t1, a0, 2
    add t2, t0, t1
    lw a0, 0(t2)
    ret
    
read_x0:
    li a0, 0
    ret

# Write register value
# Input: a0 = register number, a1 = value
write_register:
    beqz a0, write_done   # Can't write to x0
    
    la t0, registers
    slli t1, a0, 2
    add t2, t0, t1
    sw a1, 0(t2)
    
write_done:
    ret

# ========================================
# Helper Functions
# ========================================

print_registers:
    addi sp, sp, -8
    sw ra, 0(sp)
    sw s0, 4(sp)
    
    li s0, 1              # Start from x1 (skip x0)
    
print_reg_loop:
    li t0, 32
    bge s0, t0, print_reg_done
    
    # Print "Register xN = "
    la a0, reg_msg
    jal ra, print_string
    
    mv a0, s0
    jal ra, print_int
    
    la a0, eq_msg
    jal ra, print_string
    
    # Read and print register value
    mv a0, s0
    jal ra, read_register
    jal ra, print_int
    
    la a0, newline
    jal ra, print_string
    
    addi s0, s0, 1
    j print_reg_loop
    
print_reg_done:
    lw s0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 8
    ret

print_string:
    li a7, 4
    ecall
    ret

print_int:
    li a7, 1
    ecall
    ret

print_hex:
    li a7, 34
    ecall
    ret
