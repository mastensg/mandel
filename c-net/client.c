#define _GNU_SOURCE

#include <arpa/inet.h>
#include <inttypes.h>
#include <math.h>
#include <netdb.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/types.h>

#include <GL/gl.h>
#include <GL/glu.h>
#include <GL/glut.h>

#define WIDTH 1920
#define HEIGHT 1200
#define BUFFER_SIZE (WIDTH * HEIGHT * 4)

static const int port = 8164;
static int serverfd;

static uint8_t fixed_point = 0;
static uint8_t threaded = 0;

static uint8_t buffer[BUFFER_SIZE];

static double aspect_ratio = (double)WIDTH / (double)HEIGHT;

static double a_start;
static double a_stride;

static double b_start;
static double b_stride;

static double cca = 0;
static double ccb = 0;
static double cz = .5;

static void
h2bgra(uint8_t rgb[4], float h) {
    float r, g, b;

    if(h < 1/6. && h >= 0) {
        r = 1;
        g = (h - 0/6.) * 6;
        b = 0;
    } else if(h < 2/6. && h >= 1/6.) {
        r = 1 - (h - 1/6.) * 6;
        g = 1;
        b = 0;
    } else if(h < 3/6. && h >= 2/6.) {
        r = 0;
        g = 1;
        b = (h - 2/6.) * 6;
    } else if(h < 4/6. && h >= 3/6.) {
        r = 0;
        g = 1 - (h - 3/6.) * 6;
        b = 1;
    } else if(h < 5/6. && h >= 4/6.) {
        r = (h - 4/6.) * 6;
        g = 0;
        b = 1;
    } else {
        r = 0;
        g = 1;
        b = 1 - (h - 5/6.) * 6;
    }

    rgb[0] = 255 * b;
    rgb[1] = 255 * g;
    rgb[2] = 255 * r;
    rgb[3] = 255;
}

static void
pixel2plane(int x, int y, double *a, double *b) {
    *a = cca + aspect_ratio * (2 * (double)x / WIDTH - 1) / cz;
    *b = ccb - (2 * (double)y / HEIGHT - 1) / cz;
}

static void
render_line(int y, uint8_t *buf) {
    char netbuf[1920];
    double b = b_start + y * b_stride;
    double mina = a_start;
    double maxa = a_start + (WIDTH - 1) * a_stride;
    sprintf(netbuf, "%lf %lf %lf\n", b, mina, maxa);

    write(serverfd, netbuf, strlen(netbuf));

    read(serverfd, netbuf, sizeof(netbuf));

    for(int x = 0; x < WIDTH; ++x) {
        uint8_t i = netbuf[x];

        if(i == 0) {
            buf[0] = 0;
            buf[1] = 0;
            buf[2] = 0;
        } else {
            h2bgra((uint8_t *)buf, (float)i / 128);
        }

        buf += 4;
    }
}

static void *
thread(void *arg) {
    int y = (long)arg;
    render_line(y, buffer + 4 * WIDTH * y);
    pthread_exit(NULL);
}

static void
render(uint8_t *buf) {
    a_start = cca - aspect_ratio / cz;
    a_stride = aspect_ratio * 2 / cz / WIDTH;

    b_start = ccb - 1 / cz;
    b_stride = 2 / cz / HEIGHT;

    if(threaded) {
        pthread_attr_t attr;
        pthread_attr_init(&attr);
        pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE);

        pthread_t threads[HEIGHT];
        for(long i = 0; i < HEIGHT; ++i) {
            int ret = pthread_create(&threads[i], &attr, thread, (void *)i);

            if(ret) {
                fprintf(stderr, "pthread_create(): %d\n", ret);
                exit(EXIT_FAILURE);
            }
        }

        void *status;
        for(long i = 0; i < HEIGHT; ++i)
            pthread_join(threads[i], &status);
    } else {
        for(int i = 0; i < HEIGHT; ++i)
            render_line(i, buffer + 4 * WIDTH * i);
    }
}

static void
display(void) {
    render(buffer);
    glDrawPixels(WIDTH, HEIGHT, GL_BGRA, GL_UNSIGNED_BYTE, buffer);
    glutSwapBuffers();
}

static void
reshape(int w, int h) {
    aspect_ratio = (double)w / (double)h;
    glViewport(0, 0, w, h);
}

static void
keyboard(uint8_t key, int x, int y) {
    switch(key) {
    case 27:
        exit(EXIT_SUCCESS);
        break;
    case 'f':
        if(fixed_point)
            fixed_point = 0;
        else
            fixed_point = 1;
        break;
    case 'r':
        break;
    case 't':
        if(threaded)
            threaded = 0;
        else
            threaded = 1;
        break;
    }

    display();
}

static void
mouse(int button, int dir, int x, int y) {
    if(dir == 0) {
        switch(button) {
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

static int
init(int argc, char **argv, int w, int h) {
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

int
main(int argc, char **argv) {
    serverfd = socket(PF_INET, SOCK_STREAM, 0);

    struct hostent *he;
    he = gethostbyname("localhost");

    if(!he)
        return;

    struct sockaddr_in addr;
    addr.sin_family = AF_INET;
    addr.sin_port = htons(port);
    addr.sin_addr = *((struct in_addr *)he->h_addr);
    memset(addr.sin_zero, 0, sizeof(addr.sin_zero));

    connect(serverfd, (struct sockaddr *)&addr, sizeof(struct sockaddr));

    if (init(argc, argv, WIDTH, HEIGHT))
        return EXIT_FAILURE;

    glutDisplayFunc(display);
    glutReshapeFunc(reshape);
    glutKeyboardFunc(keyboard);
    glutMouseFunc(mouse);

    glutMainLoop();

    return EXIT_SUCCESS;
}
