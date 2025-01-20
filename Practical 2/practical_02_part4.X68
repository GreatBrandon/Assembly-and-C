*-----------------------------------------------------------
* Title      :Part 4
* Written by :Brandon Jaroszczak C00296052
* Date       :20/1/25
* Description:Practical 2 part 4
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here
    ; Copy the binary, hex and literal numbers 10101010 into registers D0, D1, D2
    MOVE.L #%10101010, D0
    MOVE.L #$10101010, D1
    MOVE.L #10101010, D2
    
    ; Copy the word contents of registers D0, D1, D2 into hex memory locations 2000,2010,2020
    MOVE.W D0, $2000
    MOVE.W D1, $2010
    MOVE.W D2, $2020
    
    ; Copy the byte contents of hex memory locations 2000,2010,2020 into registers D3,D4,D5
    MOVE.B $2000, D3
    MOVE.B $2010, D4
    MOVE.B $2020, D5
    
    ; Copy the binary, hex and literal numbers into regsiters A1, A2, A3
    MOVE.L #$ABCDEF10, A1
    MOVE.L #%1001, A2
    MOVE.L #1001, A3
    
    ; Copy the contents of registers A1, A2, A3 into hex memory locations 2030,2040,2050
    MOVE.L A1, $2030
    MOVE.L A2, $2040
    MOVE.L A3, $2050
    
    ; Copy the word size hex, binary and literal numbers into memory locations 2030,2040,2050
    MOVE.W #$DDDD, $2030
    MOVE.W #%1001, $2040
    MOVE.W #1001, $2050

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
