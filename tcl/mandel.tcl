proc mandelbrot { a b } {
    set za $a
    set zb $b

    for {set i 0} {$i < 128} {incr i} {
        set zaa [expr $za * $za >> 10]
        set zbb [expr $zb * $zb >> 10]

        if {$zaa + $zbb > 4096} {
            return $i
        }

        set zb [expr $za * $zb / 512 + $b]
        set za [expr $zaa - $zbb + $a]
    }

    return 128
}

puts P2
puts "1024 1024"
puts 256
for {set y 0} {$y < 1024} {incr y} {
    set b [expr 2048 - ($y << 2)]

    for {set x 0} {$x < 1024} {incr x} {
        set a [expr -2048 + ($x << 2)]
        set i [mandelbrot $a $b]
        set c [expr 256 - ($i << 1)]

        puts -nonewline "$c "
    }
}
