#!/usr/bin/perl -w

sub putuint8 {print chr($_[0] % 256);}
sub putuint16_le {putuint8($_[0] % 256); putuint8($_[0] / 256);}

$w = 1280;
$h = 1024;

putuint8(0); # id length
putuint8(0); # color map type
putuint8(2); # image type
putuint16_le(0); # first entry index
putuint16_le(0); # color map length
putuint8(0); # color map entry size
putuint16_le(0); # x origin
putuint16_le($h); # y origin
putuint16_le($w); # width
putuint16_le($h); # height
putuint8(24); # pixel depth
putuint8(32); # image descriptor

$a_pitch = 3.5 / $w;
$b_pitch = -2. / $h;

$pf = 1024;

$b = 1;
for($y = 0; $y < $h; ++$y) {
    $a = -2.5;
    for($x = 0; $x < $w; ++$x) {
        $ca = $a * $pf;
        $cb = $b * $pf;

        $za = $ca;
        $zb = $cb;

        for($i = 127; $i > 0; --$i) {
            if($za * $za / $pf + $zb * $zb / $pf > 4 * $pf) {
                last;
            }

            $na = $za * $za / $pf - $zb * $zb / $pf;
            $zb = 2 * $za * $zb / $pf + $cb;
            $za = $na + $ca;
        }

        $i *= 2;

        putuint8($i);
        putuint8($i);
        putuint8($i);

        $a += $a_pitch;
    }

    $b += $b_pitch;
}
