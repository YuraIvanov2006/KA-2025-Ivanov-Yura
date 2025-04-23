.model small
.stack 100h

.data
    buffer      db 256 dup(0)      ; Input buffer
    array       dw 10000 dup(0)    ; Array for numbers (16-bit words)
    temp_str    db 16 dup(0)       ; Temporary string for output
    count       dw 0               ; Count of numbers
    sum         dw 0, 0           ; Sum for mean calculation (32-bit)
    newline     db 13, 10          ; CR, LF for console output
    ten         dw 10              ; Constant for decimal conversion

.code
main proc
    ; Set up segments
    mov ax, @data
    mov ds, ax
    mov es, ax

    ; Initialize variables
    mov word ptr [count], 0
    mov word ptr [sum], 0
    mov word ptr [sum+2], 0
    lea di, array          ; DI points to array start

read_loop:
    ; Read character by character
    mov ah, 01h           ; DOS read character function
    int 21h
    
    cmp al, 1Ah           ; Check for Ctrl+Z (EOF)
    je process_numbers
    
    cmp al, 0Dh           ; Check for CR
    je skip_line_end
    cmp al, 0Ah           ; Check for LF
    je continue_read
    cmp al, 20h           ; Check for space
    je continue_read
    
    ; Start new number
    mov bx, 0            ; Clear accumulator
    mov cx, 0            ; Sign flag (0 = positive, 1 = negative)
    
    cmp al, '-'          ; Check for minus sign
    jne process_digit
    mov cx, 1            ; Set negative flag
    jmp continue_read

process_digit:
    sub al, '0'          ; Convert ASCII to number
    cmp al, 9            ; Check if valid digit
    ja continue_read
    
    ; Multiply BX by 10 and add new digit
    push ax              ; Save digit
    mov ax, bx
    mul word ptr [ten]   ; DX:AX = AX * 10
    mov bx, ax           ; Store result back in BX
    pop ax               ; Restore digit
    add bx, ax           ; Add new digit
    
    ; Check for overflow
    jo handle_overflow
    jmp continue_read

handle_overflow:
    mov bx, 32767        ; Set to max positive value
    jmp continue_read

store_number:
    cmp cx, 1            ; Check if negative
    jne store_positive
    neg bx               ; Make number negative
    
store_positive:
    ; Store number in array
    mov [di], bx
    add di, 2
    inc word ptr [count]
    
    ; Add to sum
    mov ax, bx
    cwd                  ; Sign extend AX into DX:AX
    add word ptr [sum], ax
    adc word ptr [sum+2], dx
    
continue_read:
    jmp read_loop

skip_line_end:
    mov ah, 01h          ; Read next character
    int 21h
    cmp al, 0Ah          ; Check if LF
    jmp continue_read

process_numbers:
    ; Sort numbers (bubble sort)
    mov cx, [count]
    dec cx               ; CX = count - 1
    jcxz print_results   ; If count <= 1, skip sorting
    
outer_loop:
    push cx
    lea si, array
    mov dx, cx          ; Inner loop counter
    
inner_loop:
    mov ax, [si]         ; Get current number
    cmp ax, [si+2]       ; Compare with next
    jle no_swap
    
    ; Swap numbers
    xchg ax, [si+2]
    mov [si], ax
    
no_swap:
    add si, 2
    dec dx
    jnz inner_loop
    
    pop cx
    loop outer_loop

print_results:
    ; Calculate median
    mov ax, [count]
    test ax, ax          ; Check if count is zero
    jz exit_program      ; Exit if no numbers
    
    test ax, 1           ; Check if count is odd
    jz even_count
    
    ; Odd count - take middle element
    shr ax, 1            ; Divide by 2
    shl ax, 1            ; Multiply by 2 for array index
    lea si, array
    add si, ax
    mov ax, [si]
    jmp print_median
    
even_count:
    ; Even count - average two middle elements
    shr ax, 1            ; Divide by 2
    dec ax
    shl ax, 1            ; Multiply by 2 for array index
    lea si, array
    add si, ax
    mov ax, [si]         ; First middle element
    add ax, [si+2]       ; Add second middle element
    sar ax, 1            ; Divide by 2
    
print_median:
    call print_number    ; Print median
    
    ; Calculate and print mean
    mov ax, word ptr [sum]
    mov dx, word ptr [sum+2]
    idiv word ptr [count]
    call print_number

exit_program:    
    ; Exit program
    mov ah, 4Ch
    int 21h
main endp

; Print signed number in AX to console
print_number proc
    push bx
    push cx
    push dx
    
    test ax, ax          ; Check if negative
    jns positive
    
    push ax
    mov dl, '-'
    mov ah, 02h
    int 21h
    pop ax
    neg ax
    
positive:
    xor cx, cx           ; Digit counter
    mov bx, 10
    
convert:
    xor dx, dx
    div bx              ; Divide by 10
    push dx             ; Save remainder
    inc cx
    test ax, ax
    jnz convert
    
print_digits:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop print_digits
    
    ; Print newline
    mov dl, 13          ; CR
    mov ah, 02h
    int 21h
    mov dl, 10          ; LF
    mov ah, 02h
    int 21h
    
    pop dx
    pop cx
    pop bx
    ret
print_number endp

end main