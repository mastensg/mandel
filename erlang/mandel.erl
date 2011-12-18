-module(mandel).
-export([mandelbrot/1, main/1]).

cadd({Ar, Ai}, {Br, Bi}) ->
    {Ar + Br, Ai + Bi}.

cpow2({Re, Im}) ->
    {Re * Re - Im * Im, 2 * Re * Im}.

mandelbrot(Z) ->
    mandelbrot(0, Z, Z).

mandelbrot(I, {Re, Im}, _) when I >= 127 orelse Re * Re + Im * Im >= 4 ->
    I;
mandelbrot(I, Z, C) ->
    mandelbrot(I + 1, cadd(cpow2(Z), C), C).

main(_) ->
    Width = 1024,
    Height = 1024,

    As = [-2 + 4 * X / Width || X <- lists:seq(0, Width - 1)],
    Bs = [2 - 4 * Y / Width || Y <- lists:seq(0, Height - 1)],

    Zs = [{A, B} || B <- Bs, A <- As],

    Iterations = [255 - 2 * mandelbrot(Z) || Z <- Zs],

    Header = <<
                0,
                0,
                2,
                0:16/little,
                0:16/little,
                0,
                0:16/little,
                Height:16/little,
                Width:16/little,
                Height:16/little,
                24,
                32
                >>,

    Pixels = << <<I:8, I:8, I:8>> || I <- Iterations >>,

    io:format(<<Header/binary, Pixels/binary>>).
