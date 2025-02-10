*-----------------------------------------------------------
* Title      : Part 4
* Written by : Brandon Jaroszczak
* Date       : 10/2/2025
* Description: Practical 5 part 4
*-----------------------------------------------------------
    ORG $1000
; D0 Used for Trap Codes, An Counting ENEMIES
; D1 Used for Players Health
; D2 Used for Enemy Positions
; D4 used for ENEMY count
; A0 for counting enemies
; A1 for progress messages
; A2 used for PLAYER_X
; A3 used for ENEMY_POSITIONS
DAMAGE EQU 10   ; Damage when collisions occur
START:
    LEA PLAYER_X, A2        ; Player will move along X axis
    LEA ENEMY_POSITIONS, A3 ; Enemy positions or spawn points
    BRA GAME_LOOP
GAME_LOOP:
    BSR COUNT_ENEMIES   ; Size of the ENEMY_POSITIONS Array
    MOVE.B D0, D4       ; Reset Enemy count at begining of loop

    LEA MSG_GAMELOOP, A1 ; Load and Draw Gameloop Message
    BSR DRAW
    
    BSR UPDATE      ; Call UPDATE
    BRA GAME_LOOP   ; Call GAME_LOOP
    
UPDATE:
    MOVE.B PLAYER_HEALTH, D1 ; Move Player Health into D1
    
    LEA MSG_HEALTH, A1 ; Load and Draw Health Message
    BSR DRAW
    
    MOVE.B #3, D0   ; Display signed number in D1.L in decimal in smallest field
    TRAP #15
    
    LEA CRLF, A1    ; Load carriage return and line feed
    BSR DRAW
    
    CMP #0, D1      ; Check if health is 0
    BLE GAME_OVER   ; Game over
    ADD.L #1, (A2)  ; Change x position of player
    BSR COLLISION   ; Check for collisions with enemies
    RTS
    
DRAW: 
    MOVE.B #13, D0
    TRAP #15
    RTS
    
COLLISION:
    MOVE.B #1, D5   ; Loop through array
    LEA ENEMY_POSITIONS, A3 ; Load ENEMY_POSITIONS array
    
ITERATE:
    CMP D5, D4      ; Counter for ENEMY_POSITIONS
    ADD.B #1, D5    ; Subtract 1
    BEQ GAME_LOOP   ; If 0 go to GAME_LOOP
    BNE CHECK_ENEMIES   ; If not check for enemy collisions
    RTS
    
CHECK_ENEMIES:
    MOVE.L (A3)+, D2    ; Move enemies positions to D2
    MOVE.L (A2), D3     ; Move player position to D3
    
    CMP.L D2, D3        ; Compare player and enemy position
    BEQ REDUCE_HEALTH   ; If equal reduce health
    BNE ITERATE         ; Iterate to next enemy
    
REDUCE_HEALTH:
    LEA MSG_COLLISION, A1   ; Load and draw collision message
    BSR DRAW
    
    SUB.B #DAMAGE, PLAYER_HEALTH
    
    LEA MSG_DAMAGE, A1      ; Load and draw damage message
    BSR DRAW
    
    BRA GAME_LOOP
    
GAME_OVER:
    LEA MSG_GAMEOVER, A1
    BSR DRAW
    SIMHALT
    
COUNT_ENEMIES:
    MOVE.B #0, D0   ; Initialise counter to 0
    LEA ENEMY_POSITIONS, A0 ; Load the address of the array into A0
    
COUNT_ENEMIES_LOOP:
    TST.L (A0)+     ; Test the byte at the address in A0 (check if 0) and increment A0
    BEQ END_COUNTING ; If the byte is 0, it's the end of the array
    
    ADD.B #1, D0    ; Increment the counter
    BRA COUNT_ENEMIES_LOOP ; Repeat the loop
    
END_COUNTING: 
    RTS
    
PLAYER_X DC.L 1
PLAYER_HEALTH DC.B 100
MSG_HEALTH DC.B 'Health: ', 0
MSG_GAMELOOP DC.B 'Game loop', 0
MSG_COLLISION DC.B 'Collision', 0
MSG_GAMEOVER DC.B 'Game over', 0
MSG_DAMAGE DC.B 'Taking damage', 0
CRLF DC.B $0D, $0A, 0
ENEMY_POSITIONS DC.L 20,30,40,50,60,70,80,90,200,300,500,0 ; Terminate array with a 0

    END START
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
