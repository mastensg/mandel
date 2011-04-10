#!/usr/bin/env lua

local width = 1280
local height = 1024
local header = string.char(
0, -- id length
0, -- color map type
2, -- image type
0, -- first entry index
0,
0, -- color map length
0,
0, -- color map entry size
0, -- x origin
0,
math.mod(height, 256), -- y origin
height / 256,
math.mod(width, 256), -- width
width / 256,
math.mod(height, 256), -- height
height / 256,
24, -- pixel depth
32 -- image descriptor
)

function cabs(z)
    local a = z[1]
    local b = z[2]

    return math.sqrt(a * a + b * b)
end

function cpow2(z)
    local a = z[1]
    local b = z[2]

    return {a * a - b * b, 2 * a * b}
end

function cadd(z, x)
    local a = z[1]
    local b = z[2]

    local c = x[1]
    local d = x[2]

    return {a + c, b + d}
end

function mandelbrot(c)
    local max = 100

    local z = c

    for i = 0, 255 do
        if cabs(z) > max then
            return 255 - i
        end

        z = cadd(cpow2(z), c)
    end

    return 0
end

function transform(x, y)
    local a = -2.5 + 3.5 * x / width
    local b = 1 - 2. * y / height

    return {a, b}
end

function write_pixel(n)
    local s = string.char(n, n, n)
    io.write(s)
end

io.write(header)

for y = 1, height do
    for x = 1, width do
        local c = transform(x, y)
        local n = mandelbrot(c)
        write_pixel(n)
    end
end

