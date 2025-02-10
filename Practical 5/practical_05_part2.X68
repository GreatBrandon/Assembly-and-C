*-----------------------------------------------------------
* Title      :Part 2
* Written by :Brandon Jaroszczak C00296052
* Date       :10/2/2025
* Description:Practical 5 part 2
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here

    LEA PLAYER_POSITION, A1 ; Load variable addresses into address registers
    LEA ENEMY_POSITION, A2
    
    MOVE.B (A1)+, D1 ; Load player x and y into D1 and D2
    MOVE.B (A1), D2
    MOVE.B (A2)+, D3 ; Load enemy x and y into D3 and D4
    MOVE.B (A2), D4
    
COLLISION_CHECK:
    CMP D3, D1      ; Compare D3 and D1 (player and emeny x)
    BLT NEXT_MOVE   ; Branch if less than
    BEQ COLLISION   ; Branch if equal (i.e player x = enemy x)
    
NEXT_MOVE:
    ADD.B #1, D1    ; Add 1 to player x and y positions
    ADD.B #1, D2    ;
    BRA COLLISION_CHECK ; Branch always
    
COLLISION:
    CMP D4, D2      ; Compare D4 and D2 (player and emeny y)
    BLT NEXT_MOVE   ; Branch if less than (player and emeny y not equal no collision)
    BRA GAME_OVER   ; Branch always (i.e. player x,y is identical to enemy x,y)
    
GAME_OVER:
    SIMHALT             ; halt simulator

* Put variables and constants here
PLAYER_POSITION: DC.B 10, 15
ENEMY_POSITION: DC.B 50, 55

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
