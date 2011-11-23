.section .rodata
    .set width, 1024
    .set height, 1024

header:
    .byte 0 /* id_length */
    .byte 0 /* color_map_type */
    .byte 2 /* image_type */
    .byte 0 /* first_entry_index */
    .byte 0
    .byte 0 /* color_map_length */
    .byte 0
    .byte 0 /* color_map_entry_size */
    .byte 0 /* x_origin */
    .byte 0
    .byte height % 256 /* y_origin */
    .byte height / 256
    .byte width % 256 /* image_width */
    .byte width / 256
    .byte height % 256 /* image_height */
    .byte height / 256
    .byte 24 /* pixel_depth */
    .byte 32 /* image_descriptor */
    .set headerlen, . - header

fmt:
    .ascii "%d,\t%ld,\t%ld,\t%ld,\t%ld\n"

.section .bss
    .lcomm buf, 3 * width
    .set buflen, 3 * width

.section .text
    .globl main
main:
    save %sp, -96, %sp

    /* Registers:
        l0  y
        l1  x
        l2  *buf
        l3  i
        l4  b
        l5  a
        l6  zb
        l7  za

        g2  zbb
        g3  zaa
     */

    mov 1, %o0
    set header, %o1
    mov headerlen, %o2
    call write

    mov 0, %l0
    lline:
        sll %l0, 12, %l4
        udiv %l4, height, %l4
        neg %l4, %l4
        add %l4, 2048, %l4

        sethi %hi(buf), %l2
        or %l2, %lo(buf), %l2

        mov 0, %l1
        lpixel:
            sll %l1, 12, %l5
            udiv %l5, width, %l5
            sub %l5, 2048, %l5

            mov %l4, %l6
            mov %l5, %l7

            mov 0, %l3
            lm:
                smul %l6, %l6, %g2
                sra %g2, 10, %g2

                smul %l7, %l7, %g3
                sra %g3, 10, %g3

                add %g2, %g3, %g1

                srl %g1, 1, %g1
                cmp %g1, 2048
                bg lmend

                smul %l6, %l7, %l6
                sra %l6, 9, %l6
                add %l6, %l4, %l6

                sub %g3, %g2, %l7
                add %l7, %l5, %l7

                cmp %l3, 126
                bl lm
                inc %l3

        lmend:
            smul %l3, 2, %l3
            mov 255, %l5
            sub %l5, %l3, %l3

            stb %l3, [%l2]
            inc %l2

            stb %l3, [%l2]
            inc %l2

            stb %l3, [%l2]
            inc %l2

            cmp %l1, width
            ble lpixel
            inc %l1

        mov 1, %o0
        set buf, %o1
        call write
        mov buflen, %o2

        cmp %l0, height
        bl lline
        inc %l0

    ret
    clr %o0
