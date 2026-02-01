# Project 3: Sorting Algorithms 📊

## Overview

Implement various sorting algorithms in RISC-V assembly. This project will help you:
- Work with arrays and memory
- Implement recursive algorithms
- Practice function calls and stack management
- Understand algorithm complexity
- Compare different sorting approaches

## Algorithms to Implement

### Required Algorithms
1. **Bubble Sort** - Simple but slow (O(n²))
2. **Selection Sort** - Find minimum repeatedly (O(n²))
3. **Insertion Sort** - Build sorted array (O(n²))
4. **Quicksort** - Fast divide-and-conquer (O(n log n))

### Bonus Algorithms
5. **Merge Sort** - Stable divide-and-conquer (O(n log n))
6. **Heap Sort** - In-place sorting (O(n log n))
7. **Counting Sort** - For integers in range (O(n + k))

## Requirements

### Core Requirements
1. Sort arrays of 32-bit integers
2. Support both ascending and descending order
3. Handle edge cases (empty, single element, sorted, reverse sorted)
4. Preserve original array or sort in-place (document which)
5. Follow RISC-V calling conventions

### Performance Comparison

Create a test harness that:
- Tests each algorithm with various inputs
- Measures execution time (cycle count)
- Verifies correctness
- Compares performance

## Implementation Guide

### Step 1: Bubble Sort (Easiest Start)

Bubble sort repeatedly steps through the list, compares adjacent elements, and swaps them if they're in the wrong order.

```assembly
# Function: bubble_sort
# Sort array using bubble sort
# Input: a0 = array pointer, a1 = array length
# Output: array is sorted in place
# Clobbers: t0-t6

bubble_sort:
    addi sp, sp, -4
    sw s0, 0(sp)
    
    mv s0, a1             # s0 = n (length)
    
bubble_outer:
    beqz s0, bubble_done
    li t0, 0              # i = 0
    addi t1, s0, -1       # limit = n - 1
    
bubble_inner:
    bge t0, t1, bubble_outer_next
    
    # Load array[i] and array[i+1]
    slli t2, t0, 2        # t2 = i * 4
    add t3, a0, t2        # t3 = &array[i]
    lw t4, 0(t3)          # t4 = array[i]
    lw t5, 4(t3)          # t5 = array[i+1]
    
    # Compare and swap if needed
    ble t4, t5, bubble_no_swap
    
    # Swap
    sw t5, 0(t3)
    sw t4, 4(t3)
    
bubble_no_swap:
    addi t0, t0, 1
    j bubble_inner
    
bubble_outer_next:
    addi s0, s0, -1
    j bubble_outer
    
bubble_done:
    lw s0, 0(sp)
    addi sp, sp, 4
    ret
```

### Step 2: Selection Sort

Find the minimum element and place it at the beginning.

```assembly
# Function: selection_sort
# Sort array using selection sort
# Input: a0 = array pointer, a1 = array length
# Output: array is sorted in place

selection_sort:
    li t0, 0              # i = 0
    
sel_outer:
    bge t0, a1, sel_done
    
    mv t1, t0             # min_idx = i
    addi t2, t0, 1        # j = i + 1
    
    # Find minimum in remaining array
sel_inner:
    bge t2, a1, sel_swap
    
    # Compare array[j] with array[min_idx]
    slli t3, t2, 2
    add t4, a0, t3
    lw t5, 0(t4)          # t5 = array[j]
    
    slli t3, t1, 2
    add t4, a0, t3
    lw t6, 0(t4)          # t6 = array[min_idx]
    
    bge t5, t6, sel_no_update
    mv t1, t2             # Update min_idx
    
sel_no_update:
    addi t2, t2, 1
    j sel_inner
    
sel_swap:
    # Swap array[i] and array[min_idx]
    beq t0, t1, sel_no_swap_needed
    
    slli t2, t0, 2
    add t3, a0, t2
    lw t4, 0(t3)          # t4 = array[i]
    
    slli t2, t1, 2
    add t3, a0, t2
    lw t5, 0(t3)          # t5 = array[min_idx]
    
    slli t2, t0, 2
    add t3, a0, t2
    sw t5, 0(t3)
    
    slli t2, t1, 2
    add t3, a0, t2
    sw t4, 0(t3)
    
sel_no_swap_needed:
    addi t0, t0, 1
    j sel_outer
    
sel_done:
    ret
```

### Step 3: Quicksort (Challenge!)

Quicksort is a divide-and-conquer algorithm that:
1. Picks a pivot element
2. Partitions array around the pivot
3. Recursively sorts sub-arrays

```assembly
# Function: quicksort
# Sort array using quicksort
# Input: a0 = array pointer, a1 = low index, a2 = high index
# Output: array is sorted in place

quicksort:
    # Base case: if low >= high, return
    bge a1, a2, qs_done
    
    # Save registers
    addi sp, sp, -16
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    
    mv s0, a0             # Save array pointer
    mv s1, a1             # Save low
    mv s2, a2             # Save high
    
    # Partition
    jal ra, partition
    mv s3, a0             # s3 = pivot index
    
    # Sort left partition
    mv a0, s0
    mv a1, s1
    addi a2, s3, -1
    jal ra, quicksort
    
    # Sort right partition
    mv a0, s0
    addi a1, s3, 1
    mv a2, s2
    jal ra, quicksort
    
    # Restore registers
    lw s2, 12(sp)
    lw s1, 8(sp)
    lw s0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 16
    
qs_done:
    ret

# Function: partition
# Partition array around pivot (last element)
# Input: a0 = array pointer, a1 = low, a2 = high
# Output: a0 = pivot index

partition:
    # Pivot = array[high]
    slli t0, a2, 2
    add t1, a0, t0
    lw t2, 0(t1)          # t2 = pivot value
    
    addi t3, a1, -1       # i = low - 1
    mv t4, a1             # j = low
    
part_loop:
    bge t4, a2, part_done
    
    # Load array[j]
    slli t0, t4, 2
    add t1, a0, t0
    lw t5, 0(t1)
    
    # If array[j] < pivot, swap
    bge t5, t2, part_no_swap
    
    addi t3, t3, 1        # i++
    
    # Swap array[i] and array[j]
    slli t0, t3, 2
    add t1, a0, t0
    lw t6, 0(t1)          # t6 = array[i]
    
    sw t5, 0(t1)          # array[i] = array[j]
    
    slli t0, t4, 2
    add t1, a0, t0
    sw t6, 0(t1)          # array[j] = array[i]
    
part_no_swap:
    addi t4, t4, 1
    j part_loop
    
part_done:
    # Swap array[i+1] with array[high] (pivot)
    addi t3, t3, 1
    
    slli t0, t3, 2
    add t1, a0, t0
    lw t5, 0(t1)
    
    slli t0, a2, 2
    add t1, a0, t0
    lw t6, 0(t1)
    
    slli t0, t3, 2
    add t1, a0, t0
    sw t6, 0(t1)
    
    slli t0, a2, 2
    add t1, a0, t0
    sw t5, 0(t1)
    
    mv a0, t3             # Return pivot index
    ret
```

## Testing

Create comprehensive tests with different array types:

### Test Cases
```
1. Empty array: []
2. Single element: [5]
3. Already sorted: [1, 2, 3, 4, 5]
4. Reverse sorted: [5, 4, 3, 2, 1]
5. All same: [3, 3, 3, 3, 3]
6. Random: [7, 2, 9, 1, 5]
7. Large array: [random 100 elements]
```

### Verification

After sorting, verify:
- Array is in correct order
- All elements are present
- No elements are lost or duplicated

```assembly
# Function: verify_sorted
# Check if array is sorted
# Input: a0 = array, a1 = length
# Output: a0 = 1 if sorted, 0 if not

verify_sorted:
    li t0, 1              # i = 1
verify_loop:
    bge t0, a1, verify_ok
    
    slli t1, t0, 2
    add t2, a0, t1
    lw t3, 0(t2)          # array[i]
    lw t4, -4(t2)         # array[i-1]
    
    blt t3, t4, verify_fail
    
    addi t0, t0, 1
    j verify_loop
    
verify_ok:
    li a0, 1
    ret
    
verify_fail:
    li a0, 0
    ret
```

## Performance Analysis

Measure and compare performance:

| Algorithm | Best Case | Average Case | Worst Case | Space |
|-----------|-----------|--------------|------------|-------|
| Bubble Sort | O(n) | O(n²) | O(n²) | O(1) |
| Selection Sort | O(n²) | O(n²) | O(n²) | O(1) |
| Insertion Sort | O(n) | O(n²) | O(n²) | O(1) |
| Quicksort | O(n log n) | O(n log n) | O(n²) | O(log n) |
| Merge Sort | O(n log n) | O(n log n) | O(n log n) | O(n) |

## Provided Code

Complete implementations are provided in `sorting.s`. Use them to:
- Study the algorithms
- Benchmark performance
- Compare implementations
- Learn optimization techniques

## Skills Practiced

- ✅ Array manipulation
- ✅ Recursive algorithms
- ✅ Stack management
- ✅ Loop optimization
- ✅ Algorithm analysis
- ✅ Performance measurement
- ✅ Testing and verification

## Tips

1. **Start simple** - Get bubble sort working first
2. **Test small** - Use small arrays for debugging
3. **Verify always** - Check if array is really sorted
4. **Watch the stack** - Recursion can use lots of stack space
5. **Optimize later** - Correctness first, performance second
6. **Use registers wisely** - Minimize memory access

## Extensions

- Implement insertion sort for small subarrays in quicksort
- Add adaptive sorting (choose algorithm based on input)
- Implement stable sorting
- Add parallel sorting (if multiple cores)
- Optimize for cache performance

## Next Steps

- Apply to real-world data
- Implement search algorithms
- Create a database-style system
- Optimize for specific hardware

## Resources

- [Lesson 05: Control Flow](../../lessons/05-control-flow/)
- [Lesson 06: Functions and Stack](../../lessons/06-functions/)
- [Lesson 10: Arrays and Pointers](../../lessons/10-arrays/)
- [Example: Data Structures](../../examples/data-structures.s)

---

Sorting is fundamental to computer science. Master it! 🚀
