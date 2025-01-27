*-----------------------------------------------------------
* Title      :Part 5
* Written by :Brandon Jaroszczak
* Date       :27/1/2025
* Description:Practical 3 part 5
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here

    MOVEA.L #ACHIEVEMENT_POINTS, A1 ; Move the address of this variable into register A1 (same as LEA)
    MOVE.L #0, D0       ; Move the long literal 0 into register D0
    
    MOVE.L (A1)+, D2    ; Copy the value stored in the memory location stored in register A1 into register D2, then increment the value stored in A1 by a long (32 bits/4 bytes)
    ADD.L D2, D0        ; Add the value stored in the registers D2 and D0 and store the result in register D0
    ; Repeat the above code 4 more times, each time pointing to the next location in the array and adding the value at that location into register D0
    MOVE.L (A1)+, D2
    ADD.L D2, D0
        
    MOVE.L (A1)+, D2
    ADD.L D2, D0
        
    MOVE.L (A1)+, D2
    ADD.L D2, D0
        
    MOVE.L (A1)+, D2
    ADD.L D2, D0
    
    SIMHALT             ; halt simulator

* Put variables and constants here

ACHIEVEMENT_POINTS: DC.L 5,10,15,20,30

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
