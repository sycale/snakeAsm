Randomize macro operand, min, max
    pusha
    
    mov  ah, 2Ch
    int  21h
    mov  ax, dx
    mov  bx, max
    sub  bx, min
    inc  bx 
    mov  dx, 00
    div  bx
    add  dx, min
    mov  operand, dx
    
    popa
endm

Sleep macro _time
    local @skip, @timer, time
    pusha

    jmp  @skip
        time dw _time
    @skip:
    
    @timer:
        mov  ah, 00h
        int  1Ah
        cmp  dx, time
    jb   @timer
    add  dx, 03
    
    mov  time, dx
    popa 
endm