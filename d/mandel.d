import std.stdio;

int
mandelbrot(int ca, int cb)
{
    int i, za, zb, zaa, zbb;

    za = ca;
    zb = cb;

    for (i = 0; i < 128; ++i)
    {
        zaa = (za * za) >> 10;
        zbb = (zb * zb) >> 10;

        if (zaa + zbb > (4 << 10))
            return i;

        zb = (za * zb) / (1 << 9) + cb;
        za = zaa - zbb + ca;
    }

    return 128;
}

void
main()
{
    int x, y, a, b, i;

    printf("P2\n1024 1024\n256\n");

    for (y = 0; y < 1024; ++y)
    {
        b = (2 << 10) - (y << 2);

        for (x = 0; x < 1024; ++x)
        {
            a = -(2 << 10) + (x << 2);
            i = 256 - 2 * mandelbrot(a, b);
            printf("%d ", i);
        }
    }
}
