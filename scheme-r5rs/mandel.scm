(define (mandelbrot-iter ca cb za zb i)
  (let ((zaa (* za za))
        (zbb (* zb zb)))

    (if (or (> i 127)
            (> (+ zaa zbb) 4))

      i
      (mandelbrot-iter ca
                       cb
                       (+ (- zaa zbb) ca)
                       (+ (* 2 za zb) cb)
                       (+ i 1)))))

(define (mandelbrot ca cb)
  (mandelbrot-iter ca cb ca cb 0))

(define (putchar c)
  (display (integer->char c)))

(define (putshort s)
  (putchar (modulo s 256))
  (putchar (quotient s 256)))

(define (putpixel w h x y)
  (let ((a (+ -2 (* 4 (/ x w))))
        (b (- 2 (* 4 (/ y h)))))

    (let ((p (* 2 (mandelbrot a b))))
          (putchar p)
          (putchar p)
          (putchar p))))

(define (putline-iter w h x y)
  (putpixel w h x y)
  (if (< x (- w 1))
    (putline-iter w h (+ x 1) y)
    0))

(define (putline w h y)
  (putline-iter w h 0 y))

(define (putimage-iter w h y)
  (putline w h y)
  (if (< y (- h 1))
    (putimage-iter w h (+ y 1))
    0))

(define (putimage w h)
  (putimage-iter w h 0))

(let ((w 1024) (h 1024))
  (putchar 0) ; id length
  (putchar 0) ; color map type
  (putchar 2) ; image type
  (putshort 0) ; first entry index
  (putshort 0) ; color map length
  (putchar 0) ; color map entry size
  (putshort 0) ; x origin
  (putshort h) ; y origin
  (putshort w) ; width
  (putshort h) ; height
  (putchar 24) ; pixel depth
  (putchar 32) ; image descriptor
  (putimage w h))

(exit)
