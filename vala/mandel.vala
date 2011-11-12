class Demo.HelloWorld : GLib.Object {
    public static int main() {
        var w = 1920;
        var h = 1200;

        stdout.putc((char)0);
        stdout.putc((char)0);
        stdout.putc((char)2);
        stdout.putc((char)0);
        stdout.putc((char)0);
        stdout.putc((char)0);
        stdout.putc((char)0);
        stdout.putc((char)0);
        stdout.putc((char)0);
        stdout.putc((char)0);
        stdout.putc((char)(h % 256));
        stdout.putc((char)(h / 256));
        stdout.putc((char)(w % 256));
        stdout.putc((char)(w / 256));
        stdout.putc((char)(h % 256));
        stdout.putc((char)(h / 256));
        stdout.putc((char)24);
        stdout.putc((char)32);

        for(var y = 0; y < h; ++y) {
            var b = 2.0 - 4.0 * y / h;

            for(var x = 0; x < w; ++x) {
                var a = -2.0 + 4.0 * x / w;

                var za = a;
                var zb = b;

                var i = 0;
                for(i = 0; i < 127; ++i) {
                    var zaa = za * za;
                    var zbb = zb * zb;

                    if(zaa + zbb > 4)
                        break;

                    zb = 2 * za * zb + b;
                    za = zaa - zbb + a;
                }

                i = 256 - 2 * i;

                stdout.putc((char)i);
                stdout.putc((char)i);
                stdout.putc((char)i);
            }
        }
        return 0;
    }
}
