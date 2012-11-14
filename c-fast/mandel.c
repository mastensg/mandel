#include <inttypes.h>
#include <stdlib.h>
#include <unistd.h>

static const int w = 1024;
static const int h = 1024;

static const uint8_t header[] = {
    0, // uint8_t id_length;
    0, // uint8_t color_map_type;
    2, // uint8_t image_type;
    0, // uint16_t first_entry_index;
    0, // 
    0, // uint16_t color_map_length;
    0, // 
    0, // uint8_t color_map_entry_size;
    0, // uint16_t x_origin;
    0, // 
    0, // uint16_t y_origin;
    4, // 
    0, // uint16_t image_width;
    4, // 
    0, // uint16_t image_height;
    4, // 
    24, // uint8_t pixel_depth;
    32, // uint8_t image_descriptor;
};

static int
mandelbrot(int ca, int cb) {
    int za = ca;
    int zb = cb;

    int i;
    for(i = 0; i < 128; ++i) {
        int zaa = za * za >> 10;
        int zbb = zb * zb >> 10;

        if(zaa + zbb > 4 << 10)
            return i;

        zb = ((za * zb) >> 9) + cb;
        za = zaa - zbb + ca;
    }

    return i;
}

int
main(int argc, char *argv[]) {
    write(1, header, sizeof(header));

    uint8_t p[3 * w * h];
    uint8_t *q = p;
    for(int y = 0; y < h; ++y) {
        int b = (2 << 10) - (y << 2);

        for(int x = 0; x < w; ++x) {
            int a = -(2 << 10) + (x << 2);

            int v = - 2 * mandelbrot(a, b);

            *q++ = v * 2;
            *q++ = v * 2;
            *q++ = v;
        }
    }

    write(1, p, sizeof(p));

    return EXIT_SUCCESS;
}
