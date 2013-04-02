size = 1024

sizeMSB = div(size, 256)
sizeLSB = mod(size, 256)

header = [
    0      ,   # id length
    0      ,   # color map type
    2      ,   # image type
    0      ,   # first entry index
    0      ,
    0      ,   # color map length
    0      ,
    0      ,   # color map entry size
    0      ,   # x origin
    0      ,
    sizeLSB,   # y origin
    sizeMSB,
    sizeLSB,   # width
    sizeMSB,
    sizeLSB,   # height
    sizeMSB,
    24     ,   # pixel depth
    32     ,   # image descriptor
]

[write(c) for c = uint8(header)]

function mandelbrot(c)
    z = c

    for i = 1 : 127
        z = z ^ 2 + c

        if abs(z) > 2
            return i
        end
    end

    127
end

for y = 0 : size - 1
    b = 2 - 4 * y / size

    for x = 0 : size - 1
        a = -2 + 4 * x / size

        c = uint8(-2 * mandelbrot(complex(a, b)))

        write(c)
        write(c)
        write(c)
    end
end
