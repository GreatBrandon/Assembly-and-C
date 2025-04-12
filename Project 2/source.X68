*------------------------------------------------------------------
* Title		: Parameter Passing Example for EASy68K
* Written by	: Philip Bourke
* Date Created	: March-25-2025
* Description	: Demonstrates passing parameters using registers
*		  and stack, performing arithmetic operations,
*		  and running a loop to keep a running sum.
*		  Highlights security vulnerabilities related to
*		  stack handling, input validation, and memory access.
*------------------------------------------------------------------
START	ORG $1000

	CLR.L	D3		; Running sum initialized to 0
	MOVE.W	#3, D4		; Loop counter set to 3

GAME_LOOP:
	* Input two numbers and add them using REGISTER_ADDER subroutine
	MOVE.B	#14,D0		; Task 14: Display string
	LEA	PROMPT,A1	; Load address of prompt string
	TRAP	#15		; System call (No input validation - Vulnerable!)

	MOVE.B	#4,D0		; Task 4: Read integer input (No input validation - Vulnerable!)
	TRAP	#15		; Execute system call
	MOVE.L	D1,D2		; Store first number in D2

	MOVE.B	#14,D0
	LEA	PROMPT,A1	; Display prompt again (No validation - Vulnerable!)
	TRAP	#15

	MOVE.B	#4,D0
	TRAP	#15		; Read second number into D1 (No validation - Vulnerable!)

	BSR	REGISTER_ADDER	; Call subroutine (D1 = D1 + D2)
	ADD.L	D1, D3		; Add result to running sum

	MOVE.B	#14,D0
	LEA	RESULT,A1
	TRAP	#15
	MOVE.B	#3,D0
	TRAP	#15

	BSR	NEW_LINE

	* Decrement loop counter and repeat if not zero
	SUBQ.W	#1, D4
	BNE	GAME_LOOP

	* Display final sum
	MOVE.B	#14,D0
	LEA	FINAL_RESULT,A1
	TRAP	#15
	MOVE.L	D3,D1
	MOVE.B	#3,D0
	TRAP	#15

	SIMHALT

*------------------------------------------------------------------
* Add numbers using register parameters
REGISTER_ADDER:
	ADD.L	D2, D1		; Add D2 to D1 (No bounds checking - Vulnerable!)
	RTS			; Return from subroutine

*------------------------------------------------------------------
* Subroutine to display Carriage Return and Line Feed
NEW_LINE:
	MOVE.B	#14,D0
	LEA	CRLF,A1
	TRAP	#15
	RTS

*------------------------------------------------------------------
* Strings
PROMPT		DC.B	'Enter number: ',0
RESULT		DC.B	'The sum is: ',0
FINAL_RESULT	DC.B	'Final sum is: ',0
CRLF		DC.B	$D,$A,0

	END	START
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
