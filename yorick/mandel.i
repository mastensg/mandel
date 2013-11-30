w = 1024
h = 1024

func mandelbrot(ca, cb)
{
    za = ca
    zb = cb

    for (i = 1; i < 128; ++i)
    {
        zaa = za * za
        zbb = zb * zb

        if (zaa + zbb > 4)
            return i

        zb = 2 * za * zb + cb
        za = zaa - zbb + ca
    }

    return 128
}

S = [[4./w,0,0],[0,-4./w,0],[0,0,1]](,+) *
    [[1,0,-w/2.],[0,1,-h/2.],[0,0,1]](,+)

write, format="%s\n", "P2"
write, format="%d %d\n", w, h
write, format="%d\n", 256
for (y = 0; y < h; ++y)
{
    for (x = 0; x < w; ++x)
    {
        c = S(,+) * [x,y,1](+)
        a = c(1)
        b = c(2)
        i = 256 - 2 * mandelbrot(a, b)
        print,i
    }
}
