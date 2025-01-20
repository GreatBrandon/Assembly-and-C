*-----------------------------------------------------------
* Title      :Part 2
* Written by :Brandon Jaroszczak C00296052
* Date       :20/1/25
* Description:Practical 2 part 2
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here

    MOVE.L #%100, D0    ; Copy the binary literal 100 into register D0
    MOVE.L #$100, D1    ; Copy the hex literal 100 into register D1
    MOVE.L #100, D2     ; Copy the literal 100 into register D2
    
    MOVE.L D0, $3000    ; Copy register D0 into hex memory location 3000
    MOVE.L D1, $3010    ; Copy register D1 into hex memory location 3010
    MOVE.L D2, $3020    ; Copy register D2 into hex memory location 3020
    
    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
