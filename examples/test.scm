(use turtle miscmacros)

(start 600 400)

(create-turtles 5)

(define (draw-sikaku self n)
  (repeat 4
          (forward self n)
          (right self 90)))
(define (wiggle self n)
  (repeat n
          (right self (random 50))
          (left self (random 50))
          (forward self 3)))

(ask turtles (begin (pendown self) (draw-sikaku self 100)))

(ask turtles (wiggle self 200))


