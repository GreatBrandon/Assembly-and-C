*-----------------------------------------------------------
* Title      :Part 2
* Written by :Brandon Jaroszczak C00296052
* Date       :26/2/2025
* Description:Practical 6 part 2
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here
    LEA MESSAGE, A1
    MOVE.W #10, D1
    ; Move trap task to D0
    MOVE.B #0, D0 ; display String in A1 D1.W bytes long with CR LF
    TRAP #15
    
    MOVE.B #1, D0 ; display String in A1 D1.W bytes long without CR LF
    TRAP #15
    
    MOVE.B #2, D0 ; read string from keyboard and store in A1
    TRAP #15
    
    MOVE.L #1000, D1
    MOVE.B #3, D0 ; display number in D1
    TRAP #15
    
    MOVE.B #4, D0 ; read number from keyboard into D1.L
    TRAP #15
    
    MOVE.B #5, D0 ; read character from keyboard into D1.B
    TRAP #15
    
    MOVE.B #6, D0 ; display single character in D1.B
    TRAP #15
    
    MOVE.B #7, D0 ; check is keyboard input pending, set D1.B to 1 if true 0 if false
    TRAP #15
    
    MOVE.B #8, D0 ; return time in 100s of a second since midnight in D1.L
    TRAP #15
    
    ; task 9 skipped terminates program
    
    ; task 10 doesnt exist
    
    MOVE.B #11, D0 ; clear screen
    TRAP #15
    
    MOVE.B #12, D0 ; keyboard echo
    TRAP #15
    
    MOVE.B #13, D0 ; display null terminated string at A1 with CR LF
    TRAP #15
    
    MOVE.B #14, D0 ; display null terminated string at A1 without CR LF
    TRAP #15
    
    ; task 15 doesnt exist
    
    MOVE.B #16, D0 ; adjust display properties using D1.B
    TRAP #15
    
    MOVE.B #17, D0 ; combination of trap tasks 14 and 3
    TRAP #15
    
    MOVE.B #18, D0 ; combination of trap tasks 14 and 4
    TRAP #15
    
    MOVE.B #19, D0 ; returns state of up to 4 specified keys or returns key scan code
                   ; D1.L = four 1 byte key codes
    TRAP #15
    
    MOVE.L #1234, D1
    MOVE.B #2, D2
    MOVE.B #20, D0 ; display signed number in D1.L in decimal in field D2.B columns wide
    TRAP #15
    
    MOVE.B #21, D0 ; set font colour
    TRAP #15
    
    MOVE.B #22, D0 ; read char at row col of text screen
    TRAP #15
    
    MOVE.B #9, D0 ; terminate program
    TRAP #15
END_PROG:
    SIMHALT             ; halt simulator

* Put variables and constants here
MESSAGE: DC.B 'Trap task test', 0
    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
