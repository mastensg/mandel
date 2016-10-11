CFLAGS  = -Wall -pedantic -std=c99 -O3 -march=native -mtune=native
LDADD = -lm

all: mandel

mandel: mandel.c
	$(CC) $(CFLAGS) -o $@ $< $(LDADD)

clean:
	rm -f $(BINARY).o $(BINARY)
