.model small
.stack 100h

.data
   product1 db "1. Phone - Stock: $"
   product2 db "2. Cooler - Stock: $"
   product3 db "3. Lamp - Stock: $"

   stock1 dw 9     ; Initial stock for smartphone
   stock2 dw 8     ; Initial stock for laptop
   stock3 dw 300     ; initial stock for headphones

   electronic_choice db 0    ; Initial choice
   quantity dw 0             ; Initial quantity

   ; Define prices in cents (to avoid floating-point math)
   price1 dw 5959     ; Phone price: 59.59
   price2 dw 3850     ; Cooler price: 38.50
   price3 dw 999      ; Lamp price: 9.99

   username_prompt db "Enter username: ", 13, 10, "$"
   password_prompt db "Enter password: ", 13, 10, "$"
   invalid_login db "Invalid login. Try again.", 13, 10, "$"
   login_success db "Login successful!", 13, 10, "$"
   correct_username db "admin$", 0
   correct_password db "password$", 0
   username_input db 20 
                  db ? 
                  db 20 dup('$')  ; Buffer for username input
   password_input db 20 
                  db ?
                  db 20 dup('$')  ; Buffer for password input
   

   input_msg db 13, 10, "Enter your choice (1-3). Enter 0 for exit:" , 13, 10, "$"
   qty_msg db "Enter quantity to purchase (1 - 9): " , 13, 10, "$"
   out_of_stock db "Insufficient stock!" , 13, 10, "$"
   success_msg db "Purchase successful! " , 13, 10, "$"
   invalid_choice db "Invalid choice!" , 13, 10, "$"
   dot db "." ; Define the string in memory
   logo db "Logo message" , 13, 10, "$" ; logo message

   unit_price_msg db "Unit price: RM $"  ; Placeholder for dynamic pricing
   total_price_msg db "Total price: RM $", "$"
   confirm_msg db "Confirm purchase? (y/n): ", 13, 10, "$"
   purchase_cancelled db "Purchase cancelled.", 13, 10, "$"

   newline db 13, 10, "$"
   temp_str db 9 dup('$')    ; Buffer for number conversion

.code
main proc
    mov ax, @data 
    mov es, ax
    mov ds, ax        ; Initialize data segment

    ; Simulate login
    call LoginSimulation

    ; If login fails, terminate the program
    cmp al, 0
    jne main_loop
    jmp exit_program

main_loop:
    lea dx, newline
    mov ah, 09h
    int 21h

    lea dx, logo
    int 21h
    
    ; Display product 1
    mov ah, 09h
    lea dx, product1
    int 21h
    
    ; Display product 1 stock
    mov ax, stock1
    call DisplayStock
    lea dx, newline
    mov ah, 09h
    int 21h

    ; Display product 2
    mov ah, 09h
    lea dx, product2
    int 21h
    
    ; Display product 2 stock
    mov ax, stock2
    call DisplayStock
    lea dx, newline
    mov ah, 09h
    int 21h

    ; Display product 3
    mov ah, 09h
    lea dx, product3
    int 21h
    
    ; Display product 3 stock
    mov ax, stock3
    call DisplayStock
    lea dx, newline
    mov ah, 09h
    int 21h

    ; Ask for user input on which electronic product to choose from
    mov ah, 09h
    lea dx, input_msg
    int 21h

    mov ah, 01h
    int 21h
    sub al, '0'

    mov ah, 09h
    mov dx, offset newline
    int 21h

    cmp al, 0
    jb invalid_input
    cmp al, 3
    ja invalid_input
    cmp al, 0
    je exit_program

    ; Save electronic choice 
    mov electronic_choice, al

    ; Display unit price label
    mov ah, 09h
    lea dx, unit_price_msg
    int 21h
    
    ; Display unit price
    xor ax, ax
    mov al, electronic_choice
    cmp ax, 1
    je display_unitprice_product1
    cmp ax, 2
    je display_unitprice_product2
    cmp ax, 3
    je display_unitprice_product3
    jmp invalid_input ; Ensure unhandled cases are treated as invalid

exit_program:
    ; Exit program
    mov ah, 4Ch      ; DOS interrupt to terminate
    int 21h

invalid_input:
    mov ah, 09h
    lea dx, invalid_choice
    int 21h
    jmp main_loop



display_unitprice_product1:
    xor ax, ax
    mov ax, price1
    call DisplayPrice

    lea dx, newline
    mov ah, 09h
    int 21h
    jmp prompt_quantity
    
display_unitprice_product2:
    xor ax, ax
    mov ax, price2
    call DisplayPrice

    lea dx, newline
    mov ah, 09h
    int 21h
    jmp prompt_quantity

display_unitprice_product3:
    xor ax, ax
    mov ax, price3
    call DisplayPrice

    lea dx, newline
    mov ah, 09h
    int 21h
    jmp prompt_quantity

prompt_quantity:
    ; Prompt user for quantity
    mov ah, 09h
    lea dx, qty_msg
    int 21h

    mov ah, 01h
    int 21h
    sub al, '0'       ; Convert ASCII to integer CS:0078

    ; store the quantity
    and ax, 0Fh
    mov quantity, ax

    mov ah, 09h
    mov dx, offset newline
    int 21h

    cmp al, 1
    jb invalid_input
    cmp al, 9
    ja invalid_input
    
    mov ah, 09h
    lea dx, confirm_msg
    int 21h

    mov ah, 01h
    int 21h

    mov ah, 09h
    mov dx, offset newline
    int 21h

    cmp al, 121
    je process_product
    cmp al, 110
    je cancel
    jmp invalid_input

process_product:
    ; Check and update stock
    xor ax, ax
    xor cx, cx
    mov al, electronic_choice
    mov cx, quantity
    cmp ax, 1
    je process_product1
    cmp ax, 2
    je process_product2
    cmp ax, 3
    je process_product3

process_product1:
    xor ax, ax
    mov ax, stock1
    cmp ax, cx       ; Check if stock is enough
    jl insufficient_stock
    sub ax, cx       ; Update stock
    mov stock1, ax
    jmp success

process_product2:
    xor ax, ax
    mov ax, stock2
    cmp ax, cx
    jl insufficient_stock
    sub ax, cx
    mov stock2, ax
    jmp success

process_product3:
    xor ax, ax
    mov ax, stock3
    cmp ax, cx
    jl insufficient_stock
    sub ax, cx
    mov stock3, ax
    jmp success

insufficient_stock:
    mov ah, 09h
    lea dx, out_of_stock
    int 21h
    jmp main_loop

cancel:
    mov ah, 09h
    lea dx, purchase_cancelled
    int 21h
    jmp main_loop

; Calculate total price
success:
    mov ah, 09h
    lea dx, success_msg
    int 21h    
    
    lea dx, total_price_msg 
    int 21h

    mov al, electronic_choice
    cmp al, 1
    je calculate_total_product1
    cmp al, 2
    je calculate_total_product2
    cmp al, 3
    je calculate_total_product3
    jmp invalid_input

calculate_total_product1:
    xor ax, ax
    mov ax, price1
    mov bx, quantity
    mul bx              ; Multiply AX by BL (quantity)
    call DisplayPrice
    lea dx, newline
    mov ah, 09h
    int 21h
    jmp main_loop

calculate_total_product2:
    xor ax, ax
    mov ax, price2
    mov bx, quantity
    mul bx
    call DisplayPrice
    lea dx, newline
    mov ah, 09h
    int 21h
    jmp main_loop

calculate_total_product3:
    xor ax, ax
    mov ax, price3
    mov bx, quantity
    mul bx
    call DisplayPrice
    lea dx, newline
    mov ah, 09h
    int 21h
    jmp main_loop

; Subroutine to display product details with stock
; Inputs:
;   DX = Address of product string
;   AX = Integer
DisplayStock proc
    lea di, temp_str
    add di, 8        ; move DI to the end of the buffer
    dec di           ; DI is decremented immediately to avoid overwriting the null terminator
    mov cx, 0        ; Initialise digit count

stock_convert_loop:
    xor dx, dx       ; Clear DX for division
    mov bx, 10
    div bx           ; AX = AX / 10, remainder in DX, quotient in AX
    add dl, '0'       ; Convert remainder to ASCII
    mov [di], dl     ; store digit in temp_str
    dec di
    inc cx
    cmp ax, 0

    jne stock_convert_loop ; Repeat until AX is 0

    ; Adjust DI to point to the start of the digits
    lea di, temp_str
    add di, 8        ; Point to end of buffer
    sub di, cx       ; Adjust for the number of digits

    mov ah, 09h
    mov dx, di
    int 21h

    ret
DisplayStock endp

; Subroutine to display product price
; Inputs:
;   DX = Address of product string
;   AX = Price in cents
DisplayPrice proc
    lea di, temp_str
    add di, 8        ; move DI to the end of the buffer
    dec di           ; DI is decremented immediately to avoid overwriting the null terminator
    mov cx, 0        ; Initialise digit count

; Convert to string
price_convert_loop:
    xor dx, dx       ; Clear DX for division
    mov bx, 10
    div bx           ; AX = AX / 10, remainder in DX, quotient in AX
    add dl, '0'       ; Convert remainder to ASCII
    mov [di], dl     ; store digit in temp_str
    dec di
    inc cx
    cmp ax, 0

    jne price_convert_loop   ; Repeat until AX is 0

; Add decimal point
    lea di, temp_str
    add di, 8        ; Point to end of buffer
    sub di, cx       ; Adjust for the number of digits
    sub di, 2        ; Adjust one more to the left
    mov dx, 0  
    dec cx
    dec cx   

shift_loop:
    add di, 1
    mov al, [di + 1]
    mov [di], al
    inc dx
    cmp dx, cx
    jne shift_loop
    
    add di, 1
    mov al, dot
    mov [di], al

    sub di, dx
    mov ah, 09h
    mov dx, di
    int 21h

    ret
DisplayPrice endp

LoginSimulation proc
    ; Prompt for username
    mov ah, 09h
    lea dx, username_prompt
    int 21h

    ; Read username
    lea dx, username_input
    mov ah, 0Ah        ; DOS interrupt to read string input
    int 21h

    ; Null-terminate the username input for comparison
    xor cx, cx
    lea di, username_input + 2 ; Skip the buffer size and input size
    mov cl, [di - 1]   ; Get input length
    add di, cx
    mov byte ptr [di], '$' ; Add '$' to terminate string

    ; Compare username
    lea si, correct_username
    lea di, username_input + 2  ; Skip the buffer size and input size
    call CompareStrings
    jne login_fail     ; If not equal, login fails

    ; Prompt for password
    mov ah, 09h
    lea dx, password_prompt
    int 21h

    ; Read password
    lea dx, password_input
    mov ah, 0Ah        ; DOS interrupt to read string input
    int 21h

    ; Null-terminate the password input for comparison
    lea di, password_input + 2
    mov cl, [di - 1]
    add di, cx
    mov byte ptr [di], '$'

    ; Compare password
    lea si, correct_password
    lea di, password_input + 2
    call CompareStrings
    jne login_fail     ; If not equal, login fails

    ; Login successful
    mov ah, 09h
    lea dx, login_success
    int 21h
    mov al, 1         ; Return success
    ret

login_fail:
    mov ah, 09h
    lea dx, invalid_login
    int 21h
    mov al, 0         ; Return failure
    ret
LoginSimulation endp

; Compare two null-terminated strings
; Inputs: SI = Address of string 1, DI = Address of string 2
; Outputs: ZF set if strings are equal, cleared otherwise
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

main endp
end main