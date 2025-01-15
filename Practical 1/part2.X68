*-----------------------------------------------------------
* Title      :Part 2
* Written by :Brandon Jaroszczak C00296052
* Date       :13/1/2025
* Description:Practical 1 part 2
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program


* Put program code here
    MOVE.L #%00001111,D1    ; Move the long (32 bits) literal (#) binary (%) number 00001111 into register D1
    MOVE.B D1,D2            ; Copy the last byte (B) of register D1 into register D2
    MOVE.B D1,$2000         ; Copy the last byte of register D1 into memory location 2000 in hex ($)
    MOVE.B $2000,D2         ; Copy the last byte of memory location 2000 in hex into register D2
    MOVE.B $2000,$3000      ; Copy the last byte of memory location 2000 in hex into memory location 3000 in hex
    
    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
