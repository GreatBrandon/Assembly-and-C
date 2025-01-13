*-----------------------------------------------------------
* Title      :Part 2
* Written by :Brandon Jaroszczak C00296052
* Date       :13/1/2025
* Description:Practical 1 part 2
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program


* Put program code here
    MOVE.L #%00001111,D1
    MOVE.B D1,D2
    MOVE.B D1,$2000
    MOVE.B $2000,D2
    MOVE.B $2000,$3000
    
    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
