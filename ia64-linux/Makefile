.SUFFIXES: .m .s .o .bin

.m.s:
	m4 $^ >$@

.s.o:
	$(CC) -mlp64 -g -c $^

.o.bin:
	$(CC) -mlp64 -g -o $@ $^

all: mandel mandel.s
