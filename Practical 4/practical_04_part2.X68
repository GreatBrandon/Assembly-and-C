*-----------------------------------------------------------
* Title      :Part 2
* Written by :Brandon Jaroszczak C00296052
* Date       :29/1/2025
* Description:Practical 4 part 2
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here

    ; Move health to memory location $3000
    MOVE.B #100, $3000
    
    ; Move location of player to data register D2
    ; X = 1st byte 0-15
    ; Y = 2nd byte 0-15
    MOVE.B #$12, D2
    
    ; Move location of NPC to data register D3
    ; X = 1st byte 0-15
    ; Y = 2nd byte 0-15
    MOVE.B #$22, D3
    
    ; Bitwise AND D2 and D3
    ; Whats new location of player
    
    ; 00010010 (D2)
    ; 00100010 (D3)
    ; -------------------
    ; 00000010 (result stored in D3)
    AND.B D2, D3
    
    ; Load memory address $3000 into address register A1
    LEA $3000, A1
    
    ; Hit by NPC
    SUB.B #20, (A1)
    
    ; Pickup health found
    ADD.B #10, (A1)
    
    ; Examples of OR, NOT and EOR below
    MOVE.B #$22, D3 ; reset D3 back to #$22    
    OR.B D2, D3     ; Performs a bitwise OR operation on D2, D3 and stores result in D3
    MOVE.B #$22, D3 ; reset D3 back to #$22
    NOT.B D3    ; performs a bitwise NOT operation on D3 and stores result in D3
    MOVE.B #$22, D3 ; reset D3 back to #$22
    EOR.B D2, D3    ; performs a bitwise XOR operation on D2, D3 and stores result in D3
    
    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
