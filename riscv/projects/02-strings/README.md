# Project 2: String Manipulation Library 📝

## Overview

Build a library of string manipulation functions similar to C's `string.h`. This project will help you:
- Work with memory and pointers
- Implement common string operations
- Practice loop constructs
- Handle null-terminated strings
- Create reusable functions

## Features

Implement these common string functions:

### Core Functions
1. **strlen** - Calculate string length
2. **strcpy** - Copy string from source to destination
3. **strcmp** - Compare two strings
4. **strcat** - Concatenate two strings
5. **strchr** - Find character in string

### Advanced Functions
6. **strrev** - Reverse a string
7. **toupper** - Convert to uppercase
8. **tolower** - Convert to lowercase
9. **strtrim** - Remove leading/trailing whitespace
10. **strstr** - Find substring

## Requirements

### Core Requirements
1. All strings are null-terminated (end with '\0')
2. Functions should not modify input strings unless specified
3. Return appropriate values (length, pointer, or comparison result)
4. Handle edge cases (null pointers, empty strings)
5. Follow RISC-V calling conventions

### Function Specifications

#### strlen
```assembly
# Function: strlen
# Calculate the length of a null-terminated string
# Input: a0 = pointer to string
# Output: a0 = length (not including null terminator)
# Clobbers: t0, t1

strlen:
    li t0, 0              # Counter
strlen_loop:
    lbu t1, 0(a0)         # Load byte
    beqz t1, strlen_done  # If null, done
    addi t0, t0, 1        # Increment counter
    addi a0, a0, 1        # Next character
    j strlen_loop
strlen_done:
    mv a0, t0             # Return length
    ret
```

#### strcpy
```assembly
# Function: strcpy
# Copy string from source to destination
# Input: a0 = destination, a1 = source
# Output: a0 = pointer to destination
# Clobbers: t0, t1

strcpy:
    mv t0, a0             # Save dest pointer
strcpy_loop:
    lbu t1, 0(a1)         # Load from source
    sb t1, 0(a0)          # Store to dest
    beqz t1, strcpy_done  # If null, done
    addi a0, a0, 1
    addi a1, a1, 1
    j strcpy_loop
strcpy_done:
    mv a0, t0             # Return original dest
    ret
```

#### strcmp
```assembly
# Function: strcmp
# Compare two strings lexicographically
# Input: a0 = string1, a1 = string2
# Output: a0 = 0 if equal, <0 if s1<s2, >0 if s1>s2
# Clobbers: t0, t1

strcmp:
strcmp_loop:
    lbu t0, 0(a0)         # Load from s1
    lbu t1, 0(a1)         # Load from s2
    bne t0, t1, strcmp_diff # Different characters
    beqz t0, strcmp_equal  # Both null = equal
    addi a0, a0, 1
    addi a1, a1, 1
    j strcmp_loop
strcmp_diff:
    sub a0, t0, t1        # Return difference
    ret
strcmp_equal:
    li a0, 0              # Return 0 (equal)
    ret
```

#### strcat
```assembly
# Function: strcat
# Concatenate source string to destination
# Input: a0 = destination, a1 = source
# Output: a0 = pointer to destination
# Note: Destination must have enough space!
# Clobbers: t0, t1, t2

strcat:
    mv t2, a0             # Save original dest
    # Find end of destination
strcat_find_end:
    lbu t0, 0(a0)
    beqz t0, strcat_copy
    addi a0, a0, 1
    j strcat_find_end
    # Copy source to end
strcat_copy:
    lbu t1, 0(a1)
    sb t1, 0(a0)
    beqz t1, strcat_done
    addi a0, a0, 1
    addi a1, a1, 1
    j strcat_copy
strcat_done:
    mv a0, t2             # Return original dest
    ret
```

#### strchr
```assembly
# Function: strchr
# Find first occurrence of character in string
# Input: a0 = string, a1 = character to find
# Output: a0 = pointer to character or NULL
# Clobbers: t0

strchr:
strchr_loop:
    lbu t0, 0(a0)
    beq t0, a1, strchr_found
    beqz t0, strchr_notfound
    addi a0, a0, 1
    j strchr_loop
strchr_found:
    ret                   # a0 already points to char
strchr_notfound:
    li a0, 0              # Return NULL
    ret
```

## Implementation Guide

### Step 1: Create Test Strings

Define test strings in the `.data` section:

```assembly
.data
str1:  .string "Hello"
str2:  .string "World"
str3:  .string "Hello"
dest:  .space 100          # Buffer for results
```

### Step 2: Implement Each Function

Start with the simplest function (strlen) and test it thoroughly before moving to the next.

### Step 3: Create Test Suite

Write a main function that tests all your string functions:

```assembly
main:
    # Test strlen
    la a0, str1
    jal ra, strlen
    # Print result
    
    # Test strcpy
    la a0, dest
    la a1, str1
    jal ra, strcpy
    # Print result
    
    # ... test other functions
```

### Step 4: Handle Edge Cases

Test with:
- Empty strings ("")
- Single characters
- Very long strings
- Special characters

## Testing

Create comprehensive tests:

### strlen tests
```
strlen("") = 0
strlen("Hi") = 2
strlen("Hello World") = 11
```

### strcpy tests
```
strcpy(dest, "Test") → dest = "Test"
strcpy(dest, "") → dest = ""
```

### strcmp tests
```
strcmp("abc", "abc") = 0
strcmp("abc", "abd") < 0
strcmp("abd", "abc") > 0
```

### strcat tests
```
strcat("Hello ", "World") = "Hello World"
strcat("", "Test") = "Test"
```

### strchr tests
```
strchr("Hello", 'e') → pointer to 'e'
strchr("Hello", 'z') → NULL
```

## Provided Code

A complete implementation is provided in `string_lib.s`. Use it as:
- A reference for implementation
- A starting point for extensions
- Practice by implementing from scratch

## Skills Practiced

- ✅ Memory operations (load/store bytes)
- ✅ Pointer manipulation
- ✅ Loop constructs
- ✅ Function calls and returns
- ✅ Null-terminated string handling
- ✅ Register conventions
- ✅ Edge case handling

## Tips

1. **Work with bytes** - Use `lbu` and `sb` for character access
2. **Watch alignment** - RISC-V requires aligned access for words
3. **Preserve registers** - Save s0-s11 if you use them
4. **Test incrementally** - One function at a time
5. **Use comments** - Explain your logic clearly
6. **Check bounds** - Avoid buffer overflows

## Extensions

After completing the basic library:
- Add Unicode/UTF-8 support
- Implement regular expression matching
- Create string formatting functions
- Add memory-safe versions (strlcpy, strlcat)
- Implement efficient algorithms (KMP for string search)

## Next Steps

- Combine with calculator project for input parsing
- Use in other projects for text processing
- Implement a text editor
- Create a simple shell

## Resources

- [Lesson 04: Memory Operations](../../lessons/04-memory/)
- [Lesson 10: Arrays and Pointers](../../lessons/10-arrays/)
- [Example: Data Structures](../../examples/data-structures.s)

---

Strings are the foundation of text processing. Master them! 📚
