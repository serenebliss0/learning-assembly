; basic-examples.s - Fundamental W65C02 Operations
; Quick reference examples for common basic operations
; Assemble with: ca65 basic-examples.s

.segment "CODE"
.org $8000

;=============================================================================
; EXAMPLE 1: Loading and Storing Values
;=============================================================================
; Loading immediate values and storing to memory

load_store_example:
    ; Load immediate value into accumulator
    LDA #$42              ; Load hex value $42 into A
    
    ; Store accumulator to memory
    STA $0200             ; Store A at address $0200
    
    ; Load from memory
    LDA $0200             ; Load value from $0200 into A
    
    ; Load immediate into X and Y
    LDX #$10              ; Load $10 into X register
    LDY #$20              ; Load $20 into Y register
    
    ; Store X and Y to memory
    STX $0201             ; Store X at $0201
    STY $0202             ; Store Y at $0202
    
    ; Zero page addressing (faster!)
    LDA #$FF              ; Load $FF into A
    STA $50               ; Store to zero page address $50
    LDA $50               ; Load from zero page $50

;=============================================================================
; EXAMPLE 2: Register Transfers
;=============================================================================
; Moving data between registers

register_transfer_example:
    ; Accumulator to X and Y
    LDA #$33              ; Load $33 into A
    TAX                   ; Transfer A to X (X now contains $33)
    TAY                   ; Transfer A to Y (Y now contains $33)
    
    ; X and Y back to Accumulator
    LDX #$44              ; Load $44 into X
    TXA                   ; Transfer X to A (A now contains $44)
    
    LDY #$55              ; Load $55 into Y
    TYA                   ; Transfer Y to A (A now contains $55)
    
    ; Stack operations
    LDA #$66              ; Load $66 into A
    PHA                   ; Push A onto stack
    LDA #$00              ; Clear A
    PLA                   ; Pull from stack back to A (A = $66 again)
    
    ; Transfer stack pointer
    TSX                   ; Transfer Stack Pointer to X
    TXS                   ; Transfer X to Stack Pointer

;=============================================================================
; EXAMPLE 3: Basic Arithmetic
;=============================================================================
; Addition and subtraction with the accumulator

arithmetic_example:
    ; Addition without carry
    CLC                   ; Clear carry flag (important!)
    LDA #$10              ; Load $10 into A
    ADC #$05              ; Add $05 to A (A = $15)
    STA $0300             ; Store result at $0300
    
    ; Addition with carry from memory
    CLC                   ; Clear carry
    LDA #$FF              ; Load $FF
    ADC #$01              ; Add $01 (A = $00, Carry = 1)
    
    ; Subtraction without borrow
    SEC                   ; Set carry flag (for subtraction)
    LDA #$20              ; Load $20
    SBC #$10              ; Subtract $10 from A (A = $10)
    STA $0301             ; Store result
    
    ; Increment and decrement
    LDA #$10              ; Load $10
    INC $0302             ; Increment memory location $0302
    DEC $0302             ; Decrement memory location $0302
    INX                   ; Increment X register
    DEX                   ; Decrement X register
    INY                   ; Increment Y register
    DEY                   ; Decrement Y register

;=============================================================================
; EXAMPLE 4: Logical Operations
;=============================================================================
; Bitwise AND, OR, XOR operations

logical_example:
    ; AND operation (mask bits)
    LDA #%11110000        ; Load binary value
    AND #%00001111        ; AND with mask (result: %00000000)
    
    ; OR operation (set bits)
    LDA #%00001111        ; Load binary value
    ORA #%11110000        ; OR with bits (result: %11111111)
    
    ; XOR operation (toggle bits)
    LDA #%10101010        ; Load binary value
    EOR #%11111111        ; XOR to invert all bits (result: %01010101)
    
    ; Bit testing
    LDA #%10000001        ; Load test value
    BIT $0200             ; Test bits against memory location
                          ; Sets N flag from bit 7, V from bit 6

;=============================================================================
; EXAMPLE 5: Shift and Rotate Operations
;=============================================================================
; Shifting and rotating bits

shift_rotate_example:
    ; Arithmetic Shift Left (multiply by 2)
    LDA #$04              ; Load $04
    ASL A                 ; Shift left (A = $08)
    ASL A                 ; Shift left again (A = $10)
    
    ; Logical Shift Right (divide by 2)
    LDA #$10              ; Load $10
    LSR A                 ; Shift right (A = $08)
    LSR A                 ; Shift right again (A = $04)
    
    ; Rotate Left through Carry
    CLC                   ; Clear carry
    LDA #%10000001        ; Load binary value
    ROL A                 ; Rotate left (C=1, A=%00000010)
    ROL A                 ; Rotate left (C=0, A=%00000101)
    
    ; Rotate Right through Carry
    CLC                   ; Clear carry
    LDA #%10000001        ; Load binary value
    ROR A                 ; Rotate right (C=1, A=%01000000)
    ROR A                 ; Rotate right (C=0, A=%10100000)

;=============================================================================
; EXAMPLE 6: Basic Loops and Branches
;=============================================================================
; Counting loop using X register

count_loop_example:
    LDX #$0A              ; Initialize counter to 10
count_loop:
    ; Do something here (example: increment a memory location)
    INC $0400             ; Increment counter at $0400
    DEX                   ; Decrement X
    BNE count_loop        ; Branch if Not Equal to zero
    
    ; Counting up loop using Y register
    LDY #$00              ; Start at 0
count_up_loop:
    ; Do something here
    INY                   ; Increment Y
    CPY #$10              ; Compare Y with 16
    BNE count_up_loop     ; Loop if not equal to 16

;=============================================================================
; EXAMPLE 7: Conditional Branches
;=============================================================================
; Testing conditions and branching

branch_example:
    ; Branch if equal
    LDA #$42              ; Load value
    CMP #$42              ; Compare with $42
    BEQ values_equal      ; Branch if equal
    
values_not_equal:
    ; Handle not equal case
    LDA #$00
    JMP branch_done
    
values_equal:
    ; Handle equal case
    LDA #$FF
    
branch_done:
    ; Branch if carry set/clear
    LDA #$10
    CMP #$20              ; Compare (10 < 20, so Carry clear)
    BCC less_than         ; Branch if Carry Clear (less than)
    BCS greater_equal     ; Branch if Carry Set (greater/equal)
    
less_than:
    LDA #$01
    JMP compare_done
    
greater_equal:
    LDA #$02
    
compare_done:
    NOP                   ; No operation

;=============================================================================
; EXAMPLE 8: Simple Subroutines
;=============================================================================
; Subroutine that adds two numbers

; Main code calls the subroutine
subroutine_example:
    LDA #$25              ; First number
    LDX #$17              ; Second number
    JSR add_numbers       ; Call subroutine (result in A)
    STA $0500             ; Store result
    
    ; Another subroutine call
    LDA #$10
    JSR double_value      ; Call subroutine to double A
    STA $0501             ; Store doubled value
    JMP main_done

; Subroutine: Add A and X, return result in A
add_numbers:
    STA $00               ; Store A in zero page temp
    TXA                   ; Transfer X to A
    CLC                   ; Clear carry
    ADC $00               ; Add stored value
    RTS                   ; Return from subroutine

; Subroutine: Double the value in A
double_value:
    ASL A                 ; Shift left (multiply by 2)
    RTS                   ; Return from subroutine

main_done:
    JMP main_done         ; Loop forever

;=============================================================================
; EXAMPLE 9: Indexed Addressing
;=============================================================================
; Using X and Y as array indices

indexed_example:
    ; Store values to array using X indexing
    LDX #$00              ; Start at index 0
store_loop:
    TXA                   ; Transfer index to A
    STA $0600,X           ; Store A at base+X
    INX                   ; Next index
    CPX #$10              ; Compare with 16
    BNE store_loop        ; Loop until X = 16
    
    ; Load values from array using Y indexing
    LDY #$05              ; Index 5
    LDA $0600,Y           ; Load from base+Y
    
    ; Indirect indexed addressing (pointer in zero page)
    LDA #$00              ; Low byte of pointer
    STA $10
    LDA #$06              ; High byte ($0600)
    STA $11
    LDY #$03              ; Offset
    LDA ($10),Y           ; Load from ($10)+Y = $0603

;=============================================================================
; EXAMPLE 10: Stack Usage
;=============================================================================
; Using the stack to save and restore register values

stack_example:
    ; Save registers to stack
    LDA #$AA              ; Load A with test value
    LDX #$BB              ; Load X with test value
    LDY #$CC              ; Load Y with test value
    
    PHA                   ; Push A
    TXA                   ; Transfer X to A
    PHA                   ; Push X (via A)
    TYA                   ; Transfer Y to A
    PHA                   ; Push Y (via A)
    
    ; Modify registers
    LDA #$00
    LDX #$00
    LDY #$00
    
    ; Restore registers from stack (reverse order!)
    PLA                   ; Pull Y
    TAY                   ; Transfer A to Y
    PLA                   ; Pull X
    TAX                   ; Transfer A to X
    PLA                   ; Pull A
    
    ; Registers now restored to $AA, $BB, $CC

;=============================================================================
; Interrupt Vectors
;=============================================================================
.segment "VECTORS"
.org $FFFC
.word $8000               ; Reset vector
.word $0000               ; NMI vector (not used)
