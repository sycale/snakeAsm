printStr macro _text, format
    local text, @skip, @notSpec, @notN, @notT, @notB, @notR, @putsym, @exit 
    local @pushsym, @printsym
    pusha
      
    ifndef _text
        jmp  @skip
            text db _text, 00h
        @skip:
        
        mov  ah, 02h
        xor  si, si
        @putsym:
            mov  dl, text[si]
            cmp  dl, 00h
            je   @exit
            
            cmp  dl, '\'
            jne  @notSpec
                mov  dl, text[si+1]
                cmp  dl, 'n'
                jne  @notN
                    mov  dl, 0Ah
                    int  21h
                    mov  dl, 0Dh
                    int  21h
                @notN:
                
                cmp  dl, 't'
                jne  @notT
                    mov  dl, 09h
                    int  21h
                @notT:
                
                cmp  dl, 'b'
                jne  @notB
                    mov  dl, 08h
                    int  21h
                @notB:
                
                cmp  dl, 'r'
                jne  @notR
                    mov  dl, 0Dh
                    int  21h
                @notR:
                
                add  si, 02h
                jmp  @putsym
            @notSpec:
            
            int  21h
            inc  si
            cmp  text[si], 00h   
        jne  @putsym
        
        @exit:
    else
        mov  ah, 02h
        xor  si, si
        @putsym:
            mov  dl, _text[si]
            cmp  dl, 00h
            je   @exit
            
            int  21h
            inc  si
            cmp  _text[si], 00h   
        jne  @putsym
    
        @exit:
    endif
            
    popa
endm

printNum macro rr
    local @pushsym, @printsym
    pusha
    
    mov  ax, rr
    mov  bx, 0Ah
    xor  cx, cx
    xor  dx, dx
    @pushsym:
        div  bx
        push dx
        xor  dx, dx
        inc  cx
        cmp  ax, 00h
    jne  @pushsym
        
    mov  ah, 02h
    @printsym:
        pop  dx
        add  dl, 30h
        int  21h
    loop @printsym  
      
    popa
endm

print macro operand, format:=<'s'>
    if format eq 'n'
        printNum operand
    else
        printStr operand
    endif
endm