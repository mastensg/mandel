.section .rodata
    .set width, 1920
    .set height, 1080

header:
    .byte 0 /* id_length */
    .byte 0 /* color_map_type */
    .byte 2 /* image_type */
    .word 0 /* first_entry_index */
    .word 0 /* color_map_length */
    .byte 0 /* color_map_entry_size */
    .word 0 /* x_origin */
    .word height /* y_origin */
    .word width /* image_width */
    .word height /* image_height */
    .byte 24 /* pixel_depth */
    .byte 32 /* image_descriptor */

    .set headerlen, . - header

.section .bss
    .lcomm buf, 3 * width * height
    .set buflen, 3 * width * height

.section .text
mandelbrot:
    push %rbx
    mov $63, %rax
    pop %rbx
    ret

    .globl _start
_start:
    /* write header */
    mov $1, %rax /* sys_write */
    mov $1, %rdi /* stdout */
    mov $header, %rsi
    mov $headerlen, %rdx
    syscall

    /* fill buffer */
    mov $buf, %rbx
    mov $buflen, %rcx
setpixel:
    mov %rcx, (%rbx)
    inc %rbx
    loop setpixel

    /* write buffer */
    mov $1, %rax /* sys_write */
    mov $1, %rdi /* stdout */
    mov $buf, %rsi
    mov $buflen, %rdx
    syscall

    /* exit */
    movq $60, %rax /* sys_exit */
    movq $0, %rdi
    syscall
