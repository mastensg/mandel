#include "mandelbrot.h"

int
mandelbrot(float a, float b) {
    int i, ca, cb, za, zb, zaa, zbb;

    ca = a * 1024;
    cb = b * 1024;
    za = ca;
    zb = cb;

    for(i = 0; i < 127; ++i) {
        zaa = za * za >> 10;
        zbb = zb * zb >> 10;

        if(zaa + zbb > 4 << 10)
            return i;

        zb = ((za * zb) >> 9) + cb;
        za = zaa - zbb + ca;
    }

    return i;
}
