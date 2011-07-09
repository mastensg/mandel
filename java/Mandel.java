import java.nio.*;
import java.lang.Math;

class Mandel {
    public static double cabs(double[] z) {
        double a = z[0];
        double b = z[1];

        return Math.sqrt(a * a + b * b);
    }

    public static double[] cpow2(double[] z) {
        double a = z[0];
        double b = z[1];

        double[] y = new double[2];
        y[0] = a * a - b * b;
        y[1] = 2 * a * b;

        return y;
    }

    public static double[] cadd(double[] z, double[] x) {
        double a = z[0];
        double b = z[1];

        double c = x[0];
        double d = x[1];

        double[] y = new double[2];
        y[0] = a + c;
        y[1] = b + d;

        return y;
    }

    public static int mandelbrot(double[] c) {
        int max = 100;

        double[] z = new double[2];
        z[0] = c[0];
        z[1] = c[1];

        for(int i = 0; i < 128; ++i) {
            if(cabs(z) > max)
                return (128 - i);

            z = cadd(cpow2(z), c);
        }

        return 0;
    }

    public static double[] transform(int x, int y, int width, int height) {
        double[] z = new double[2];
        z[0] = -2.5 + 3.5 * x / width;
        z[1] = 1 - 2. * y / height;

        return z;
    }

    public static void main(String[] args) {
        int width = 1280;
        int height = 1024;

        int headerlen = 18;
        byte[] header = new byte[headerlen];

        header[0] = 0; // id length
        header[1] = 0; // color map type
        header[2] = 2; // image type
        header[3] = 0; // first entry index
        header[4] = 0;
        header[5] = 0; // color map length
        header[6] = 0;
        header[7] = 0; // color map entry size
        header[8] = 0; // x origin
        header[9] = 0;
        header[10] = (byte)(height % 256); // y origin
        header[11] = (byte)(height / 256);
        header[12] = (byte)(width % 256); // width
        header[13] = (byte)(width / 256);
        header[14] = (byte)(height % 256); // height
        header[15] = (byte)(height / 256);
        header[16] = 24; // pixel depth
        header[17] = 32; // image descriptor

        System.out.print(new String(header));

        for(int y = 0; y < height; ++y) {
            for(int x = 0; x < width; ++x) {
                double[] c = transform(x, y, width, height);
                int m = mandelbrot(c);
                byte n = (byte)(2 * m);
                System.out.write(n);
                System.out.write(n);
                System.out.write(n);
            }
        }

        System.out.flush();
    }
}
