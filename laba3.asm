data segment
    buffer db 30, 0, 30 dup(0)
    array dw 30 dup(0) 
    array_len   dw ?
    start_msg   db "Enter length of array : ", 0Dh, 0Ah, '$'  
    CrLf        db 0Dh, 0Ah, '$'
    input_msg   db "Enter array :", 0Dh, 0Ah, '$'     
    error       db "Input error", 0Dh, 0Ah, '$'
    pkey db "press any key...$"           
    message1    db "Assending order", 0Dh, 0Ah, '$'
    message2    db "Descending order", 0Dh, 0Ah, '$'
    message3    db "Random order", 0Dh, 0Ah, '$'  
    
ends

stack segment
    dw   128  dup(0)
ends

code segment
start:

    mov     ax, data
    mov     ds, ax
    mov     es, ax    
    
    lea     dx, start_msg
    call    print  
    
    mov     ah, 0Ah
    lea     dx, buffer
    int     21h  
    
    lea     dx, CrLf
    call    print

    push    array_len  
    call    parse
    pop     array_len
    
    mov     cx, array_len
    lea     si, array
    
    lea     dx, input_msg
    call    print   
    
input_of_array:
        
    mov     ah, 0Ah
    lea     dx, buffer
    int     21h   
    
    lea     dx, CrLf
    call    print 
    
    push    word ptr[si]
    call    parse
    pop     word ptr[si]
    add     si, 2
    
    loop    input_of_array  
    
    lea     si, array
    push    si
    push    array_len
    call    order 
    call    print  
    
    lea     dx, CrLf
    call    print 
            
exit:
    lea     dx, pkey
    mov     ah, 9
    int     21h        
    
        
    mov     ah, 1
    int     21h
    
    mov     ax, 4c00h 
    int     21h    
    
    
    order proc 
        push    bp
        mov     bp, sp
        push    si
        push    ax
        push    cx
        xor     dx, dx
        
        mov     cx, [bp+4]
        mov     si, [bp+6]
        dec     cx
        
    loop_order:
        mov     ax, word ptr[si]
        cmp     ax, word ptr[si+2] 
        jl      low
        jg      great 
        
    next:
        add     si, 2
        loop    loop_order 
        jmp     find_order
        
    low:
        or      dl, 1
        jmp     next
    great:
        or      dl, 2
        jmp     next
        
    find_order:
        cmp     dl, 2
        lea     dx, message1
        jl      return_order
        lea     dx, message2
        je      return_order
        lea     dx, message3
        jg      return_order
        
    return_order:
    
        pop     cx
        pop     ax
        pop     si
        pop     bp
        
        ret     4
        endp    order
    

    parse proc
        push    bp
        mov     bp, sp
        push    ax
        push    bx
        push    cx
        push    si 
        
        mov     dx, 0    
        push    dx

        xor     ax, ax
        mov     bx, 0
        
        mov     cx, 0
        mov     cl, [buffer+1]
        
        lea     si, buffer+2  
        
        cld 
               
        lodsb           ;proverka na vvod minusa pri vvode razmera mssiva
        dec     si 
        cmp     al, 2Dh         
        jne     For     
        inc     si
        dec     cl  
        pop     dx
        mov     dl, 1
        push    dx
        
    
    For:
        lodsb   
        sub     al, '0'  
        cmp     al, 10
        jge     exception  
        
        push    ax
        mov     ax, bx
        mov     bx, 10
        mul     bx 
        
        cmp     dx, 0
        jne     exception
        
        mov     bx, ax
        pop     ax
        add     bx, ax
        
        push    bx 
        and     bh, 80h
        cmp     bh, 0
        jne     exception  
        pop     bx
        
        loop    For
                     
        pop     dx
        cmp     dl, 0
        jnz     negative
        
        mov     [bp+4], bx 
        jmp     end_function
        
    negative:     
        sub     bx, 1
        not     bx
        mov     [bp+4], bx 
        jmp     end_function
        
    exception:
        lea     dx, error
        call    print    
        jmp     exit
    end_function:       
        pop     si
        pop     cx
        pop     bx
        pop     ax
        pop     bp
        
        ret
    parse endp
        
             
    
    print       proc 
        
        push    ax
        mov     ah, 09h
        int     21h
        pop     ax
        ret
    print endp
ends

end start 
