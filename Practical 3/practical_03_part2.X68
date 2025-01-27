*-----------------------------------------------------------
* Title      :Part 2
* Written by :Brandon Jaroszczak C00296052
* Date       :27/1/2025
* Description:Practical 3 part 2
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here
    
    LEA $4000, A2       ; Load the hex memory address 4000 into register A2
    MOVE.B #100, (A2)   ; Move the byte literal 100 into the memory location stored in register A2
    SUB.B #10, (A2)     ; Subtract the byte literal 10 from the value stored in memory location stored in register A2
    
    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
