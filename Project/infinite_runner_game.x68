*-----------------------------------------------------------
* Title      : Infinite runner game
* Written by : Brandon Jaroszczak
* Date       : 05/02/2025
* Description: Built on top of the Project Starter Kit
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program
*-----------------------------------------------------------
* Subroutine    : Initialise
* Description   : Initialise game data into memory such as 
* sounds and screen size
*-----------------------------------------------------------
INITIALISE:
    ; Initialise Sounds
    BSR     RUN_LOAD                ; Load Run Sound into Memory
    BSR     JUMP_LOAD               ; Load Jump Sound into Memory
    BSR     OPPS_LOAD               ; Load Opps (Collision) Sound into Memory

    ; Screen Size
    MOVE.B  #TC_SCREEN, D0          ; access screen information
    MOVE.L  #TC_S_SIZE, D1          ; placing 0 in D1 triggers loading screen size information
    TRAP    #15                     ; interpret D0 and D1 for screen size
    MOVE.W  D1,         SCREEN_H    ; place screen height in memory location
    SWAP    D1                      ; Swap top and bottom word to retrive screen size
    MOVE.W  D1,         SCREEN_W    ; place screen width in memory location

    ; Place the Player at the center of the screen
    CLR.L   D1                      ; Clear contents of D1
    MOVE.W  SCREEN_W,   D1          ; Place Screen width in D1
    DIVU    #02,        D1          ; divide by 2 for center on X Axis
    MOVE.L  D1,         PLAYER_X    ; Players X Position

    CLR.L   D1                      ; Clear contents of D1
    MOVE.W  SCREEN_H,   D1          ; Place Screen height in D1
    DIVU    #02,        D1          ; divide by 2 for center on Y Axis
    MOVE.L  D1,         PLAYER_Y    ; Players Y Position
    ADD.L   #PLYR_H_INIT, D1        ; Add player height to D1
    
    MOVE.L  D1,         GROUND_HEIGHT   ; Initialise ground height
    MOVE.L  #0,         PLAYER_SCORE    ; Initialise Player Score    
    MOVE.L  #PLYR_DFLT_V, PLYR_VELOCITY ; Initialise Player Velocity
    MOVE.L  #PLYR_DFLT_G, PLYR_GRAVITY  ; Initialise Player Gravity
    MOVE.L  #GND_TRUE,  PLYR_ON_GND     ; Initialize Player on Ground

    ; Initial Position for Enemy
    CLR.L   D1                      ; Clear contents of D1
    MOVE.W  SCREEN_W,   D1          ; Place Screen width in D1
    MOVE.L  D1,         ENEMY_X     ; Enemy X Position
    MOVE.W  SCREEN_H,   D1          ; Place Screen width in D1
    DIVU    #02,        D1          ; divide by 2 for center on Y Axis
    MOVE.L  D1,         ENEMY_Y     ; Enemy Y Position

    ; Enable the screen back buffer(see easy 68k help)
	MOVE.B  #TC_DBL_BUF,D0          ; 92 Enables Double Buffer
    MOVE.B  #17,        D1          ; Combine Tasks
	TRAP	#15                     ; Trap (Perform action)
	BRA     MAIN_MENU               ; Branch to main menu
*-----------------------------------------------------------
* Subroutine    : Game
* Description   : Game including main GameLoop. GameLoop is like
* a while loop in that it runs forever until interupted
* (Input, Update, Draw). The Enemies Run at Player Jump to Avoid
*-----------------------------------------------------------
GAME:
    BSR     PLAY_RUN                ; Play Run Wav
GAMELOOP:
    ; Main Gameloop
    BSR     INPUT                   ; Check Keyboard Input
    BSR     UPDATE                  ; Update positions and points
    BSR     IS_PLAYER_ON_GND        ; Check if player is on ground
    BSR     CHECK_COLLISIONS        ; Check for Collisions
    BSR     DRAW_SCENE              ; Draw the Scene
    BSR     ADD_DELAY               ; Add a delay to slow down the game
    BRA     GAMELOOP                ; Loop back to GameLoop
*-----------------------------------------------------------
* Subroutine    : Input
* Description   : Process Keyboard Input
*-----------------------------------------------------------
INPUT:
    CMP.B #0, F3_KEY_COOLDOWN       ; Check is the f3 key cooldown = 0
    BLE CONTINUE_PROCESSING         ; If at 0 skip counting down
    SUB.B #1, F3_KEY_COOLDOWN       ; Decrement cooldown by 1
CONTINUE_PROCESSING:
    ; Process Input
    CLR.L   D1                      ; Clear Data Register
    MOVE.B  #TC_KEYCODE,D0          ; Listen for Keys
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  D1,         D2          ; Move last key D1 to D2
    CMP.B   #00,        D2          ; Key is pressed
    TRAP    #15                     ; Trap for Last Key
    ; Check if key still pressed
    CMP.B   #$FF,       D1          ; Is it still pressed
    BEQ     PROCESS_INPUT           ; Process Last Key
    RTS                             ; Return to subroutine
*-----------------------------------------------------------
* Subroutine    : Process Input
* Description   : Branch based on keys pressed
*-----------------------------------------------------------
PROCESS_INPUT:
    MOVE.L  D2,         CURRENT_KEY ; Put Current Key in Memory
    CMP.L   #ESCAPE,    CURRENT_KEY ; Is Current Key Escape
    BEQ     OPTIONS_MENU            ; Options menu if Escape
    CMP.L   #F3KEY,     CURRENT_KEY ; Is current key f3
    BNE SKIP_TOGGLE                 ; Skip toggling if not
    CMP.B   #0, F3_KEY_COOLDOWN     ; Check cooldown
    BGT     SKIP_TOGGLE             ; If cooldown > 0 skip toggling (prevents multiple presses)
    MOVE.B  #100, F3_KEY_COOLDOWN   ; Set cooldown period (80 frames)
    CMP.B   #1, SHOW_ADVANCED_INFO  ; Check is advanced info on or off
    BEQ TOGGLE_OFF                  ; If on toggle off
    BNE TOGGLE_ON                   ; If off toggle on
    
TOGGLE_OFF:
    MOVE.B #0, SHOW_ADVANCED_INFO   ; Toggle off advanced info
    BRA SKIP_TOGGLE                 ; Branch to skip toggle

TOGGLE_ON:
    MOVE.B #1, SHOW_ADVANCED_INFO   ; Toggle on advanced info
SKIP_TOGGLE:
    CMP.L   #SPACEBAR,  CURRENT_KEY ; Is Current Key Spacebar
    BEQ     JUMP                    ; Jump
    BRA     IDLE                    ; Or Idle
    RTS                             ; Return to subroutine
*-----------------------------------------------------------
* Subroutine    : Update
* Description   : Main update loop update Player and Enemies
*-----------------------------------------------------------
UPDATE:
    CMP.B   #0, JUMP_SKIP_FRAMES    ; Check is jump cooldown = 0
    BGT     SKIP_JUMP_UPDATE        ; If > 0 skip jump calculation (i.e. move world horizontally, makes the jump look a lot more realistic)
    ; Update the Players Positon based on Velocity and Gravity
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.L  PLYR_VELOCITY, D1       ; Fetch Player Velocity
    MOVE.L  PLYR_GRAVITY, D2        ; Fetch Player Gravity
    ADD.L   D2,         D1          ; Add Gravity to Velocity
    MOVE.L  D1,         PLYR_VELOCITY ; Update Player Velocity
    ADD.L   PLAYER_Y,   D1          ; Add Velocity to Player
    MOVE.L  D1,         PLAYER_Y    ; Update Players Y Position 
    MOVE.B  JUMP_COOLDOWN, JUMP_SKIP_FRAMES ; Set jump skip frames (i.e. how often the player falls, simulates gravity slower than 1)
SKIP_JUMP_UPDATE:
    SUB.B   #1, JUMP_SKIP_FRAMES    ; Decrement jump skip frames
    ; Move the Enemy
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.L  ENEMY_X,    D1          ; Move the Enemy X Position to D0
    CMP.L   #00,        D1          ; Check is D1 <= 0
    BLE     RESET_ENEMY_POSITION    ; Reset Enemy if off Screen
    BRA     MOVE_ENEMY              ; Move the Enemy
*-----------------------------------------------------------
* Subroutine    : Move Enemy
* Description   : Move Enemy Right to Left
*-----------------------------------------------------------
MOVE_ENEMY:
    SUB.L   #01,        ENEMY_X     ; Move enemy by X Value
    RTS
*-----------------------------------------------------------
* Subroutine    : Reset Enemy
* Description   : Reset Enemy if to passes 0 to Right of Screen
*-----------------------------------------------------------
RESET_ENEMY_POSITION:
    CLR.L   D1            ; clear D1
    MOVE.W  SCREEN_W, D1    ; this is needed because screen W is a word 
    MOVE.L  D1, ENEMY_X     ; enemy X Position
    
    MOVE.B  #8, D0          ; get the current time in 1/100s since midnight
    TRAP    #15
    AND.L   #$0000FFFF, D1  ; clear the upper word of D1 (DIVU only works with 16 bits or less so it reduces the time to 16 bits, the most important "random" part is in the last 8 bits anyways)
    
    MOVE.L  D1, D3          ; Copy D1 into D3
    DIVU    #10, D3         ; Divide D3 by 10
    SWAP    D3              ; Swap the upper and lower words of D3 to get the remainder (pseudo-random value)
    AND.L   #$0000FFFF, D3  ; Clear the upper word of D3
    CMP.L   #0, D3          ; Check is D3 = 0 (i.e. 10% chance of D3 being 1, 90% chance of D3 being 1-9)
    BLE     SPAWN_HEALTH    ; Spawn health if 0
    BGT     SPAWN_ENEMY     ; Spawn enemy if 1-9
SPAWN_HEALTH:
    MOVE.B  #1, IS_POWERUP  ; set to 1 (true)
    MOVE.L  GROUND_HEIGHT, D1 ; copy ground height into D1
    SUB.L   ENEMY_W, D1     ; subtract enemy height from ground height to get top of enemy (ENEMY_W is used as its constant while ENEMY_H changes each time, initially they're both equal)
    MOVE.L  D1, ENEMY_Y     ; copy D1 to enemy y
    MOVE.L  ENEMY_W, ENEMY_H ; set enemy height to the initial value (stored in enemy w)
    BRA FINISH_SPAWNING     ; skip spawning enemy
SPAWN_ENEMY:
    MOVE.B  #0, IS_POWERUP  ; set to 0 (false)
    DIVU    MAX_ENEMY_HEIGHT, D1 ; divide the time by max enemy height (amount of Y variance in enemy)
    SWAP    D1              ; swap the upper and lower words to have the remainder on the lower word
    AND.L   #$0000FFFF, D1  ; clear the upper word of D1    
    MOVE.L  D1, ENEMY_H     ; set the random value as the height of the enemy
    MOVE.L  GROUND_HEIGHT, D0   ; move the ground height into D0
    SUB.L   D1, D0          ; subtract D0 from D1 and store in D0 to get y position of the top of the enemy
    MOVE.L  D0, ENEMY_Y     ; set enemy y to be random value above the ground
FINISH_SPAWNING:
    CLR.L D0                ; clear D0 just in case
    CLR.L D1                ; clear D1 just in case
    RTS
*-----------------------------------------------------------
* Subroutine    : DRAW
* Description   : Draw current frame in back buffer
*-----------------------------------------------------------
DRAW:
    MOVE.B  #94,        D0 ; draw trap task
    TRAP    #15
    RTS
*-----------------------------------------------------------
* Subroutine    : DRAW_SCENE
* Description   : Draw Screen
*-----------------------------------------------------------
DRAW_SCENE: 
    BSR     CLEAR_SCREEN            ; Clear the screen
    BSR     DRAW_ENVIRONMENT        ; Draw the environment
    BSR     DRAW_PLYR_DATA          ; Draw Draw Score, HUD, Player X and Y
    BSR     DRAW_PLAYER             ; Draw Player
    BSR     DRAW_ENEMY              ; Draw Enemy
    BSR     DRAW                    ; Draw frame
    RTS                             ; Return to subroutine
*-----------------------------------------------------------
* Subroutine    : Draw Player Data
* Description   : Draw Player X, Y, Velocity, Gravity and OnGround
*-----------------------------------------------------------
DRAW_PLYR_DATA:
    CLR.L D1                        ; Clear contents of D1 (XOR is faster)

    ; Difficulty Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0201,     D1          ; Col 02, Row 01
    TRAP    #15                     ; Trap (Perform action)
    LEA     DIFFICULTY_MSG,  A1     ; Difficulty Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)

    ; Difficulty message value
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0E01,     D1          ; Col 09, Row 01
    TRAP    #15                     ; Trap (Perform action)
    CMP.B   #2, DIFFICULTY
    BLT RENDER_EASY     ; =1
    BEQ RENDER_NORMAL   ; =2
    BGT RENDER_HARD     ; =3
    
RENDER_EASY:
    LEA DIFFICULTY_MSG_EASY, A1     ; load easy message into A1
    BRA CONTINUE_DRAWING_1          ; skip to continue drawing

RENDER_NORMAL:
    LEA DIFFICULTY_MSG_NORMAL, A1   ; load medium message into A1
    BRA CONTINUE_DRAWING_1          ; skip to continue drawing
    
RENDER_HARD:
    LEA DIFFICULTY_MSG_HARD, A1     ; load hard message into A1

CONTINUE_DRAWING_1:
    MOVE.B  #13, D0                 ; display String     
    TRAP #15
    ; Planet Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0202,     D1          ; Col 02, Row 01
    TRAP    #15                     ; Trap (Perform action)
    LEA     PLANET_MSG,  A1     ; Difficulty Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)

    ; Planet message value
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0A02,     D1          ; Col 09, Row 01
    TRAP    #15                     ; Trap (Perform action)
    CMP.B   #2, PLANET
    BLT RENDER_EARTH    ; =1
    BEQ RENDER_MOON     ; =2
    BGT RENDER_MARS     ; =3
    
RENDER_EARTH:
    LEA PLANET_MSG_EARTH, A1    ; load earth message into A1
    BRA CONTINUE_DRAWING        ; skip to continue drawing

RENDER_MOON:
    LEA PLANET_MSG_MOON, A1     ; load moon message into A1
    BRA CONTINUE_DRAWING        ; skip to continue drawing
    
RENDER_MARS:
    LEA PLANET_MSG_MARS, A1     ; load mars message into A1

CONTINUE_DRAWING:
    MOVE.B  #13, D0             ; display string   
    TRAP #15

    ; Player Score Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0203,     D1          ; Col 02, Row 01
    TRAP    #15                     ; Trap (Perform action)
    LEA     SCORE_MSG,  A1          ; Score Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)

    ; Player Score Value
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0903,     D1          ; Col 09, Row 01
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #03,        D0          ; Display number at D1.L
    MOVE.L  PLAYER_SCORE,D1         ; Move Score to D1.L
    TRAP    #15                     ; Trap (Perform action)
    
    ; Lives Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0204,     D1          ; Col 02, Row 01
    TRAP    #15                     ; Trap (Perform action)
    LEA     LIVES_MSG,  A1          ; Score Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)

    ; Lives Value
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0904,     D1          ; Col 09, Row 01
    TRAP    #15                     ; Trap (Perform action)
    MOVE    #3,        D0           ; No Line feed
    CLR.L   D1
    MOVE.B  LIVES, D1               ; display lives
    TRAP    #15                     ; Trap (Perform action)
    
    CMP.B   #0, SHOW_ADVANCED_INFO
    BEQ     SKIP_MESSAGES
    ; Player X Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0205,     D1          ; Col 02, Row 02
    TRAP    #15                     ; Trap (Perform action)
    LEA     X_MSG,      A1          ; X Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Player X
    MOVE.B  #TC_CURSR_P, D0         ; Set Cursor Position
    MOVE.W  #$0505,     D1          ; Col 05, Row 02
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #03,        D0          ; Display number at D1.L
    MOVE.L  PLAYER_X,   D1          ; Move X to D1.L
    TRAP    #15                     ; Trap (Perform action)
    
    ; Player Y Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0A05,     D1          ; Col 10, Row 02
    TRAP    #15                     ; Trap (Perform action)
    LEA     Y_MSG,      A1          ; Y Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Player Y
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0D05,     D1          ; Col 12, Row 02
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #03,        D0          ; Display number at D1.L
    MOVE.L  PLAYER_Y,   D1          ; Move X to D1.L
    TRAP    #15                     ; Trap (Perform action) 

    ; Player Velocity Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0206,     D1          ; Col 02, Row 03
    TRAP    #15                     ; Trap (Perform action)
    LEA     V_MSG,      A1          ; Velocity Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Player Velocity
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0506,     D1          ; Col 05, Row 03
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #03,        D0          ; Display number at D1.L
    MOVE.L  PLYR_VELOCITY,D1        ; Move X to D1.L
    TRAP    #15                     ; Trap (Perform action)
    
    ; Player Gravity Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0A06,     D1          ; Col 10, Row 03
    TRAP    #15                     ; Trap (Perform action)
    LEA     G_MSG,      A1          ; G Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Player Gravity
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0D06,     D1          ; Col 12, Row 03
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #03,        D0          ; Display number at D1.L
    MOVE.L  PLYR_GRAVITY,D1         ; Move Gravity to D1.L
    TRAP    #15                     ; Trap (Perform action)

    ; Player On Ground Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0207,     D1          ; Col 10, Row 03
    TRAP    #15                     ; Trap (Perform action)
    LEA     GND_MSG,    A1          ; On Ground Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Player On Ground
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0607,     D1          ; Col 06, Row 04
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #03,        D0          ; Display number at D1.L
    MOVE.L  PLYR_ON_GND,D1          ; Move Play on Ground ? to D1.L
    TRAP    #15                     ; Trap (Perform action)

    ; Show Keys Pressed
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$2001,     D1          ; Col 20, Row 1
    TRAP    #15                     ; Trap (Perform action)
    LEA     KEYCODE_MSG, A1         ; Keycode
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)

    ; Show KeyCode
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$2901,     D1          ; Col 30, Row 1
    TRAP    #15                     ; Trap (Perform action)    
    MOVE.L  CURRENT_KEY,D1          ; Move Key Pressed to D1
    MOVE.B  #03,        D0          ; Display the contents of D1
    TRAP    #15                     ; Trap (Perform action)

    ; Show delay
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0208,     D1          ; Col 02, Row 05
    TRAP    #15                     ; Trap (Perform action)
    MOVE    #3,        D0           ; No Line feed
    MOVE.L  DELAY, D1               ; display delay
    TRAP    #15                     ; Trap (Perform action)

    ; Show cycles to next increase
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0209,     D1          ; Col 02, Row 06
    TRAP    #15                     ; Trap (Perform action)
    MOVE    #3,        D0           ; No Line feed
    MOVE.L  CYCLES_TO_NEXT_INCREASE, D1 ; display cycles
    TRAP    #15                     ; Trap (Perform action)

    ; Show minimum delay
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$020A,     D1          ; Col 02, Row 07
    TRAP    #15                     ; Trap (Perform action)
    MOVE    #3,        D0           ; No Line feed
    MOVE.L  MINIMUM_DELAY, D1       ; display minimum delay
    TRAP    #15                     ; Trap (Perform action)

SKIP_MESSAGES:
    RTS
*-----------------------------------------------------------
* Subroutine    : Player is on Ground
* Description   : Check if the Player is on or off Ground
*-----------------------------------------------------------
IS_PLAYER_ON_GND:
    ; Check if Player is on Ground
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    CLR.L   D2                      ; Clear contents of D2 (XOR is faster)
    MOVE.W  SCREEN_H,   D1          ; Place Screen width in D1
    DIVU    #02,        D1          ; divide by 2 for center on Y Axis
    MOVE.L  PLAYER_Y,   D2          ; Player Y Position
    CMP     D1,         D2          ; Compare middle of Screen with Players Y Position 
    BGE     SET_ON_GROUND           ; The Player is on the Ground Plane
    BLT     SET_OFF_GROUND          ; The Player is off the Ground
    RTS                             ; Return to subroutine
*-----------------------------------------------------------
* Subroutine    : On Ground
* Description   : Set the Player On Ground
*-----------------------------------------------------------
SET_ON_GROUND:
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_H,   D1          ; Place Screen width in D1
    DIVU    #02,        D1          ; divide by 2 for center on Y Axis
    MOVE.L  D1,         PLAYER_Y    ; Reset the Player Y Position
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.L  #00,        D1          ; Player Velocity
    MOVE.L  D1,         PLYR_VELOCITY ; Set Player Velocity
    MOVE.L  #GND_TRUE,  PLYR_ON_GND ; Player is on Ground
    RTS
*-----------------------------------------------------------
* Subroutine    : Off Ground
* Description   : Set the Player Off Ground
*-----------------------------------------------------------
SET_OFF_GROUND:
    MOVE.L  #GND_FALSE, PLYR_ON_GND ; Player if off Ground
    RTS                             ; Return to subroutine
*-----------------------------------------------------------
* Subroutine    : Jump
* Description   : Perform a Jump
*-----------------------------------------------------------
JUMP:
    CMP.L   #GND_TRUE,PLYR_ON_GND   ; Player is on the Ground ?
    BEQ     PERFORM_JUMP            ; Do Jump
    BRA     JUMP_DONE               ; finish jump
PERFORM_JUMP:
    BSR     PLAY_JUMP               ; Play jump sound
    MOVE.L  PLYR_JUMP_V,PLYR_VELOCITY ; Set the players velocity to true
    RTS                             ; Return to subroutine
JUMP_DONE:
    RTS                             ; Return to subroutine
*-----------------------------------------------------------
* Subroutine    : Idle
* Description   : Perform a Idle
*----------------------------------------------------------- 
IDLE:
    BSR     PLAY_RUN                ; Play Run Wav
    RTS                             ; Return to subroutine
*-----------------------------------------------------------
* Subroutines   : Sound Load and Play
* Description   : Initialise game sounds into memory 
* Current Sounds are RUN, JUMP and Opps for Collision
*-----------------------------------------------------------
RUN_LOAD:
    LEA     RUN_WAV,    A1          ; Load Wav File into A1
    MOVE    #RUN_INDEX, D1          ; Assign it INDEX
    MOVE    #71,        D0          ; Load into memory
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

PLAY_RUN:
    MOVE    #RUN_INDEX, D1          ; Load Sound INDEX
    MOVE    #72,        D0          ; Play Sound
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

JUMP_LOAD:
    LEA     JUMP_WAV,   A1          ; Load Wav File into A1
    MOVE    #JMP_INDEX, D1          ; Assign it INDEX
    MOVE    #71,        D0          ; Load into memory
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

PLAY_JUMP:
    MOVE    #JMP_INDEX, D1          ; Load Sound INDEX
    MOVE    #72,        D0          ; Play Sound
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

OPPS_LOAD:
    LEA     OPPS_WAV,   A1          ; Load Wav File into A1
    MOVE    #OPPS_INDEX,D1          ; Assign it INDEX
    MOVE    #71,        D0          ; Load into memory
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

PLAY_OPPS:
    MOVE    #OPPS_INDEX,D1          ; Load Sound INDEX
    MOVE    #72,        D0          ; Play Sound
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine
*-----------------------------------------------------------
* Subroutine    : Draw Player
* Description   : Draw Player Square
*-----------------------------------------------------------
DRAW_PLAYER:
    ; Set Pixel Colors
    MOVE.L  #WHITE,     D1          ; Set Background color
    MOVE.B  #80,        D0          ; Task for Background Color
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #81, D0                 ; fill colour task
    TRAP    #15     

    ; Set X, Y, Width and Height
    MOVE.L  PLAYER_X,   D1          ; X
    MOVE.L  PLAYER_Y,   D2          ; Y
    MOVE.L  PLAYER_X,   D3
    ADD.L   #PLYR_W_INIT,   D3      ; Width
    MOVE.L  PLAYER_Y,   D4 
    ADD.L   #PLYR_H_INIT,   D4      ; Height
    
    ; Draw Player
    MOVE.B  #87,        D0          ; Draw Player
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine
*-----------------------------------------------------------
* Subroutine    : Draw Enemy
* Description   : Draw Enemy Square
*-----------------------------------------------------------
DRAW_ENEMY:
    CMP.B   #1, IS_POWERUP          ; check is current enemy a powerup or enemy
    BEQ POWERUP_COLOURS             ; set powerup colour
    MOVE.L  ENEMY_COLOUR, D1        ; set enemy color
    BRA CONTINUE_DRAWING_ENEMY      ; continue drawing enemy
POWERUP_COLOURS:
    MOVE.L  POWERUP_COLOUR, D1      ; set powerup colour
CONTINUE_DRAWING_ENEMY:
    MOVE.B  #80,        D0          ; Task for Background Color
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #81, D0                 ; set fill colour
    TRAP    #15

    ; Set X, Y, Width and Height    
    MOVE.L  ENEMY_X,    D1          ; X
    MOVE.L  ENEMY_Y,    D2          ; Y
    MOVE.L  D1,    D3               
    MOVE.L  D2,    D4
    ADD.L   ENEMY_W,   D3           ; Width
    ADD.L   ENEMY_H,   D4           ; Height
    
    ; Draw Enemy    
    MOVE.B  #87,        D0          ; Draw Enemy
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine
*-----------------------------------------------------------
* Subroutine    : Draw Environment
* Description   : Draw Environment (ground and sky colours)
*-----------------------------------------------------------
DRAW_ENVIRONMENT:
    MOVE.L GROUND_COLOUR, D1    ; get ground colour
    MOVE.B #80, D0              ; set pen colour
    TRAP #15
    MOVE.B #81, D0              ; set fill colour
    TRAP #15
    
    MOVE.B #87, D0              ; draw rectangle
    MOVE.L #0, D1               ; x
    MOVE.L GROUND_HEIGHT, D2    ; y
    MOVE.W #640, D3             ; width
    MOVE.L #480, D4             ; heght
    TRAP #15                    ; draw
    
    MOVE.L SKY_COLOUR, D1       ; get sky colour
    MOVE.B #80, D0              ; set pen colour
    TRAP #15
    MOVE.B #81, D0              ; set fill colour
    TRAP #15
    
    MOVE.B #87, D0              ; draw rectangle
    MOVE.L #0, D1               ; x
    MOVE.L #0, D2               ; y
    MOVE.L #640, D3             ; width
    MOVE.L GrOUND_HEIGHT, D4    ; height
    TRAP #15                    ; draw
    RTS
*-----------------------------------------------------------
* Subroutine    : Collision Check
* Description   : Axis-Aligned Bounding Box Collision Detection
* Algorithm checks for overlap on the 4 sides of the Player and 
* NO POSSIBLE COLLISION IF:
* Player left >= enemy right OR
* Player right <= enemy left OR
* Player top >= enemy bottom OR
* Player bottom <= enemy top
*-----------------------------------------------------------
CHECK_COLLISIONS:
    CLR.L   D1                      ; Clear D1
    CLR.L   D2                      ; Clear D2
    CMP.B #0, COLLISION_COOLDOWN    ; check collision cooldown
    BGT REDUCE_COOLDOWN ; if cooldown > 0 don't check for collisions
    
    ; check collisions
    MOVE.L  PLAYER_X, D1 ; player x to d1
    MOVE.L  ENEMY_X, D2  ; enemy x to d2
    ADD.L   ENEMY_W, D2  ; add enemy width to d2
    CMP.L   D2, D1          
    BGE     COLLISION_CHECK_DONE ; if player left >= enemy right no possible collision

    ADD.L   #PLYR_W_INIT, D1    ; add player width to d1
    MOVE.L  ENEMY_X, D2         ; enemy x to d2
    CMP.L   D2, D1
    BLE     COLLISION_CHECK_DONE ; if player right <= enemy left no possible collision

    MOVE.L  PLAYER_Y, D1 ; player y to d1
    MOVE.L  ENEMY_Y, D2  ; enemy y to d2
    ADD.L   ENEMY_H, D2  ; add enemy height to d2
    CMP.L   D2, D1
    BGE     COLLISION_CHECK_DONE ; if player top >= enemy bottom no possible collision

    ADD.L   #PLYR_H_INIT, D1    ; add player height to d1
    MOVE.L  ENEMY_Y, D2         ; enemy y to d2
    CMP.L   D2, D1 
    BLE     COLLISION_CHECK_DONE ; if player bottom <= enemy top no possible collision

    ; if collision run code
    CMP.B #1, IS_POWERUP    ; check is it powerup
    BEQ PICKUP_POWERUP      ; if = 1 then branch to pickup powerup
    BSR     PLAY_OPPS       ; Play Opps Wav
    SUB.B #1, LIVES         ; take a life
    CMP.B #0, LIVES         ; check if any lives remaining
    BLE GAME_OVER           ; if <= 0 game over
    BRA FINISH_COLLISION    ; otherwise branch
    
PICKUP_POWERUP:
    ADD.B #1, LIVES         ; add a life
FINISH_COLLISION:
    MOVE.L ENEMY_W, D0      ; Load ENEMY_W into D0
    ASL.B  #1, D0           ; Multiply by 2 (Shift Left)
    MOVE.B D0, COLLISION_COOLDOWN  ; add 2* enemy to collision cooldown to prevent multiple lives from being subtracted (or added)
    RTS
    
REDUCE_COOLDOWN:
    SUB.B #1, COLLISION_COOLDOWN    ; reduce cooldown by 1
COLLISION_CHECK_DONE:
    ADD.L   #1, PLAYER_SCORE        ; add a point to score
    RTS                             ; Return to subroutine
*-----------------------------------------------------------
* Subroutine    : ADD_DELAY
* Description   : Add a delay to the game rendering to slow down the game physics
*-----------------------------------------------------------
ADD_DELAY:
    MOVE.L DELAY, D6    ; get the delay
DELAY_LOOP:             ; while D6 > 0 
    SUB.L #1, D6        ; subtract 1 from D6
    CMP.L #0, D6        ; check is D6 = 0
    BGT DELAY_LOOP      ; if > 0 continue loop
    BLE END_LOOP        ; if <= 0 end loop
    
END_LOOP:
    SUB.L #1, CYCLES_TO_NEXT_INCREASE   ; subtract 1 from cycles to next increase (i.e. frames until the delay is permanently reduced by 1, slowly speed up the game)
    MOVE.L CYCLES_TO_NEXT_INCREASE, D6  ; copy to D6
    CMP.L #0, D6                        ; check is D6 = 0
    BLE REDUCE_DELAY                    ; reduce delay (speed up game) if <= 0
    RTS
    
REDUCE_DELAY:
    MOVE.L DELAY, D6            ; copy delay to D6
    MOVE.L MINIMUM_DELAY, D5    ; copy minimum delay to D5
    CMP.L D5, D6                ; compare
    BLE SKIP_REDUCE             ; if delay <= minimum delay dont reduce delay anymore (fastest speed of the game is this)
    SUB.L #1, DELAY             ; otherwise permanently reduce delay by 1
    
SKIP_REDUCE:
    MOVE.L NEXT_INCREASE_CYCLES, D6     ; copy delay reduction constant into D6
    ADD.L D6, CYCLES_TO_NEXT_INCREASE   ; add D6 to next delay increase
    RTS
*-----------------------------------------------------------
* Subroutine    : MAIN_MENU
* Description   : Render the main menu and difficulty choice
*-----------------------------------------------------------
MAIN_MENU: 
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    BSR CLEAR_SCREEN                ; clear screen
	
    ; Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$1E02,     D1          
    TRAP    #15                     ; Trap (Perform action)
    LEA     CHOOSE_LEVEL_MSG,  A1   ; Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)

    ; DRAW EASY BOX
    ; Set Pixel Colors
    MOVE.L  #GREEN,     D1          ; Set Background color
    MOVE.B  #80,        D0          ; Task for Background Color
    TRAP    #15                     ; Trap (Perform action)
    MOVE.L  #50, D1                 ; X
    MOVE.L  #150, D2                ; Y
    MOVE.L  D1, D3
    MOVE.L  D2, D4
    ADD.L   #BOX_SIZE,  D3          ; Width
    ADD.L   #BOX_SIZE,  D4          ; Height
    MOVE.B  #87,        D0          ; Draw box
    TRAP    #15                     ; Trap (Perform action)
    
    ; DRAW MEDIUM BOX
    ; Set Pixel Colors
    MOVE.L  #ORANGE,     D1         ; Set Background color
    MOVE.B  #80,        D0          ; Task for Background Color
    TRAP    #15                     ; Trap (Perform action)
    MOVE.L  #245, D1                ; X
    MOVE.L  #150, D2                ; Y
    MOVE.L  D1, D3
    MOVE.L  D2, D4
    ADD.L   #BOX_SIZE,  D3          ; Width
    ADD.L   #BOX_SIZE,  D4          ; Height
    MOVE.B  #87,        D0          ; Draw box
    TRAP    #15                     ; Trap (Perform action)
    
    ; DRAW HARD BOX
    ; Set Pixel Colors
    MOVE.L  #RED,     D1            ; Set Background color
    MOVE.B  #80,        D0          ; Task for Background Color
    TRAP    #15                     ; Trap (Perform action)
    MOVE.L  #440, D1                ; X
    MOVE.L  #150, D2                ; Y
    MOVE.L  D1, D3
    MOVE.L  D2, D4
    ADD.L   #BOX_SIZE,  D3          ; Width
    ADD.L   #BOX_SIZE,  D4          ; Height
    MOVE.B  #87,        D0          ; Draw box
    TRAP    #15                     ; Trap (Perform action)
    
    ; Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0D09,     D1          
    TRAP    #15                     ; Trap (Perform action)
    LEA     EASY_MSG1,  A1   ; Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)

    ; Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$090D,     D1          
    TRAP    #15                     ; Trap (Perform action)
    LEA     EASY_MSG2,  A1   ; Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$080E,     D1          
    TRAP    #15                     ; Trap (Perform action)
    LEA     EASY_MSG3,  A1   ; Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0A0F,     D1          
    TRAP    #15                     ; Trap (Perform action)
    LEA     EASY_MSG4,  A1   ; Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$2409,     D1          
    TRAP    #15                     ; Trap (Perform action)
    LEA     MEDIUM_MSG1,  A1   ; Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$220D,     D1          
    TRAP    #15                     ; Trap (Perform action)
    LEA     MEDIUM_MSG2,  A1   ; Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$210E,     D1          
    TRAP    #15                     ; Trap (Perform action)
    LEA     MEDIUM_MSG3,  A1   ; Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$210F,     D1          
    TRAP    #15                     ; Trap (Perform action)
    LEA     MEDIUM_MSG4,  A1   ; Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$3D09,     D1          
    TRAP    #15                     ; Trap (Perform action)
    LEA     HARD_MSG1,  A1   ; Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$3A0D,     D1          
    TRAP    #15                     ; Trap (Perform action)
    LEA     HARD_MSG2,  A1   ; Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$390E,     D1          
    TRAP    #15                     ; Trap (Perform action)
    LEA     HARD_MSG3,  A1   ; Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$3B0F,     D1          
    TRAP    #15                     ; Trap (Perform action)
    LEA     HARD_MSG4,  A1   ; Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)

    ; Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$1C1F,     D1          
    TRAP    #15                     ; Trap (Perform action)
    LEA     ENTER_DIFFICULTY_MSG,  A1   ; Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    BSR DRAW                        ; draw to screen
    
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$341E,     D1          
    TRAP    #15                     ; Trap (Perform action)
    
    CLR.L D1        ; clear D1
    MOVE.L #4, D0   ; read input task and store result in D1
    TRAP #15
    
    CMP.L #1, D1    
    BEQ SETUP_EASY  ; if D1 = 1
    CMP.L #2, D1
    BEQ SETUP_MEDIUM ; if D1 = 2
    CMP.L #3, D1
    BEQ SETUP_HARD  ; if D1 = 3
    BRA MAIN_MENU   ; if D1 is anything else try again
*-----------------------------------------------------------
* Subroutine    : SETUP_EASY
* Description   : Setup easy mode and initialise all variables
*-----------------------------------------------------------
SETUP_EASY:
    MOVE.L #$3FF, DELAY
    MOVE.L #$40, CYCLES_TO_NEXT_INCREASE
    MOVE.L #$40, NEXT_INCREASE_CYCLES
    MOVE.L #$17F, MINIMUM_DELAY
    MOVE.L #GREEN, ENEMY_COLOUR
    MOVE.B #10, LIVES
    MOVE.B #1, DIFFICULTY
    MOVE.L #8, ENEMY_W
    MOVE.L #8, ENEMY_H
    BRA PLANET_MENU
*-----------------------------------------------------------
* Subroutine    : SETUP_MEDIUM
* Description   : Setup medium mode and initialise all variables
*-----------------------------------------------------------
SETUP_MEDIUM:
    MOVE.L #$2FF, DELAY
    MOVE.L #$25, CYCLES_TO_NEXT_INCREASE
    MOVE.L #$25, NEXT_INCREASE_CYCLES
    MOVE.L #$12F, MINIMUM_DELAY
    MOVE.L #ORANGE, ENEMY_COLOUR
    MOVE.B #5, LIVES
    MOVE.B #2, DIFFICULTY
    MOVE.L #12, ENEMY_W
    MOVE.L #12, ENEMY_H
    BRA PLANET_MENU
*-----------------------------------------------------------
* Subroutine    : SETUP_HARD
* Description   : Setup hard mode and initialise all variables
*-----------------------------------------------------------
SETUP_HARD:
    MOVE.L #$1FF, DELAY
    MOVE.L #$10, CYCLES_TO_NEXT_INCREASE
    MOVE.L #$10, NEXT_INCREASE_CYCLES
    MOVE.L #$5F, MINIMUM_DELAY
    MOVE.L #RED, ENEMY_COLOUR
    MOVE.B #3, LIVES
    MOVE.B #3, DIFFICULTY
    MOVE.L #16, ENEMY_W
    MOVE.L #16, ENEMY_H
    BRA PLANET_MENU
*-----------------------------------------------------------
* Subroutine    : PLANET_MENU
* Description   : Render the planet menu and choose planet
*-----------------------------------------------------------
PLANET_MENU: 
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    BSR CLEAR_SCREEN                ; clear screen

    ; Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$2002,     D1          
    TRAP    #15                     ; Trap (Perform action)
    LEA     CHOOSE_PLANET_MSG,  A1  ; Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)

    ; DRAW EARTH BOX
    ; Set Pixel Colors
    MOVE.L  #GROUND_EARTH,     D1   ; Set Background color
    MOVE.B  #80,        D0          ; Task for Background Color
    TRAP    #15                     ; Trap (Perform action)
    MOVE.L  #50, D1                 ; X
    MOVE.L  #150, D2                ; Y
    MOVE.L  D1, D3
    MOVE.L  D2, D4
    ADD.L   #BOX_SIZE,  D3          ; Width
    ADD.L   #BOX_SIZE,  D4          ; Height
    MOVE.B  #87,        D0          ; Draw box
    TRAP    #15                     ; Trap (Perform action)
    
    ; DRAW MOON BOX
    ; Set Pixel Colors
    MOVE.L  #GROUND_MOON,     D1    ; Set Background color
    MOVE.B  #80,        D0          ; Task for Background Color
    TRAP    #15                     ; Trap (Perform action)
    MOVE.L  #245, D1                ; X
    MOVE.L  #150, D2                ; Y
    MOVE.L  D1, D3
    MOVE.L  D2, D4
    ADD.L   #BOX_SIZE,  D3          ; Width
    ADD.L   #BOX_SIZE,  D4          ; Height
    MOVE.B  #87,        D0          ; Draw box
    TRAP    #15                     ; Trap (Perform action)
    
    ; DRAW MARS BOX
    ; Set Pixel Colors
    MOVE.L  #GROUND_MARS,     D1    ; Set Background color
    MOVE.B  #80,        D0          ; Task for Background Color
    TRAP    #15                     ; Trap (Perform action)
    MOVE.L  #440, D1                ; X
    MOVE.L  #150, D2                ; Y
    MOVE.L  D1, D3
    MOVE.L  D2, D4
    ADD.L   #BOX_SIZE,  D3          ; Width
    ADD.L   #BOX_SIZE,  D4          ; Height
    MOVE.B  #87,        D0          ; Draw box
    TRAP    #15                     ; Trap (Perform action)
    
    ; Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0C09,     D1          
    TRAP    #15                     ; Trap (Perform action)
    LEA     EARTH_MSG1,  A1   ; Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)

    ; Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$090D,     D1          
    TRAP    #15                     ; Trap (Perform action)
    LEA     EARTH_MSG2,  A1   ; Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0A0E,     D1          
    TRAP    #15                     ; Trap (Perform action)
    LEA     EARTH_MSG3,  A1   ; Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$0B0F,     D1          
    TRAP    #15                     ; Trap (Perform action)
    LEA     EARTH_MSG4,  A1   ; Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$2509,     D1          
    TRAP    #15                     ; Trap (Perform action)
    LEA     MOON_MSG1,  A1   ; Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$200D,     D1          
    TRAP    #15                     ; Trap (Perform action)
    LEA     MOON_MSG2,  A1   ; Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$220E,     D1          
    TRAP    #15                     ; Trap (Perform action)
    LEA     MOON_MSG3,  A1   ; Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$200F,     D1          
    TRAP    #15                     ; Trap (Perform action)
    LEA     MOON_MSG4,  A1   ; Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$3D09,     D1          
    TRAP    #15                     ; Trap (Perform action)
    LEA     MARS_MSG1,  A1   ; Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$390D,     D1          
    TRAP    #15                     ; Trap (Perform action)
    LEA     MARS_MSG2,  A1   ; Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$390E,     D1          
    TRAP    #15                     ; Trap (Perform action)
    LEA     MARS_MSG3,  A1   ; Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$3B0F,     D1          
    TRAP    #15                     ; Trap (Perform action)
    LEA     MARS_MSG4,  A1   ; Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)

    ; Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$1E1F,     D1          
    TRAP    #15                     ; Trap (Perform action)
    LEA     ENTER_PLANET_MSG,  A1   ; Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    BSR DRAW
    
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$321E,     D1          
    TRAP    #15                     ; Trap (Perform action)

    CLR.L D1        ; clear D1
    MOVE.L #4, D0   ; read input task and store result in D1
    TRAP #15
    
    CMP.L #1, D1
    BEQ SETUP_EARTH ; if D1 = 1
    CMP.L #2, D1
    BEQ SETUP_MOON  ; if D1 = 2
    CMP.L #3, D1
    BEQ SETUP_MARS  ; if D1 = 3
    BRA PLANET_MENU ; if D1 is anything else try again
*-----------------------------------------------------------
* Subroutine    : SETUP_EARTH
* Description   : Setup earth world and initialise all variables
*-----------------------------------------------------------
SETUP_EARTH:
    MOVE.B #1, PLANET
    MOVE.L #GROUND_EARTH, GROUND_COLOUR
    MOVE.L #SKY_EARTH, SKY_COLOUR
    MOVE.L #-14, PLYR_JUMP_V
    MOVE.W #50, MAX_ENEMY_HEIGHT
    MOVE.B #4, JUMP_COOLDOWN
    BRA GAME
*-----------------------------------------------------------
* Subroutine    : SETUP_MOON
* Description   : Setup moon world and initialise all variables
*-----------------------------------------------------------
SETUP_MOON:
    MOVE.B #2, PLANET
    MOVE.L #GROUND_MOON, GROUND_COLOUR
    MOVE.L #SKY_MOON, SKY_COLOUR
    MOVE.L #-22, PLYR_JUMP_V
    MOVE.W #175, MAX_ENEMY_HEIGHT
    MOVE.B #8, JUMP_COOLDOWN
    BRA GAME
*-----------------------------------------------------------
* Subroutine    : SETUP_MARS
* Description   : Setup mars world and initialise all variables
*-----------------------------------------------------------
SETUP_MARS:
    MOVE.B #3, PLANET
    MOVE.L #GROUND_MARS, GROUND_COLOUR
    MOVE.L #SKY_MARS, SKY_COLOUR
    MOVE.L #-18, PLYR_JUMP_V
    MOVE.W #100, MAX_ENEMY_HEIGHT
    MOVE.B #4, JUMP_COOLDOWN
    BRA GAME
*-----------------------------------------------------------
* Subroutine    : OPTIONS MENU
* Description   : Options menu when esc key pressed
*-----------------------------------------------------------
OPTIONS_MENU:
    BSR CLEAR_SCREEN ; clear screen

	MOVE.L #$00000000, D1   ; reset colour to black
    MOVE.B #80, D0          ; set pen colour
    TRAP #15
    MOVE.B #81, D0          ; set fill colour
    TRAP #15
    
    ; Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$2202,     D1          
    TRAP    #15                     ; Trap (Perform action)
    LEA     OPTIONS_MSG,  A1   ; Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$1D09,     D1          
    TRAP    #15                     ; Trap (Perform action)
    LEA     OPTIONS_MSG_1,  A1   ; Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$1D0A,     D1          
    TRAP    #15                     ; Trap (Perform action)
    LEA     OPTIONS_MSG_2,  A1   ; Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
        
    ; Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$1D0B,     D1          
    TRAP    #15                     ; Trap (Perform action)
    LEA     OPTIONS_MSG_3,  A1   ; Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)

    ; Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$1D0C,     D1          
    TRAP    #15                     ; Trap (Perform action)
    LEA     ENTER_OPTION_MSG,  A1   ; Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
	BSR DRAW
    
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$2B0C,     D1          
    TRAP    #15                     ; Trap (Perform action)
        
    CLR.L D1        ; clear D1
    MOVE.L #4, D0   ; read input task and store result in D1
    TRAP #15
    
    CMP.L #1, D1
    BEQ CONTINUE    ; if D1 = 1 return
    CMP.L #2, D1
    BEQ INITIALISE  ; if D1 = 2 branch to initialise
    CMP.L #3, D1
    BEQ EXIT        ; if D1 = 3 exit program
    BRA OPTIONS_MENU ; if D1 = anything else try again
CONTINUE:
    RTS
*-----------------------------------------------------------
* Subroutine    : CLEAR_SCREEN
* Description   : Clear screen subroutine
*-----------------------------------------------------------
CLEAR_SCREEN:
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
	MOVE.W  #$FF00,     D1          ; Fill Screen Clear
	TRAP	#15                     ; Trap (Perform action)
	RTS
*-----------------------------------------------------------
* Subroutine    : GAME_OVER
* Description   : Game over
*-----------------------------------------------------------
GAME_OVER:
    BSR CLEAR_SCREEN        ; clear screen

	MOVE.L #$00000000, D1   ; reset colour to black
    MOVE.B #80, D0          ; set pen colour
    TRAP #15
    MOVE.B #81, D0          ; set fill colour
    TRAP #15
    ; Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$2202,     D1          
    TRAP    #15                     ; Trap (Perform action)
    LEA     GAME_OVER_MSG,  A1   ; Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$1D09,     D1          
    TRAP    #15                     ; Trap (Perform action)
    LEA     GAME_OVER_MSG_1,  A1   ; Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$1D0A,     D1          
    TRAP    #15                     ; Trap (Perform action)
    LEA     GAME_OVER_MSG_2,  A1   ; Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    ; Player Score Value
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$2A0A,     D1          ; Col 09, Row 01
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  #03,        D0          ; Display number at D1.L
    MOVE.L  PLAYER_SCORE,D1         ; Move Score to D1.L
    TRAP    #15                     ; Trap (Perform action)
*-----------------------------------------------------------
* Subroutine    : EXIT
* Description   : Exit the program
*-----------------------------------------------------------
EXIT:
    ; Message
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$1D16,     D1          
    TRAP    #15                     ; Trap (Perform action)
    LEA     EXIT_MSG,  A1           ; Message
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
	BSR DRAW    ; draw scene
	
    MOVE.B  #9,   D0                ; Exit Code
    TRAP    #15                     ; Trap (Perform action)
    SIMHALT
*-----------------------------------------------------------
* Section       : Trap Codes
* Description   : Trap Codes used throughout StarterKit
*-----------------------------------------------------------
* Trap CODES
TC_SCREEN   EQU         33          ; Screen size information trap code
TC_S_SIZE   EQU         00          ; Places 0 in D1.L to retrieve Screen width and height in D1.L
                                    ; First 16 bit Word is screen Width and Second 16 bits is screen Height
TC_KEYCODE  EQU         19          ; Check for pressed keys
TC_DBL_BUF  EQU         92          ; Double Buffer Screen Trap Code
TC_CURSR_P  EQU         11          ; Trap code cursor position
*-----------------------------------------------------------
* Section       : Charater Setup
* Description   : Size of Player and Enemy and properties
* of these characters e.g Starting Positions and Sizes
*-----------------------------------------------------------
PLYR_W_INIT EQU         08          ; Players initial Width
PLYR_H_INIT EQU         08          ; Players initial Height

PLYR_DFLT_V EQU         00          ; Default Player Velocity
PLYR_JUMP_V DS.L        01          ; Player Jump Velocity
PLYR_DFLT_G EQU         01          ; Player Default Gravity

GND_TRUE    EQU         01          ; Player on Ground True
GND_FALSE   EQU         00          ; Player on Ground False

RUN_INDEX   EQU         00          ; Player Run Sound Index  
JMP_INDEX   EQU         01          ; Player Jump Sound Index  
OPPS_INDEX  EQU         02          ; Player Opps Sound Index

ENEMY_W     DS.L         1          ; Enemy initial Width
ENEMY_H     DS.L         1          ; Enemy initial Height
*-----------------------------------------------------------
* Section       : Game Stats
* Description   : Core game counters
*-----------------------------------------------------------
POINTS      EQU         01          ; Points added
LIVES       DC.B        0           ; Amount of lives
DIFFICULTY  DS.B        1           ; difficulty
PLANET      DS.B        1           ; planet
*-----------------------------------------------------------
* Section       : Keyboard Keys
* Description   : Spacebar and Escape or two functioning keys
* Spacebar to JUMP and Escape to Exit Game
*-----------------------------------------------------------
SPACEBAR    EQU         $20         ; Spacebar ASCII Keycode
ESCAPE      EQU         $1B         ; Escape ASCII Keycode
F3KEY       EQU         114         ; F3 key ASCII keycode
*-----------------------------------------------------------
* Section       : Delay variables
* Description   : Delay variables
*-----------------------------------------------------------
DELAY                   DC.L $5FF   ; Amount of clock cycles for each delay cycles
NEXT_INCREASE_CYCLES    DC.L $1F    ; Amount of delay cycles to wait before reducing the delay
CYCLES_TO_NEXT_INCREASE DC.L $1F    ; Counter of delay cycles
MINIMUM_DELAY           DC.L $1     ; Minimum amount of cycles for the delay, prevents game from going too fast
*-----------------------------------------------------------
* Section       : Messages
* Description   : Messages to Print on Console, names should be self documenting
*-----------------------------------------------------------
SCORE_MSG       DC.B    'Score: ', 0       ; Score Message
KEYCODE_MSG     DC.B    'KeyCode: ', 0     ; Keycode Message

X_MSG           DC.B    'X:', 0             ; X Position Message
Y_MSG           DC.B    'Y:', 0             ; Y Position Message
V_MSG           DC.B    'V:', 0             ; Velocity Position Message
G_MSG           DC.B    'G:', 0             ; Gravity Position Message
GND_MSG         DC.B    'GND:', 0           ; On Ground Position Message

EXIT_MSG        DC.B    'Exiting...', 0    ; Exit Message

CHOOSE_LEVEL_MSG DC.B 'CHOOSE A DIFFICULTY:', 0 
EASY_MSG1 DC.B '1-EASY', 0 
EASY_MSG2 DC.B 'Less, slower,', 0 
EASY_MSG3 DC.B 'Smaller enemies', 0 
EASY_MSG4 DC.B 'More lives', 0 
MEDIUM_MSG1 DC.B '2-MEDIUM', 0 
MEDIUM_MSG2 DC.B 'Medium speed', 0 
MEDIUM_MSG3 DC.B 'Normal enemies', 0
MEDIUM_MSG4 DC.B 'Standard lives', 0 
HARD_MSG1 DC.B '3-HARD', 0 
HARD_MSG2 DC.B 'More, bigger', 0 
HARD_MSG3 DC.B 'Faster enemies', 0 
HARD_MSG4 DC.B 'Less lives', 0 
ENTER_DIFFICULTY_MSG DC.B 'Enter difficulty (1-3):', 0
DIFFICULTY_MSG DC.B 'Difficulty:',0
DIFFICULTY_MSG_EASY DC.B 'easy',0
DIFFICULTY_MSG_NORMAL DC.B 'medium',0
DIFFICULTY_MSG_HARD DC.B 'hard',0
LIVES_MSG DC.B 'Lives:',0
CHOOSE_PLANET_MSG DC.B 'CHOOSE A PLANET:', 0 
EARTH_MSG1 DC.B '1-EARTH', 0 
EARTH_MSG2 DC.B 'Familiar world', 0 
EARTH_MSG3 DC.B 'High gravity', 0 
EARTH_MSG4 DC.B 'Low jumps', 0 
MOON_MSG1 DC.B '2-MOON', 0 
MOON_MSG2 DC.B 'Earths neighbour', 0 
MOON_MSG3 DC.B 'Low gravity', 0
MOON_MSG4 DC.B 'Super high jumps', 0 
MARS_MSG1 DC.B '3-MARS', 0 
MARS_MSG2 DC.B 'The red planet', 0 
MARS_MSG3 DC.B 'Medium gravity', 0 
MARS_MSG4 DC.B 'High jumps', 0 
ENTER_PLANET_MSG DC.B 'Enter planet (1-3):', 0
PLANET_MSG DC.B 'Planet:',0
PLANET_MSG_EARTH DC.B 'earth',0
PLANET_MSG_MOON DC.B 'moon',0
PLANET_MSG_MARS DC.B 'mars',0
OPTIONS_MSG DC.B 'GAME PAUSED', 0
OPTIONS_MSG_1 DC.B '1-continue', 0
OPTIONS_MSG_2 DC.B '2-reset game', 0
OPTIONS_MSG_3 DC.B '3-exit', 0
ENTER_OPTION_MSG DC.B 'Enter option: ', 0
GAME_OVER_MSG DC.B 'GAME OVER', 0
GAME_OVER_MSG_1 DC.B 'You lost all your lives!', 0
GAME_OVER_MSG_2 DC.B 'Final score: ', 0
*-----------------------------------------------------------
* Section       : Graphic Colors
* Description   : Colours constants
*-----------------------------------------------------------
WHITE           EQU     $00FFFFFF
RED             EQU     $000000FF
ORANGE          EQU     $0000A5FF
GREEN           EQU     $0000FF00
GROUND_EARTH    EQU     $00099900
SKY_EARTH       EQU     $00FFD21B
GROUND_MOON     EQU     $00AAAAAA
SKY_MOON        EQU     $00000000
GROUND_MARS     EQU     $001F59B4
SKY_MARS        EQU     $008AD3FF
; reserve space for colours
ENEMY_COLOUR    DS.L    1
GROUND_COLOUR   DS.L    1
SKY_COLOUR      DS.L    1
POWERUP_COLOUR  DC.L    $00AAAAAA
*-----------------------------------------------------------
* Section       : Screen Size
* Description   : Screen Width and Height (640*480)
*-----------------------------------------------------------
SCREEN_W        DS.W    01  ; Reserve Space for Screen Width
SCREEN_H        DS.W    01  ; Reserve Space for Screen Height
*-----------------------------------------------------------
* Section       : Keyboard Input
* Description   : Used for storing Keypresses
*-----------------------------------------------------------
CURRENT_KEY     DS.L    01  ; Reserve Space for Current Key Pressed
*-----------------------------------------------------------
* Section       : Character Positions
* Description   : Player and Enemy Position Memory Locations
*-----------------------------------------------------------
PLAYER_X        DS.L    01  ; Reserve Space for Player X Position
PLAYER_Y        DS.L    01  ; Reserve Space for Player Y Position
PLAYER_SCORE    DS.L    01  ; Reserve Space for Player Score

PLYR_VELOCITY   DS.L    01  ; Reserve Space for Player Velocity
PLYR_GRAVITY    DS.L    01  ; Reserve Space for Player Gravity
PLYR_ON_GND     DS.L    01  ; Reserve Space for Player on Ground

ENEMY_X         DS.L    01  ; Reserve Space for Enemy X Position
ENEMY_Y         DS.L    01  ; Reserve Space for Enemy Y Position
*-----------------------------------------------------------
* Section       : Other variables and constants
*-----------------------------------------------------------
BOX_SIZE           EQU  150 ; Box size constant
SHOW_ADVANCED_INFO DC.B 0   ; 0 = false, 1 = true
COLLISION_COOLDOWN DS.B 1   ; amount of frames to skip collision checking after a collison occurred, prevents multiple lives from being taken away on 1 hit
JUMP_SKIP_FRAMES   DC.B 1   ; slow down jump
JUMP_COOLDOWN      DS.B 1   ; how much the jump is slowed down by (i.e. gravity because no floating point numbers so if gravity = 1 and jump_cooldown = 4 then actual gravity = 0.25)
F3_KEY_COOLDOWN    DS.B 1   ; prevent f3 key from double clicking
MAX_ENEMY_HEIGHT   DS.W 1   ; max height of enemy (for each planet)
GROUND_HEIGHT      DS.L 1   ; height of the ground
IS_POWERUP         DS.B 1   ; is the current enemy a powerup (1 = true, 0 = false)
*-----------------------------------------------------------
* Section       : Sounds
* Description   : Sound files, which are then loaded and given
* an address in memory, they take a longtime to process and play
* so keep the files small. Used https://voicemaker.in/ to 
* generate and Audacity to convert MP3 to WAV
*-----------------------------------------------------------
JUMP_WAV        DC.B    'jump.wav',0        ; Jump Sound
RUN_WAV         DC.B    'run.wav',0         ; Run Sound
OPPS_WAV        DC.B    'opps.wav',0        ; Collision Opps
    END    START        ; last line of source










*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
