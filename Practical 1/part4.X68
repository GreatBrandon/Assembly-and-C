*-----------------------------------------------------------
* Title      :Part 4
* Written by :Brandon Jaroszczak C00296052
* Date       :13/1/25
* Description:Practical 1 part 4
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here
    LEA text, A1
    MOVE #4, D0
    TRAP #15
    MOVE #14, D0
    TRAP #15
    MOVE #3, D0
    TRAP #15
    
    SIMHALT             ; halt simulator

* Put variables and constants here

text dc.b 'Data Register: ',0

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
