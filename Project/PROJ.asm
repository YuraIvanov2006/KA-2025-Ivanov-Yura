.model small
.stack 100h

.data
    buffer      db 256 dup(0)      ; Input buffer
    array       dw 10000 dup(0)    ; Array for numbers (16-bit words)
    temp_str    db 16 dup(0)       ; Temporary string for output
    count       dw 0               ; Count of numbers
    sum         dd 0               ; Sum for mean calculation
    newline     db 13, 10, '$'

.code
    ASSUME CS:CODE, DS:DATA
START:
    MOV AX, @data
    MOV DS, AX              ; Initialize data segment
    MOV ES, AX              ; Initialize extra segment

    ; Read and parse input
    MOV word ptr [count], 0
    MOV dword ptr [sum], 0

read_loop:
    ; Read line from stdin
    MOV AH, 3Fh         ; DOS read function
    MOV BX, 0           ; stdin handle
    MOV CX, 255         ; max bytes to read
    LEA DX, buffer
    INT 21h
    
    CMP AX, 0           ; Check EOF
    JLE sort_numbers
    
    ; Parse numbers from buffer
    LEA SI, buffer
    MOV CX, [count]
    LEA DI, array
    
parse_loop:
    CALL atoi           ; Convert string to integer
    CMP AX, 32767       ; Check upper bound
    JG set_max
    CMP AX, -32768      ; Check lower bound
    JL set_min
    JMP store_num
    
set_max:
    MOV AX, 32767
    JMP store_num
    
set_min:
    MOV AX, -32768
    
store_num:
    MOV [DI + CX*2], AX
    ADD word ptr [sum], AX
    ADC word ptr [sum+2], 0
    INC CX
    
    CALL skip_delimiter
    CMP byte ptr [SI], 0
    JNE parse_loop
    
    MOV [count], CX
    JMP read_loop

sort_numbers:
    MOV CX, [count]
    DEC CX              ; CX = count - 1 (outer loop runs count-1 times)

outerLoop:
    PUSH CX            ; Save outer loop counter
    MOV DX, CX         ; DX keeps track of the number of comparisons
    LEA SI, array

innerLoop:
    MOV AX, [SI]       ; Load current element
    CMP AX, [SI+2]     ; Compare with next element
    JLE nextStep       ; If already in order, skip swapping

    XCHG AX, [SI+2]    ; Swap elements
    MOV [SI], AX

nextStep:
    ADD SI, 2          ; Move to next element in array
    DEC DX             ; Reduce number of comparisons
    JNZ innerLoop      ; Repeat until DX reaches zero

    POP CX             ; Restore outer loop counter
    LOOP outerLoop     ; Repeat outer loop

    ; Calculate and print median
    MOV AX, [count]
    SHR AX, 1          ; Divide by 2
    MOV BX, AX         ; Middle index
    MOV AX, [array + BX*2]
    CALL print_number

    ; Calculate and print mean
    MOV AX, word ptr [sum]
    MOV DX, word ptr [sum+2]
    IDIV word ptr [count]
    CALL print_number

    ; Exit program
    MOV AH, 4Ch        ; DOS exit function
    INT 21h            ; Call DOS interrupt

; Convert string to integer
atoi proc
    PUSH BX
    PUSH CX
    XOR AX, AX          ; Result
    XOR BX, BX          ; Sign flag
    XOR CX, CX          ; Digit
    
    CMP byte ptr [SI], '-'
    JNE atoi_loop
    INC SI
    MOV BX, 1           ; Negative number
    
atoi_loop:
    MOV CL, [SI]
    CMP CL, 0
    JE atoi_done
    CMP CL, ' '
    JE atoi_done
    CMP CL, 13
    JE atoi_done
    CMP CL, 10
    JE atoi_done
    
    SUB CL, '0'
    IMUL AX, 10
    ADD AX, CX
    INC SI
    JMP atoi_loop
    
atoi_done:
    CMP BX, 1
    JNE atoi_exit
    NEG AX
    
atoi_exit:
    POP CX
    POP BX
    RET
atoi endp

; Skip to next number
skip_delimiter proc
    MOV AL, [SI]
    CMP AL, 0
    JE skip_exit
    CMP AL, ' '
    JE skip_next
    CMP AL, 13
    JE skip_next
    CMP AL, 10
    JE skip_next
    RET
    
skip_next:
    INC SI
    JMP skip_delimiter
    
skip_exit:
    RET
skip_delimiter endp

; Print number
print_number proc
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    LEA DI, temp_str + 15
    MOV byte ptr [DI], '$'
    MOV BX, 10
    MOV CX, 0
    
    CMP AX, 0
    JGE convert_loop
    NEG AX
    PUSH AX
    MOV AH, 02h
    MOV DL, '-'
    INT 21h
    POP AX
    
convert_loop:
    XOR DX, DX
    DIV BX
    ADD DL, '0'
    DEC DI
    MOV [DI], DL
    INC CX
    CMP AX, 0
    JNZ convert_loop
    
    MOV AH, 09h
    MOV DX, DI
    INT 21h
    
    MOV AH, 09h
    LEA DX, newline
    INT 21h
    
    POP DX
    POP CX
    POP BX
    POP AX
    RET
print_number endp

END START