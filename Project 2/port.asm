global _start
section .text
_start:
    ; start of program, initalise values
    mov     r8, 3       ; initialise loop to 3
    mov     r10, 0      ; initialise total sum to 0

main_loop:
    ; main loop
    mov     r9, 0       ; initialise sum to 0
    
    mov     rsi, PROMPT ; load address of string into rsi
    mov     rdx, PROMPT_LEN ; load string length into rdx
    call    print       ; call print function

    call    read        ; call read function
    call    add_input   ; call add input function to convert input string into hex and add to total

    mov     rsi, PROMPT ; load address of string into rsi
    mov     rdx, PROMPT_LEN ; load string length into rdx
    call    print       ; call print function

    call    read        ; call read function
    call    add_input   ; call add input function to convert input string into hex and add to total

    mov     rsi, RESULT ; load address of string into rsi
    mov     rdx, RESULT_LEN ; load string length into rdx
    call    print       ; call print function

    mov     rax, r9     ; copy the current sum into rax
    call    display_sum ; call display_sum function to convert hex to string output and display it
    
    add     r10, r9     ; add the total of last 2 inputs to final total
    dec     r8          ; decrement loop counter
    jnz     main_loop   ; jump to main_loop if r8 > 0

    mov     rsi, FINAL_RESULT       ; load address of string into rsi
    mov     rdx, FINAL_RESULT_LEN   ; load string length into rdx
    call    print                   ; call print function

    mov     rax, r10        ; copy the final sum into rax
    call    display_sum     ; call display_sum function to convert hex to string output and display it

    mov     rax, 60     ; system call number for sys_exit
    xor     rdi, rdi    ; clear rdi to get argument 0 (success) on exit
    syscall             ; call kernel

read:
    ; read function reads input from terminal and stores in input buffer
    mov     rax, 0      ; system call number for sys_read
    mov     rdi, 0      ; stdin (console)
    mov     rsi, input  ; load address of input buffer into rsi
    mov     rdx, input_len     ; load length of input buffer into rdx
    syscall             ; call kernel
    ret                 ; return

print:
    ; print function prints the current string in rsi and string length in rdx to console
    mov     rax, 1  ; system call number for sys_write
    mov     rdi, 1  ; stdout (console)
    syscall         ; call kernel
    ret             ; return

println:
    ; println function does the same as print, however it also prints a CRLF at the end (original rsi and rdx is preserved)
    call    print   ; call print function
    push    rsi     ; push rsi to save address
    push    rdx     ; push rdx to save string length

    mov     rax, 1  ; system call number for sys_write
    mov     rsi, CRLF   ; load address of CRLF to rsi
    mov     rdx, 2  ; length of CRLF
    syscall         ; call kernel

    pop     rdx     ; pop to retrieve stored string length into rdx
    pop     rsi     ; pop to retrieve stored string address into rsi
    ret             ; return


add_input:
    ; add_input function gets the value stored in input buffer and attempts to add the numerical value to r9
    ; if input is non numerical (characters other than 0-9) then it will print an error message instead and won't add
    cmp     rax, input_len  ; check is the amount of bytes read in the terminal greater than the input buffer
    jge     input_too_long  ; if the input doesn't fit into buffer, jump to this function to prevent buffer overflow vulnerability
    mov     rsi, input      ; copy input buffer into rsi
    xor     rax, rax        ; clear rax


convert_loop:
    ; convert_loop handles the logic of converting the string into integer format
    ; it loops through all characters of the input buffer (most significant to least significant) for each character:
    ; 1. checks is it valid
    ; 2. converts it from ascii into numerical
    ; 3. adds it to the total
    ; 4. multiply total by 10
    movzx   rbx, byte [rsi] ; get the current byte (position) of the string address stored in rsi and copy it to rbx
    test    rbx, rbx        ; check is rbx = 0
    jz      done            ; if equal jump to done

    cmp     rbx, 0x0A       ; check is rbx a newline character (enter key)
    je      done            ; if equal jump to done

    cmp     rbx, '0'        ; compare rbx to the ascii value of '0'
    jl      invalid_input   ; if less than 0, jump to invalid input

    cmp     rbx, '9'        ; compare rbx to the ascii value of '9'
    jg      invalid_input   ; if greater than 9, jump to invalid input

    ; if character stored in rbx is between 0-9, continue running
    sub     rbx, '0'        ; subtract the ascii value of '0' from rbx (e.g. ascii '1' = 49, we want the decimal value 1 so we subtract 48 AKA '0')

    imul    rax, rax, 10    ; multiply the value of rax by 10 and store the result in rax
    add     rax, rbx        ; add the value in rbx to rax and store result in rax

    inc     rsi             ; increment rsi (move to next character in input string)
    jmp     convert_loop    ; loop back to convert loop

done:
    ; done function simply adds the total in rax into r9 and returns
    add     r9, rax         ; add the value of rax to r9 and store result in r9
    ret                     ; return

invalid_input:
    ; this function prints an error message to console and returns, preventing anything from being added
    mov     rsi, INVALID_MSG        ; load address of string into rsi
    mov     rdx, INVALID_MSG_LENGTH ; load string length into rdx
    call    println                 ; call println function
    ret                             ; return

input_too_long:
    ; this function discards all excess input by reading in buffered input from the terminal byte by byte until the newline has been reached
    ; this prevents buffer overflow from happening
    mov     rax, 0      ; system call number for sys_read
    mov     rdi, 0      ; stdin (console)
    mov     rsi, input  ; load address of input buffer into rsi
    mov     rdx, 1      ; read only 1 byte
    syscall             ; call kernel

    cmp     byte [input], 0xA   ; check has the newline character been reached 
    jne     input_too_long      ; if not continue reading bytes until newline has been reached

    mov     rsi, TOO_LONG           ; load address of string into rsi
    mov     rdx, TOO_LONG_LENGTH    ; load length of string into rdx
    call    println                 ; call println function
    ret                             ; return

display_sum:
    ; display_sum function displays the current sum stored in rax into console
    mov     rdi, output + output_len    ; copy the address of the last character in the output buffer into rdi
    mov     byte [rdi], 0               ; place a 0 (null terminator) into the byte at that address in rdi


display_loop:
    ; convert_loop handles the logic of converting the integer into string format
    ; it continues looping until rax = 0:
    ; 1. divide rax by 10
    ; 2. get the remainder and convert into ascii represntation
    ; 3. copy it into the least significant empty byte of the output buffer (output buffer is filled right to left, least significant to most significant digit)
    ; 4. decrement the pointer to point to the next more significant byte
    ; finally it prints the string stored in the output buffer
    xor     rdx, rdx        ; clear rdx
    mov     rbx, 10         ; move 10 into rbx
    div     rbx             ; divide the value in rax by rbx, result is stored in rax, remainder is stored in dl

    add     dl, '0'         ; add the ascii value of 0 into dl (e.g. 3 in dl add 48 is equal to 52, which is the ascii value of '3')
    dec     rdi             ; decrement rdi (i.e. move to the next byte in the output buffer string address stored in rdi)
    mov     [rdi], dl       ; copy dl into that value in rdi (keyword byte not needed as dl is exactly a byte long)

    test    rax, rax        ; check is the value in rax = 0
    jnz     display_loop    ; loop back to display loop if not equal to 0

    mov     rsi, output     ; load address of string into rsi
    mov     rdx, output_len ; load string length into rdx
    call    println         ; call println function
    ret                     ; return

section .data
    ; this section stores all initialised constants and variables
    PROMPT          db  'Enter number: ', 0
    PROMPT_LEN      equ  $-PROMPT
    RESULT          db  'The sum is: ' ,0
    RESULT_LEN      equ  $-RESULT
    FINAL_RESULT    db  'Final sum is: ', 0
    FINAL_RESULT_LEN equ $-FINAL_RESULT
    CRLF            db   0x0D, 0x0A, 0
    CRLF_LEN        equ  $-CRLF
    INVALID_MSG     db  'Invalid input! Only 0-9 allowed! Input was replaced with 0!', 0
    INVALID_MSG_LENGTH equ $-INVALID_MSG
    TOO_LONG        db  'Input too long (only 15 characters allowed)! Input was replaced with 0!', 0
    TOO_LONG_LENGTH equ  $-TOO_LONG 

section .bss
    ; this section stores all uninitialised constants and variables
    input           resb 15     ; reserve 10 bytes for buffer
    input_len       equ $-input ; length of input buffer
    output          resb 21     ; reserve 21 bytes for output buffer (64 bit number never bigger than 21 bytes)
    output_len      equ $-output    ; length of output buffer