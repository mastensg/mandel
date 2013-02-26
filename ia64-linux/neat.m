define(ar_pfs_old, loc0)
define(gp_old, loc1)
define(rp_old, loc2)

.set width, 1024
.set height, 1024

.rodata
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
    .ascii "%lld %lld\n"

.bss
    .lcomm buf, 3 * width, 4
    .set buflen, 3 * width

.text
    .global main
    .proc main
main:
    .prologue
    alloc ar_pfs_old = ar.pfs, 2, 5, 3, 0
    mov gp_old = gp
    mov rp_old = rp

    define(main_y, loc3)
    define(main_h, loc4)

    .body
    mov out0 = 1
    add out1 = @ltoff(header), gp
    mov out2 = headerlen
    ;;
    ld8 out1 = [out1]
    br.call.sptk rp = write
    mov gp = gp_old
    mov main_y = 0
    mov main_h = height
    ;;
lline:
    mov out0 = main_y
    br.call.sptk rp = line
    mov gp = gp_old
    ;;

    cmp4.ge p6, p7 = main_h, main_y
    add main_y = 1, main_y
    (p6) br.cond.dptk lline

    .restore sp
    mov gp = gp_old
    mov rp = rp_old
    mov ar.pfs = ar_pfs_old
    mov ret0 = 0
    br.ret.sptk rp
    .endp main

    .proc line
line:
    .prologue
    alloc ar_pfs_old = ar.pfs, 1, 7, 3, 0
    mov gp_old = gp
    mov rp_old = rp

    define(line_y, in0)
    define(line_x, loc3)
    define(b, loc4)
    define(w, loc5)

    .body
    add b = @ltoff(buf), gp
    ;;
    ld8 b = [b]
    mov line_x = 0
    mov w = width
    ;;
    lpixel:
        mov out2 = -2048
        ;;
        shladd out0 = line_x, 2, out2
        shladd out1 = line_y, 2, out2
        br.call.sptk rp = mandelbrot

        st1 [b] = ret0
        add b = 1, b
        ;;
        st1 [b] = ret0
        add b = 1, b
        ;;
        st1 [b] = ret0
        cmp4.ge p6, p7 = w, line_x
        add line_x = 1, line_x
        add b = 1, b
        (p6) br.cond.dptk lpixel

    mov out0 = 1
    add out1 = @ltoff(buf), gp
    mov out2 = buflen
    ;;
    ld8 out1 = [out1]
    br.call.sptk rp = write
    ;;

    .restore sp
    mov gp = gp_old
    mov rp = rp_old
    mov ar.pfs = ar_pfs_old
    br.ret.sptk rp
    .endp line

    .global mandelbrot
    .proc mandelbrot
mandelbrot:
    .prologue
    alloc ar_pfs_old = ar.pfs, 2, 9, 3, 0
    mov gp_old = gp
    mov rp_old = rp

    define(ca, in0)
    define(cb, in1)
    define(zaa, loc3)
    define(zbb, loc4)
    define(zbb, loc5)
    define(len, loc6)
    define(max, loc7)
    define(i, loc8)
    define(fa, f6)
    define(fb, f7)
    define(fbb, f8)

    .body
    setf.sig fa = ca
    setf.sig fb = cb
    mov max = 4096
    mov i = 0
    ;;
    lm:
        xmpy.l fbb = fb, fb
        xmpy.l fb = fa, fb
        ;;
        xmpy.l fa = fa, fa
        ;;
        getf.sig zaa = fa
        getf.sig zbb = fbb
        ;;
        shr zaa = zaa, 10
        shr zbb = zbb, 10
        ;;
        add len = zaa, zbb
        ;;
        add out0 = @ltoff(fmt), gp
        mov out1 = zaa
        mov out2 = i
        ;;
        ld8 out0 = [out0]
        #br.call.sptk rp = printf

        cmp.gt p6, p7 = len, max
        ;;
        (p6) br.cond.dptk lmend

        cmp.le p8, p9 = 127, i
        add i = 1, i
        (p9) br.cond.dptk lm
    ;;

lmend:
    mov ret0 = len
    .restore sp
    mov gp = gp_old
    mov rp = rp_old
    mov ar.pfs = ar_pfs_old
    br.ret.sptk rp
    .endp mandelbrot
