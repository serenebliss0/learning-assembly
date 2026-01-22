; hardware-examples.s - Hardware Control for W65C02
; Quick reference examples for hardware interfacing (VIA, LCD, Timers, Interrupts)
; Assemble with: ca65 hardware-examples.s

;=============================================================================
; 65C22 VIA Register Definitions
;=============================================================================
.define VIA_BASE    $6000     ; Base address for VIA

; VIA Port A registers
.define VIA_PORTA   VIA_BASE+1   ; Port A data register
.define VIA_DDRA    VIA_BASE+3   ; Port A data direction register

; VIA Port B registers
.define VIA_PORTB   VIA_BASE     ; Port B data register
.define VIA_DDRB    VIA_BASE+2   ; Port B data direction register

; Timer registers
.define VIA_T1CL    VIA_BASE+4   ; Timer 1 counter low
.define VIA_T1CH    VIA_BASE+5   ; Timer 1 counter high
.define VIA_T1LL    VIA_BASE+6   ; Timer 1 latch low
.define VIA_T1LH    VIA_BASE+7   ; Timer 1 latch high
.define VIA_T2CL    VIA_BASE+8   ; Timer 2 counter low
.define VIA_T2CH    VIA_BASE+9   ; Timer 2 counter high

; Control registers
.define VIA_ACR     VIA_BASE+11  ; Auxiliary control register
.define VIA_PCR     VIA_BASE+12  ; Peripheral control register
.define VIA_IFR     VIA_BASE+13  ; Interrupt flag register
.define VIA_IER     VIA_BASE+14  ; Interrupt enable register

;=============================================================================
; LCD Display Definitions (HD44780 compatible)
;=============================================================================
.define LCD_RS      %00000001    ; Register Select bit (PB0)
.define LCD_RW      %00000010    ; Read/Write bit (PB1)
.define LCD_E       %00000100    ; Enable bit (PB2)

; LCD Commands
.define LCD_CLEAR   $01          ; Clear display
.define LCD_HOME    $02          ; Return home
.define LCD_ENTRY   $06          ; Entry mode: increment, no shift
.define LCD_ON      $0C          ; Display on, cursor off
.define LCD_OFF     $08          ; Display off
.define LCD_LINE1   $80          ; Set DDRAM address for line 1
.define LCD_LINE2   $C0          ; Set DDRAM address for line 2
.define LCD_8BIT    $38          ; 8-bit mode, 2 lines, 5x8 font
.define LCD_4BIT    $28          ; 4-bit mode, 2 lines, 5x8 font

.segment "CODE"
.org $8000

;=============================================================================
; EXAMPLE 1: VIA Port Configuration
;=============================================================================
; Configure VIA ports as inputs and outputs

via_port_setup:
    ; Configure Port A: all outputs
    LDA #$FF              ; All pins as outputs
    STA VIA_DDRA
    
    ; Configure Port B: mixed I/O
    ; Bits 0-3 outputs, bits 4-7 inputs
    LDA #%00001111
    STA VIA_DDRB
    
    ; Initialize ports
    LDA #$00
    STA VIA_PORTA         ; Clear Port A
    STA VIA_PORTB         ; Clear Port B outputs

;=============================================================================
; EXAMPLE 2: Basic Port I/O
;=============================================================================
; Read from one port, write to another

via_io_example:
    ; Read from Port A
    LDA VIA_PORTA
    STA $0800             ; Store reading
    
    ; Write to Port B
    LDA #$AA              ; Pattern
    STA VIA_PORTB
    
    ; Read-modify-write
    LDA VIA_PORTB         ; Read current state
    ORA #%00000001        ; Set bit 0
    STA VIA_PORTB         ; Write back
    
    ; Read inputs from upper bits of Port B
    LDA VIA_PORTB
    AND #%11110000        ; Mask input bits
    LSR A                 ; Shift to lower nibble
    LSR A
    LSR A
    LSR A
    STA $0801             ; Store input value

;=============================================================================
; EXAMPLE 3: Timer 1 Free-Running Mode
;=============================================================================
; Configure Timer 1 for continuous counting

timer1_freerun_setup:
    ; Set Timer 1 for free-running mode
    LDA #%01000000        ; T1 continuous, PB7 disabled
    STA VIA_ACR
    
    ; Load Timer 1 latch with count value
    ; For 1 MHz clock, $FF means ~255 microseconds
    LDA #$FF              ; Low byte of count
    STA VIA_T1LL
    LDA #$FF              ; High byte of count
    STA VIA_T1LH
    
    ; Start timer by writing to counter high byte
    LDA #$FF
    STA VIA_T1CH
    
    ; Timer is now running

;=============================================================================
; EXAMPLE 4: Timer 1 One-Shot Mode
;=============================================================================
; Configure Timer 1 for one-shot timing

timer1_oneshot:
    ; Set Timer 1 for one-shot mode
    LDA #%00000000        ; T1 one-shot
    STA VIA_ACR
    
    ; Load counter with delay value
    ; Example: $1000 = 4096 cycles
    LDA #$00              ; Low byte
    STA VIA_T1CL
    LDA #$10              ; High byte
    STA VIA_T1CH          ; Writing high byte starts timer
    
    ; Wait for timer to expire
wait_timer1:
    LDA VIA_IFR           ; Read interrupt flags
    AND #%01000000        ; Check Timer 1 flag
    BEQ wait_timer1       ; Wait until set
    
    ; Clear Timer 1 interrupt flag by reading T1CL
    LDA VIA_T1CL
    
    ; Timer has expired
    NOP

;=============================================================================
; EXAMPLE 5: Timer 2 Pulse Counting
;=============================================================================
; Configure Timer 2 to count pulses on PB6

timer2_pulse_count:
    ; Configure Timer 2 for pulse counting
    LDA #%00100000        ; T2 pulse counting mode
    STA VIA_ACR
    
    ; Load counter with initial value
    LDA #$00              ; Count down from $0100
    STA VIA_T2CL
    LDA #$01
    STA VIA_T2CH
    
    ; Counter now decrements on each PB6 pulse
    ; Read current count
read_pulse_count:
    LDA VIA_T2CL          ; Read low byte
    STA $0810
    LDA VIA_T2CH          ; Read high byte
    STA $0811

;=============================================================================
; EXAMPLE 6: Generate Square Wave with Timer
;=============================================================================
; Generate square wave on PB7 using Timer 1

squarewave_generate:
    ; Configure Timer 1 with PB7 output
    LDA #%11000000        ; T1 continuous, PB7 toggling
    STA VIA_ACR
    
    ; Set Port B bit 7 as output
    LDA VIA_DDRB
    ORA #%10000000
    STA VIA_DDRB
    
    ; Load frequency (example: 1000 Hz at 1 MHz clock)
    ; Count = Clock / (2 * Frequency) = 1000000 / 2000 = 500 = $01F4
    LDA #$F4              ; Low byte
    STA VIA_T1LL
    LDA #$01              ; High byte
    STA VIA_T1LH
    
    ; Start timer
    LDA #$F4
    STA VIA_T1CL
    LDA #$01
    STA VIA_T1CH
    
    ; Square wave now generating on PB7

;=============================================================================
; EXAMPLE 7: Shift Register Mode
;=============================================================================
; Configure VIA for shift register operation (serial I/O)

shift_register_setup:
    ; Configure ACR for shift register mode
    ; Mode 4: Shift out under T2 control
    LDA #%00011100        ; SR mode bits = 111, shift out
    STA VIA_ACR
    
    ; Load shift register
    LDA #%10101010        ; Data to shift out
    STA VIA_BASE+10       ; SR register
    
    ; Timer 2 controls shift rate
    LDA #$10              ; Shift rate
    STA VIA_T2CL
    LDA #$00
    STA VIA_T2CH
    
    ; Data shifts out on CB1, clocked by CB2

;=============================================================================
; EXAMPLE 8: LCD Initialization (4-bit mode)
;=============================================================================
; Initialize HD44780 LCD in 4-bit mode
; Assumes LCD data on PA4-PA7, control on PB0-PB2

lcd_init:
    ; Configure VIA ports
    LDA #$FF              ; Port A all outputs
    STA VIA_DDRA
    LDA #$07              ; PB0-PB2 outputs (RS, RW, E)
    STA VIA_DDRB
    
    ; Wait for LCD power-on (>40ms)
    JSR lcd_long_delay
    
    ; Initialization sequence for 4-bit mode
    LDA #$03              ; Function set: 8-bit mode (initial)
    JSR lcd_init_nibble
    JSR lcd_delay
    
    LDA #$03              ; Function set again
    JSR lcd_init_nibble
    JSR lcd_delay
    
    LDA #$03              ; Function set third time
    JSR lcd_init_nibble
    JSR lcd_delay
    
    LDA #$02              ; Function set: 4-bit mode
    JSR lcd_init_nibble
    JSR lcd_delay
    
    ; Now in 4-bit mode, send full commands
    LDA #LCD_4BIT         ; 4-bit, 2 lines, 5x8 font
    JSR lcd_command
    
    LDA #LCD_OFF          ; Display off
    JSR lcd_command
    
    LDA #LCD_CLEAR        ; Clear display
    JSR lcd_command
    JSR lcd_long_delay    ; Clear needs extra time
    
    LDA #LCD_ENTRY        ; Entry mode
    JSR lcd_command
    
    LDA #LCD_ON           ; Display on
    JSR lcd_command
    
    RTS

; Send initialization nibble (upper 4 bits of A)
lcd_init_nibble:
    ASL A                 ; Shift nibble to upper 4 bits
    ASL A
    ASL A
    ASL A
    STA VIA_PORTA
    
    ; Pulse Enable
    LDA #LCD_E
    STA VIA_PORTB
    NOP
    NOP
    LDA #$00
    STA VIA_PORTB
    
    RTS

;=============================================================================
; EXAMPLE 9: LCD Write Command
;=============================================================================
; Send command to LCD in 4-bit mode

lcd_command:
    PHA                   ; Save command
    
    ; Send upper nibble
    AND #$F0              ; Mask upper nibble
    STA VIA_PORTA
    
    LDA #$00              ; RS=0 (command), RW=0 (write)
    STA VIA_PORTB
    
    LDA #LCD_E            ; Pulse Enable
    STA VIA_PORTB
    NOP
    NOP
    LDA #$00
    STA VIA_PORTB
    
    ; Send lower nibble
    PLA                   ; Restore command
    ASL A                 ; Shift lower nibble to upper
    ASL A
    ASL A
    ASL A
    STA VIA_PORTA
    
    LDA #$00              ; RS=0, RW=0
    STA VIA_PORTB
    
    LDA #LCD_E            ; Pulse Enable
    STA VIA_PORTB
    NOP
    NOP
    LDA #$00
    STA VIA_PORTB
    
    JSR lcd_delay
    RTS

;=============================================================================
; EXAMPLE 10: LCD Write Data (Character)
;=============================================================================
; Send data (character) to LCD in 4-bit mode

lcd_data:
    PHA                   ; Save data
    
    ; Send upper nibble
    AND #$F0              ; Mask upper nibble
    STA VIA_PORTA
    
    LDA #LCD_RS           ; RS=1 (data), RW=0 (write)
    STA VIA_PORTB
    
    ORA #LCD_E            ; Pulse Enable
    STA VIA_PORTB
    NOP
    NOP
    LDA #LCD_RS           ; E low
    STA VIA_PORTB
    
    ; Send lower nibble
    PLA                   ; Restore data
    ASL A                 ; Shift lower nibble to upper
    ASL A
    ASL A
    ASL A
    STA VIA_PORTA
    
    LDA #LCD_RS           ; RS=1, RW=0
    STA VIA_PORTB
    
    ORA #LCD_E            ; Pulse Enable
    STA VIA_PORTB
    NOP
    NOP
    LDA #LCD_RS           ; E low
    STA VIA_PORTB
    
    JSR lcd_delay
    RTS

;=============================================================================
; EXAMPLE 11: LCD Print String
;=============================================================================
; Print null-terminated string to LCD

lcd_print_string:
    ; Initialize LCD
    JSR lcd_init
    
    ; Set cursor to line 1
    LDA #LCD_LINE1
    JSR lcd_command
    
    ; Print string
    LDX #$00
print_loop:
    LDA lcd_message,X
    BEQ print_done
    JSR lcd_data
    INX
    JMP print_loop
    
print_done:
    RTS

lcd_message:
    .byte "Hello, LCD!", $00

;=============================================================================
; EXAMPLE 12: LCD Custom Character
;=============================================================================
; Define and display custom character

lcd_custom_char:
    ; Set CGRAM address (character 0)
    LDA #$40              ; CGRAM address 0
    JSR lcd_command
    
    ; Write 8 bytes of character data
    LDX #$00
custom_loop:
    LDA custom_char_data,X
    JSR lcd_data
    INX
    CPX #$08
    BNE custom_loop
    
    ; Return to DDRAM
    LDA #LCD_LINE1
    JSR lcd_command
    
    ; Display custom character (code 0)
    LDA #$00
    JSR lcd_data
    
    RTS

custom_char_data:
    .byte %00000000       ; Row 0
    .byte %00001010       ; Row 1
    .byte %00001010       ; Row 2
    .byte %00000000       ; Row 3
    .byte %00010001       ; Row 4
    .byte %00001110       ; Row 5
    .byte %00000000       ; Row 6
    .byte %00000000       ; Row 7

;=============================================================================
; EXAMPLE 13: Interrupt Setup (IRQ)
;=============================================================================
; Configure VIA interrupts

interrupt_setup:
    ; Disable interrupts during setup
    SEI
    
    ; Configure Timer 1 for interrupts
    LDA #%01000000        ; T1 continuous mode
    STA VIA_ACR
    
    ; Set Timer 1 interval (example: 10ms at 1MHz)
    ; Count = 10000 = $2710
    LDA #$10
    STA VIA_T1LL
    LDA #$27
    STA VIA_T1LH
    
    ; Start timer
    LDA #$10
    STA VIA_T1CL
    LDA #$27
    STA VIA_T1CH
    
    ; Enable Timer 1 interrupts
    LDA #%11000000        ; Enable T1, set bit 7 to enable
    STA VIA_IER
    
    ; Clear any pending interrupts
    LDA VIA_T1CL
    
    ; Enable CPU interrupts
    CLI
    
    RTS

;=============================================================================
; EXAMPLE 14: IRQ Handler
;=============================================================================
; Interrupt service routine

irq_handler:
    ; Save registers
    PHA
    TXA
    PHA
    TYA
    PHA
    
    ; Check which interrupt occurred
    LDA VIA_IFR
    AND #%01000000        ; Timer 1 interrupt?
    BEQ check_other_irq
    
    ; Handle Timer 1 interrupt
    INC $0900             ; Increment counter
    
    ; Toggle LED
    LDA $0900
    AND #$01
    BEQ led_off
    LDA #$FF
    STA VIA_PORTA
    JMP irq_clear
    
led_off:
    LDA #$00
    STA VIA_PORTA
    
irq_clear:
    ; Clear Timer 1 interrupt flag
    LDA VIA_T1CL          ; Reading T1CL clears interrupt
    
check_other_irq:
    ; Check for other interrupt sources here
    
irq_done:
    ; Restore registers
    PLA
    TAY
    PLA
    TAX
    PLA
    
    RTI                   ; Return from interrupt

;=============================================================================
; EXAMPLE 15: CA1/CA2 Edge Detection
;=============================================================================
; Configure CA1 for positive edge detection

edge_detection_setup:
    ; Configure CA1 for positive edge interrupt
    LDA VIA_PCR
    ORA #%00000001        ; CA1 positive edge
    STA VIA_PCR
    
    ; Enable CA1 interrupt
    LDA #%10000010        ; Enable CA1 (bit 1), set bit 7
    STA VIA_IER
    
    ; Configure CA2 as output
    LDA VIA_PCR
    ORA #%00001100        ; CA2 output mode
    STA VIA_PCR
    
    RTS

;=============================================================================
; LCD Utility Subroutines
;=============================================================================

; Short delay for LCD operations
lcd_delay:
    PHA
    LDA #$FF
lcd_d1:
    DEC
    BNE lcd_d1
    PLA
    RTS

; Long delay for LCD initialization and clear
lcd_long_delay:
    PHA
    PHX
    LDX #$FF
lcd_d2:
    LDA #$FF
lcd_d3:
    DEC
    BNE lcd_d3
    DEX
    BNE lcd_d2
    PLX
    PLA
    RTS

;=============================================================================
; Reset and Main Loop
;=============================================================================

reset:
    ; Initialize stack pointer
    LDX #$FF
    TXS
    
    ; Initialize VIA
    JSR via_port_setup
    
    ; Choose example to run:
    ; JSR lcd_init
    ; JSR lcd_print_string
    ; JSR interrupt_setup
    
    ; Main loop
main_loop:
    NOP
    JMP main_loop

;=============================================================================
; Interrupt Vectors
;=============================================================================
.segment "VECTORS"
.org $FFFA
.word $0000               ; NMI vector (not used)
.word reset               ; Reset vector
.word irq_handler         ; IRQ vector
