# Project 1: Command-Line Calculator 🧮

## Overview

Build a command-line calculator that can perform basic arithmetic operations. This project will help you practice:
- String to integer conversion
- Arithmetic operations
- Function calls and stack management
- Error handling
- User input processing

## Features

Your calculator should support:
- **Addition** (`+`)
- **Subtraction** (`-`)
- **Multiplication** (`*`)
- **Division** (`/`)
- **Modulo** (`%`)

## Input Format

The calculator should read expressions in the format:
```
<number1> <operator> <number2>
```

Example:
```
15 + 27
42
```

## Requirements

### Core Requirements
1. Read two integers and an operator from the user
2. Perform the requested operation
3. Display the result
4. Handle division by zero gracefully
5. Support negative numbers

### Bonus Features
- Support for multiple operations in sequence
- Parentheses support
- Floating-point operations (using F extension)
- Expression evaluation with operator precedence

## Implementation Guide

### Step 1: Parse Input

Create functions to:
- Read a line of input
- Parse numbers (convert ASCII to integer)
- Identify the operator

```assembly
# Function: read_integer
# Input: none (reads from stdin)
# Output: a0 = integer value
# Clobbers: a1, a2, t0-t6

read_integer:
    # Your implementation here
    ret
```

### Step 2: Implement Operations

Create a function for each operation:

```assembly
# Function: add
# Input: a0 = first number, a1 = second number
# Output: a0 = result
# Clobbers: none

add:
    add a0, a0, a1
    ret

# Function: subtract
# Input: a0 = first number, a1 = second number
# Output: a0 = result

subtract:
    sub a0, a0, a1
    ret

# Similar functions for mul, div, mod
```

### Step 3: Main Calculator Loop

```assembly
main:
    # 1. Read first number
    # 2. Read operator
    # 3. Read second number
    # 4. Call appropriate function
    # 5. Print result
    # 6. Loop or exit
```

### Step 4: Error Handling

Handle edge cases:
- Division by zero
- Integer overflow
- Invalid operators
- Non-numeric input

## Testing

Test your calculator with:

1. **Basic operations:**
   ```
   5 + 3 = 8
   10 - 4 = 6
   6 * 7 = 42
   20 / 4 = 5
   17 % 5 = 2
   ```

2. **Negative numbers:**
   ```
   -5 + 3 = -2
   -10 - 4 = -14
   -6 * 7 = -42
   ```

3. **Edge cases:**
   ```
   10 / 0 = ERROR
   0 / 5 = 0
   0 * 100 = 0
   ```

## Provided Code

A basic implementation is provided in `calculator.s`. You can:
- Use it as a reference
- Extend it with bonus features
- Rewrite it from scratch as practice

## Skills Practiced

- ✅ String parsing and conversion
- ✅ Arithmetic operations (R-type instructions)
- ✅ Function calls and return values
- ✅ Stack management
- ✅ Conditional branching
- ✅ Error handling
- ✅ System calls for I/O

## Tips

1. **Start simple** - Get basic addition working first
2. **Test incrementally** - Test each function separately
3. **Use syscalls** - RISC-V syscalls can help with I/O
4. **Handle overflow** - Be aware of 32-bit integer limits
5. **Comment your code** - Explain complex logic

## Next Steps

After completing this project:
- Add more operations (power, square root)
- Implement floating-point support
- Create a scientific calculator
- Add expression parsing (e.g., "2 + 3 * 4")

## Resources

- [Lesson 03: Arithmetic Operations](../../lessons/03-arithmetic/)
- [Lesson 06: Functions and Stack](../../lessons/06-functions/)
- [Lesson 09: System Calls](../../lessons/09-syscalls/)
- [Example: Basic Operations](../../examples/basic-ops.s)

---

Good luck! Remember: even professional calculators started with basic operations. 🚀
