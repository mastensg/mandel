w := 1280
h := 1024

buf := Sequence clone setItemType("uint8")

Sequence append16le := method(i,
    self append(i & 0xff)
    self append(i >> 8)
)

buf append(0) // id length
buf append(0) // color map type
buf append(2) // image type
buf append16le(0) // first entry index
buf append16le(0) // color map length
buf append(0) // color map entry size
buf append16le(0) // x origin
buf append16le(h) // y origin
buf append16le(w) // width
buf append16le(h) // height
buf append(24) // pixel depth
buf append(32) // image descriptor

Complex := Object clone

Complex do(
    real ::= 0
    imaginary ::= 0

    + := method(z, if(z isKindOf(Complex),
        with(real + z real, imaginary + z imaginary),
        with(real + z, imaginary)))

    abs := method((real ** 2 + imaginary ** 2) sqrt)
    pow2 := method(with(real ** 2 - imaginary ** 2, 2 * real * imaginary))

    mandelbrot := method(
        c := self
        z := c

        for(i, 0, 255,
            if(z abs > 2,
                return 255 - i
            )

            z = z pow2 + c
        )

        0
    )

    asString := method(real .. "+" .. imaginary .. "i")
    with := method(a, b, self clone setReal(a) setImaginary(b))
)

for(y, 0, h - 1,
    b := 1 - 2 * y / h

    for(x, 0, w - 1,
        a := -2.5 + 3.5 * x / w
        i := Complex with(a, b) mandelbrot

        buf append(i)
        buf append(i)
        buf append(i)
    )
)

buf print
