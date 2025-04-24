.model small
.stack 100h

.data
    filename    db 'TEST.IN', 0    ; Input file name (uppercase for DOS)
    buffer      db 256 dup(0)      ; Input buffer
    array       dw 10000 dup(0)    ; Array for numbers (16-bit words)
    temp_str    db 16 dup(0)       ; Temporary string for output
    count       dw 0               ; Count of numbers
    sum         dw 0, 0           ; Sum for mean calculation (32-bit)
    file_handle dw 0              ; File handle
    ten         dw 10              ; Constant for decimal conversion
    error_msg   db 'Error opening file TEST.IN$'
    median_msg  db 'Median: $'
    mean_msg    db 'Mean: $'
    newline     db 13, 10, '$'     ; CRLF string
    pause_msg   db 'Press any key to continue...$'

.code
main proc
    ; Set up segments
    mov ax, @data
    mov ds, ax
    mov es, ax

    ; Open file for reading
    mov ah, 3Dh         ; DOS open file function
    mov al, 0           ; Read access
    lea dx, filename
    int 21h
    jnc file_opened     ; Jump if no error (carry flag not set)
    
    ; Print error message
    mov ah, 09h
    lea dx, error_msg
    int 21h
    mov ah, 09h
    lea dx, newline
    int 21h
    jmp exit_program
    
file_opened:
    mov [file_handle], ax

    ; Initialize variables
    mov word ptr [count], 0
    mov word ptr [sum], 0
    mov word ptr [sum+2], 0
    lea di, array          ; DI points to array start

read_file:
    ; Read from file
    mov ah, 3Fh         ; DOS read file function
    mov bx, [file_handle]
    mov cx, 255         ; Max bytes to read
    lea dx, buffer
    int 21h
    jc file_error       ; Jump if error
    
    test ax, ax         ; Check if EOF (ax = 0)
    jz process_numbers  ; If EOF, process numbers
    
    ; Process buffer
    lea si, buffer
    mov cx, ax          ; Number of bytes read
    
process_buffer:
    lodsb               ; Load byte from SI into AL and increment SI
    
    cmp al, 0Dh         ; Check for CR
    je skip_line_end
    cmp al, 0Ah         ; Check for LF
    je next_char
    cmp al, 20h         ; Check for space
    je next_char
    
    ; Start new number
    mov bx, 0            ; Clear accumulator
    mov dx, 0            ; Sign flag (0 = positive, 1 = negative)
    
    cmp al, '-'          ; Check for minus sign
    jne process_digit
    mov dx, 1            ; Set negative flag
    jmp next_char

process_digit:
    sub al, '0'          ; Convert ASCII to number
    cmp al, 9            ; Check if valid digit
    ja next_char
    
    ; Multiply BX by 10 and add new digit
    push ax              ; Save digit
    mov ax, bx
    mul word ptr [ten]   ; DX:AX = AX * 10
    mov bx, ax           ; Store result back in BX
    pop ax               ; Restore digit
    add bx, ax           ; Add new digit
    
    ; Check for number delimiter (space, CR, LF)
    mov al, [si]
    cmp al, 20h          ; Space
    je store_number
    cmp al, 0Dh          ; CR
    je store_number
    cmp al, 0Ah          ; LF
    je store_number
    cmp al, 0            ; End of buffer
    je store_number
    
    jmp next_char

store_number:
    cmp dx, 1            ; Check if negative
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
    
next_char:
    dec cx
    jnz process_buffer
    jmp read_file

skip_line_end:
    dec cx
    jz read_file
    inc si               ; Skip CR
    cmp byte ptr [si], 0Ah  ; Check if LF follows
    jne next_char
    inc si               ; Skip LF
    dec cx
    jnz process_buffer
    jmp read_file

file_error:
    ; Print error message
    mov ah, 09h
    lea dx, error_msg
    int 21h
    
    ; Close file if it was opened
    mov bx, [file_handle]
    test bx, bx
    jz no_close
    mov ah, 3Eh
    int 21h
    
no_close:
    ; Print pause message
    mov ah, 09h
    lea dx, pause_msg
    int 21h
    
    ; Wait for key press
    mov ah, 01h
    int 21h
    
    jmp exit_program

process_numbers:
    ; Close file
    mov ah, 3Eh
    mov bx, [file_handle]
    int 21h

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
    
    ; Print "Median: " message
    mov ah, 09h
    lea dx, median_msg
    int 21h
    
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
    
    ; Print "Mean: " message
    mov ah, 09h
    lea dx, mean_msg
    int 21h
    
    ; Calculate and print mean
    mov ax, word ptr [sum]
    mov dx, word ptr [sum+2]
    idiv word ptr [count]
    call print_number
    
    ; Print pause message
    mov ah, 09h
    lea dx, pause_msg
    int 21h
    
    ; Wait for key press
    mov ah, 01h
    int 21h

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
    mov ah, 09h
    lea dx, newline
    int 21h
    
    pop dx
    pop cx
    pop bx
    ret
print_number endp

end main