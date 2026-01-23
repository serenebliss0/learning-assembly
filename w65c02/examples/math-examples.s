; math-examples.s - Mathematical Operations for W65C02
; Quick reference examples for arithmetic and math operations
; Assemble with: ca65 math-examples.s

.segment "CODE"
.org $8000

;=============================================================================
; EXAMPLE 1: 8-bit Addition with Carry
;=============================================================================
; Adding two 8-bit numbers with overflow detection

add_8bit_example:
    CLC                   ; Clear carry flag
    LDA #$80              ; Load first number (128)
    ADC #$90              ; Add second number (144)
    STA $0300             ; Store result (272 & $FF = $10)
    
    ; Carry flag is now set (overflow occurred)
    BCS overflow_occurred ; Branch if carry set
    BCC no_overflow       ; Branch if carry clear
    
overflow_occurred:
    LDA #$FF              ; Set error flag
    STA $0301
    JMP add_done
    
no_overflow:
    LDA #$00              ; Clear error flag
    STA $0301
    
add_done:
    NOP

;=============================================================================
; EXAMPLE 2: 16-bit Addition
;=============================================================================
; Adding two 16-bit numbers (little-endian)
; Number 1 at $10-$11, Number 2 at $12-$13, Result at $14-$15

add_16bit_example:
    ; Initialize test values
    LDA #$34              ; Low byte of $1234
    STA $10
    LDA #$12              ; High byte
    STA $11
    
    LDA #$78              ; Low byte of $5678
    STA $12
    LDA #$56              ; High byte
    STA $13
    
    ; Add low bytes
    CLC                   ; Clear carry
    LDA $10               ; Load first low byte
    ADC $12               ; Add second low byte
    STA $14               ; Store result low byte
    
    ; Add high bytes with carry
    LDA $11               ; Load first high byte
    ADC $13               ; Add second high byte (with carry)
    STA $15               ; Store result high byte
    ; Result: $68AC = $1234 + $5678

;=============================================================================
; EXAMPLE 3: 8-bit Subtraction
;=============================================================================
; Subtracting two 8-bit numbers with borrow detection

subtract_8bit_example:
    SEC                   ; Set carry (no borrow)
    LDA #$50              ; Load minuend (80)
    SBC #$30              ; Subtract subtrahend (48)
    STA $0310             ; Store result (32)
    
    ; Subtract with potential borrow
    SEC                   ; Set carry
    LDA #$10              ; Load 16
    SBC #$20              ; Subtract 32 (result negative)
    STA $0311             ; Store result ($F0 = -16 in two's complement)
    BCC borrow_occurred   ; Branch if carry clear (borrow)
    BCS no_borrow
    
borrow_occurred:
    LDA #$FF              ; Set borrow flag
    STA $0312
    JMP sub_done
    
no_borrow:
    LDA #$00
    STA $0312
    
sub_done:
    NOP

;=============================================================================
; EXAMPLE 4: 16-bit Subtraction
;=============================================================================
; Subtracting two 16-bit numbers
; Number 1 at $20-$21, Number 2 at $22-$23, Result at $24-$25

subtract_16bit_example:
    ; Initialize test values
    LDA #$00              ; Low byte of $5000
    STA $20
    LDA #$50              ; High byte
    STA $21
    
    LDA #$34              ; Low byte of $1234
    STA $22
    LDA #$12              ; High byte
    STA $23
    
    ; Subtract low bytes
    SEC                   ; Set carry (no borrow)
    LDA $20               ; Load first low byte
    SBC $22               ; Subtract second low byte
    STA $24               ; Store result low byte
    
    ; Subtract high bytes with borrow
    LDA $21               ; Load first high byte
    SBC $23               ; Subtract second high byte (with borrow)
    STA $25               ; Store result high byte
    ; Result: $3DCC = $5000 - $1234

;=============================================================================
; EXAMPLE 5: 8-bit Multiplication by Powers of 2
;=============================================================================
; Fast multiplication using shift operations

multiply_by_2_example:
    LDA #$05              ; Load 5
    ASL A                 ; Multiply by 2 (result: 10)
    STA $0320
    
    LDA #$03              ; Load 3
    ASL A                 ; Multiply by 2 (6)
    ASL A                 ; Multiply by 2 again (12)
    ASL A                 ; Multiply by 2 again (24)
    STA $0321             ; Result: 3 * 8 = 24

;=============================================================================
; EXAMPLE 6: 8-bit Multiplication (General)
;=============================================================================
; Multiply two 8-bit numbers using repeated addition
; Multiplies value in $30 by value in $31, result in $32-$33

multiply_8bit:
    ; Initialize test values
    LDA #$07              ; Multiplicand (7)
    STA $30
    LDA #$09              ; Multiplier (9)
    STA $31
    
    ; Initialize result to 0
    LDA #$00
    STA $32               ; Result low byte
    STA $33               ; Result high byte
    
    ; Check for zero multiplier
    LDA $31
    BEQ multiply_done
    
    ; Multiplication loop
multiply_loop:
    CLC                   ; Clear carry
    LDA $32               ; Load result low byte
    ADC $30               ; Add multiplicand
    STA $32               ; Store result low byte
    LDA $33               ; Load result high byte
    ADC #$00              ; Add carry
    STA $33               ; Store result high byte
    
    DEC $31               ; Decrement multiplier
    BNE multiply_loop     ; Continue if not zero
    
multiply_done:
    ; Result: $003F = 63 = 7 * 9
    NOP

;=============================================================================
; EXAMPLE 7: 8-bit Division by Powers of 2
;=============================================================================
; Fast division using shift operations

divide_by_2_example:
    LDA #$20              ; Load 32
    LSR A                 ; Divide by 2 (result: 16)
    STA $0330
    
    LDA #$40              ; Load 64
    LSR A                 ; Divide by 2 (32)
    LSR A                 ; Divide by 2 again (16)
    LSR A                 ; Divide by 2 again (8)
    STA $0331             ; Result: 64 / 8 = 8

;=============================================================================
; EXAMPLE 8: 8-bit Division (General)
;=============================================================================
; Divide 8-bit number by 8-bit number using repeated subtraction
; Divides $40 by $41, quotient in $42, remainder in $43

divide_8bit:
    ; Initialize test values
    LDA #$1E              ; Dividend (30)
    STA $40
    LDA #$07              ; Divisor (7)
    STA $41
    
    ; Initialize quotient to 0
    LDA #$00
    STA $42               ; Quotient
    
    ; Division loop
divide_loop:
    SEC                   ; Set carry (no borrow)
    LDA $40               ; Load dividend
    SBC $41               ; Subtract divisor
    BCC divide_done       ; If borrow, we're done
    
    STA $40               ; Update dividend with remainder
    INC $42               ; Increment quotient
    JMP divide_loop       ; Continue
    
divide_done:
    LDA $40               ; Final remainder
    STA $43               ; Store remainder
    ; Result: quotient = 4, remainder = 2 (30 = 7*4 + 2)
    NOP

;=============================================================================
; EXAMPLE 9: BCD Addition
;=============================================================================
; Binary Coded Decimal addition (each byte stores 0-99)

bcd_add_example:
    SED                   ; Set Decimal mode
    
    CLC                   ; Clear carry
    LDA #$25              ; 25 in BCD
    ADC #$37              ; Add 37 in BCD
    STA $0350             ; Result: $62 (62 in BCD)
    
    ; BCD addition with carry
    CLC
    LDA #$99              ; 99 in BCD
    ADC #$01              ; Add 1
    STA $0351             ; Result: $00, Carry = 1
    
    CLD                   ; Clear Decimal mode (back to binary)

;=============================================================================
; EXAMPLE 10: BCD Subtraction
;=============================================================================
; Binary Coded Decimal subtraction

bcd_subtract_example:
    SED                   ; Set Decimal mode
    
    SEC                   ; Set carry (no borrow)
    LDA #$55              ; 55 in BCD
    SBC #$27              ; Subtract 27 in BCD
    STA $0360             ; Result: $28 (28 in BCD)
    
    ; BCD subtraction with borrow
    SEC
    LDA #$10              ; 10 in BCD
    SBC #$25              ; Subtract 25 in BCD
    STA $0361             ; Result with borrow
    
    CLD                   ; Clear Decimal mode

;=============================================================================
; EXAMPLE 11: Find Maximum of Two Numbers
;=============================================================================
; Compare two numbers and return the larger one

find_max:
    ; Initialize test values
    LDA #$42              ; First number
    STA $50
    LDA #$37              ; Second number
    STA $51
    
    ; Compare values
    LDA $50               ; Load first number
    CMP $51               ; Compare with second
    BCS first_is_max      ; Branch if first >= second
    
    ; Second is maximum
    LDA $51
    STA $52               ; Store max
    JMP max_done
    
first_is_max:
    LDA $50
    STA $52               ; Store max
    
max_done:
    ; Result: $42 at $52
    NOP

;=============================================================================
; EXAMPLE 12: Find Minimum of Two Numbers
;=============================================================================
; Compare two numbers and return the smaller one

find_min:
    ; Initialize test values
    LDA #$42              ; First number
    STA $60
    LDA #$37              ; Second number
    STA $61
    
    ; Compare values
    LDA $60               ; Load first number
    CMP $61               ; Compare with second
    BCC first_is_min      ; Branch if first < second
    
    ; Second is minimum
    LDA $61
    STA $62               ; Store min
    JMP min_done
    
first_is_min:
    LDA $60
    STA $62               ; Store min
    
min_done:
    ; Result: $37 at $62
    NOP

;=============================================================================
; EXAMPLE 13: Absolute Value
;=============================================================================
; Convert signed 8-bit number to absolute value (two's complement)

absolute_value:
    LDA #$F5              ; Load -11 in two's complement
    STA $70
    
    ; Check if negative (bit 7 set)
    BPL already_positive  ; Branch if positive
    
    ; Negate: invert bits and add 1
    EOR #$FF              ; Invert all bits
    CLC
    ADC #$01              ; Add 1
    STA $71               ; Store absolute value
    JMP abs_done
    
already_positive:
    STA $71               ; Just copy value
    
abs_done:
    ; Result: $0B (11) at $71
    NOP

;=============================================================================
; EXAMPLE 14: 16-bit Increment
;=============================================================================
; Increment a 16-bit number at $80-$81

increment_16bit:
    ; Initialize test value $12FF
    LDA #$FF
    STA $80               ; Low byte
    LDA #$12
    STA $81               ; High byte
    
    ; Increment
    INC $80               ; Increment low byte
    BNE inc16_done        ; If not zero, done
    INC $81               ; If zero, increment high byte
    
inc16_done:
    ; Result: $1300 at $80-$81
    NOP

;=============================================================================
; EXAMPLE 15: 16-bit Decrement
;=============================================================================
; Decrement a 16-bit number at $90-$91

decrement_16bit:
    ; Initialize test value $1300
    LDA #$00
    STA $90               ; Low byte
    LDA #$13
    STA $91               ; High byte
    
    ; Decrement
    LDA $90               ; Load low byte
    BNE dec16_low         ; If not zero, just decrement low
    DEC $91               ; If zero, decrement high byte first
    
dec16_low:
    DEC $90               ; Decrement low byte
    
    ; Result: $12FF at $90-$91
    NOP

;=============================================================================
; EXAMPLE 16: Average of Two Numbers
;=============================================================================
; Calculate average of two 8-bit numbers

calculate_average:
    ; Initialize test values
    LDA #$80              ; First number (128)
    STA $A0
    LDA #$60              ; Second number (96)
    STA $A1
    
    ; Add numbers
    CLC
    LDA $A0
    ADC $A1
    
    ; Divide by 2 (with carry handling)
    ROR A                 ; Rotate right (divide by 2, carry into bit 7)
    STA $A2               ; Store average
    ; Result: $70 (112) at $A2
    NOP

;=============================================================================
; Main loop
;=============================================================================
reset:
    JMP reset             ; Loop forever

;=============================================================================
; Interrupt Vectors
;=============================================================================
.segment "VECTORS"
.org $FFFC
.word reset               ; Reset vector
.word $0000               ; NMI vector (not used)
