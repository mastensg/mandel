all: m

mandel: mandel.asm
	fasm $^ $@

mandel.lzma: mandel
	@lzma -f -k mandel

m: m.sh mandel.lzma
	@cat m.sh mandel.lzma > m
	@chmod +x m
	@echo -n "size of m: "
	@stat -c %s m

clean:
	@rm -f mandel mandel.lzma m
