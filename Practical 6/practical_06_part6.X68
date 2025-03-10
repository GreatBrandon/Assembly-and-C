*-----------------------------------------------------------
* Title      : Part 6
* Written by : Brandon Jaroszczak C00296052
* Date       : 10/3/2025
* Description: Practical 6 part 6
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here

    MOVE.L #HEALTH, -(SP) ; Note position in stack
    
    MOVE.B #14, D0
    MOVE.B #14, D1
    
    MOVE.L D0, -(SP) ; player x
    MOVE.L D1, -(SP) ; enemy x
    
    JSR GAME_LOOP
    BSR HEADS_UP_DISPLAY
    BRA END_GAME
    
GAME_LOOP:
    
    MOVE.L 4(SP), D1 ; Note depth in stack
    MOVE.L 8(SP), D0 ; Note depth in stack
    
    CMP D0, D1
    BEQ DAMAGE
    BRA NO_DAMAGE
    
DAMAGE:
    MOVEA.L 12(SP), A1 ; Note depth in stack
    SUB.B #10, (A1)
NO_DAMAGE:
    RTS
    
HEADS_UP_DISPLAY:
    MOVE.B HEALTH, D1
    MOVE.B #3, D0
    TRAP #15
    RTS
    
END_GAME:
    SIMHALT             ; halt simulator

* Put variables and constants here
HEALTH: DC.B 100
    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
