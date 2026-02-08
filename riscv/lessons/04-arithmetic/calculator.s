# calculator.s - Simple calculator using M extension (multiply/divide)
# Demonstrates MUL, DIV, REM operations
# Assemble with: riscv64-unknown-elf-as -march=rv32im -mabi=ilp32 calculator.s -o calculator.o

.section .data
num1:   .word 42
num2:   .word 17
sum:    .word 0
diff:   .word 0
prod:   .word 0
quot:   .word 0
remain: .word 0

.section .text
.globl _start

_start:
    # Load numbers from memory
    la t0, num1
    lw a0, 0(t0)            # a0 = 42
    la t0, num2
    lw a1, 0(t0)            # a1 = 17
    
    # Addition: 42 + 17 = 59
    add t1, a0, a1
    la t0, sum
    sw t1, 0(t0)
    
    # Subtraction: 42 - 17 = 25
    sub t1, a0, a1
    la t0, diff
    sw t1, 0(t0)
    
    # Multiplication: 42 * 17 = 714 (requires M extension)
    mul t1, a0, a1
    la t0, prod
    sw t1, 0(t0)
    
    # Division: 42 / 17 = 2 (requires M extension)
    div t1, a0, a1
    la t0, quot
    sw t1, 0(t0)
    
    # Remainder: 42 % 17 = 8 (requires M extension)
    rem t1, a0, a1
    la t0, remain
    sw t1, 0(t0)
    
    # Exit
    li a0, 0
    li a7, 93
    ecall
