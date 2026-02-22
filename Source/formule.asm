[BITS 16]
[ORG 0x7c00]

setup:
    mov ax, 0x13
    int 10h
    
    mov ax, 0xA000
    mov es, ax

    xor ax, ax
    mov ds, ax

main_loop:
    xor di, di
    mov bx, [t]

    mov cx, 0         ; Y = 0
loop_y:
    mov dx, 0         ; X = 0
loop_x:
    mov ax, dx        ; ax = x
    add ax, bx        ; ax = x + t
    mov si, cx        ; si = y
    add si, bx        ; si = y + t
    
    imul ax, si       ; AX = (x+t) * (y+t)

    and al, 0x3F      
    
    mov [es:di], al
    inc di
    inc dx
    cmp dx, 320
    jne loop_x
    inc cx
    cmp cx, 200
    jne loop_y

    mov ah, 0x02
    xor bh, bh
    xor dx, dx
    int 10h

    mov si, string
    mov bl, [text_color]

print_loop:
    mov al, [si]
    cmp al, 0
    je end_print

    mov ah, 0x0E
    int 10h
    
    inc si
    inc bl

    cmp bl, 55
    jne skip_reset
    mov bl, 32
skip_reset:
    jmp print_loop

end_print:
    inc word [t]
    inc byte [text_color]

    cmp byte [text_color], 55
    jne keep_color
    mov byte [text_color], 32
keep_color:

    mov cx, 0x0FFF
delay:
    loop delay

    mov ah, 01h
    int 16h
    jz main_loop

    ret

t dw 0
text_color db 32
string db "And we purified you", 0

times 510 - ($ - $$) db 0
dw 0xAA55