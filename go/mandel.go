package main

import (
    "fmt"
    "cmath"
)

func putchar(c int) {
    fmt.Printf("%c", c)
}

func mandelbrot(c complex128) int {
    z := c

    for i := 0; i < 127; i++ {
        if cmath.Abs(z) > 2 {
            return i
        }

        z = z * z + c
    }

    return 127
}

func main() {
    w := 1024
    h := 1024

    putchar(0) // id length
    putchar(0) // color map type
    putchar(2) // image type
    putchar(0) // first entry index
    putchar(0)
    putchar(0) // color map length
    putchar(0)
    putchar(0) // color map entry size
    putchar(0) // x origin
    putchar(0)
    putchar(h % 256) // y origin
    putchar(h / 256)
    putchar(w % 256) // y origin
    putchar(w / 256)
    putchar(h % 256) // y origin
    putchar(h / 256)
    putchar(24) // pixel depth
    putchar(32) // image descriptor

    for y := 0; y < h; y++ {
        b := 2.0 - 4.0 * float64(y) / float64(h)

        for x := 0; x < w; x++ {
            a := -2.0 + 4.0 * float64(x) / float64(w)

            i := 127 - mandelbrot(complex(a, b))

            putchar(i)
            putchar(i)
            putchar(i)
        }
    }
}
