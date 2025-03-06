.model small
.stack 100h 
.data 
a dw 30 
b dw 50
c dw 120 

.code 
main proc
    mov ax, @data    ; set data segment 
    mov ds, ax 
    
    ; if ((a >= 10 && a <= 40) || (a >= 14 && b <= 58 && c > 100))
    ; {
    ;     a = b + 10
    ;     b = c + 10
    ;     c = a + 10
    ; }
    ; else
    ; {
    ;     a = 123
    ; }
    
    ; Load variables into registers
    mov ax, a        ; ax = a
    mov bx, b        ; bx = b
    mov cx, c        ; cx = c
    
    ; First condition: (a >= 10 && a <= 40)
    cmp ax, 10
    jl check_second  ; If a < 10, first condition fails, check second condition
    
    cmp ax, 40
    jg check_second  ; If a > 40, first condition fails, check second condition
    
    ; First condition is true, jump to THEN block
    jmp then_block
    
check_second:
    ; Second condition: (a >= 14 && b <= 58 && c > 100)
    cmp ax, 14
    jl else_block    ; If a < 14, second condition fails (lazy evaluation)
    
    cmp bx, 58
    jg else_block    ; If b > 58, second condition fails (lazy evaluation)
    
    cmp cx, 100
    jle else_block   ; If c <= 100, second condition fails
    
    ; Second condition is true, continue to THEN block
    
then_block:
    ; THEN block: a = b + 10, b = c + 10, c = a + 10
    ; Note: need to be careful with order of operations since a changes
    mov ax, b
    add ax, 10       ; ax = b + 10
    mov dx, ax       ; Store new value of a temporarily in dx
    
    mov ax, c
    add ax, 10       ; ax = c + 10
    mov b, ax        ; b = c + 10
    
    mov ax, dx       ; ax = new value of a (b + 10)
    add ax, 10       ; ax = (b + 10) + 10
    mov c, ax        ; c = a + 10
    
    mov a, dx        ; a = b + 10 (from temporary storage)
    jmp end_if
    
else_block:
    ; ELSE block: a = 123
    mov a, 123
    
end_if:
    mov ax, 4c00h    ; exit program 
    int 21h 
main endp
end main