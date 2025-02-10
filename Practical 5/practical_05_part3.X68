*-----------------------------------------------------------
* Title      : Part 3
* Written by : Brandon Jaroszczak C00296052
* Date       : 10/2/2025
* Description: Pracitcal 5 part 3
*-----------------------------------------------------------
    ORG    $1000
    
DAMAGE EQU 100 ; Define constant DAMAGE with value 100
START:                  ; first instruction of program

* Put program code here
GAME_LOOP:
    LEA MSG_GAME_LOOP, A1   ; Load address of variable into A1
    MOVE.B #13, D0  ; Move 13 into D0
    TRAP #15        ; Execute trap 13 (display String in (A1))
    CMP.B #0, PLAYER_HEALTH ; Compare D0 and value of player health
    BEQ GAME_OVER   ; Branch if equal
    BSR UPDATE      ; Branch to subroutine
    BSR COLLISION_CHECK ; Branch to subroutine
    BRA GAME_LOOP   ; Branch always
    
UPDATE:
    ADD.B #1, PLAYER_POSITION ; Add 1 to player positions
    RTS ; Return

COLLISION_CHECK:
    MOVE.B PLAYER_POSITION, D1 ; Move player position into D1
    CMP.B D2, D1    ; Compare D2 and D1
    BEQ COLLISION   ; Branch if equal
    RTS             ; Return
    
COLLISION:
    SUB.B #DAMAGE, PLAYER_HEALTH    ; Subtract damage from player health
    BRA GAME_LOOP   ; Branch always
    
GAME_OVER:
    LEA MSG_GAME_OVER, A1   ; Load address of game over message into A1
    MOVE.B #13, D0          ; Move 13 into D0
    TRAP #15                ; Trap 13 (display String at (A1))
    SIMHALT             ; halt simulator

* Put variables and constants here

PLAYER_POSITION: DC.B 10
ENEMY_POSITION: DC.B 50
PLAYER_HEALTH: DC.B 100

MSG_GAME_LOOP DC.B 'Game Loop.....', 0
MSG_GAME_OVER DC.B 'Game over!', 0

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
