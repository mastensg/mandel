.section .rodata
    .set size, 1024
    .set width, size
    .set height, size

header:
    .byte 0         /* id_length */
    .byte 0         /* color_map_type */
    .byte 2         /* image_type */
    .hword 0         /* first_entry_index */
    .hword 0         /* color_map_length */
    .byte 0         /* color_map_entry_size */
    .hword 0         /* x_origin */
    .hword height    /* y_origin */
    .hword width     /* image_width */
    .hword height    /* image_height */
    .byte 24        /* pixel_depth */
    .byte 32        /* image_descriptor */

    .set headerlen, . - header

.section .bss
    .lcomm buf, 3 * width * height
    .set buflen, 3 * width * height

.section .text

/*
 * r0   *buf
 * r1   color
 * r2   x
 * r3   y
 * r4   ca
 * r5   cb
 * r6   za
 * r7   zb
 * r8   zaa
 * r9   zbb
 * r10  size
 * r11  2048
 * r12  magnitude
 * r13  4096
 */

.global _start
_start:
    mov r0, #1
    ldr r1, =header
    ldr r2, =headerlen
    mov r7, #4
    swi 0

    ldr r0, =buf
    mov r10, #size
    mov r11, #(2 << 10)
    mov r13, #(4 << 10)

    mov r3, #0

    next_line:
        sub r5, r11, r3, lsl #2

        mov r2, #0

        next_pixel:
            rsb r4, r11, r2, lsl #2

            mov r6, r4
            mov r7, r5

            mov r1, #254

            mandelbrot:
                mul r8, r6, r6
                mul r9, r7, r7

                mov r8, r8, asr #10
                mov r9, r9, asr #10

                mul r7, r6, r7
                add r7, r5, r7, asr #9

                sub r6, r8, r9
                add r6, r6, r4

                add r12, r8, r9
                cmp r12, r13
                bhs mandelbrot_end

                subs r1, r1, #2
                bne mandelbrot

            mandelbrot_end:

            strb r1, [r0, #1]!
            strb r1, [r0, #1]!
            strb r1, [r0, #1]!

            add r2, r2, #1
            cmp r2, r10
            blo next_pixel

        add r3, r3, #1
        cmp r3, r10
        blo next_line

    mov r0, #1
    ldr r1, =buf
    ldr r2, =buflen
    mov r7, #4
    swi 0

    mov r0, #0
    mov r7, #1
    swi 0
