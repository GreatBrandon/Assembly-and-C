*-----------------------------------------------------------
* Title      :Part 3
* Written by :Brandon Jaroszczak C00296052
* Date       :13/1/2025
* Description:Practical 1 part 3
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here

    MOVE.B #$64, D1     ; Copy the byte of the literal hex value 64 into D1
                        ; LEA = Load Effective Address
    LEA text, A1        ; Copy the memory location of the variable "text" into register A1
    MOVE #14, D0        ; Copy the literal 14 into register D0
    TRAP #15            ; TRAP #15 is used for I/O, the task number is stored in register D0 (in this case 14)
                        ; this displays the NULL terminated String at register A1 without CR,LF
    MOVE #3, D0         ; Copy the literal 3 into register D0
    TRAP #15            ; This time TRAP #15 uses task number 3 (stored in D0)
                        ; Task 3 displays signed number in register D1.L in decimal
    SIMHALT             ; halt simulator

* Put variables and constants here
text dc.b 'Data Register: ',0   ;dc.b means "Define constant byte"
                                ;this stores the String 'Data Register: ' with the label "text"
                                ;0 represents a NULL terminator (0 in ascii is null) used to mark the end of the String
                                
    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
