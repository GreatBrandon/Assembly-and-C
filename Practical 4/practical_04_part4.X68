*-----------------------------------------------------------
* Title      :Part 4
* Written by :Brandon Jaroszczak C00296052
* Date       :29/1/2025
* Description:Practical 4 part 4
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here
    
    ; load addresses of variables into address registers
    LEA HEALTH, A1
    LEA POSITION, A2
    LEA BOSSHEALTH, A3
    LEA BOSSPOSITION, A4
    LEA POINTS, A5
    ; run the code subroutines
    BSR START_NEW_GAME
    BSR MOVE_PLAYER
    BSR MOVE_BOSS
    BSR HIT_BOSS
    BSR TAKE_DAMAGE
    BSR HIT_BOSS
    BSR TAKE_DAMAGE
    BSR HIT_BOSS
    BSR TAKE_DAMAGE
    BSR TAKE_DAMAGE
    BSR PICKUP_HEALTH
    BSR HIT_BOSS
    BSR TAKE_DAMAGE
    BSR TAKE_DAMAGE
    BSR HIT_BOSS
    BRA END ; exit the program by calling this, it will never return and therefore won't loop infinitely
    
START_NEW_GAME:
                        ; initialises all values to default for new game
    MOVE.B #100, (A1)
    MOVE.B #$11, (A2)
    MOVE.W #1000, (A3)
    MOVE.B #$55, (A4)
    MOVE.W #0, (A5)
    RTS                 ; exit the branch and return to next instruction
    
TAKE_DAMAGE:
    SUB.B #10, (A1)     ; subtract 10 damage from player
    RTS                 ; return
    
PICKUP_HEALTH:
    ADD.B #50, (A1)     ; add 50 health to player
    CMP.B #100, (A1)    ; compare does the player have more than 100 health or not
    BHI SET_MAX_HEALTH  ; if player has more than 100 health, branch to this subroutine
    RTS                 ; return

SET_MAX_HEALTH:
    MOVE.B #100, (A1)   ; sets the max health to 100 if above 100
    RTS                 ; return
    
HIT_BOSS:
    SUB.W #200, (A3)    ; subtract 200 from boss health (stored in address in A3)
    CMP.W #0, (A3)      ; compares if boss health (memory location stored in A3) <= 0 
    BLS VICTORY         ; if boss health <= 0 run this subroutine
    RTS                 ; return
    
VICTORY:
    ADD.W #1000, (A5)   ; add 1000 to points
    MOVE.W (A5), D3     ; show points in D3
    RTS                 ; return
    
MOVE_PLAYER:
    MOVE.B (A2), D1     ; move player pos to D1
    MOVE.B (A4), D2     ; move boss pos to D2
    EOR.B D2, D1        ; do a xor operation and store result as new player position in D1
    MOVE.B D1, (A2)     ; save new player pos to memory
    RTS                 ; return
    
MOVE_BOSS:
    MOVE.B (A2), D1     ; move player pos to D1
    MOVE.B (A4), D2     ; move boss pos to D2
    AND.B D1, D2        ; do a and operation and store the result as new boss position in D2
    MOVE.B D2, (A4)     ; save new boss pos to memory
    RTS                 ; return
    
END:
    SIMHALT             ; halt simulator

* Put variables and constants here

HEALTH dc.b 100
POSITION dc.b $11

BOSSHEALTH dc.w 1000
BOSSPOSITION dc.b $55

POINTS dc.w 0

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
