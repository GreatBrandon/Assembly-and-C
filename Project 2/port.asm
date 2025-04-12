global _start

section .text
_start:
    mov     r8, 3       ; initialise loop to 3
    mov     r10, 0      ; initialise total sum to 0

main_loop:
    mov     r9, 0       ; initialise sum to 0
    
    mov     rsi, PROMPT ; Load address of string into rsi
    mov     rdx, PROMPT_LEN ; load string length into rdx
    call    print       ; call print function

    call    read        ; call read function
    call    add_input   ; call add input function to convert input string into hex and add to total

    mov     rsi, PROMPT ; Load address of string into rsi
    mov     rdx, PROMPT_LEN ; load string length into rdx
    call    print       ; call print function

    call    read        ; call read function
    call    add_input   ; call add input function to convert input string into hex and add to total

    mov     rsi, RESULT ; address of string
    mov     rdx, RESULT_LEN ; length of string
    call    print       ; print string

    mov     rax, r9     ; move the current sum into rax
    call    display_sum ; call display sum function to convert hex to string output and display it
    
    add     r10, r9     ; add the total of last 2 inputs to final total
    dec     r8          ; decrement loop counter
    jnz     main_loop   ; jump to main_loop if r8 > 0

    mov     rsi, FINAL_RESULT
    mov     rdx, FINAL_RESULT_LEN
    call    print

    mov     rax, r10
    call    display_sum

    mov     rsi, rdi
    mov     rdx, output_len
    call    println

    mov     rax, 60     ; system call number for sys_exit
    xor     rdi, rdi    ; clear rdi to get argument 0 (success) on exit
    syscall             ; call kernel

read:
    mov     rax, 0      ; system call number for sys_read
    mov     rdi, 0      ; stdin (console)
    mov     rsi, input
    mov     rdx, input_len     ; max bytes to read
    syscall             ; call kernel
    ret

print:
    mov     rax, 1  ; system call number for sys_write
    mov     rdi, 1  ; stdout (console)
    syscall         ; call kernel
    ret

println:
    call    print   ; call print function
    push    rsi     ; push rsi to save address
    push    rdx     ; push rdx to save string length

    mov     rax, 1  ; system call number for sys_write
    mov     rsi, CRLF   ; get address of CRLF to rsi
    mov     rdx, 2  ; length of CRLF
    syscall         ; call kernel

    pop     rdx     ; pop to retrieve stored string length into rdx
    pop     rsi     ; pop to retrieve stored string address into rsi
    ret             ; return

add_input:
    mov     rsi, input
    xor     rax, rax

convert_loop:
    movzx   rbx, byte [rsi]
    test    rbx, rbx
    jz      done

    cmp     rbx, 0x0A
    je      done

    cmp     rbx, '0'
    jl      invalid_input

    cmp     rbx, '9'
    jg      invalid_input

    sub     rbx, '0'

    imul    rax, rax, 10
    add     rax, rbx

    inc     rsi
    jmp     convert_loop

done:
    add     r9, rax
    ret

invalid_input:
    mov     rsi, INVALID_MSG
    mov     rdx, INVALID_MSG_LENGTH
    call    println
    ret

display_sum:
    mov     rdi, output + output_len
    mov     byte [rdi], 0

display_loop:
    xor     rdx, rdx
    mov     rbx, 10
    div     rbx

    add     dl, '0'
    dec     rdi
    mov     [rdi], dl

    test    rax, rax
    jnz     display_loop

    mov     rsi, rdi
    mov     rdx, output_len
    call    println
    ret

section .data
    PROMPT          db  'Enter number: ', 0
    PROMPT_LEN      equ  $-PROMPT
    RESULT          db  'The sum is: ' ,0
    RESULT_LEN      equ  $-RESULT
    FINAL_RESULT    db  'Final sum is: ', 0
    FINAL_RESULT_LEN equ $-FINAL_RESULT
    CRLF            db   0x0D, 0x0A, 0
    CRLF_LEN        equ  $-CRLF
    INVALID_MSG     db  'Invalid input! Only 0-9 allowed!', 0
    INVALID_MSG_LENGTH equ $-INVALID_MSG
    TOO_LONG        db  'Input too long!', 0
    TOO_LONG_LENGTH equ  $-TOO_LONG 

section .bss
    input           resb 10 ; reserve 10 bytes for buffer
    input_len       equ $-input 
    output          resb 21
    output_len      equ $-output