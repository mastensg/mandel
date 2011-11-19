: w 1024 ;
: h 1024 ;

: metadata ( -- )
    0 emit ( id length )
    0 emit ( color map type )
    2 emit ( image type )
    0 emit ( first entry index )
    0 emit
    0 emit ( color map length )
    0 emit
    0 emit ( color map entry size )
    0 emit ( x origin )
    0 emit
    h 256 mod emit ( y origin )
    h 256 / emit
    w 256 mod emit ( x size )
    w 256 / emit
    h 256 mod emit ( y size )
    h 256 / emit
    24 emit ( pixel depth )
    32 emit ( image descriptor )
;

: dn 1024 / ;
: up 1024 * ;

variable ca
variable cb
variable za
variable zb
variable zaa
variable zbb

: mandelbrot ( a b -- i )
    dup cb ! zb !
    dup ca ! za !

    129 0 do
        i 127 > if i leave then

        za @ dup * dn zaa !
        zb @ dup * dn zbb !

        zaa @ zbb @ + 2 up dup * > if i leave then

        za @ zb @ * dn 2 * cb @ + zb !
        zaa @ zbb @ - ca @ + za !
    loop
;

: xtoa ( x -- a ) up 4 * w / -2 up + ;
: ytob ( y -- b ) up -4 * h / 2 up + ;
: xytoab ( x y -- a b ) ytob swap xtoa swap ;

: putpixel ( v -- ) dup dup emit emit emit ;

: render ( -- ) h 0 do w 0 do i j xytoab mandelbrot dup + 256 swap - putpixel loop loop ;

metadata
render

bye
