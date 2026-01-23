; io-examples.s - Input/Output Operations for W65C02
; Quick reference examples for I/O operations
; Assemble with: ca65 io-examples.s

; Memory-mapped I/O locations (common examples)
.define IO_PORT     $6000     ; General I/O port
.define LED_PORT    $6000     ; LED control port
.define BUTTON_PORT $6001     ; Button input port
.define CHAR_OUT    $6000     ; Character output location
.define CHAR_IN     $6001     ; Character input location

.segment "CODE"
.org $8000

;=============================================================================
; EXAMPLE 1: Simple LED Control
;=============================================================================
; Turn LEDs on and off using memory-mapped I/O

led_control_example:
    ; Turn on all LEDs (write $FF)
    LDA #$FF
    STA LED_PORT          ; All 8 LEDs on
    
    ; Simple delay (not precise)
    LDX #$00
    LDY #$00
delay1:
    INX
    BNE delay1
    INY
    BNE delay1
    
    ; Turn off all LEDs
    LDA #$00
    STA LED_PORT          ; All 8 LEDs off
    
    ; Turn on specific LEDs (bits 0, 2, 4, 6)
    LDA #%01010101
    STA LED_PORT

;=============================================================================
; EXAMPLE 2: LED Pattern Generator
;=============================================================================
; Generate running light pattern

led_pattern_example:
    LDX #$08              ; 8 LEDs
    LDA #$01              ; Start with LED 0
    
pattern_loop:
    STA LED_PORT          ; Display pattern
    
    ; Delay
    JSR short_delay
    
    ; Rotate pattern left
    ASL A                 ; Shift left
    BCC pattern_no_wrap   ; If no carry, continue
    LDA #$01              ; Wrap around to LED 0
    
pattern_no_wrap:
    DEX                   ; Count down
    BNE pattern_loop      ; Continue pattern
    
    ; Pattern complete
    JMP pattern_done

;=============================================================================
; EXAMPLE 3: Button Reading
;=============================================================================
; Read button state from input port

button_read_example:
    ; Read single button (bit 0)
    LDA BUTTON_PORT       ; Read button port
    AND #$01              ; Mask bit 0
    BEQ button_not_pressed ; If 0, button not pressed
    
button_pressed:
    ; Button is pressed - turn on LED
    LDA #$FF
    STA LED_PORT
    JMP button_done
    
button_not_pressed:
    ; Button not pressed - turn off LED
    LDA #$00
    STA LED_PORT
    
button_done:
    NOP

;=============================================================================
; EXAMPLE 4: Multiple Button Reading
;=============================================================================
; Read multiple buttons and display on LEDs

multi_button_example:
    LDA BUTTON_PORT       ; Read all buttons
    STA LED_PORT          ; Display button state on LEDs
    
    ; Check specific buttons
    LDA BUTTON_PORT
    AND #%00000001        ; Check button 0
    BEQ check_button1
    ; Button 0 is pressed
    INC $0400             ; Increment counter
    
check_button1:
    LDA BUTTON_PORT
    AND #%00000010        ; Check button 1
    BEQ check_button2
    ; Button 1 is pressed
    DEC $0400             ; Decrement counter
    
check_button2:
    LDA BUTTON_PORT
    AND #%00000100        ; Check button 2
    BEQ buttons_done
    ; Button 2 is pressed - reset counter
    LDA #$00
    STA $0400
    
buttons_done:
    NOP

;=============================================================================
; EXAMPLE 5: Button Debouncing
;=============================================================================
; Debounce a button to avoid false triggers
; Uses zero page locations $D0-$D2

button_debounce_example:
    ; Initialize previous state
    LDA #$00
    STA $D0               ; Previous button state
    STA $D1               ; Debounce counter
    
debounce_loop:
    LDA BUTTON_PORT       ; Read current button state
    AND #$01              ; Mask button 0
    STA $D2               ; Store current state
    
    ; Compare with previous state
    CMP $D0
    BEQ state_same        ; State unchanged
    
    ; State changed - reset counter
    LDA #$00
    STA $D1
    LDA $D2
    STA $D0               ; Update previous state
    JMP debounce_continue
    
state_same:
    ; State stable - increment counter
    INC $D1
    LDA $D1
    CMP #$05              ; Debounce threshold (5 stable reads)
    BCC debounce_continue ; Not yet stable
    
    ; Button state confirmed stable
    LDA $D2
    BEQ button_released
    
button_pressed_stable:
    ; Confirmed button press - do action
    LDA #$FF
    STA LED_PORT
    JMP debounce_continue
    
button_released:
    ; Button released
    LDA #$00
    STA LED_PORT
    
debounce_continue:
    JSR short_delay       ; Small delay between reads
    JMP debounce_loop     ; Continue monitoring

;=============================================================================
; EXAMPLE 6: Polling Loop
;=============================================================================
; Wait for button press using polling

poll_button:
    ; Wait for button 0 to be pressed
wait_press:
    LDA BUTTON_PORT
    AND #$01              ; Check button 0
    BEQ wait_press        ; Loop until pressed
    
    ; Button pressed - do action
    LDA #$FF
    STA LED_PORT
    
    ; Wait for button release
wait_release:
    LDA BUTTON_PORT
    AND #$01
    BNE wait_release      ; Loop until released
    
    ; Button released
    LDA #$00
    STA LED_PORT
    JMP poll_button       ; Repeat

;=============================================================================
; EXAMPLE 7: Character Output to Memory
;=============================================================================
; Write a string to memory-mapped output

char_output_example:
    LDX #$00              ; Initialize index
    
char_out_loop:
    LDA output_message,X  ; Load character from message
    BEQ char_out_done     ; If zero, we're done
    STA CHAR_OUT          ; Write character to output
    
    JSR short_delay       ; Delay between characters
    
    INX                   ; Next character
    JMP char_out_loop
    
char_out_done:
    NOP

output_message:
    .byte "Hello!", $00

;=============================================================================
; EXAMPLE 8: Character Input from Memory
;=============================================================================
; Read characters from memory-mapped input into buffer
; Buffer at $0500, max 16 characters

char_input_example:
    LDX #$00              ; Initialize buffer index
    
char_in_loop:
    ; Check if we have data available (implementation specific)
    ; For this example, we assume CHAR_IN has data when non-zero
    
    LDA CHAR_IN           ; Read character
    BEQ char_in_loop      ; If zero, wait for input
    
    CMP #$0D              ; Check for Enter (carriage return)
    BEQ char_in_done      ; If Enter, we're done
    
    STA $0500,X           ; Store in buffer
    INX                   ; Next position
    CPX #$10              ; Check buffer limit
    BEQ char_in_done      ; Buffer full
    
    ; Clear input location (acknowledge read)
    LDA #$00
    STA CHAR_IN
    
    JMP char_in_loop
    
char_in_done:
    ; Null-terminate string
    LDA #$00
    STA $0500,X
    NOP

;=============================================================================
; EXAMPLE 9: Bit-banging Output
;=============================================================================
; Manually control individual I/O bits

bitbang_example:
    ; Set bit 3 high, keep others unchanged
    LDA IO_PORT           ; Read current value
    ORA #%00001000        ; Set bit 3
    STA IO_PORT           ; Write back
    
    JSR short_delay
    
    ; Clear bit 3, keep others unchanged
    LDA IO_PORT           ; Read current value
    AND #%11110111        ; Clear bit 3
    STA IO_PORT           ; Write back
    
    ; Toggle bit 5
    LDA IO_PORT           ; Read current value
    EOR #%00100000        ; Toggle bit 5
    STA IO_PORT           ; Write back

;=============================================================================
; EXAMPLE 10: Read-Modify-Write Pattern
;=============================================================================
; Safely modify specific bits without affecting others

read_modify_write:
    ; Turn on bits 0 and 1, turn off bit 2, leave others unchanged
    LDA IO_PORT           ; Read current state
    ORA #%00000011        ; Set bits 0 and 1
    AND #%11111011        ; Clear bit 2
    STA IO_PORT           ; Write back
    
    ; Set multiple bits using mask
    LDA IO_PORT
    AND #%11110000        ; Clear lower 4 bits
    ORA #%00001010        ; Set bits 1 and 3
    STA IO_PORT

;=============================================================================
; EXAMPLE 11: Data Direction Register Setup
;=============================================================================
; Configure which pins are inputs and which are outputs
; Assumes DDR at IO_PORT+1

.define DDR_PORT (IO_PORT+1)

port_direction_setup:
    ; Configure port: bits 0-3 as outputs, bits 4-7 as inputs
    LDA #%00001111        ; 1 = output, 0 = input
    STA DDR_PORT
    
    ; Now use the port
    LDA #%00001010        ; Set outputs (bits 0-3)
    STA IO_PORT           ; Only affects output pins
    
    ; Read inputs
    LDA IO_PORT           ; Read all pins
    AND #%11110000        ; Mask input bits (4-7)
    LSR A                 ; Shift down to bits 0-3
    LSR A
    LSR A
    LSR A
    STA $0600             ; Store input value

;=============================================================================
; EXAMPLE 12: Binary to LED Display
;=============================================================================
; Display binary number on 8 LEDs

binary_display:
    ; Display numbers 0-255 on LEDs
    LDX #$00              ; Start at 0
    
display_loop:
    TXA                   ; Transfer count to A
    STA LED_PORT          ; Display on LEDs
    
    JSR medium_delay      ; Delay so we can see it
    
    INX                   ; Next number
    BNE display_loop      ; Continue until wrap to 0
    
    ; Sequence complete
    NOP

;=============================================================================
; EXAMPLE 13: Button State Machine
;=============================================================================
; Simple state machine for button control
; State 0: off, State 1: on, toggle on button press

button_state_machine:
    ; Initialize state
    LDA #$00
    STA $0700             ; Current state
    STA $0701             ; Previous button state
    
state_machine_loop:
    ; Read button
    LDA BUTTON_PORT
    AND #$01              ; Button 0
    STA $0702             ; Current button state
    
    ; Check if button just pressed (was 0, now 1)
    CMP #$01
    BNE not_pressed
    LDA $0701
    BNE not_pressed       ; Was already pressed
    
    ; Button just pressed - toggle state
    LDA $0700             ; Load current state
    EOR #$01              ; Toggle bit 0
    STA $0700             ; Save new state
    
not_pressed:
    ; Update previous button state
    LDA $0702
    STA $0701
    
    ; Display state on LED
    LDA $0700
    BEQ state_off
    
state_on:
    LDA #$FF
    STA LED_PORT
    JMP state_continue
    
state_off:
    LDA #$00
    STA LED_PORT
    
state_continue:
    JSR short_delay
    JMP state_machine_loop

;=============================================================================
; EXAMPLE 14: Input with Timeout
;=============================================================================
; Wait for input with timeout counter

input_with_timeout:
    ; Initialize timeout counter
    LDA #$00
    STA $0710             ; Timeout counter low
    STA $0711             ; Timeout counter high
    
timeout_loop:
    ; Check for input
    LDA BUTTON_PORT
    AND #$01
    BNE input_received    ; Button pressed
    
    ; Increment timeout counter
    INC $0710
    BNE timeout_check
    INC $0711
    
timeout_check:
    ; Check if timeout reached (example: $1000)
    LDA $0711
    CMP #$10
    BCC timeout_loop      ; Not yet timed out
    
    ; Timeout occurred
    LDA #$FF              ; Error indicator
    STA $0712
    JMP timeout_done
    
input_received:
    ; Input received before timeout
    LDA #$00              ; Success indicator
    STA $0712
    
timeout_done:
    NOP

;=============================================================================
; Utility Subroutines
;=============================================================================

; Short delay routine
short_delay:
    PHA                   ; Save A
    LDA #$20              ; Delay count
sd_loop:
    DEC                   ; Decrement A
    BNE sd_loop           ; Loop until zero
    PLA                   ; Restore A
    RTS

; Medium delay routine
medium_delay:
    PHA                   ; Save A
    PHX                   ; Save X
    LDX #$FF
md_outer:
    LDA #$FF
md_inner:
    DEC
    BNE md_inner
    DEX
    BNE md_outer
    PLX                   ; Restore X
    PLA                   ; Restore A
    RTS

;=============================================================================
; Main Reset Vector
;=============================================================================
reset:
    ; Initialize system
    LDA #$00
    STA LED_PORT          ; LEDs off
    
    ; Jump to examples (choose one)
    ; JMP led_control_example
    ; JMP button_debounce_example
    JMP reset             ; Loop forever
    
pattern_done:
    JMP pattern_done      ; Halt

;=============================================================================
; Interrupt Vectors
;=============================================================================
.segment "VECTORS"
.org $FFFC
.word reset               ; Reset vector
.word $0000               ; NMI vector (not used)
