*-----------------------------------------------------------
* Title      :Part 3
* Written by :Brandon Jaroszczak C00296052
* Date       :27/1/2025
* Description:Practical 3 part 3
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here

    LEA HEALTH, A3      ; Load the memory location of the variable HEALTH and store it in register A3
    SUB.B #10, (A3)     ; Subtract byte literal 10 from the memory location stored in register A3

    SIMHALT             ; halt simulator

* Put variables and constants here

HEALTH dc.b $64 
    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
