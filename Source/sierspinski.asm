[BITS 16]
[ORG 0x7C00]

start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00

    mov ax, 0x0013
    int 0x10

    call print_msg

    mov ax, 0xA000
    mov es, ax

render_fractal:
    xor di, di

.loop_y:
    mov ax, di
    xor dx, dx
    mov bx, 320
    div bx

    cmp ax, 16
    jl .next_pixel

    mov bx, ax
    and bx, dx
    
    jnz .draw_black

    mov al, dl
    add al, byte [color_offset]
    mov [es:di], al
    jmp .next_pixel

.draw_black:
    mov byte [es:di], 0

.next_pixel:
    inc di
    cmp di, 64000
    jne .loop_y

    inc byte [color_offset]

    jmp render_fractal

print_msg:
    mov si, msg
    mov bl, 32
.loop:
    lodsb
    test al, al
    jz .done
    
    mov ah, 0x0E
    int 0x10
    
    inc bl
    cmp bl, 50
    jne .loop
    mov bl, 32
    jmp .loop
.done:
    ret

msg: db "Hello user, welcome to paradise", 0
color_offset: db 0

times 510-($-$$) db 0
dw 0xAA55