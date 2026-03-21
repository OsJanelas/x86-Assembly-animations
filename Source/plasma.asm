; WE WANT TO GIVE THE CREDITS OF THIS PLASMA EFFECT FOR ARTICZERA
;         ###
;          #
;          #
;          #
;      #   #
;      #   #
;       ###

[bits 16]
[ORG 0x7C00]

%define KERNEL 0x7E00
%define SECTRS 0x0005
%define VIDMOD 0x0013

;---------------------------- BOOT ------------------------------

main:
    xor ax, ax
    mov ds, ax
    mov es, ax

    mov sp, 0x7C00
    mov ss, ax

    call setvidmode
    call kersecs

    jmp 0x0000:KERNEL

kersecs:
    mov ah, 0x02
    mov al, SECTRS
    mov ch, 0x00
    mov cl, 0x02
    mov dh, 0x00

    xor bx, bx
    mov es, bx

    mov bx, KERNEL

    int 0x13

    ret

setvidmode:
    mov ax, VIDMOD
    int 0x10
    
    ret

times 510- ($ - $$) db 0x00
dw 0xAA55

;---------------------------- KERNEL ----------------------------

WSCREEN equ 320
HSCREEN equ 200

kernelmain:
    call setup
    call plasma

    jmp $

setup:
    push 0xA000
    pop es

    mov ah, 0x0C

    xor al, al
    xor bx, bx
    xor cx, cx

    fninit

    mov word [mincolor], 32
    mov word [maxcolor], 55

    mov si, msg
    call printstring

    ret

plasma:
    mov word [x], cx
    mov word [y], dx

    mov word [zx], cx
    mov word [zy], dx

    cmp word [time], 256
    ja crash

    jb plasmaeffect

    jmp setpixel

;--------------------------- GRAPHICS ---------------------------

reset:
    xor cx, cx
    mov dx, 0x08

    inc word [time]

    fld dword [alpha]
    fadd dword [angle2]
    fstp dword [angle2]

    setpixel:
        cmp cx, WSCREEN
        jae nextline

        cmp dx, HSCREEN
        jae reset

        int 0x10

        inc cx
        
        jmp plasma

        ret

nextline:
    xor cx, cx
    inc dx

    jmp plasma

;---------------------------- EFFECT ----------------------------

plasmaeffect:
    push cx
    add cx, [time]

    mov word [zx], cx

    pop cx

    fild dword [zx]
    fdiv dword [pr4]
    fsin
    fdiv dword [pr1]
    fmul dword [pr1]
    fadd dword [pr1]
    fstp dword [pr3]

    fild dword [zy]
    fdiv dword [pr4]
    fsin
    fdiv dword [pr1]
    fmul dword [pr1]
    fadd dword [pr1]
    fadd dword [pr3]
    fstp dword [pr2]

    mov al, [pr2]
    shr al, 1

    sub al, [time]

    call setrainbow
    jmp palette

;---------------------------- COLORS ----------------------------

palette:
    cmp al, [pxmaxcolor]
    ja delcolor

    cmp al, [pxmincolor]
    jb addcolor

    jmp setpixel

addcolor:
    add al, [addcol]
    jmp palette

delcolor:
    sub al, [delcol]
    jmp palette

setvgapalette:
    pusha

        palette.loop:
            mov dx, 0x3C8
            mov al, bl
            out dx, al

            mov dx, 0x3C9

            xor al, al
            out dx, al

            mov al, bl
            out dx, al

            xor al, al
            out dx, al

            inc bx

            cmp bx, 0xFF
            jb palette.loop

    popa

    ret

setrainbow:
    mov byte [pxmaxcolor], 55
    mov byte [pxmincolor], 32

    ret

;--------------------------- THREAD -----------------------------
strthread:
    call resetcursor
    call printstring

    inc byte [printed + di]

    ret

thread:
    cmp byte [printed + 1], 0x00
    jnz plasmaeffect

    mov word [mincolor], 64
    mov word [maxcolor], 79

    mov word [delcol], 31

    mov si, msg
    mov di, 0x01
    call strthread

    jmp plasma

;--------------------------- REBOOT -----------------------------

crash:
    mov ax, 0x03
    int 0x10

;---------------------------- PRINT -----------------------------

printstring:
    pusha

    mov ah, 0x0E
    mov al, [si]

    xor bh, bh

    printstring.color:
        mov bl, [mincolor]

        printstring.loop:
            inc bl

            cmp bl, [maxcolor]
            jae printstring.color

            int 10h

            inc si
            mov al, [si]

            cmp al, 0x00
            jnz printstring.loop

    popa

    ret

resetcursor:
    pusha

    mov ah, 0x02

    xor bh, bh
    xor dx, dx

    int 0x10

    popa

    ret

;---------------------------- DATA ------------------------------

pxmaxcolor: dw 0x00
pxmincolor: dw 0x00

maxcolor: dw 0x00
mincolor: dw 0x00

angle2: dq 0.00
alpha: dq 0.1

addcol: dw 32
delcol: dw 16

x: dw 0
y: dw 0
z: dw 0

zx: dd 0.0
zy: dd 0.0

gx: dw 0.0
gy: dw 0.0

pr1: dw 8.0
pr2: dw 256.0
pr3: dw 256.0
pr4: dd 12.0

msg: db "             Hello World!               ", 0x00

printed: times 13 dw 0x00

time: dw 0