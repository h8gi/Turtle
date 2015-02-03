(use turtle)

(define (tree b-length b-deg n)
  (cond ((zero? n) #t)
        (else (ask turtles (begin (forward self b-length)
                                  (copy self heading: (- (heading-of self) b-deg))
                                  (right self b-deg)))
              (tree b-length b-deg (sub1 n)))))
;;; draw tree 
(start 600 400)
(create-turtles 1)
(ask turtles (set! (heading-of self) 0))
(ask turtles (set! (y-of self) (sub1 *height*)))
(ask turtles (pendown self))
(tree 40 10 10)
(sleep 2)
(clear-all)

;;; draw spiral
(define (1/x x)
  (/ x))
(define (sp-rad x)
  (* 90. (1/x x)))
(define (spiral self proc step depth #!optional (turn right))
  (define (inner x depth)
    (cond ((zero? depth) #t)
          (else (forward self step)
                (turn self (proc x))
                (inner (+ x step) (sub1 depth)))))
  (inner 1 depth))

(create-turtles 1)
(ask turtles (pendown self))
(ask turtles (spiral self sp-rad 0.2 5000))
(sleep 2)
(clear-all)

(define (star self len)
  (do ((x 5 (sub1 x)))
      ((zero? x) #t)
    (forward self len)
    (right self 144)))
(create-turtles 10)
(ask turtles
     (begin (forward self (random 50))
            (pendown self)))
(ask turtles (star self 100))



