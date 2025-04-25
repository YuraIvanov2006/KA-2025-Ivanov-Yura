.model small
.stack 100h

.data
    filename    db 'test.in', 0     ; Input filename
    buffer      db 256 dup(0)       ; Input buffer for reading
    array       dw 100 dup(0)       ; Array to store numbers
    count       dw 0                ; Number of elements in array
    sum         dw 0                ; Sum for average calculation
    ten         dw 10               ; For decimal conversion
    temp        dw 0                ; Temporary storage for number parsing
    is_negative db 0                ; Flag for negative numbers
    
    ; Messages
    start_msg   db 'Program started', 13, 10, '$'
    open_msg    db 'Opening file...', 13, 10, '$'
    read_msg    db 'Reading file...', 13, 10, '$'
    sort_msg    db 'Sorting data...', 13, 10, '$'
    median_msg  db 'Median: $'
    mean_msg    db 13, 10, 'Average: $'
    error_file  db 'Error opening file!', 13, 10, '$'
    count_msg   db 'Numbers found: $'
    newline     db 13, 10, '$'
    file_handle dw 0

.code
main PROC
    ; Set up data segment
    mov ax, @data
    mov ds, ax

    ; Print start message
    mov ah, 09h
    lea dx, start_msg
    int 21h

    ; Open file
    mov ah, 3Dh
    mov al, 0                    ; Read mode
    lea dx, filename
    int 21h
    jnc file_opened
    
    ; File error
    mov ah, 09h
    lea dx, error_file
    int 21h
    jmp exit_program
    
file_opened:
    mov [file_handle], ax
    
    ; Initialize array index
    xor di, di                  ; DI will index into array
    mov word ptr [count], 0     ; Reset count
    mov word ptr [sum], 0       ; Reset sum
    mov word ptr [temp], 0      ; Clear temp
    mov byte ptr [is_negative], 0 ; Clear negative flag

read_loop:
    ; Read character from file
    mov ah, 3Fh
    mov bx, [file_handle]
    mov cx, 1                   ; Read one character
    lea dx, buffer
    int 21h
    
    ; Check for EOF or error
    cmp ax, 0
    je process_number
    
    mov al, [buffer]           ; Get the character
    
    ; Skip whitespace
    cmp al, ' '
    je save_and_reset
    cmp al, 13                 ; CR
    je save_and_reset
    cmp al, 10                 ; LF
    je save_and_reset
    cmp al, 9                  ; Tab
    je save_and_reset
    
    ; Check for negative sign
    cmp al, '-'
    jne not_negative
    mov byte ptr [is_negative], 1
    jmp read_loop
    
not_negative:
    ; Convert digit
    sub al, '0'
    cmp al, 9
    ja read_loop               ; Skip if not a digit
    
    ; Multiply current number by 10 and add new digit
    mov bx, [temp]
    mov dx, 10
    mov cx, ax                 ; Save digit
    mov ax, bx
    mul dx                     ; DX:AX = AX * 10
    add ax, cx                 ; Add new digit
    mov [temp], ax
    jmp read_loop

save_and_reset:
    ; If we have a number in progress, save it
    cmp word ptr [temp], 0     ; Check if we have a number
    jne process_number         ; If we have a number, process it
    jmp read_loop              ; Otherwise continue reading

process_number:
    ; Process current number
    mov ax, [temp]
    
    ; Apply negative sign if needed
    cmp byte ptr [is_negative], 0
    je store_positive
    neg ax                     ; Make negative if needed
    
store_positive:
    mov [array + di], ax       ; Store in array
    add di, 2                  ; Next array position
    inc word ptr [count]       ; Increment count
    add word ptr [sum], ax     ; Add to sum
    
    ; Reset for next number
    mov word ptr [temp], 0
    mov byte ptr [is_negative], 0
    
    ; If we reached EOF, we're done, otherwise continue reading
    cmp word ptr [count], 100  ; Check if array is full
    je sort_array              ; If full, stop reading
    
    ; Check if we were at EOF
    cmp ax, 0
    je sort_array              ; If EOF, we're done
    jmp read_loop              ; Otherwise continue reading
    
sort_array:
    ; Sort array (bubble sort)
    mov cx, [count]
    cmp cx, 1                  ; Skip sort if 0 or 1 elements
    jle print_results
    
    dec cx                     ; CX = count - 1
    
sort_outer:
    push cx
    lea si, array
    
sort_inner:
    mov ax, [si]
    cmp ax, [si+2]
    jle no_swap
    xchg ax, [si+2]
    mov [si], ax
    
no_swap:
    add si, 2
    loop sort_inner
    pop cx
    loop sort_outer
    
print_results:
    ; Print count
    mov ah, 09h
    lea dx, count_msg
    int 21h
    
    mov ax, [count]
    call print_number
    
    mov ah, 09h
    lea dx, newline
    int 21h
    
    ; Check if we have any numbers
    cmp word ptr [count], 0
    je close_file
    
    ; Calculate and print median
    mov ah, 09h
    lea dx, median_msg
    int 21h
    
    mov cx, [count]
    test cx, 1                 ; Check if count is odd
    jnz odd_count

    ; Even count - average of two middle elements
    mov ax, cx
    shr ax, 1                  ; count/2
    mov bx, ax
    dec bx                     ; (count/2)-1
    
    shl bx, 1                  ; Convert to word offset
    shl ax, 1
    
    lea si, array
    add si, bx                 ; Point to first middle element
    mov dx, [si]               ; Get first middle element
    add si, 2                  ; Move to second middle element
    add dx, [si]               ; Add second middle element
    
    mov ax, dx
    sar ax, 1                  ; Divide by 2 (signed)
    jmp print_median
    
odd_count:
    ; Odd count - middle element
    mov ax, cx
    shr ax, 1                  ; count/2
    shl ax, 1                  ; Convert to word offset
    
    lea si, array
    add si, ax                 ; Point to middle element
    mov ax, [si]               ; Get middle element
    
print_median:
    call print_number
    
    ; Calculate and print mean
    mov ah, 09h
    lea dx, mean_msg
    int 21h
    
    mov ax, [sum]
    cwd                        ; Sign extend to DX:AX
    idiv word ptr [count]
    call print_number
    
    mov ah, 09h
    lea dx, newline
    int 21h
    
close_file:
    ; Close file
    mov ah, 3Eh
    mov bx, [file_handle]
    int 21h
    
exit_program:
    mov ah, 4Ch
    int 21h
main ENDP

; Print signed number in AX
print_number PROC
    push bx
    push cx
    push dx
    
    test ax, ax
    jns positive
    
    push ax
    mov dl, '-'
    mov ah, 02h
    int 21h
    pop ax
    neg ax
    
positive:
    mov cx, 0
    mov bx, 10
    
convert:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz convert
    
print_digits:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop print_digits
    
    pop dx
    pop cx
    pop bx
    ret
print_number ENDP

end main