require 'viewmat'

m =: 3 : 0
    z=.y
    c=.z
    o=.0*z
    for_i. i. 127 do.
        z=.c+*:z*3>|z
        o=.o+2<|z
    end.
    o
)

s=.1000
l=.(2$s)$((i.s)-s%2)%s%4
viewmat m l+|:j.l
