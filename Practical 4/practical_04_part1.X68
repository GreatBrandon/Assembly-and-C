*-----------------------------------------------------------
* Title      :Part 1
* Written by :Brandon Jaroszczak C00296052
* Date       :29/1/2025
* Description:Practical 4 part 4
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here
    ; Move health to memory location $3000
    MOVE.B #100, $3000
    
    ; Load memory address $3000 into address register A1
    LEA $3000, A1
    
    ; Hit by NPC
    SUB.B #20, (A1) ; subtract 20 from the contents of the memory location stored in register A1
    
    ; Pickup health found
    ADD.B #10, (A1) ; add 10 to the contents of the memory location stored in register A1

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
