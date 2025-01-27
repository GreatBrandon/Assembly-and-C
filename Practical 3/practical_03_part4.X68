*-----------------------------------------------------------
* Title      :Part 4
* Written by :Brandon Jaroszczak C00296052
* Date       :27/1/2025
* Description:Practical 3 part 4
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here

    ; Load the memory addresses of the variables below into registers A1-7
    LEA POINTS, A1
    LEA HEALTH, A2
    LEA PLAYERX, A3
    LEA PLAYERY, A4
    LEA BOSSHEALTH, A5
    LEA BOSSX, A6
    LEA BOSSY, A7
    
    ; Adjust/add player X and Y coordinates stored in the memory locations stored in registers A3, A4
    ADD.B #100, (A3)
    ADD.B #100, (A4)
    
    ; Adjust/subtract boss X and Y coordinates stored in the memory locations stored in registers A6. A7
    SUB.W #100, (A6)
    SUB.W #100, (A7)
    
    ; Subtract boss and player health stored in the memory locations stored in registers A5 and A2
    SUB.W #500, (A5)
    SUB.B #70, (A2)
    SUB.W #500, (A5)
    
    ; Increase player points stored in the memory location stored in register A1
    ADD.L #1000, (A1)
    ; Copy the value stored in the memory location stored in register A1 into register D1
    MOVE.L (A1), D1

    SIMHALT             ; halt simulator

* Put variables and constants here

POINTS dc.l $0 
HEALTH dc.b $64
PLAYERX dc.b 100
PLAYERY dc.b 100
BOSSHEALTH dc.w 1000
BOSSX dc.w 300
BOSSY dc.w 300

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
