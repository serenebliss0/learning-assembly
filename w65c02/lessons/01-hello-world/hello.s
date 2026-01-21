; hello.s - Your first W65C02 program
; This program writes "Hello, World!" to memory location $6000
; py65mon can read this location and display it

.segment "CODE"
.org $8000              ; Start program at address $8000

reset:
    LDX #$00           ; Initialize X register to 0

loop:
    LDA message,X      ; Load character from message into A
    BEQ done          ; If zero (end of string), we're done
    STA $6000         ; Store character to output location
    INX               ; Increment X (move to next character)
    JMP loop          ; Jump back to loop

done:
    JMP done          ; Loop forever (halt)

message:
    .byte "Hello, World!", $00    ; Our message, null-terminated

; Interrupt vectors
.segment "VECTORS"
.org $FFFC
.word reset           ; Reset vector points to our start
.word $0000           ; NMI vector (not used)
