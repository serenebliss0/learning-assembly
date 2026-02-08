# registers.s - Exploring RISC-V registers
# This program demonstrates register operations

.section .data
result_msg:
    .string "Register operations complete!\n"

.section .text
.globl _start

_start:
    # === Zero Register ===
    # x0 always reads as 0
    addi x5, x0, 100       # x5 = 0 + 100 = 100
    add x6, x0, x0         # x6 = 0 + 0 = 0
    
    # Writing to x0 does nothing
    addi x0, x5, 50        # x0 is still 0!
    
    # === Using Temporary Registers ===
    # t0-t6 are for temporary values
    li t0, 42              # t0 = 42
    li t1, 58              # t1 = 58
    add t2, t0, t1         # t2 = 42 + 58 = 100
    
    # === Register Arithmetic ===
    li a0, 10              # a0 = 10
    li a1, 20              # a1 = 20
    add a2, a0, a1         # a2 = 10 + 20 = 30
    sub a3, a1, a0         # a3 = 20 - 10 = 10
    
    # === Bitwise Operations ===
    li t0, 0b11110000      # t0 = 0xF0 (240)
    li t1, 0b00111100      # t1 = 0x3C (60)
    
    and t2, t0, t1         # t2 = 0xF0 & 0x3C = 0x30
    or  t3, t0, t1         # t3 = 0xF0 | 0x3C = 0xFC
    xor t4, t0, t1         # t4 = 0xF0 ^ 0x3C = 0xCC
    
    # === Shift Operations ===
    li t0, 8               # t0 = 8 (binary: 1000)
    slli t1, t0, 2         # t1 = 8 << 2 = 32 (shift left logical)
    srli t2, t0, 1         # t2 = 8 >> 1 = 4 (shift right logical)
    
    li t0, -8              # t0 = -8 (0xFFFFFFF8)
    srai t3, t0, 1         # t3 = -8 >> 1 = -4 (arithmetic shift)
    
    # === Comparison and Set Operations ===
    li t0, 10
    li t1, 20
    
    slt t2, t0, t1         # t2 = (10 < 20) = 1 (true)
    slt t3, t1, t0         # t3 = (20 < 10) = 0 (false)
    
    sltu t4, t0, t1        # Unsigned comparison
    
    # === Immediate Operations ===
    # Most instructions have immediate variants
    li t0, 100
    addi t1, t0, 50        # t1 = 100 + 50 = 150
    andi t2, t0, 0xFF      # t2 = 100 & 255 = 100
    ori t3, t0, 0x0F       # t3 = 100 | 15 = 111
    xori t4, t0, 0xFF      # t4 = 100 ^ 255 = 155
    slti t5, t0, 150       # t5 = (100 < 150) = 1
    
    # === Loading Upper Immediate ===
    # LUI loads 20-bit immediate into upper 20 bits
    lui t0, 0x12345        # t0 = 0x12345000
    
    # AUIPC adds upper immediate to PC
    auipc t1, 0            # t1 = current PC value
    
    # === Pseudo-Instructions ===
    # These expand to multiple instructions
    
    # li (load immediate) - expands to lui + addi
    li t0, 0x12345678      # Load large constant
    
    # mv (move) - expands to addi rd, rs, 0
    li t0, 42
    mv t1, t0              # t1 = t0 (really: addi t1, t0, 0)
    
    # not - expands to xori rd, rs, -1
    li t0, 0b10101010
    not t1, t0             # t1 = ~t0 (bitwise NOT)
    
    # neg - expands to sub rd, x0, rs
    li t0, 42
    neg t1, t0             # t1 = -t0 (really: sub t1, x0, t0)
    
    # === Register Usage Best Practices ===
    # Use saved registers (s0-s11) for values that must survive function calls
    li s0, 100             # Saved across function calls
    li s1, 200
    
    # Use temporary registers (t0-t6) for scratch calculations
    li t0, 10              # Not preserved across calls
    li t1, 20
    
    # Use argument registers (a0-a7) for function parameters
    li a0, 42              # First argument
    li a1, 58              # Second argument
    
    # Print success message
    li a0, 1               # stdout
    la a1, result_msg      # message address
    li a2, 31              # message length
    li a7, 64              # write syscall
    ecall
    
    # Exit
    li a0, 0
    li a7, 93
    ecall
