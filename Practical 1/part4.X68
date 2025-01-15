*-----------------------------------------------------------
* Title      :Part 4
* Written by :Brandon Jaroszczak C00296052
* Date       :13/1/25
* Description:Practical 1 part 4
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here
    LEA text, A1        ; Load the memory location of "text" and store it in register A1
    MOVE #4, D0         ; Copy the literal value 4 into register D4
    TRAP #15            ; Call TRAP #15 which is used for I/O, the task number is stored in register D0
                        ; Task no is 4, which reads a single number from the keyboard and stores in register D1.L
    MOVE #14, D0        ; Move the literal value 14 into D0
    TRAP #15            ; Task 14 is called, displays the NULL terminated String at A1 without CR,LF
    MOVE #3, D0         ; Move the literal value 3 into D0
    TRAP #15            ; Task 3 is called, which displays signed number in D1.L in decimal
    
    SIMHALT             ; halt simulator

* Put variables and constants here

text dc.b 'Data Register: ',0

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
