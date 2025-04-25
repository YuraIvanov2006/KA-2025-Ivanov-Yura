.model small
.stack 100h

.data
    filename    db 'custom.in', 0     ; оголошую всі зміні проекту
    buffer      db 256 dup(0)       
    array       dw 10000 dup(0)       
    count       dw 0                
    sum         dw 0                
    ten         dw 10               
    temp        dw 0                
    is_negative db 0                
    
    
    start_msg   db 'Program started', 13, 10, '$'       ; огголошую всі текстові меседжі    
    median_msg  db 'Median: $'
    mean_msg    db 13, 10, 'Average: $'
    error_file  db 'Error opening file!', 13, 10, '$'   ; ерор кетчер 
    count_msg   db 'Numbers found: $'
    newline     db 13, 10, '$'
    file_handle dw 0

.code
main PROC
    
    mov ax, @data ; просто оголошую дата сегмент 
    mov ds, ax

    
    mov ah, 09h             ;вивожу меседж про початок програми 
    lea dx, start_msg          
    int 21h                 ;екзекьютор програми

    
    mov ah, 3Dh                 ; відкриваю файл із значеннями 
    mov al, 0                    ; рід онлін 
    lea dx, filename             ; вказую назву
    int 21h                      
    jnc file_opened               ; перехід до відкривання файлу 
    
    
    mov ah, 09h                 ; виводимо помилку і екзіт 
    lea dx, error_file
    int 21h
    jmp exit_program
    
file_opened:
    mov [file_handle], ax
    
    
    xor di, di                  ; очищую 
    mov word ptr [count], 0     
    mov word ptr [sum], 0       
    mov word ptr [temp], 0      
    mov byte ptr [is_negative], 0 

read_loop:
    
    mov ah, 3Fh
    mov bx, [file_handle]
    mov cx, 1                   
    lea dx, buffer
    int 21h
    
    
    cmp ax, 0               ;кінець файлу чи нє
    je process_number
    
    mov al, [buffer]           
    
    
    cmp al, ' '                 ; якщо пробіл tab or CR LF, то зберігаю і очищую
    je save_and_reset
    cmp al, 13                 
    je save_and_reset
    cmp al, 10                 
    je save_and_reset
    cmp al, 9                  
    je save_and_reset
    
    
    cmp al, '-'                 ; чек чи відємне 
    jne not_negative            ; якщо не відємне, то перехід до not_negative           
    mov byte ptr [is_negative], ;       [] - звертаємось не до щзмінної я до її значення 
    jmp read_loop               
    
not_negative:
    
    sub al, '0'     ; віднімаємо 0(48) шоб вийшло число 
    cmp al, 9
    ja read_loop               ; чи цифра чи не 
    
    
    mov bx, [temp]
    mov dx, 10
    mov cx, ax                 
    mov ax, bx
    mul dx                     
    add ax, cx                 
    mov [temp], ax
    jmp read_loop

save_and_reset:
    
    cmp word ptr [temp], 0     
    jne process_number         
    jmp read_loop              

process_number:
    
    mov ax, [temp]
    
    
    cmp byte ptr [is_negative], 0
    je store_positive
    neg ax                     
    
store_positive:
    mov [array + di], ax       
    add di, 2                  
    inc word ptr [count]       
    add word ptr [sum], ax     
    
    
    mov word ptr [temp], 0
    mov byte ptr [is_negative], 0
    
    
    cmp word ptr [count], 100  
    je sort_array              
    
    
    cmp ax, 0
    je sort_array              
    jmp read_loop              
    
sort_array:
    
    mov cx, [count]
    cmp cx, 1                  
    jle print_results
    
    dec cx                     
    
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
    
    mov ah, 09h
    lea dx, count_msg
    int 21h
    
    mov ax, [count]
    call print_number
    
    mov ah, 09h
    lea dx, newline
    int 21h
    
    
    cmp word ptr [count], 0
    je close_file
    
    
    mov ah, 09h
    lea dx, median_msg
    int 21h
    
    mov cx, [count]
    test cx, 1                 
    jnz odd_count

    
    mov ax, cx
    shr ax, 1                  
    mov bx, ax
    dec bx                     
    
    shl bx, 1                  
    shl ax, 1
    
    lea si, array
    add si, bx                 
    mov dx, [si]               
    add si, 2                  
    add dx, [si]               
    
    mov ax, dx
    sar ax, 1                  ;зсув всі біти вправо на 1
    jmp print_median
    
odd_count:
    
    mov ax, cx
    shr ax, 1                  
    shl ax, 1                  
    
    lea si, array
    add si, ax                 
    mov ax, [si]               
    
print_median:
    call print_number
    
    
    mov ah, 09h
    lea dx, mean_msg
    int 21h
    
    mov ax, [sum]
    cwd                         ; розширення значення з 16 дор 32
    idiv word ptr [count]       ; ділення 
    call print_number
    
    mov ah, 09h
    lea dx, newline
    int 21h
    
close_file:
    
    mov ah, 3Eh
    mov bx, [file_handle]
    int 21h
    
exit_program:
    mov ah, 4Ch
    int 21h
main ENDP


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
