#!/usr/bin/env lua

local bit = require("bit")
local lshift = bit.lshift

local width = 1024
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

local function mandelbrot(ca, cb)
    local arshift = bit.arshift
    local za = ca
    local zb = cb

    for i = 1, 128 do
        local zaa = arshift(za * za, 10)
        local zbb = arshift(zb * zb, 10)

        if zaa + zaa > 4096 then
            return i
        end

        zb = arshift(za * zb, 9) + cb
        za = zaa - zbb + ca
    end

    return 128
end

io.write(header)

for y = 1, height do
    local b = 2048 - lshift(y, 2)

    for x = 1, width do
        local a = -2048 + lshift(x, 2)
        local v = 256 - 2 * mandelbrot(a, b)

        io.write(string.char(v, v, v))
    end
end
