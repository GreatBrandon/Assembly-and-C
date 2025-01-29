*-----------------------------------------------------------
* Title      :Part 3
* Written by :Brandon Jaroszczak C00296052
* Date       :29/1/2025
* Description:Practical 4 part 3
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here

    ; Move health to memory location $3000
    MOVE.B #100, $3000
    
    ; Load memory address $3000 into address register A1
    LEA $3000, A1
    
    ; Branch to TAKING_DAMAGE
    BSR TAKING_DAMAGE   ; Branch to the TAKING_DAMAGE subroutine

BACK_IN_THE_GAME:
    ; lets help this player out
    ; BSR saves the return address onto the stack so it can be accessed later
    ; BRA doesn't do that and subroutines can't return
    BSR HEALTH_PICKUP   ; Branch to the HEALTH_PICKUP subroutine
    BRA GAME_END        ; Branch always to the GAME_END subroutine
TAKING_DAMAGE:
    ; Hit by NPC
    SUB.B #20, (A1)     
    BRA BACK_IN_THE_GAME ;Branch always to the BACK_IN_THE_GAME subroutine
    
HEALTH_PICKUP:
    ; Pickup health found
    ADD.B #10, (A1)
    RTS                 ; Return to the address stored on the top of the stack
                        ; (The address of the instruction that called BSR HEALTH_PICKUP)
    
GAME_END:
    ; Game over
    MOVE.B #$00, (A1)

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
