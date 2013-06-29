let size = 1024

let sizeMSB = size / 256
let sizeLSB = size mod 256

let header = [
    0      ;   (* id length             *)
    0      ;   (* color map type        *)
    2      ;   (* image type            *)
    0      ;   (* first entry index     *)
    0      ;
    0      ;   (* color map length      *)
    0      ;
    0      ;   (* color map entry size  *)
    0      ;   (* x origin              *)
    0      ;
    sizeLSB;   (* y origin              *)
    sizeMSB;
    sizeLSB;   (* width                 *)
    sizeMSB;
    sizeLSB;   (* height                *)
    sizeMSB;
    24     ;   (* pixel depth           *)
    32     ;   (* image descriptor      *)
]

let rec mandelbrot ca cb za zb i =
    let zaa = (za * za) lsr 10
    and zbb = (zb * zb) lsr 10 in

    if zaa + zbb > 4 lsl 10 || i >= 127 then
        i
    else
        mandelbrot ca cb (zaa - zbb + ca) ((za * zb) asr 9 + cb) (i + 1)

let putchar = output_byte stdout

let _ =
    List.map putchar header;

    for y = 0 to size - 1 do
        let b = 2 lsl 10 - y lsl 2 in

        for x = 0 to size - 1 do
            let a = -2 lsl 10 + x lsl 2 in
            let c = 255 - (mandelbrot a b a b 0) lsl 2 in

            putchar c;
            putchar c;
            putchar c;
        done
    done
