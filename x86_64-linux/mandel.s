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
    movl $63, %eax
    pop %rbx
    ret

    .globl _start
_start:
    /* write header */
    movq $1, %rax
    movq $1, %rdi
    movq $header, %rsi
    movq $headerlen, %rdx
    syscall

    /* subl $4, %esp */
    /* fill buffer */
    movl $buf, %ebx
    movl $buflen, %ecx
setpixel:
    movw %cx, (%ebx)
    inc %ebx
    loop setpixel

    /* write buffer */
    movl $buflen, %edx
    movl $buf, %ecx
    movl $1, %ebx /* stdout */
    movl $4, %eax /* sys_write */
    int $0x80

    /* exit */
    movq $60, %rax /* sys_exit */
    movq $0, %rdi
    syscall
