.model small
.stack 100h

.data
   newline db 0dh, 0ah, "$"

   logo db 10 dup(' ') 
        db "#####", 0dh, 0ah
        db 10 dup(' ')  
        db "#", 0dh, 0ah
        db 10 dup(' ')         
        db "#####", 0dh, 0ah
        db 10 dup(' ')          
        db "#", 0dh, 0ah
        db 10 dup(' ') 
        db "#####", 0dh, 0ah, "$"

    correct_username db "admin$"
    correct_password db "password$"
    invalid_login_msg db "Wrong login credential provided.", 0dh, 0ah, "$"
    successful_login_msg db "Successful login.", 0dh, 0ah, "$"
    username_prompt_msg db "Username: ", "$"
    password_prompt_msg db "Password: ", "$"
    buffer_user db 20
                db "?"
                db 20 dup("$")
    buffer_password db 20
                    db "?"
                    db 20 dup("$")

    menu db "Please select what you intend to do (1, 2 or 3). Or press ESC to exit program", 0dh, 0ah
         db "1. Stock level tracking", 0dh, 0ah
         db "2. Cost calculation", 0dh, 0ah
         db "3. Sales tracking", 0dh, 0ah, "$"

    invalid_input_msg db "Invalid input!", 0dh, 0ah, "$"

    placeholder1 db "processing choice 1...", 0dh, 0ah, "$"
    placeholder2 db "processing choice 2...", 0dh, 0ah, "$"
    placeholder3 db "processing choice 3...", 0dh, 0ah, "$"

    ; For Choice 1: Stock tracking
    ; Prompt messages
    c1_initial_prompt    DB 'Enter Initial Stock (4-digit number): $'
    c1_received_prompt   DB 0Dh, 0Ah, 'Enter Items Received (4-digit number): $'
    c1_sold_prompt       DB 0Dh, 0Ah, 'Enter Items Sold (4-digit number): $'
    c1_result_prompt     DB 0Dh, 0Ah, 'Current Stock: $'
    
    ; Variables to store input values
    c1_initial_stock     DW ?
    c1_items_received    DW ?
    c1_items_sold        DW ?
    c1_current_stock     DW ?
    
    ; Buffer for number conversion (5 bytes, including newline and null terminator)
    c1_buffer            DB 5 DUP(?)

    ;invalid_input
    c1_invalid_msg       DB 0DH, 0AH,  'Please enter number between 4 digit : $'
   
.code
main proc
    mov ax, @data 
    mov es, ax
    mov ds, ax ; Initialize data segment

display_logo:
    ; Display string 
    mov ah, 09h
    lea dx, logo
    int 21h

    lea dx, newline
    int 21h
 
    jmp login_program

login_program:
    ; Display username prompt
    mov ah, 09h
    lea dx, username_prompt_msg
    int 21h

    ; Ask for username input
    mov ah, 0ah
    lea dx, buffer_user
    int 21h

    mov ah, 09h
    lea dx, newline
    int 21h

    ; Replace 0Dh null terminator with "$" 
    lea dx, buffer_user
    mov cx, 0
    add dx, 1
    mov bx, dx
    mov cl, [bx]
    add cl, 2

    lea dx, buffer_user
    mov bx, dx
    add bx, cx
    mov byte ptr [bx], "$"

    ; Compare username
    lea si, correct_username
    lea di, buffer_user
    add di, 2
    call CompareStrings
    jne invalid_login_program

    ; Display password prompt

    mov ah, 09h
    lea dx, password_prompt_msg
    int 21h

    ; Ask for password input 
    mov ah, 0ah
    lea dx, buffer_password
    int 21h

    mov ah, 09h
    lea dx, newline
    int 21h
     
    ; Replace 0Dh null terminator with "$" 
    lea dx, buffer_password
    mov cx, 0
    add dx, 1
    mov bx, dx
    mov cl, [bx]
    add cl, 2

    lea dx, buffer_password
    mov bx, dx
    add bx, cx
    mov byte ptr [bx], "$"

    ; Compare password
    lea si, correct_password
    lea di, buffer_password
    add di, 2
    call CompareStrings
    jne invalid_login_program

    jmp main_loop

invalid_login_program:
    ; Display invalid login message
    lea dx, invalid_login_msg
    int 21h
    jmp login_program

main_loop:
    ; Display menu
    mov ah, 09h
    lea dx, newline
    int 21h
  
    mov ah, 09h
    lea dx, menu
    int 21h

    ; Read user input 
    mov ah, 01h
    int 21h

    mov ah, 09h
    lea dx, newline
    int 21h

    cmp al, 1bh
    je exit_program

    cmp al, 31h
    jb invalid_program

    cmp al, 33h
    ja invalid_program

    cmp al, 31h
    je process_choice_1

    cmp al, 32h
    je process_choice_2

    cmp al, 33h
    je process_choice_3

process_choice_1:
    ; Call ProcessChoice1 function
    call ProcessChoice1

    ; Jump back main loop
    jmp main_loop

process_choice_2:
    ; Call ProcessChoice2 function
    call ProcessChoice2

    ; Jump back main loop
    jmp main_loop

process_choice_3:
    ; Call ProcessChoice3 function
    call ProcessChoice3

    ; Jump back main loop
    jmp main_loop

exit_program:
    ; Exit program
    mov ah, 4ch
    int 21h

invalid_program:
    ; Display error message
    lea dx, invalid_input_msg
    int 21h
    jmp main_loop

; Process choice 1 logic
ProcessChoice1 proc
    ; Prompt for initial stock
    mov ah, 09h
    lea dx, c1_initial_prompt
    int 21h
    
    ; Read initial stock
    call ReadNumber
    mov c1_initial_stock, ax
    
    ; Prompt for items received
    mov ah, 09h
    lea dx, c1_received_prompt
    int 21h
    
    ; Read items received
    call ReadNumber
    mov c1_items_received, ax
    
    ; Prompt for items sold
    mov ah, 09h
    lea dx, c1_sold_prompt
    int 21h
    
    ; Read items sold
    call ReadNumber
    mov c1_items_sold, ax
    
    ; Calculate current stock
    mov ax, c1_initial_stock
    add ax, c1_items_received
    sub ax, c1_items_sold
    mov c1_current_stock, ax
    
    ; Display result prompt
    mov ah, 09h
    lea dx, c1_result_prompt
    int 21h
    
    ; Convert and display current stock
    mov ax, c1_current_stock
    call DisplayNumber

    ret

ProcessChoice1 endp

; Process choice 2 logic
ProcessChoice2 proc
    mov ah, 09h
    lea dx, placeholder2 
    int 21h

    mov ah, 09h
    lea dx, newline
    int 21h
    
    ret
ProcessChoice2 endp

; Process choice 3 logic
ProcessChoice3 proc
    mov ah, 09h
    lea dx, placeholder3 
    int 21h

    mov ah, 09h
    lea dx, newline
    int 21h
    
    ret
ProcessChoice3 endp

; Compare two null-terminated strings
CompareStrings proc
     cld               ; Clear direction flag for forward string compare

compare_loop:
    lodsb             ; Load byte from SI to AL
    scasb             ; Compare byte in AL with byte in DI
    jne strings_not_equal
    cmp al, '$'       ; Check for null terminator
    jne compare_loop
    ret

strings_not_equal:
    stc               ; Set carry flag to indicate inequality
    ret

CompareStrings endp

; Procedure to read a 4-digit number
ReadNumber PROC
    ; Clear the buffer
    lea si, c1_buffer
    mov cx, 5      ; Maximum 5 characters (4 digits + newline)
    mov bx, 0      ; Accumulator for number
    
read_digit:
    ; Read single character
    mov ah, 01h
    int 21h
    
    ; Check for carriage return (Enter key)
    cmp al, 0Dh
    je done_reading
    
    ; Check if character is a digit ('0' - '9')
    cmp al, '0'
    jb invalid_input
    cmp al, '9'
    ja invalid_input
    
    ; Convert ASCII to number (subtract '0')
    sub al, '0'
    mov ah, 0
    
    ; Multiply previous number by 10 and add new digit
    push ax

    mov ax, bx
    mov dx, 10
    mul dx
    mov bx, ax
    pop ax
    add bx, ax
    
    ; Move to next digit
    loop read_digit
    
invalid_input:
    ; Handle invalid input, just a simple message
    ; First, print a newline to move to a new line
    mov dl, 0Dh     ; Carriage return
    mov ah, 02h
    int 21h
    mov dl, 0Ah     ; Line feed
    int 21h

    ; Now print the invalid message
    mov ah, 09h
    lea dx, c1_invalid_msg
    int 21h

    ; Jump back to read number procedure to retry input
    jmp ReadNumber ; Retry if input is invalid


done_reading:
    ; Print newline after input
    mov dl, 0Dh
    mov ah, 02h
    int 21h
    mov dl, 0Ah
    int 21h
    
    ; Return number in AX
    mov ax, bx
    ret
ReadNumber ENDP

; Convert number to string
DisplayNumber proc
    ; If the number is negative, handle it
    cmp ax, 0
    jge display_positive
    mov dl, '-'     ; Print negative sign
    mov ah, 02h
    int 21h
    neg ax

display_positive:
    ; Convert number to string
    lea si, c1_buffer
    mov cx, 0      ; Digit counter
    mov bx, 10     ; Divisor
    
convert_loop:
    mov dx, 0      ; Clear remainder
    div bx         ; Divide by 10
    add dl, '0'    ; Convert to ASCII
    push dx        ; Save digit
    inc cx         ; Increment counter
    
    ; Check if quotient is zero
    cmp ax, 0
    jne convert_loop
    
    ; Display digits
display_loop:
    pop dx         ; Retrieve digit
    mov ah, 02h
    int 21h
    loop display_loop
    
    ret

DisplayNumber endp 

main endp
end main