[BITS 16]
[ORG 0x7c00]

jmp setup

setup:
    mov ax, 0x13
    int 10h
    mov ax, 0xA000
    mov es, ax
    xor ax, ax
    mov ds, ax

main_loop:
    xor di, di
    mov bp, [frame]

    mov cx, 0           ; Y
loop_y:
    mov dx, 0           ; X
loop_x:
    mov ax, dx
    sub ax, 160         ; Centralize X
    mov si, cx
    sub si, 100         ; Centralize Y

    add ax, bp
    xor ax, si
    and al, 0x1F

    mov bx, ax
    
    mov ax, si
    add ax, bp
    sar ax, 2
    and ax, 0x1F
    
    add ax, 160
    sub ax, dx

    cmp ax, 4
    jg draw_bg
    cmp ax, -4
    jl draw_bg
    mov bl, 15

draw_bg:
    mov al, bl
    stosb

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
    mov bl, [text_col]
print_loop:
    mov al, [si]
    test al, al
    jz end_frame
    mov ah, 0x0E
    int 10h
    inc si
    inc bl
    cmp bl, 56
    jne skip_r
    mov bl, 32
skip_r:
    jmp print_loop

end_frame:
    add word [frame], 2
    inc byte [text_col]
    cmp byte [text_col], 56
    jne no_reset
    mov byte [text_col], 32
no_reset:
    jmp main_loop

frame dw 0
text_col db 32
string db "Now, you going to be teleported to heaven", 0

times 510-($-$$) db 0
dw 0xAA55