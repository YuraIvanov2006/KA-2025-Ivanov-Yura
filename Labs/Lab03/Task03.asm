.model small
.stack 100h
.data
NumA = 0FFFFh
NumB = 8000h

.code
main:

mov ax, NumA
mov dx, NumB

and ax, bx
cmp ax, bx
jnz caseWhenNotEquals
mov ax, 1
jmp finish

caseWhenNotEquals:
xor ax,ax 

finish:
mov ah,4Ch
int 21h


end main
