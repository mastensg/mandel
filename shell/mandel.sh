#!/bin/sh

w=$(tput cols)
h=$(tput lines)

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

        #echo -n $((i<127))
        echo -n "[4$((7 - (i >> 4)))m "

        x=$((x + 1))
    done

    echo "[0m"

    y=$((y + 1))
done
