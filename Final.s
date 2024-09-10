    AREA    Reaction_Game, CODE, READONLY  ; Define a code section named Reaction_Game
    EXPORT  __main                         

__main PROC                                ; Begin a procedure named __main
    ; Configure GPIO
    LDR     R0, =0x40004C00               ; Load base address of Port 4 GPIO registers into R0
    ADD     R0, #0x21                     ; Adjust the address to point to the P4DIR and P4OUT registers
    MOV     R1, #0xF0                     ; P4.0 - P4.3 input, P4.4 - P4.7 output, 4.7 not needed
    STRB    R1, [R0, #0x04]               ; Store the value in the P4DIR register to configure direction

    ; Turn off all LEDs initially
    MOV     R1, #0x00                     ; Clear R1, setting it to 0x00
    STRB    R1, [R0, #0x02]               ; Clear R1, setting it to 0x00

    ; Small delay to stabilize
    BL      delay_short

    ; Long delay before starting the game for players to get ready
    BL      long_delay

    ; Turn on center LED (P4.4) to signal the start of the game
    MOV     R1, #0x10
    STRB    R1, [R0, #0x02]               ; P4OUT

start_game
    ; Wait for any button press
wait_press
    LDRB    R3, [R0]                      ; Read P4IN
    AND     R4, R3, #0x03                 ; Mask for P4.0 (Player 1 button) and P4.1 (Player 2 button)
    CMP     R4, #0x00                     ; Check if any button is pressed
    BEQ     wait_press

    ; Debounce logic
    BL      debounce
    LDRB    R3, [R0]                      ; Read P4IN again after debounce
    AND     R4, R3, #0x03                 ; Mask for P4.0 (Player 1 button) and P4.1 (Player 2 button)
    CMP     R4, #0x00                     ; Check if any button is pressed
    BEQ     wait_press

    ; Determine which player pressed the button first
    AND     R4, R3, #0x01                 ; Mask for P4.0 (Player 1 button)
    CMP     R4, #0x00                     ; Compare the result to 0
    BEQ     player1_wins                  ; If P4.0 is pressed, Player 1 wins


    AND     R4, R3, #0x02                 ; Mask for P4.1 (Player 2 button)
    CMP     R4, #0x00                     ; Compare the result to 0
    BEQ     player2_wins                  ; If P4.1 is pressed, Player 2 wins

player1_wins
    ; Turn off center LED and turn on Player 1 LED (P4.5)
    MOV     R1, #0x20                     ; Load 0x20 into R1, setting P4.5 high
    STRB    R1, [R0, #0x02]               ; Store the value in P4OUT to turn on the Player 1 LED
    BL      delay                         ; Call delay function
    B       stop                          ; Stop the program

player2_wins
    ; Turn off center LED and turn on Player 2 LED (P4.6)
    MOV     R1, #0x40                     ; Load 0x40 into R1, setting P4.6 high
    STRB    R1, [R0, #0x02]               ; Store the value in P4OUT to turn on the Player 2 LED
    BL      delay                         ; Call delay function
    B       stop                          ; Stop the program

stop
    B       stop                          ; Infinite loop to stop the program
    ENDP                                 ; End of __main procedure

debounce PROC
    ; Simple debounce routine
    MOV     R5, #0x1000                   ; Set a small delay for debounce
debounce_loop
    SUBS    R5, R5, #1                    ; Decrement R5
    BNE     debounce_loop
    BX      LR
    ENDP                                 ; End of debounce procedure

delay PROC
    PUSH    {R0-R3, LR}                  ; Save registers R0-R3 and the link register on the stack
    MOV     R0, #0xFFFF                  ; Load a large value into R0 for the delay loop
delay_loop
    SUBS    R0, R0, #1                   ; Decrement R0
    BNE     delay_loop                   ; If R0 is not zero, loop back
    POP     {R0-R3, LR}                  ; Restore registers R0-R3 and the link register from the stack
    BX      LR                           ; Return from delay routine
    ENDP                                 ; End of delay procedure

delay_short PROC
    PUSH    {R0, LR}                     ; Save R0 and the link register on the stack
    MOV     R0, #0x0FFF                  ; Load a smaller value into R0 for a shorter delay
delay_short_loop
    SUBS    R0, R0, #1                   ; Decrement R0
    BNE     delay_short_loop             ; If R0 is not zero, loop back
    POP     {R0, LR}                     ; Restore R0 and the link register from the stack
    BX      LR                           ; Return from delay_short routine
    ENDP                                 ; End of delay_short procedure

long_delay PROC
    PUSH    {R0, LR}                     ; Save R0 and the link register on the stack
    LDR     R0, =0xFFFFF                 ; Load a very large value into R0 for a long delay
long_delay_loop
    SUBS    R0, R0, #1                   ; Decrement R0
    BNE     long_delay_loop              ; If R0 is not zero loop back
    POP     {R0, LR}                     ; Restore R0 and the link register from the stack
    BX      LR                           ; Return from long_delay routine
    ENDP                                 ; End of long_delay procedure

    END                                  ; End
