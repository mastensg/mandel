width = 1280
height = 1024
pixels = width * height
bytes = 3 * pixels

format ELF64 executable

include "include/linux_def.inc"
include "include/unistd64.inc"

segment readable executable

_start:
    ; render image
    lea rbx, [pixbuf]
    xor rdi, rdi

line:
    mov rcx, width

    pixel:
        mov rax, width
        sub rax, rcx

        push rcx
        call mandelbrot
        pop rcx

        mov byte [rbx], al
        inc rbx
        mov byte [rbx], al
        inc rbx
        mov byte [rbx], al
        inc rbx

        loop pixel
    
    inc rdi
    cmp rdi, height
    jl line

    ; write image
    mov rdx, image_size
    lea rsi, [header]
    mov rdi, STDOUT
    mov rax, sys_write
    syscall

    ; exit
    xor rdi, rdi
    mov rax, sys_exit
    syscall

mandelbrot:
    cvtsi2ss xmm0, eax

    mov ax, width
    cvtsi2ss xmm7, eax
    divss xmm0, xmm7

    mov ax, 35
    cvtsi2ss xmm7, eax
    mulss xmm0, xmm7

    mov al, 10
    cvtsi2ss xmm7, eax
    divss xmm0, xmm7

    mov al, 25
    cvtsi2ss xmm2, eax
    divss xmm2, xmm7
    subss xmm0, xmm2

    cvtsi2ss xmm1, rdi

    mov ax, height
    cvtsi2ss xmm7, eax
    divss xmm1, xmm7

    addss xmm1, xmm1

    movss xmm7, xmm1
    mov ax, 1
    cvtsi2ss xmm1, eax
    subss xmm1, xmm7

    movss xmm2, xmm0
    movss xmm3, xmm1

    mov al, 100
    cvtsi2ss xmm4, eax

    mov cx, 128

    mandelloop:
        movss xmm5, xmm2
        movss xmm6, xmm3
        mulss xmm5, xmm5
        mulss xmm6, xmm6
        addss xmm5, xmm6
        sqrtss xmm5, xmm5

        cmpltss xmm5, xmm4
        cvtss2si rax, xmm5
        cmp rax, 0
        je mandelend

        movss xmm5, xmm2
        movss xmm7, xmm3

        mulss xmm5, xmm5
        mulss xmm7, xmm7

        subss xmm5, xmm7

        mulss xmm3, xmm2

        addss xmm3, xmm3
        movss xmm2, xmm5

        addss xmm2, xmm0
        addss xmm3, xmm1

        loop mandelloop

    mandelend:
        mov al, cl
        add al, al
        ret

segment readable writable

header:
    db 0        ; id_length
    db 0        ; color_map_type
    db 2        ; image_type
    dw 0        ; first_entry_index
    dw 0        ; color_map_length
    db 0        ; color_map_entry_size
    dw 0        ; x_origin
    dw height   ; y_origin
    dw width    ; image_width
    dw height   ; image_height
    db 24       ; pixel_depth
    db 32       ; image_descriptor
pixbuf:
    rb bytes
image_size = $ - header
