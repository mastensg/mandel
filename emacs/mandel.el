(defun mandel-pixel (ca cb)
  (setq za ca)
  (setq zb cb)
  (setq zaa (ash (* za za) -10))
  (setq zbb (ash (* zb zb) -10))

  (setq i 1)

  (while (and (< (+ zaa zbb) 4096)
          (< i 128))

    (setq zb (+ (ash (* za zb) -9) cb))
    (setq za (+ (- zaa zbb) ca))

    (setq zaa (ash (* za za) -10))
    (setq zbb (ash (* zb zb) -10))

    (setq i (+ i 1)))

  i)

(defun mandelbrot ()
  (let ((h 64)
    (w 128))

    (setq y 0)

    (while (< y h)
      (setq x 0)

      (while (< x w)
    (let* ((ca (+ -2048 (lsh x 5)))
           (cb (-  2048 (lsh y 6)))
           (i (mandel-pixel ca cb)))
      (insert (if (> i 100) "#" ".")))
    (setq x (+ x 1)))
      (insert "\n")
      (setq y (+ y 1)))))

(mandelbrot)
