all: m

mandel: mandel.asm
	fasm $^ $@

mandel.lzma: mandel
	@lzma -f -k mandel

m: m.sh mandel.lzma
	@cat m.sh mandel.lzma > m
	@chmod +x m

clean:
	@rm -f mandel mandel.lzma m
