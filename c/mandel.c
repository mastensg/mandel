#include <complex.h>
#include <err.h>
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#pragma pack(push)
#pragma pack(1)

struct tga_header {
    uint8_t id_length;
    uint8_t color_map_type;
    uint8_t image_type;
    uint16_t first_entry_index;
    uint16_t color_map_length;
    uint8_t color_map_entry_size;
    uint16_t x_origin;
    uint16_t y_origin;
    uint16_t image_width;
    uint16_t image_height;
    uint8_t pixel_depth;
    uint8_t image_descriptor;
};

#pragma pack(pop)

static void
tga_write(FILE *file, const uint8_t *pixels, const uint16_t width, const uint16_t height) {
    struct tga_header h;
    memset(&h, 0, sizeof(struct tga_header));
    h.image_type = 2;
    h.y_origin = height;
    h.image_width = width;
    h.image_height = height;
    h.pixel_depth = 24;
    h.image_descriptor = 32;

    if(fwrite(&h, sizeof(struct tga_header), 1, file) == -1)
        err(1, "write header");

    if(fwrite(pixels, 3, width * height, file) == -1)
        err(1, "write pixels");
}

static uint8_t
mandelbrot(const float a, const float b) {
    static const float max = 200;

    float complex c = a + b * I;
    float complex z = c;

    for(uint8_t i = 127; i < 128; --i) {
        if(cabs(z) > max)
            return i;

        z = z * z + c;
    }

    return 0;
}

int
main(int argc, char *argv[]) {
    uint16_t w = 1280;
    uint16_t h = 1024;
    uint8_t p[3 * w * h];

    for(int y = 0; y < h; ++y) {
        float b = 1 - 2. * y / h;

        for(int x = 0; x < w; ++x) {
            float a = -2.5 + 3.5 * x / w;

            uint8_t v = 2 * mandelbrot(a, b);

            uint8_t r = v;
            uint8_t g = v;
            uint8_t b = v;

            int i = 3 * (y * w + x);

            p[i + 0] = r;
            p[i + 1] = g;
            p[i + 2] = b;
        }
    }

    tga_write(stdout, p, w, h);

    return EXIT_SUCCESS;
}
