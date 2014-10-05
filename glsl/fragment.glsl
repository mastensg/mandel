uniform vec2 center;
uniform float zoom;

varying vec2 coord;

void
main(void)
{
    float p;
    int i;
    vec2 c, z, zz;

    c = zoom * 2.0 * (coord + center);

    z = c;

    for (i = 0; i < 127; ++i)
    {
        zz = z * z;

        if (4.0 < zz.x + zz.y)
            break;

        z.y = 2.0 * z.x * z.y + c.y;
        z.x = zz.x - zz.y + c.x;
    }

    //p = 1.0 - 1.0 / float(i);
    p = zz.x + zz.y;
    p = 1.0 / p;
    p = 1.0 - p;

    gl_FragColor = vec4(p, p, p, 1.0);
}
