; color constants
CL_BLACK     equ 00h
CL_DARKBLUE  equ 01h
CL_DARKGREEN equ 02h
CL_CYAN      equ 03h
CL_CRIMSON   equ 04h
CL_PURPLE    equ 05h
CL_OLIVE     equ 06h
CL_GRAY      equ 07h

CL_DARKGRAY  equ 08h
CL_BLUE      equ 09h
CL_GREEN     equ 0Ah
CL_SKYBLUE   equ 0Bh
CL_RED       equ 0Ch
CL_MAGENTA   equ 0Dh
CL_YELLOW    equ 0Eh
CL_WHITE     equ 0Fh

SetConsoleColor macro foreground, background
    pusha
       
    mov  bh, foreground ;14
	mov  al, background ;15
	mov  bl, 10h        ;16  
	mul  bl             ; 15 * 16 = 240
    add  bh, al
    
    mov  ax, 600h
    mov  cx, 00h
    mov  dx, 184Fh  
    int  10h
    
    popa
endm

CursorVisibLe macro status:=<true>
    local @notTrue, @next
    pusha
    
    mov  ah, 01
    mov  bx, status
    cmp  bx, true
    jne  @notTrue
        mov  cx, 0607h
        jmp  @next
    @notTrue:
    
    mov  cx, 2607h
    int  10h 
    @next: 
    
    popa
endm

SetCursorPosition macro X, Y
    pusha

    mov  ax, X
    mov  cx, Y
    mov  dl, al
    mov  dh, cl

    mov  ah, 02h
    int  10h
    popa
endm