(defn putchar [c]
      (-> (System/out) (.write (int c))))

(defn mandelbrot [ca cb]
      (def za ca)
      (def zb cb)
      (def zaa (* za za))
      (def zbb (* zb zb))

      (def i 127)
      (while (and (< (+ zaa zbb) 4) (> i 0))
             (def zb (+ (* 2 za zb) cb))
             (def za (+ (- zaa zbb) ca))

             (def zaa (* za za))
             (def zbb (* zb zb))

             (def i (dec i)))
      i)

(def w 1920)
(def h 1200)

(putchar 0) ; id length
(putchar 0) ; color map type
(putchar 2) ; image type
(putchar 0) ; first entry index
(putchar 0)
(putchar 0) ; color map length
(putchar 0)
(putchar 0) ; color map entry size
(putchar 0) ; x origin
(putchar 0)
(putchar (mod h 256)) ; y origin
(putchar (/ h 256))
(putchar (mod w 256)) ; width
(putchar (/ w 256))
(putchar (mod h 256)) ; height
(putchar (/ h 256))
(putchar 24) ; pixel depth
(putchar 32) ; image descriptor

(loop [y 0]
      (let [b (float (- 2 (* 4 (/ (float y) h))))]
        (loop [x 0]
              (let [a (float (+ -2 (- (/ w h)) (* 4 (/ (float x) w) (/ w h))))]
                (let [v (* 2 (mandelbrot a b))]
                  (putchar v)
                  (putchar v)
                  (putchar v)))
              (if (< x (dec w))
                (recur (inc x)))))
      (if (< y (dec h))
        (recur (inc y))))
