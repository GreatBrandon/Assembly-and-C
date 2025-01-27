*-----------------------------------------------------------
* Title      :Part 1
* Written by :Brandon Jaroszczak C00296052
* Date       :27/1/2025
* Description:Practical 3 part 1
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here

    LEA $4000, A1       ; Load the hex memory address 4000 into register A1
    MOVE.B #100, (A1)   ; Move the byte literal 100 into the memory address stored in A1

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
