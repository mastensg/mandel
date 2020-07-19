.equ WIDTH,     1024
.equ HEIGHT,    1024

.equ TGA_HEADER_LEN, 18
.equ BUF_LEN,   (TGA_HEADER_LEN + HEIGHT * WIDTH * 3)

.equ STDOUT_FILENO, 1

##############################################################################

.section .text

.set noreorder
#.set nomacro

######################################

.global le16_encode
.ent le16_encode

le16_encode:
    # $a0 destination
    # $a1 value

    sb $a1, 0($a0)

    srl $a1, $a1, 8
    sb $a1, 1($a0)

    jr $ra
    nop
.end le16_encode

######################################

.global tga_header_encode
.ent tga_header_encode

tga_header_encode:
    # $a0 destination
    # $a1 width
    # $a2 height

    daddiu $sp, -32
    sd $ra, 0($sp)
    sd $s0, 8($sp)
    sd $s1, 16($sp)
    sd $s2, 24($sp)

    move $s0, $a0
    move $s1, $a1
    move $s2, $a2

    #  0    id length
    sb $0, 0($s0)

    #  1    color map type
    sb $0, 1($s0)

    #  2    image type
    # uncompressed true-color image
    dli $t8, 2
    sb $t8, 2($s0)

    #  3    color type
    sb $0, 3($s0)
    sb $0, 4($s0)
    sb $0, 5($s0)
    sb $0, 6($s0)
    sb $0, 7($s0)

    #  8    image specification
    #       u16 x-origin
    daddiu $a0, $s0, 8
    jal le16_encode
    dli $a1, 0

    #       u16 y-origin
    daddiu $a0, $s0, 10
    jal le16_encode
    dli $a1, 0

    #       u16 width
    daddiu $a0, $s0, 12
    jal le16_encode
    move $a1, $s1

    #       u16 height
    daddiu $a0, $s0, 14
    jal le16_encode
    move $a1, $s2

    #       u8  bits per pixel
    dli $t8, 24
    sb $t8, 16($s0)

    #       u8  image descriptor (0x20 = 0,0 at top left)
    dli $t8, 0x00
    sb $t8, 17($s0)

    ld $ra, 0($sp)
    ld $s0, 8($sp)
    ld $s1, 16($sp)
    ld $s2, 24($sp)
    jr $ra
    daddiu $sp, 32
.end tga_header_encode

######################################

.global mandel
.ent mandel
mandel:
    # a0        i48.16  c_a
    # a1        i48.16  c_b
    # a2        i48.16  z_a
    # a3        i48.16  z_b
    # a4        i48.16  z_a ** 2
    # a5        i48.16  z_b ** 2
    # a6        i48.16  z_a ** 2 + z_b ** 2
    # a7        i48.16  4.0
    #   t0      i48.16  tmp
    #     v0    i64     i

    move $a2, $a0
    move $a3, $a1
    dli $a7, 4 << 16
    dli $v0, 127

1:
    # z_a ** 2
    dmult $a2, $a2
    mflo $a4
    sra $a4, 16

    # z_b ** 2
    dmult $a3, $a3
    mflo $a5
    sra $a5, 16

    # z_a ** 2 + z_b ** 2
    dadd $a6, $a4, $a5

    # break loop if outside r=2
    dsub $t0, $a6, $a7
    bgez $t0, 2f
    nop

    # z_b  <-  2 * z_a * z_b + c_b
    dmult $a2, $a3
    mflo $a3
    dsra $a3, 15
    dadd $a3, $a1

    # z_a  <-  z_a ** 2 - z_b ** 2 + c_a
    dsub $a2, $a4, $a5
    dadd $a2, $a0

    daddiu $v0, -1
    bnez $v0, 1b
    nop

2:
    jr $ra
    nop
.end mandel

######################################

.global picture
.ent picture
picture:
    # a0    s0    buf
    # a1    s1    width
    # a2    s2    height
    #       s3    i48.16    pixel_x
    #       s4    i48.16    pixel_y
    #       s5    i48.16    c_a
    #       s6    i48.16    c_b

    daddiu $sp, -64
    sd $ra, 0($sp)
    sd $s0, 8($sp)
    sd $s1, 16($sp)
    sd $s2, 24($sp)
    sd $s3, 32($sp)
    sd $s4, 40($sp)
    sd $s5, 48($sp)
    sd $s6, 56($sp)

    move $s0, $a0
    move $s1, $a1
    move $s2, $a2

    dli $s4, 0

    # for each row
1:
    # c_b = 4.0 * ((u48.16)pixel_y / height - 0.5)
    dsll $s6, $s4, 16
    ddiv $s6, $s2
    mflo $s6
    daddi $s6, $s6, -(1 << 15)
    dsll $s6, 2

    dli $s3, 0

    # for each column
2:
    # c_a = 4.0 * ((u48.16)pixel_x / width - 0.5)
    dsll $s5, $s3, 16
    ddiv $s5, $s1
    mflo $s5
    daddi $s5, $s5, -(1 << 15)
    dsll $s5, 2

    # r**2 = c_a**2 + c_b**2
    # dmult $s5, $s5
    # madd $s6, $s6
    # mflo $t0
    # dsra $t0, $t0, 16
    # dsra $t0, $t0, 8

    move $a0, $s5
    move $a1, $s6
    jal mandel
    nop

    dsll $v0, 1

    # BGR
    sb $v0, 0($s0)
    sb $v0, 1($s0)
    sb $v0, 2($s0)

    daddiu $s0, 3

    daddiu $s3, 1
    bne $s1, $s3, 2b
    nop

    daddiu $s4, 1
    bne $s2, $s4, 1b
    nop

    ld $ra, 0($sp)
    ld $s0, 8($sp)
    ld $s1, 16($sp)
    ld $s2, 24($sp)
    ld $s3, 32($sp)
    ld $s4, 40($sp)
    ld $s5, 48($sp)
    ld $s6, 56($sp)
    jr $ra
    daddiu $sp, 64
.end picture

######################################

.global main
.ent main
main:
    # s0    buf

    daddiu $sp, -16
    sd $ra, 0($sp)
    sd $s0, 8($sp)

    dli $a0, BUF_LEN
    jal malloc
    nop
    move $s0, $v0

    move $a0, $s0
    dli $a1, WIDTH
    dli $a2, HEIGHT
    jal tga_header_encode
    nop

    daddiu $a0, $s0, TGA_HEADER_LEN
    dli $a1, WIDTH
    dli $a2, HEIGHT
    jal picture
    nop

    # d, buf, nbytes
    dli $a0, STDOUT_FILENO
    move $a1, $s0
    dli $a2, BUF_LEN
    jal write
    nop

    dli $v0, 0

    ld $ra, 0($sp)
    ld $s0, 8($sp)
    jr $ra
    daddiu $sp, 16
.end main
