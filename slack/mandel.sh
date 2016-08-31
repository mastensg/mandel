#!/bin/sh

w=$(tput cols)
h=$(tput lines)
w=50
h=50

y=1
while [ $y -lt $h ]
do
    cb=$((2047 - 4096 * y / h))

    x=0
    while [ $x -lt $w ]
    do
        ca=$((-2047 + 4096 * x / w))

        za=$ca
        zb=$cb

        i=0

        while [ $i -lt 127 ]
        do
            zaa=$((za * za >> 10))
            zbb=$((zb * zb >> 10))

            [ $((zaa + zbb > 4096)) -ne 0 ] &&
                break

            zb=$(((za * zb >> 9) + cb))
            za=$((zaa - zbb + ca))

            i=$((i + 1))
        done

        echo -n ":skin-tone-$((2 + (i / 30))): "
        #xdotool type --delay 10 ":skin-tone-$((2 + (i / 30))): "
        #echo -n "[4$((7 - (i >> 4)))m "

        x=$((x + 1))
    done | xsel -i

    xdotool click 2
    sleep .7
    xdotool key Return
    sleep .7

    #echo "[0m"

    y=$((y + 1))
done
