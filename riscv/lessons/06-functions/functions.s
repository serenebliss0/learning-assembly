# functions.s - RISC-V function call demonstrations
# Shows calling conventions, stack frames, and recursion

.section .text
.globl _start

_start:
    # Test 1: Call factorial(5)
    li a0, 5
    call factorial
    mv s0, a0               # Save result (should be 120)
    
    # Test 2: Call fibonacci(10)
    li a0, 10
    call fibonacci
    mv s1, a0               # Save result
    
    # Test 3: Call max3(15, 42, 28)
    li a0, 15
    li a1, 42
    li a2, 28
    call max3
    mv s2, a0               # Save result (should be 42)
    
    # Exit with factorial result
    mv a0, s0
    li a7, 93
    ecall

# Function: factorial (iterative)
# Input: a0 = n
# Output: a0 = n!
factorial:
    li t1, 1                # result = 1
    li t0, 1                # counter = 1

fact_loop:
    bgt t0, a0, fact_done
    mul t1, t1, t0          # result *= counter
    addi t0, t0, 1
    j fact_loop

fact_done:
    mv a0, t1
    ret

# Function: fibonacci (iterative)
# Input: a0 = n
# Output: a0 = fib(n)
fibonacci:
    beqz a0, fib_zero
    li t1, 1
    beq a0, t1, fib_one
    
    li t0, 0                # fib(i-2)
    li t1, 1                # fib(i-1)
    li t3, 2                # counter

fib_loop:
    bgt t3, a0, fib_done
    add t2, t0, t1          # fib(i) = fib(i-1) + fib(i-2)
    mv t0, t1
    mv t1, t2
    addi t3, t3, 1
    j fib_loop

fib_done:
    mv a0, t1
    ret

fib_zero:
    li a0, 0
    ret

fib_one:
    li a0, 1
    ret

# Function: max3
# Input: a0, a1, a2 = three numbers
# Output: a0 = maximum
max3:
    bge a0, a1, check_a0_vs_a2
    mv a0, a1

check_a0_vs_a2:
    bge a0, a2, max3_done
    mv a0, a2

max3_done:
    ret
