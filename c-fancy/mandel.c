#include <GL/gl.h>
#include <GL/glu.h>
#include <GL/glut.h>
#include <complex.h>
#include <inttypes.h>
#include <math.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define WIDTH 1366
#define HEIGHT 768
#define BUFFER_SIZE (WIDTH * HEIGHT * 4)

static uint8_t fixed_point = 0;
static uint8_t threaded = 1;

static uint8_t buffer[BUFFER_SIZE];
static uint8_t exponent = 14;

static double aspect_ratio = (double)WIDTH / (double)HEIGHT;

static double a_start;
static double a_stride;

static double b_start;
static double b_stride;

static double cca = 0;
static double ccb = 0;
static double cz = .5;

static double rotate = 0.0;
static double magnify = 0.0;

static void h2bgra(uint8_t rgb[4], float h) {
  float r, g, b;

  if (h < 1 / 6. && h >= 0) {
    r = 1;
    g = (h - 0 / 6.) * 6;
    b = 0;
  } else if (h < 2 / 6. && h >= 1 / 6.) {
    r = 1 - (h - 1 / 6.) * 6;
    g = 1;
    b = 0;
  } else if (h < 3 / 6. && h >= 2 / 6.) {
    r = 0;
    g = 1;
    b = (h - 2 / 6.) * 6;
  } else if (h < 4 / 6. && h >= 3 / 6.) {
    r = 0;
    g = 1 - (h - 3 / 6.) * 6;
    b = 1;
  } else if (h < 5 / 6. && h >= 4 / 6.) {
    r = (h - 4 / 6.) * 6;
    g = 0;
    b = 1;
  } else if (h < 6 / 6. && h >= 5 / 6.) {
    r = 1;
    g = 0;
    b = 1 - (h - 5 / 6.) * 6;
  }

  rgb[0] = 255 * b;
  rgb[1] = 255 * g;
  rgb[2] = 255 * r;
  rgb[3] = 255;
}

static void pixel2plane(int x, int y, double *a, double *b) {
  *a = cca + aspect_ratio * (2 * (double)x / WIDTH - 1) / cz;
  *b = ccb - (2 * (double)y / HEIGHT - 1) / cz;
}

static uint8_t mandelbrot_fixedpoint(double a, double b) {
  int ca = a * (1 << exponent);
  int cb = b * (1 << exponent);
  int za = ca;
  int zb = cb;
  int zaa = 0;
  int zbb = 0;

  // printf("%d %d\n\n", ca, cb);
  uint8_t i;
  for (i = 127; i > 0; --i) {
    zaa = (za * za) >> exponent;
    zbb = (zb * zb) >> exponent;

    if (zaa + zbb > (4 << exponent)) break;

    zb = (2 * za * zb >> exponent) + cb;
    za = zaa - zbb + ca;
  }

  return i;
}

static uint8_t mandelbrot(double ca, double cb) {
  double za = ca;
  double zb = cb;
  double zaa = 0;
  double zbb = 0;

  uint8_t i;
  for (i = 127; i > 0; --i) {
    zaa = za * za;
    zbb = zb * zb;

    if (zaa + zbb > 4) break;

    zb = (2 * za * zb) + cb;
    za = zaa - zbb + ca;
  }

  return i;
}

static void render_line(int y, uint8_t *buf) {
  double b = b_start + y * b_stride;

  for (int x = 0; x < WIDTH; ++x) {
    double a = a_start + x * a_stride;

    int i;
    if (fixed_point) {
      // i = mandelbrot_fixedpoint(a, b);

      double a = a_start + x * a_stride;

// z = z * z + c;
#if 1
      double ca = a;
      double cb = b;
      double za = ca;
      double zb = cb;
      double zaa = 0;
      double zbb = 0;

      uint8_t i;
      for (i = 100; i > 0; --i) {
        zaa = za * za;
        zbb = zb * zb;

        if (4.0 < zaa + zbb) {
          break;
        }

        zb = (2 * za * zb) + cb;
        za = zaa - zbb + ca;
      }

      complex z = za + zb * I;
#else
      complex c = a + b * I;
      complex z = cexp(c) + ccos(cexp(c));
#endif

      double z_arg = cargf(z);
      double z_arg_from_0_to_1 = fmod(1.0 + z_arg / M_PI / 2.0f + rotate, 1.0);

      double z_abs = cabsf(z);
      double z_abs_mod_1 = fmodf(z_abs + magnify, 1.0f);

      h2bgra((uint8_t *)buf, z_arg_from_0_to_1);

      double amplification = fabsf(2.0 * (z_abs_mod_1 - 0.5));
      // double amplification = z_abs_mod_1 - 0.5;

      buf[0] *= amplification;
      buf[1] *= amplification;
      buf[2] *= amplification;
    } else {
      i = mandelbrot(a, b);

      if (i == 0) {
        buf[0] = 0;
        buf[1] = 0;
        buf[2] = 0;
      } else {
        h2bgra((uint8_t *)buf, (float)i / 128);
      }
    }

    buf += 4;
  }
}

static void *thread(void *arg) {
  int y = (long)arg;
  render_line(y, buffer + 4 * WIDTH * y);
  pthread_exit(NULL);
}

static void render(uint8_t *buf) {
  a_start = cca - aspect_ratio / cz;
  a_stride = aspect_ratio * 2 / cz / WIDTH;

  b_start = ccb - 1 / cz;
  b_stride = 2 / cz / HEIGHT;

  if (threaded) {
    pthread_attr_t attr;
    pthread_attr_init(&attr);
    pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE);

    pthread_t threads[HEIGHT];
    for (long i = 0; i < HEIGHT; ++i) {
      int ret = pthread_create(&threads[i], &attr, thread, (void *)i);

      if (ret) {
        fprintf(stderr, "pthread_create(): %d\n", ret);
        exit(EXIT_FAILURE);
      }
    }

    void *status;
    for (long i = 0; i < HEIGHT; ++i) pthread_join(threads[i], &status);
  } else {
    for (int i = 0; i < HEIGHT; ++i) render_line(i, buffer + 4 * WIDTH * i);
  }
}

static void display(void) {
  render(buffer);
  glDrawPixels(WIDTH, HEIGHT, GL_BGRA, GL_UNSIGNED_BYTE, buffer);
  glutSwapBuffers();
}

static void reshape(int w, int h) {
  aspect_ratio = (double)w / (double)h;
  glViewport(0, 0, w, h);
}

static void keyboard(uint8_t key, int x, int y) {
  switch (key) {
    case 27:
      exit(EXIT_SUCCESS);
      break;
    case 'f':
      if (fixed_point)
        fixed_point = 0;
      else
        fixed_point = 1;
      break;
    case 'k':
      rotate += 0.1;
      break;
    case 'l':
      magnify += 0.01;
      break;
    case 'o':
      magnify += 0.01;
      rotate += 0.1;
      break;
    case 'r':
      break;
    case 't':
      if (threaded)
        threaded = 0;
      else
        threaded = 1;
      break;
  }

  display();
}

static void mouse(int button, int dir, int x, int y) {
  if (dir == 0) {
    switch (button) {
      case 0:
        pixel2plane(x, y, &cca, &ccb);
        break;
      case 2:
        break;
      case 3:
        cz /= 1.32;
        break;
      case 4:
        cz *= 1.32;
        break;
    }
  }

  display();
}

static int init(int argc, char **argv, int w, int h) {
  glutInit(&argc, argv);

  glutInitWindowPosition(0, 0);
  glutInitWindowSize(w, h);
  glutInitDisplayMode(GLUT_RGB);
  glutCreateWindow(argv[0]);

  glDepthMask(0);
  glDisable(GL_DEPTH_TEST);
  glDisable(GL_BLEND);

  return 0;
}

int main(int argc, char **argv) {
  if (init(argc, argv, WIDTH, HEIGHT)) return EXIT_FAILURE;

  glutDisplayFunc(display);
  glutReshapeFunc(reshape);
  glutKeyboardFunc(keyboard);
  glutMouseFunc(mouse);

  glutMainLoop();

  return EXIT_SUCCESS;
}
