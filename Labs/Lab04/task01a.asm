.model small
.stack 100h
.data 
msg db 14 dup(0AAh) 

.code
main PROC
    mov ax, SEG @data       
    mov ds, ax

    mov dx, offset msg
 
    mov al, 0; counter 
    mov bh, 3   
    cmp al, 14
    jl array_set
    

    array_set:
    add bh, 3
    mov [msg + al], bh
    inc al
    cmp al, 14
    jl array_set

    
    mov ah, 4Ch       
    int 21h

main ENDP
end main
