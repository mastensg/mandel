#!/bin/bash

w=1024
h=768

im() {
    echo "$*" | bc
}

m() {
    echo "scale=10; $*" | bc
}

wd() {
    printf "%b" "\x"$(echo 10 i 16 o $1 p | dc)
}

header() {
    wd 0 # id_length
    wd 0 # color_map_type
    wd 2 # image_type
    wd 0 # first_entry_index
    wd 0 #
    wd 0 # color_map_length
    wd 0 #
    wd 0 # color_map_entry_size
    wd 0 # x_origin
    wd 0 #
    wd `im $h % 256` # y_origin
    wd `im $h / 256` #
    wd `im $w % 256` # image_width
    wd `im $w / 256` #
    wd `im $h % 256` # image_height
    wd `im $h / 256` #
    wd 24 # pixel_depth
    wd 32 # image_descriptor
}

mandelbrot() {
    ca=$1
    cb=$2

    za=$ca
    zb=$cb

    for i in `seq 127 -1 0`; do
        a=`m "sqrt($za * $za + $zb * $zb) > 3"`

        test $a = 1 &&
            return $i

        ta=`m "$za * $za - $zb * $zb"`
        tb=`m "2 * $za * $zb"`

        za=`m "$ta + $ca"`
        zb=`m "$tb + $cb"`
    done

    return 0
}

header

for y in `seq $h`; do
    b=`m "1 - 2 * $y / $h"`

    for x in `seq $w`; do
        a=`m "-2.5 + 3.5 * $x / $w"`

        mandelbrot $a $b

        i=`m "2 * $?"`

        wd $i
        wd $i
        wd $i
    done
done
