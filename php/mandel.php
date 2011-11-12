#!/usr/bin/env php
<?
function putchar($c) {
    printf("%c", $c);
}

function mandelbrot($ca, $cb) {
    global $w;
    global $h;

    $za = $ca;
    $zb = $cb;

    for($i = 0; $i < 128; ++$i) {
        $zaa = $za * $za;
        $zbb = $zb * $zb;

        if($zaa + $zbb > 4)
            return $i;

        $zb = 2 * $za * $zb + $cb;
        $za = $zaa - $zbb + $ca;
    }

    return 127;
}

$w = 1920;
$h = 1200;

putchar(0); // id length
putchar(0); // color map type
putchar(2); // image type
putchar(0); // first entry index
putchar(0);
putchar(0); // color map length
putchar(0);
putchar(0); // color map entry size
putchar(0); // x origin
putchar(0);
putchar($h % 256); // y origin
putchar($h / 256);
putchar($w % 256); // y origin
putchar($w / 256);
putchar($h % 256); // y origin
putchar($h / 256);
putchar(24); // pixel depth
putchar(32); // image descriptor

for($y = 0; $y < $h; ++$y) {
    $b = 2.0 - 4.0 * $y / $h;

    for($x = 0; $x < $w; ++$x) {
        $a = -2.0 + 4.0 * $x / $w;

        $i = 256 - 2 * mandelbrot($a, $b);

        putchar($i);
        putchar($i);
        putchar($i);
    }
}
?>
