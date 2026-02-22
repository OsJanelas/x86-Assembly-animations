[BITS 16]
[ORG 0x7c00]

setup:
    mov ax, 0x13
    int 10h
    mov ax, 0xA000
    mov es, ax
    fninit

main_render:
    xor di, di
    mov word [y_cnt], 0

loop_y:
    mov word [x_cnt], 0
loop_x:
    fld dword [zoom]

    fild word [x_cnt]
    fsub dword [half_w]
    fadd dword [off_x]
    fmul st0, st1       ; zx

    fild word [y_cnt]
    fsub dword [half_h]
    fadd dword [off_y]
    fmul st0, st2       ; zy

    mov cx, 32

julia_iter:
    ; st0 = zy, st1 = zx
    fld st1
    fmul st0, st0       ; zx^2
    fld st1
    fmul st0, st0       ; zy^2
    
    fsubp st1, st0      ; zx^2 - zy^2
    fadd dword [cx_val]
    
    fld st2
    fmul st0, st1
    fadd st0, st0       ; 2 * zx * zy
    fadd dword [cy_val]
    
    fstp st2
    fstp st2

    fld st1
    fmul st0, st0
    fld st1
    fmul st0, st0
    faddp
    fcomp dword [limit]
    fstsw ax
    sahf
    ja escaped

    loop julia_iter

escaped:
    mov al, cl
    add al, [color_j]
    stosb

    ffree st0
    ffree st1
    
    inc word [x_cnt]
    cmp word [x_cnt], 320
    jne loop_x

    inc word [y_cnt]
    cmp word [y_cnt], 200
    jne loop_y

    mov ah, 01h
    int 16h
    jz main_render

    mov ah, 00h
    int 16h

    cmp al, 'w'
    jne .s
    fld dword [off_y]
    fsub dword [step]
    fstp dword [off_y]
.s: cmp al, 's'
    jne .a
    fld dword [off_y]
    fadd dword [step]
    fstp dword [off_y]
.a: cmp al, 'a'
    jne .d
    fld dword [off_x]
    fsub dword [step]
    fstp dword [off_x]
.d: cmp al, 'd'
    jne .z
    fld dword [off_x]
    fadd dword [step]
    fstp dword [off_x]
.z: cmp al, 'z'
    jne .x
    fld dword [zoom]
    fmul dword [z_in]
    fstp dword [zoom]
.x: cmp al, 'x'
    jne .j
    fld dword [zoom]
    fmul dword [z_out]
    fstp dword [zoom]
.j: cmp al, 'j'
    jne .end
    inc byte [color_j]

.end:
    jmp main_render

x_cnt   dw 0
y_cnt   dw 0
half_w  dd 160.0
half_h  dd 100.0
limit   dd 4.0
zoom    dd 0.01
z_in    dd 0.9
z_out   dd 1.1
step    dd 5.0
off_x   dd 0.0
off_y   dd 0.0
cx_val  dd -0.7
cy_val  dd 0.27015
color_j db 0

times 510-($-$$) db 0
dw 0xAA55