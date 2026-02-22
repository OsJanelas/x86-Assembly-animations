[BITS 16]
[ORG 0x7c00]

setup:
    mov ax, 0x13
    int 10h

    mov ax, 0xA000
    mov es, ax

main_render:
    xor di, di
    mov bx, [t]
    mov cx, 0

loop_y:
    mov dx, 0
loop_x:
    mov ax, dx
    add ax, bx
    and ax, cx

    and al, 0x1F        
    
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
    mov bl, [color_ptr]

print_loop:
    mov al, [si]
    cmp al, 0
    je end_print

    mov ah, 0x0E
    int 10h
    
    inc si
    inc bl
    jmp print_loop

end_print:
    inc word [t]
    inc byte [color_ptr]

    mov cx, 0x0FFF
delay:
    loop delay

    mov ah, 01h
    int 16h
    jz main_render

    ret

t dw 0
color_ptr db 32
string db "God punished you", 0

times 510 - ($ - $$) db 0
dw 0xAA55