*-----------------------------------------------------------
* Title      :Part 1
* Written by :Brandon Jaroszczak C00296052
* Date       :10/2/2025
* Description:Practical 5 part 1
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here

INITIALISE:
    MOVE.B  #3, D0      ; Move 3 to D0
    MOVE.B  #0, D1      ; Move 0 to D1
    
GAME_LOOP:
    CMP.B   #1, D0      ; compare D0 and #1
    BNE     GAME_POINTS ; Branch if not equal
    BEQ     GAME_OVER   ; Branch if equal
    
GAME_POINTS:
    ADD.B   #10, D1     ; Add 10 to D1
    SUB.B   #1, D0      ; Subtract 1 from D0
    BRA     GAME_LOOP   ; Branch always
    
GAME_OVER:
    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
