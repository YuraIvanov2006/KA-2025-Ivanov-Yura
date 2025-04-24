.model small
.stack 100h
.data 
msg dw 14 dup(0) 

.code
main PROC
    mov ax, SEG @data       
    mov ds, ax

    mov dx, offset msg
 
    mov si, 0    ; counter 
    mov bx, 3   
    
array_set:
    add bx, 3
    mov di, si
    add di, di    ; multiply by 2 for word access
    mov [msg + di], bx
    inc si
    cmp si, 14
    jl array_set

    mov ah, 4Ch       
    int 21h

main ENDP
end main
