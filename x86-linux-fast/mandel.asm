width = 1024
height = 768
a_pitch = 3584 / width
b_pitch = -2048 / height
a_start = -2560
b_start = 1024
pixels = width * height
bytes = 3 * pixels

format ELF64 executable

include "include/linux_def.inc"
include "include/unistd64.inc"

segment readable executable

; r8    x
; r9    y
; r10   ca
; r11   cb
; r12   za
; r13   zb
; r14   zaa
; r15   zbb

_start:
    lea rbx, [pixbuf]

    xor r9, r9
    mov r11, b_start

    mov rdi, 2

    lline:
        xor r8, r8
        mov r10, a_start

        lpixel:
            mov r12, r10
            mov r13, r11
            xor rcx, rcx
            mov rcx, 63

            lm:
                mov rax, r12
                mul r12
                sar rax, 10
                mov r14, rax

                mov rax, r13
                mul r13
                sar rax, 10
                mov r15, rax

                add rax, r14
                cmp rax, 4096
                jg lmend

                mov rax, r13
                mul r12
                add rax, rax
                sar rax, 10
                add rax, r11
                mov r13, rax

                mov r12, r14
                sub r12, r15
                add r12, r10

                loop lm

            lmend:

            mov rax, rcx
            shl rax, 2

            mov byte [rbx], al
            inc rbx
            mov byte [rbx], al
            inc rbx
            mov byte [rbx], al
            inc rbx

            add r10, a_pitch

            inc r8
            cmp r8, width
            jl lpixel

        add r11, b_pitch
        inc r9
        cmp r9, height
        jl lline

    mov rdx, image_size
    lea rsi, [header]
    mov rdi, STDOUT
    mov rax, sys_write
    syscall

    ; exit
    xor rdi, rdi
    mov rax, sys_exit
    syscall

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
