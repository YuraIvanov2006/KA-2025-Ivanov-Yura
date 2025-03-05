.model small
.stack 100h

.code
main PROC
    xor ax, ax    ; Clear AX register (AX = 0)

    mov ah, 4Ch   ; DOS terminate function
    int 21h       ; Call DOS interrupt to exit

main ENDP
end main
