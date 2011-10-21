.section .rodata
    .set width, 1280
    .set height, 1024

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
    .set pixels, width * height
    .lcomm buf, 3 * pixels
    .set buflen, 3 * pixels

.section .text
mandelbrot:
    push %rbx

    /*
     * xmm0 c real
     * xmm1 c imag
     * xmm2 tmp1/z real
     * xmm3 tmp2/z imag
     * xmm4 max
     * xmm5 r/abs/Z real
     * xmm6 i/Z imag
     * xmm7 Ztemp
     */

    /* a = -2.5 + 3.5 * x / w */
    /* a = x */
    cvtsi2ss %rax, %xmm0

    /* a /= w */
    mov $width, %rax
    cvtsi2ss %rax, %xmm7
    divss %xmm7, %xmm0

    /* a *= 35 */
    mov $35, %rax
    cvtsi2ss %rax, %xmm7
    mulss %xmm7, %xmm0

    /* a /= 10 */
    mov $10, %rax
    cvtsi2ss %rax, %xmm7
    divss %xmm7, %xmm0

    /* a -= 2.5 */
    mov $25, %rax
    cvtsi2ss %rax, %xmm2
    divss %xmm7, %xmm2
    subss %xmm2, %xmm0

    /* b = 1 - 2. * y / h */
    /* b = y */
    cvtsi2ss %rdi, %xmm1

    /* b /= h */
    mov $height, %rax
    cvtsi2ss %rax, %xmm7
    divss %xmm7, %xmm1

    /* b *= 2. */
    mov $2, %rax
    cvtsi2ss %rax, %xmm7
    mulss %xmm7, %xmm1

    /* b = 1 - b */
    movss %xmm1, %xmm7
    mov $1, %rax
    cvtsi2ss %rax, %xmm1
    subss %xmm7, %xmm1

    /* c = a + b * i */

    /* z = c */
    movss %xmm0, %xmm2
    movss %xmm1, %xmm3

    /* max = 100 */
    mov $100, %rax
    cvtsi2ss %rax, %xmm4

    /* loop at most 256 times */
    mov $256, %rcx

mandelloop:
    /* abs = cabs(z) */
    movss %xmm2, %xmm5
    movss %xmm3, %xmm6
    mulss %xmm5, %xmm5
    mulss %xmm6, %xmm6
    addss %xmm6, %xmm5
    sqrtss %xmm5, %xmm5

    /* if(cabs(z) > max) goto mandelend */
    cmpltss %xmm4, %xmm5
    cvtss2si %xmm5, %rax
    cmp $0, %rax
    je mandelend

    /* z = z * z + c */
    movss %xmm2, %xmm5
    movss %xmm3, %xmm7

    mulss %xmm5, %xmm5
    mulss %xmm7, %xmm7

    /* A = aa - bb */
    subss %xmm7, %xmm5

    /* B = ab */
    mulss %xmm2, %xmm3

    /* B *= 2 */
    addss %xmm3, %xmm3

    movss %xmm5, %xmm2

    /* Z += c */
    addss %xmm0, %xmm2
    addss %xmm1, %xmm3

    loop mandelloop

mandelend:
    mov %rcx, %rax
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

    /* render image */
    mov $buf, %rbx
    mov $0, %rdi
lineloop:

    mov $width, %rcx
    mov $0, %rax
pixelloop:
    mov $width, %rax
    sub %rcx, %rax

    push %rcx
    call mandelbrot
    pop %rcx

    movb %al, (%rbx)
    inc %rbx
    movb %al, (%rbx)
    inc %rbx
    movb %al, (%rbx)
    inc %rbx

    loop pixelloop

    inc %rdi
    cmp $height, %rdi
    jl lineloop

    /* write image */
    mov $1, %rax /* sys_write */
    mov $1, %rdi /* stdout */
    mov $buf, %rsi
    mov $buflen, %rdx
    syscall

    /* exit */
    mov $60, %rax /* sys_exit */
    mov $0, %rdi
    syscall
