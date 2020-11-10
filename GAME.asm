include io.asm
include console.asm
include time.asm

.model small
.stack 100h
.386p

; CONSTANTS
    ; logical
    TRUE  equ 1
    FALSE equ 0

    ; directions
    NONE  equ 0
    UP    equ 1
    DOWN  equ 2
    LEFT  equ 3
    RIGHT equ 4

    ; sizes of the game field
    MAP_HEIGHT equ 20
    MAP_WIDTH  equ 30
    
    ; max size of snake
    MAX_SNAKE_LENGTH equ 40

; VARIABLES
.data
    ; elements of game
    fruit       db '*', 0
    snake_head  db '^', 0
    snake_body  db 'o', 0
    border      db '#', 0
    
    ;colors
    forecolor   db CL_YELLOW
    backcolor   db CL_GRAY
   
    ; coordinates of elements   
    head_X      dw MAP_WIDTH / 2
    head_Y      dw MAP_HEIGHT / 2
    body_X      dw MAX_SNAKE_LENGTH dup(0)
    body_Y      dw MAX_SNAKE_LENGTH dup(0)
    fruit_X     dw ?
    fruit_Y     dw ?
     
    ; current direction
    direction   dw NONE
    
    ; score, game status
    score       dw ?
    game_over   dw false
    
.code

load macro
    mov  ax, @data
    mov  ds, ax
    mov  di, 00h  ; di = body length and last body part
endm

exit macro
    mov  ah, 4Ch
    int  21h
endm

CheckCollisions macro
    push ax
    push bx
    push cx
    push dx

    cmp  head_X, map_width - 1
    jle  @notCollideLeft
        mov  head_X, 2
    @notCollideLeft:
    
    cmp  head_X, 2
    jge  @notCollideRight
        mov  head_X, map_width - 1
    @notCollideRight:
    
    cmp  head_Y, map_height - 2
    jle  @notCollideTop
        mov  head_Y, 1
    @notCollideTop:
    
    cmp  head_Y, 1
    jge   @notCollideBottom
        mov  head_Y, map_height - 2
    @notCollideBottom:

    mov  ax, fruit_X
    mov  bx, fruit_Y
    cmp  head_X, ax
    jne  @notCollideFruit
        cmp  head_Y, bx
        jne   @notCollideFruit            
            cmp  body_X[0], 0
            jne  @firstBodyPartExists
                mov  bx, head_X
                mov  body_X[0], bx
                mov  bx, head_Y
                mov  body_Y[0], bx
                jmp  @noBody
            @firstBodyPartExists:
                
            cmp  body_X[di], 0
            jne   @currentBodyPartExists
                mov  bx, body_X[di - type body_X]
                mov  body_X[di], bx
                mov  bx, body_Y[di - type body_X]
                mov  body_Y[di], bx
            @currentBodyPartExists:
             
            @noBody:
            Randomize fruit_X, 2, map_width-1
            Randomize fruit_Y, 1, map_height-2
            
            cmp  di, size body_X-type body_X
            jge   @stop     
                add  di, type body_X
            @stop:
            inc  score
    @notCollideFruit:
    
    mov  ax, head_X
    mov  bx, head_Y
    
    mov  si, type body_X
    @checkCollisionBody:
        cmp  ax, body_X[si]
        jne  @notCollideBody
        cmp  bx, body_Y[si]
        jne  @notCollideBody
            mov  game_over, true
        @notCollideBody:
        
        add  si, type body_X
        cmp  si, size body_X
    jne  @checkCollisionBody
        
    pop  dx
    pop  cx
    pop  bx
    pop  ax
endm

DrawAll macro
    CursorVisible false
    SetCursorPosition 0, 0
    Sleep 3

    mov  cx, map_width
    @drawTopBorder:
        print '#'
    loop @drawTopBorder
        
    print '\n'
    
    mov  dx, map_height - 2
    @drawSideBorders: 
    mov  cx, map_width
        @drawLine:

            cmp  cx, 1
            jne  @notBorder1
                print border
                jmp  @next            
            @notBorder1:
            
            cmp  cx, map_width
            jne  @notBorder2
                print border
                jmp  @next        
            @notBorder2:
            
            cmp  cx, head_X
            jne  @notHead
                cmp  dx, head_Y
                jne  @notHead
                    print snake_head
                    jmp  @next             
            @notHead:
                        
            cmp  cx, fruit_X
            jne  @notFruit
                cmp  dx, fruit_Y
                jne  @notFruit
                    print fruit
                    jmp  @next             
            @notFruit:
                        
            print ' '
            
            @next:
            dec  cx
            cmp  cx, 00h
        jne  @drawLine
        
        print '\n'
        
        dec  dx
        cmp  dx, 00h       
    jne  @drawSideBorders
     
    mov  cx, map_width
    @drawBottomBorder:
        print '#'
    loop @drawBottomBorder
   
    mov  si, 00h
    @drawBody:

        mov  bx, map_width
        sub  bx, body_X[si]
        mov  dx, map_height - 1
        sub  dx, body_Y[si]
       
        cmp  dx, map_height - 1
        jge  @notDrawBody
            SetCursorPosition bx, dx
            print snake_body
        @notDrawBody:
        add  si, type body_X
        cmp  si, size body_X
    jne  @drawBody
  
    SetCursorPosition 0, map_height
    
    print '\n\nScore: '
    print score, 'n'
endm

CheckDirections macro
    mov  si, di
    cmp  si, 00h
    je   @noBody1
    @moveBody:
        cmp  body_X[si], 0
            je   @firstBodyPartNotExist1
            mov  bx, body_X[si - type body_X]
            mov  body_X[si], bx
            mov  bx, body_Y[si - type body_Y]
            mov  body_Y[si], bx
        @firstBodyPartNotExist1:
        sub  si, type body_X
        cmp  si, 00h
    jne  @moveBody
    
    @noBody1:
    cmp  body_X[0], 0
    je   @firstBodyPartNotExist
        mov  bx, head_X
        mov  body_X[0], bx
        mov  bx, head_Y
        mov  body_Y[0], bx
    @firstBodyPartNotExist:
    
    cmp  direction, UP
    jne  @notUP
        mov  snake_head, '^'
        inc  head_Y       
    @notUP:
    
    cmp  direction, DOWN
    jne  @notDOWN
        mov  snake_head, 'v'
        dec  head_Y     
    @notDOWN:

    cmp  direction, LEFT
    jne  @notLEFT
        mov  snake_head, '<'
        inc  head_X       
    @notLEFT:

    cmp  direction, RIGHT
    jne  @notRIGHT
        mov  snake_head, '>'
        dec  head_X        
    @notRIGHT:    
endm

CheckKeyPressed macro
    mov  ah, 0Bh
    int  21h
        
    cmp  al, 00h
    je   @skipPause  
        mov  ah, 08h
        int  21h   
    @skipPause:
    
    cmp  al, 20h
    jne  @notKeySPACE
        inc  forecolor
        cmp  forecolor, CL_WHITE
        jle  @notAboveWhite
            mov  forecolor, 8
        @notAboveWhite:
        
        sub  backcolor, 2
        cmp  backcolor, 1
        jge  @notBelowBlack
            mov  backcolor, 7
        @notBelowBlack:
        
        SetConsoleColor forecolor, backcolor
    @notKeySPACE:
    
    cmp  al, 'w'
    jne  @notKeyW
        mov  direction, UP       
    @notKeyW:
    
    cmp  al, 's'
    jne  @notKeyS
        mov  direction, DOWN
    @notKeyS:
    
    cmp  al, 'a'
    jne  @notKeyA
        mov  direction, LEFT
    @notKeyA:
        
    cmp  al, 'd'
    jne  @notKeyD
        mov  direction, RIGHT
    @notKeyD:    
endm

main:
    load
    
    mov  game_over, false        
    Randomize fruit_X, 2, map_width-1
    Randomize fruit_Y, 1, map_height-2    
    SetConsoleColor forecolor, backcolor
    
    @updateGame:       
        CheckCollisions
        DrawAll
        CheckDirections
        CheckKeyPressed
        
        cmp  game_over, false
    je  @updateGame

    print "\nGAME OVER!"
    
    exit
end  main