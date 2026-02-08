# bitfields.s - Bit field extraction and insertion operations

.section .data
# Example: RGB color (24-bit color format)
color1:
    .word 0x00FF8040            # Red=255, Green=128, Blue=64

color2:
    .word 0x0080C0E0            # Red=128, Green=192, Blue=224

# Status register format:
# Bits 0-3: Error code
# Bits 4-7: Warning level  
# Bits 8-15: Device ID
# Bits 16-23: Status flags
# Bits 24-31: Reserved
status_reg:
    .word 0x12345678

.section .text
.globl _start

_start:
    # Test 1: Extract RGB color components
    lw a0, color1
    call extract_red
    mv s0, a0                   # s0 = 255
    
    lw a0, color1
    call extract_green
    mv s1, a0                   # s1 = 128
    
    lw a0, color1
    call extract_blue
    mv s2, a0                   # s2 = 64
    
    # Test 2: Create RGB color from components
    li a0, 200                  # Red
    li a1, 150                  # Green
    li a2, 100                  # Blue
    call make_rgb
    mv s3, a0                   # s3 = 0x00C89664
    
    # Test 3: Modify color component
    lw a0, color1
    li a1, 200                  # New green value
    call set_green
    mv s4, a0                   # Modified color
    
    # Test 4: Extract arbitrary bit fields
    lw a0, status_reg
    li a1, 0                    # Start bit
    li a2, 4                    # Width (4 bits)
    call extract_bitfield
    mv s5, a0                   # s5 = error code (0x8)
    
    lw a0, status_reg
    li a1, 8                    # Start bit
    li a2, 8                    # Width (8 bits)
    call extract_bitfield
    mv s6, a0                   # s6 = device ID (0x56)
    
    # Test 5: Insert bit field
    li a0, 0x00000000
    li a1, 0xAB                 # Value to insert
    li a2, 8                    # Start bit
    li a3, 8                    # Width
    call insert_bitfield
    mv s7, a0                   # s7 = 0x0000AB00
    
    # Test 6: Pack multiple small values
    li a0, 15                   # 4-bit value
    li a1, 7                    # 3-bit value
    li a2, 31                   # 5-bit value
    li a3, 255                  # 8-bit value
    call pack_values
    # a0 = packed result
    
    # Test 7: Blend two colors (50/50)
    lw a0, color1
    lw a1, color2
    call blend_colors
    mv s8, a0
    
    # Test 8: Extract nibbles (4-bit chunks)
    li a0, 0x12345678
    call extract_nibble_0
    # a0 = 0x8
    
    # Exit
    li a0, 0
    li a7, 93
    ecall

# Function: extract_red
# Extract red component (bits 16-23)
# Input: a0 = RGB color (0x00RRGGBB)
# Output: a0 = red component (0-255)
extract_red:
    srli a0, a0, 16             # Shift right 16 bits
    andi a0, a0, 0xFF           # Mask to 8 bits
    ret

# Function: extract_green
# Extract green component (bits 8-15)
# Input: a0 = RGB color (0x00RRGGBB)
# Output: a0 = green component (0-255)
extract_green:
    srli a0, a0, 8              # Shift right 8 bits
    andi a0, a0, 0xFF           # Mask to 8 bits
    ret

# Function: extract_blue
# Extract blue component (bits 0-7)
# Input: a0 = RGB color (0x00RRGGBB)
# Output: a0 = blue component (0-255)
extract_blue:
    andi a0, a0, 0xFF           # Mask to 8 bits
    ret

# Function: make_rgb
# Create RGB color from components
# Input: a0 = red, a1 = green, a2 = blue (0-255 each)
# Output: a0 = RGB color (0x00RRGGBB)
make_rgb:
    andi a0, a0, 0xFF           # Ensure 8-bit
    andi a1, a1, 0xFF
    andi a2, a2, 0xFF
    
    slli a0, a0, 16             # Red to bits 16-23
    slli a1, a1, 8              # Green to bits 8-15
    # Blue already in bits 0-7
    
    or a0, a0, a1
    or a0, a0, a2
    ret

# Function: set_red
# Set red component, preserve others
# Input: a0 = color, a1 = new red value
# Output: a0 = modified color
set_red:
    li t0, 0x00FFFFFF           # Mask to clear red
    and a0, a0, t0              # Clear red bits
    
    andi a1, a1, 0xFF           # Ensure 8-bit
    slli a1, a1, 16             # Position red
    or a0, a0, a1               # Combine
    ret

# Function: set_green
# Set green component, preserve others
# Input: a0 = color, a1 = new green value
# Output: a0 = modified color
set_green:
    li t0, 0x00FF00FF           # Mask to clear green
    and a0, a0, t0              # Clear green bits
    
    andi a1, a1, 0xFF           # Ensure 8-bit
    slli a1, a1, 8              # Position green
    or a0, a0, a1               # Combine
    ret

# Function: set_blue
# Set blue component, preserve others
# Input: a0 = color, a1 = new blue value
# Output: a0 = modified color
set_blue:
    li t0, 0x00FFFF00           # Mask to clear blue
    and a0, a0, t0              # Clear blue bits
    
    andi a1, a1, 0xFF           # Ensure 8-bit
    or a0, a0, a1               # Combine
    ret

# Function: extract_bitfield
# Extract arbitrary bit field
# Input: a0 = value, a1 = start_bit, a2 = width
# Output: a0 = extracted field value
extract_bitfield:
    # Shift right to align field with LSB
    srl a0, a0, a1
    
    # Create mask: (1 << width) - 1
    li t0, 1
    sll t0, t0, a2              # t0 = 1 << width
    addi t0, t0, -1             # t0 = (1 << width) - 1
    
    # Apply mask
    and a0, a0, t0
    ret

# Function: insert_bitfield
# Insert value into bit field
# Input: a0 = original value, a1 = new field value, 
#        a2 = start_bit, a3 = width
# Output: a0 = modified value
insert_bitfield:
    addi sp, sp, -16
    sw s0, 12(sp)
    sw s1, 8(sp)
    sw s2, 4(sp)
    
    mv s0, a0                   # Save original value
    mv s1, a2                   # Save start_bit
    
    # Create mask for field width
    li t0, 1
    sll t0, t0, a3              # t0 = 1 << width
    addi t0, t0, -1             # t0 = (1 << width) - 1
    
    # Mask new value to field width
    and s2, a1, t0              # s2 = masked value
    
    # Position the new value
    sll s2, s2, s1              # s2 = value << start_bit
    
    # Create clearing mask
    sll t0, t0, s1              # Position field mask
    not t0, t0                  # Invert to get clearing mask
    
    # Clear field in original value
    and s0, s0, t0              # Clear the field
    
    # Insert new value
    or a0, s0, s2               # Combine
    
    lw s2, 4(sp)
    lw s1, 8(sp)
    lw s0, 12(sp)
    addi sp, sp, 16
    ret

# Function: pack_values
# Pack multiple values into single word
# Input: a0 = 4-bit val, a1 = 3-bit val, a2 = 5-bit val, a3 = 8-bit val
# Output: a0 = packed word
pack_values:
    # Pack as: [8-bit][5-bit][3-bit][4-bit]
    andi a0, a0, 0xF            # Mask to 4 bits
    andi a1, a1, 0x7            # Mask to 3 bits
    andi a2, a2, 0x1F           # Mask to 5 bits
    andi a3, a3, 0xFF           # Mask to 8 bits
    
    # Position values
    slli a1, a1, 4              # 3-bit at position 4
    slli a2, a2, 7              # 5-bit at position 7
    slli a3, a3, 12             # 8-bit at position 12
    
    # Combine
    or a0, a0, a1
    or a0, a0, a2
    or a0, a0, a3
    ret

# Function: blend_colors
# Blend two RGB colors (50/50 average)
# Input: a0 = color1, a1 = color2
# Output: a0 = blended color
blend_colors:
    addi sp, sp, -16
    sw s0, 12(sp)
    sw s1, 8(sp)
    sw s2, 4(sp)
    
    # Extract components from color1
    mv t0, a0
    srli s0, t0, 16
    andi s0, s0, 0xFF           # r1
    srli s1, t0, 8
    andi s1, s1, 0xFF           # g1
    andi s2, t0, 0xFF           # b1
    
    # Extract components from color2
    mv t0, a1
    srli t1, t0, 16
    andi t1, t1, 0xFF           # r2
    srli t2, t0, 8
    andi t2, t2, 0xFF           # g2
    andi t3, t0, 0xFF           # b2
    
    # Average components
    add s0, s0, t1
    srli s0, s0, 1              # r = (r1 + r2) / 2
    
    add s1, s1, t2
    srli s1, s1, 1              # g = (g1 + g2) / 2
    
    add s2, s2, t3
    srli s2, s2, 1              # b = (b1 + b2) / 2
    
    # Combine into result
    slli s0, s0, 16
    slli s1, s1, 8
    or a0, s0, s1
    or a0, a0, s2
    
    lw s2, 4(sp)
    lw s1, 8(sp)
    lw s0, 12(sp)
    addi sp, sp, 16
    ret

# Function: extract_nibble_0
# Extract nibble 0 (bits 0-3)
# Input: a0 = value
# Output: a0 = nibble (0-15)
extract_nibble_0:
    andi a0, a0, 0xF
    ret

# Function: extract_nibble_1
# Extract nibble 1 (bits 4-7)
# Input: a0 = value
# Output: a0 = nibble (0-15)
extract_nibble_1:
    srli a0, a0, 4
    andi a0, a0, 0xF
    ret

# Function: set_nibble
# Set specific nibble (4 bits)
# Input: a0 = value, a1 = nibble_index (0-7), a2 = nibble_value (0-15)
# Output: a0 = modified value
set_nibble:
    # Clear target nibble
    li t0, 0xF
    sll t0, t0, a1              # Position clear mask
    not t0, t0                  # Invert
    and a0, a0, t0              # Clear nibble
    
    # Set new nibble
    andi a2, a2, 0xF            # Ensure 4-bit
    sll a2, a2, a1              # Position nibble
    or a0, a0, a2               # Combine
    ret
