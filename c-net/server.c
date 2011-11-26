#include <arpa/inet.h>
#include <err.h>
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <unistd.h>

static const int port = 8164;

static uint8_t
mandelbrot(double ca, double cb, int maxiter) {
    double za = ca;
    double zb = cb;

    int i;
    for(i = 0; i < maxiter; ++i) {
        puts("y");
        double zaa = za * za;
        double zbb = zb * zb;

        if(zaa + zaa > 4)
            return i;

        zb = 2 * za * zb + cb;
        za = zaa - zbb + ca;
    }

    return i;
}

static void
mandelline(uint8_t *buf, size_t buflen, double b, double mina, double maxa, int maxiter) {
    double da = (maxa - mina) / buflen;

    for(int x = 0; x < buflen; ++x) {
        puts("x");
        double a = mina + x * da;
        buf[x] = mandelbrot(a, b, maxiter);
    }
}

int
main(int argc, char *argv[]) {
    int listenfd;
    if((listenfd = socket(PF_INET, SOCK_STREAM, 0)) == -1)
        err(EXIT_FAILURE, "socket");

    struct sockaddr_in address;
    address.sin_family = AF_INET;
    address.sin_addr.s_addr = INADDR_ANY;
    address.sin_port = htons(port);
    if(bind(listenfd, (struct sockaddr *)&address, sizeof(address)) == -1)
        err(EXIT_FAILURE, "bind");

    if(listen(listenfd, 16) == -1)
        err(EXIT_FAILURE, "listen");

    for(;;) {
        struct sockaddr_in addr;

        socklen_t addrlen = sizeof(addr);

        int clientfd = accept(listenfd, (struct sockaddr *)&addr , &addrlen);

        puts("hello");

        int talking = 1;
        while(talking) {
            uint8_t buf[1024];
            int numbytes;

            if((numbytes = read(clientfd, buf, sizeof(buf))) == 0)
                break;

            buf[numbytes] = '\0';

            puts("hmm...");
            double b, mina, maxa;
            if(sscanf((char *)buf, "%lf %lf %lf\n", &b, &mina, &maxa) != 3)
                continue;

            mandelline(buf, sizeof(buf), b, mina, maxa, 128);
            write(clientfd, buf, sizeof(buf));
        }

        puts("goodbye");

        close(clientfd);
    }

    return EXIT_SUCCESS;
}
