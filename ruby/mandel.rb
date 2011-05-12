#!/usr/bin/env ruby

require "complex"

w = 1024
h = 768

header = [
        0, # id_length
        0, # color_map_type
        2, # image_type
        0, # first_entry_index
        0, #
        0, # color_map_length
        0, #
        0, # color_map_entry_size
        0, # x_origin
        0, #
        h % 256, # y_origin
        h / 256, #
        w % 256, # image_width
        w / 256, #
        h % 256, # image_height
        h / 256, #
        24, # pixel_depth
        32, # image_descriptor
        ]

def write ary
    str = ary.pack "c" * ary.length
    $stdout.write str
end

def mandelbrot c
    z = c

    i = 127
    i.times do
        return i if z.abs > 3

        z = z * z + c

        i -= 1
    end

    i
end

p = []
for y in 0...h
    b = 1 - 2.0 * y / h

    for x in 0...w
        a = -2.5 + 3.5 * x / w
        c = Complex a, b
        i = mandelbrot c
        i *= 2
        p << i << i << i
    end
end

write header + p
