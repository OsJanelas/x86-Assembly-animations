; ORIGINAL CODE BY: ArTicZera
; OPTIMIZED BY: OsJanelas

[bits 16]
[ORG 0x7C00]

%define WSCREEN 320
%define HSCREEN 200

main:
        push    0xA000
        pop     es

        mov     ax, 0x13
        int     0x10

        xor     bp, bp ;X POS
        xor     dx, dx ;Y POS
        xor     di, di ;INDEX

        fninit

        call    setcolors

        jmp     nullroto

;----------------------------------------------

draw:
        cmp     bp, WSCREEN
        jae     nextline

        cmp     dx, HSCREEN
        jae     resetdraw

        stosb

        inc     bp

        jmp     nullroto

nextline:
        xor     bp, bp
        inc     dx

        jmp     nullroto

resetdraw:
        xor     bp, bp
        xor     dx, dx
        xor     di, di

        fld     dword [alpha]
        fadd    dword [angle]
        fstp    dword [angle]

        jmp     nullroto

;----------------------------------------------

setcolors:
        pusha

        xor     bx, bx

        palette.loop:
                mov     dx, 0x3C8
                mov     al, bl
                out     dx, al

                mov     dx, 0x3C9

                ;R = 1
                mov     al, bl
                out     dx, al

                ;G = 1
                mov     al, bl
                out     dx, al

                ;B = 1
                mov     al, bl
                out     dx, al

                inc     bx

                cmp     bx, 0x0F
                jb      palette.loop

        popa

        ret

;----------------------------------------------

nullroto:
        mov     word [x], bp
        mov     word [y], dx

        fild    qword [angle]
        fsin
        fmul    dword [y]
        fstp    dword [r1]

        fild    qword [angle]
        fcos
        fmul    dword [x]
        fsub    dword [r1]
        fstp    dword [gx]

        fild    qword [angle]
        fcos
        fmul    dword [y]
        fstp    dword [r2]

        fild    qword [angle]
        fsin
        fmul    dword [x]
        fadd    dword [r2]
        fstp    dword [gy]

        ;x ^ y
        mov     bx, [gx]
        xor     bx, [gy]

        ;(x ^ y) & 10000
        and     bx, 10000

        mov     al, bl
        add     al, 20

        jmp     draw


x: dd 0.0
y: dd 0.0

gx: dw 0.0
gy: dw 0.0

r1: dd 0.0
r2: dd 0.0

angle: dq 100.00
alpha: dq 0.01

;----------------------------------------------

times 510 - ($ - $$) db 0x00
dw 0xAA55