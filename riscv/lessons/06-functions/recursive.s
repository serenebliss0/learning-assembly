# recursive.s - Recursive function examples

.section .text
.globl _start

_start:
    # Test recursive factorial(5)
    li a0, 5
    call factorial_rec
    mv s0, a0               # s0 = 120
    
    # Test recursive GCD(48, 18)
    li a0, 48
    li a1, 18
    call gcd
    mv s1, a0               # s1 = 6
    
    # Exit with GCD result
    mv a0, s1
    li a7, 93
    ecall

# Recursive factorial
factorial_rec:
    li t0, 1
    ble a0, t0, fact_base
    
    # Recursive case: n * factorial(n-1)
    addi sp, sp, -8
    sw ra, 4(sp)
    sw a0, 0(sp)
    
    addi a0, a0, -1
    call factorial_rec
    
    lw t0, 0(sp)
    mul a0, a0, t0
    
    lw ra, 4(sp)
    addi sp, sp, 8
    ret

fact_base:
    li a0, 1
    ret

# Recursive GCD (Euclidean algorithm)
# gcd(a, b) = gcd(b, a mod b), base: gcd(a, 0) = a
gcd:
    beqz a1, gcd_base
    
    # Recursive case
    addi sp, sp, -4
    sw ra, 0(sp)
    
    rem t0, a0, a1          # t0 = a mod b
    mv a0, a1               # a = b
    mv a1, t0               # b = a mod b
    call gcd
    
    lw ra, 0(sp)
    addi sp, sp, 4
    ret

gcd_base:
    ret
