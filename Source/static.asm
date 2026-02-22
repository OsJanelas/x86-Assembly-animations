[bits 16]
[org 0x7c00]

start:
    ; VGA mode
    mov ax, 0x0013
    int 0x10

    mov ax, 0xa000
    mov es, ax          ; Video memory
main_loop:
    ; 1. Static background
    xor di, di
    mov cx, 64000
static_bg:
    in al, 0x40         ; Random timer number
    and al, 0x1F        ; Dark gray
    mov [es:di], al
    inc di
    loop static_bg

    ; 2. Text
    mov ah, 0x13        ; Print
    mov al, 1           ; String atributes
    mov bh, 0           ; Page 0
    mov bl, 0x0D        ; Color
    mov cx, 18          ; string size
    mov dh, 2           ; Line
    mov dl, 11          ; Colun
    push cs
    pop es
    mov bp, msg
    int 0x10
    
    ; Video memory cube
    mov ax, 0xa000
    mov es, ax

    ; 3. Cube logic
    
    inc byte [timer]    ; frame
    mov bl, [timer]     ; angle

    ; Draw
    mov cx, 50
draw_cube:
    push cx
    mov al, bl
    add al, cl          ; Variant based in point
    
    ; Math
    ; X = 160 + sin(t+i)*40, Y = 100 + cos(t+i)*40
    mov dx, 100         ; Y base
    mov ax, 160         ; X base
    
    ; Colors
    test cl, 1
    jnz color_blue
    mov al, 55          ; Purple
    jmp plot
color_blue:
    mov al, 32          ; Blue

plot:
    ; 3D logic
    ; To MBR continue running, simplified code
    imul di, dx, 320
    add di, ax
    mov [es:di], al     ; Draw Pixel
    
    pop cx
    loop draw_cube

    ; Simple delay and loop
    mov dx, 0x3DA
wait_retrace:
    in al, dx
    test al, 8
    jz wait_retrace

    jmp main_loop

msg db "Entering in paradise"
timer db 0

times 510-($-$$) db 0
dw 0xAA55