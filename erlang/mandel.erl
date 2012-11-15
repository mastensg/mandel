-module(mandel).
-export([writer/2, calculator/3, main/0]).

mandelbrot(Z) ->
    mandelbrot(0, Z, Z).

mandelbrot(I, _, _) when I >= 127 ->
    I;
mandelbrot(I, {Za, Zb}, {Ca, Cb}) ->
    Zaa = Za * Za bsr 10,
    Zbb = Zb * Zb bsr 10,

    if
        Zaa + Zbb > 4096 ->
            I;
        true ->
            mandelbrot(I + 1, {Zaa - Zbb + Ca, (Za * Zb bsr 9) + Cb}, {Ca, Cb})
    end.

write(Lines, Width, Height) ->
    Header = << 0, 0, 2, 0:16/little, 0:16/little, 0,
                0:16/little, Height:16/little, Width:16/little, Height:16/little, 24, 32 >>,

    Iterations = lists:flatten([I || {_, I} <- lists:reverse(lists:sort(Lines))]),

    Pixels = << <<I:8, I:8, I:8>> || I <- Iterations >>,

    io:format(<<Header/binary, Pixels/binary>>),

    init:stop().

writer(Width, Height) ->
    writer(Width, Height, [], 1).

writer(Width, Height, Lines, N) ->
    receive
        Line ->
            Newlines = [Line | Lines],

            if
                N == Height ->
                    write(Newlines, Width, Height);
                true ->
                    writer(Width, Height, Newlines, N + 1)
            end
    end.

calculator(Width, Writer, B) ->
    As = [-2048 + (X bsl 2) || X <- lists:seq(0, Width - 1)],
    Zs = [{A, B} || A <- As],
    Iterations = [255 - 2 * mandelbrot(Z) || Z <- Zs],

    Writer ! {B, Iterations}.

main() ->
    Width = 1024,
    Height = 1024,

    Writer = spawn(mandel, writer, [Width, Height]),

    Bs = [2048 - (Y bsl 2) || Y <- lists:seq(0, Height - 1)],

    [spawn(mandel, calculator, [Width, Writer, B]) || B <- Bs].
