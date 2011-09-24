(defn mandelbrot [ca cb]
    (def za ca)
    (def zb cb)
    (def zaa 0)
    (def zbb 0)

    (def i 127)
    (def j i)
    (while (> i 0)
        (def zaa (* za za))
        (def zbb (* zb zb))

        (if (< (+ zaa zbb) 4)
            (def j (- j 1)))

        (def zb (+ (* 2 za zb) zb))
        (def za (+ (- zaa zbb) ca))

        (def i (- i 1)))

    j)

(def w 1024)
(def h 768)

(def w 256)
(def h 256)

(print (char 0))
(print (char 0))
(print (char 2))
(print (char 0))
(print (char 0))
(print (char 0))
(print (char 0))
(print (char 0))
(print (char 0))
(print (char 0))
(print (char (mod h 256)))
(print (char (/ h 256)))
(print (char (mod w 256)))
(print (char (/ w 256)))
(print (char (mod h 256)))
(print (char (/ h 256)))
(print (char 24))
(print (char 32))

(doseq [y (range 0 h)]
    (let [b (- 1 (* 2 (/ y (float h))))]
        (doseq [x (range 0 w)]
            (let [a (+ -2.5 (* 3.5 (/ x (float w))))]
                (let [v (mandelbrot a b)]
                    (print (char v))
                    (print (char v))
                    (print (char v)))))))
