; Luis Miguel Rana
; Zhoe Aeris Gon Gon
; LBARrcx S13 | MCO1
%include "io64.inc"
section .data
    user_input times 15 db 0
    digits_buffer times 15 db 0  ; buffer to store digits found in the string
    count db 0 ; variable to store the count of digits
    user_char db 0xA ; for user input instructions
    converted_number dq 0 ; variable to store the converted number
    sum_of_squares dq 0
section .text
global main
main:
    PRINT_STRING "Input: "
    GET_STRING user_input, 12
    
    ; initialize count to 0
    mov byte [count], 0
    
    ; rsi points to the start of the string
    mov rsi, user_input  
    
    ; check if negative
    mov al, [user_input] ; load first character input
    cmp al, '-'
    je negative_input
    
    ; else, check for integers   
    xor rcx, rcx
    jmp count_loop

negative_input:
    PRINT_STRING "Error: Negative number input"
    jmp ask_to_continue

count_loop:
    cmp byte [rsi], 0   ; Check if we've reached the end of the string
    je end_count_loop   ; If yes, jump out of the loop
    
    ; Check if the character is a digit
    cmp byte [rsi], '0' ; Compare with the ASCII value of '0'
    jl not_digit        ; If less than '0', it's not a digit
    cmp byte [rsi], '9' ; Compare with the ASCII value of '9'
    jg not_digit        ; If greater than '9', it's not a digit
    
    ; If it's a digit, increment the count and store the digit
    inc byte [count]    
    mov al, [rsi]       ; Move the digit to AL register
    mov [digits_buffer + rcx], al ; Store the digit in the buffer
    inc rcx             ; Move to the next position in the buffer

not_digit:
    inc rsi             ; Move to the next character in the string
    jmp count_loop     ; Repeat the loop

end_count_loop: 
    cmp byte [count], 0
    jz invalid_input    ; if no integer, invalid
    jg validate_digits  ; if integer, validate if positive
    jmp ask_to_continue ; else continue
    
invalid_input:
    PRINT_STRING "Error: Invalid input"
    mov byte [count], 0     ; initialize count to 0
    jmp ask_to_continue
    
validate_digits:
    mov byte [count], 0     ; initialize count to 0
    mov rsi, digits_buffer  ; rsi pointer to first digit
    mov qword [converted_number], 0
    jmp clear_digits_buffer
    
clear_digits_buffer:
    cmp byte [rsi], 0   ; Check if we've reached the end of the string
    je execute_program  ; If yes, jump out of the loop
    
    ; Convert ASCII to decimal and store in converted_number
    sub byte [rsi], '0'
    movzx rax, byte [rsi]
    imul rdx, qword [converted_number], 10
    add rax, rdx
    mov qword [converted_number], rax
    
    ; Clear and increment
    mov byte [rsi], 0   ; Set the current character to 0
    inc byte [count]    ; Increment the count
    inc rsi             ; Move to the next character in the string
    jmp clear_digits_buffer      ; Repeat the loop


execute_program:
    mov rcx, 1 ; intialize counter
    mov rbx, qword [converted_number]
    cmp rbx, 0
    jz invalid_input
    PRINT_STRING "Iterations: "
    mov rax, [converted_number]
    mov qword [sum_of_squares], rax
    jmp iterations

sum_of_squares_loop:
    ; Get the LSdigit
    mov rdx, 0
    mov rsi, 10
    div rsi

    imul rdx, rdx ; rdx * rdx (square)
    add qword [sum_of_squares], rdx ; add the square to the sum
    cmp rax, 0
    jne sum_of_squares_loop ; loop through if there are remaining digits, 
    
    ; Proceed with next iteration
    jmp iterations

iterations:
    PRINT_UDEC 8, sum_of_squares ; Print current sum of squares
    
    ; If count<19 then is happy number, else if count=20 then sad number
    cmp qword [sum_of_squares], 1
    je happy_number 
    cmp rcx, 20
    je sad_number
   
    inc rcx ; increment counter
    
    mov rax, [sum_of_squares] ; Reset sum loop with new number from sum of squares
    
    mov qword [sum_of_squares], 0 ; Set the sum to 0
    PRINT_STRING ", "
    jmp sum_of_squares_loop ; calculate sum of squares

happy_number:
    NEWLINE
    PRINT_STRING "Sad Number: No"
    jmp ask_to_continue
sad_number:
    NEWLINE
    PRINT_STRING "Sad Number: Yes"
    NEWLINE
    jmp main

ask_to_continue:
    NEWLINE
    PRINT_STRING "Do you want to continue (Y/N)? "
    GET_STRING [user_char], 2
    
    ; Terminate if No
    cmp byte [user_char], 'N'
    je end_program
    
    ; Get input if Yes
    cmp byte [user_char], 'Y'
    GET_CHAR [user_char]
   
    jmp main
    
end_program:
    PRINT_STRING "Press the Enter Key to end terminal."
    GET_CHAR [user_char]
    GET_CHAR CX
    cmp CX, 0xA ; Hex value for enter Key
    je terminate_program
    jmp end_program

terminate_program:
    xor rax, rax
    ret