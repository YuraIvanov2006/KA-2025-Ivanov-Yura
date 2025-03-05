.model small
.stack 100h
.data 

.code
main PROC
    ; Initialize registers
    mov ax, 200h  ; AX = 200h
    mov dx, 100h  ; DX = 100h 

    ; Swap values using BX as a temporary register
    mov bx, ax    ; Store AX in BX (temporary register)
    mov ax, dx    ; AX = DX
    mov dx, bx    ; DX = BX (original AX value)

    ; Exit program
     
    int 21h       ; end of prog

main ENDP
end main
