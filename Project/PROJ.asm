. model small
.stack 100h
.data
   array DW 3, 2, 6, 4, 1
   count DW 5

CODE SEGMENT
    ASSUME CS:CODE, DS:DATA
START:
    MOV AX, DATA
    MOV DS, AX   ; Initialize data segment

    MOV CX, count
    DEC CX  ; CX = count - 1 (outer loop runs count-1 times)

outerLoop:
    PUSH CX       ; Save outer loop counter
    MOV DX, CX    ; DX keeps track of the number of comparisons in this pass
    LEA SI, array

innerLoop:
    MOV AX, [SI]        ; Load current element
    CMP AX, [SI+2]      ; Compare with next element
    JLE nextStep        ; If already in order, skip swapping

    XCHG AX, [SI+2]     ; Swap elements
    MOV [SI], AX

nextStep:
    ADD SI, 2           ; Move to next element in array
    DEC DX              ; Reduce number of comparisons
    JNZ innerLoop       ; Repeat until DX reaches zero

    POP CX              ; Restore outer loop counter
    LOOP outerLoop      ; Repeat outer loop

    MOV AH, 4Ch         ; DOS exit function
    INT 21h             ; Call DOS interrupt

CODE ENDS
END START
