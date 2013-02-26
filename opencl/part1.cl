__kernel void part1(__global float *a, __global float *b, __global unsigned int *c)
{
    unsigned int i = get_global_id(0);

    unsigned int pf = 1024;
    unsigned int ca = a[i] * pf;
    unsigned int cb = b[i] * pf;
    unsigned int za = ca;
    unsigned int zb = cb;

    c[i] = 0;
    for(unsigned int j = 127; j < 128; --j) {
        if(za * za / pf + zb * zb / pf > 4 * pf) {
            c[i] = 2 * j;
            break;
        }

        int na = za * za / pf - zb * zb / pf;
        zb = 2 * za * zb / pf + cb;
        za = na + ca;
    }
}
