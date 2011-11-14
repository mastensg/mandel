function mandelbrot(ca, cb) {
    var za = ca;
    var zb = cb;

    for(var i = 0; i < 128; ++i) {
        var zaa = za * za;
        var zbb = zb * zb;

        if(zaa + zbb > 4)
            return i;

        zb = 2 * za * zb + cb;
        za = zaa - zbb + ca;
    }

    return 127;
}

var w = 51;
var h = 51;

for(var y = 0; y < h; ++y) {
    var b = 2 - 4 * y / h;

    var l = "";
    for(var x = 0; x < w; ++x) {
        var a = -2 + 4 * x / w;

        var i = mandelbrot(a, b);
        if(i == 127)
            l += "*";
        else
            l += " ";
    }

    console.log(l);
}
