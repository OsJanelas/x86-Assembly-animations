[BITS 16]
[ORG 0x7C00]

jmp setup

setup:
    mov ax, 0x0013
    int 0x10

    mov ax, 0xA000
    mov es, ax
    xor ax, ax
    mov ds, ax

main_loop:
    xor di, di
    mov bl, [t]

draw_pixels:
    mov ax, di
    mov cx, 320
    xor dx, dx
    div cx              ; ax = y, dx = x

    xor al, dl          ; al = y ^ x
    add al, bl
    
    mov [es:di], al
    
    inc di
    cmp di, 64000
    jne draw_pixels

    mov ah, 0x02
    xor bh, bh
    xor dx, dx
    int 10h

    mov si, string
    mov bl, [text_col]

print_loop:
    mov al, [si]
    cmp al, 0
    je end_frame

    mov ah, 0x0E
    int 10h
    
    inc si
    inc bl

    cmp bl, 56
    jne skip_reset
    mov bl, 32
skip_reset:
    jmp print_loop

end_frame:
    inc byte [t]
    inc byte [text_col]

    cmp byte [text_col], 56
    jne delay
    mov byte [text_col], 32

delay:
    mov cx, 0x07FF
wait_loop:
    loop wait_loop

    mov ah, 01h
    int 16h
    jz main_loop

    ret

t        db 0
text_col db 32
string   db "Now, you are a good people", 0

times 510-($-$$) db 0
dw 0xAA55