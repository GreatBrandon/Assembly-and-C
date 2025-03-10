*-----------------------------------------------------------
* Title      :Part 1
* Written by :Brandon Jaroszczak C00296052
* Date       :24/2/2025
* Description:Practical 6 part 1
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here

    ; Move trap task to D0
    MOVE.B #2, D0
    ; Interupt and trap task
    TRAP #15
    
    LEA MESSAGE, A1
    MOVE.B #13, D0
    TRAP #15
    
END_PROG:
    SIMHALT             ; halt simulator

* Put variables and constants here
MESSAGE: DC.B 'Trap task test', 0
    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
