*-----------------------------------------------------------
* Title      :Part 3
* Written by :Brandon Jaroszczak C00296052
* Date       :26/2/2025
* Description:Pracitcal 6 part 3
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here
    LEA $4000, A7
    
    MOVE.B #1, -(A7)
    MOVE.B #2, -(A7)
    MOVE.B #3, -(A7)
    MOVE.B #4, -(A7)
    
    MOVE.B (A7)+, D1
    MOVE.B (A7)+, D1
    MOVE.B (A7)+, D1
    MOVE.B (A7)+, D1
    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
