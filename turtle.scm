;;; turtle.scm
(module turtle
  *
  ;; (get-width get-height white black blue red green pi rgb

  ;;            create-turtles clear-all
  ;;            ask
  ;;            forward left right kill pendown penup set-slot!
  ;;            start redraw clear-canvas end
  ;;            id-of x-of y-of heading-of width-of pendown-of
  ;;            *width* *height* turtles   )
  ;; 
  (import scheme chicken srfi-1 extras)
  (use ezxdisp coops)
  (define turtles '())
  (define *canvas* #f)
  (define *width* 0)
  (define *height* 0)
  (define (get-width)
    *width*)
  (define (get-height)
    *height*)

  (define white (make-ezx-color 1 1 1))
  (define black (make-ezx-color 0 0 0))
  (define red (make-ezx-color 1 0 0))
  (define green (make-ezx-color 0 1 0))
  (define blue (make-ezx-color 0 0 1))
  (define pi (acos -1))
  (define (rgb r g b)
    (make-ezx-color (/ r 255.) (/ g 255.) (/ b 255.)))
  (define (deg2rad deg)
    (* (/ deg 180) pi))

  (define-class <turtle> ()
    ((color initform: (rgb (random 256) (random 256) (random 256))
            accessor: color-of)
     (width initform: 2
            accessor: width-of)
     (pendown initform: #f
              accessor: pendown-of)
     (x initform: (/ *width* 2)
        accessor: x-of)
     (y initform: (/ *height* 2)
        accessor: y-of)
     (heading initform: (random 360)
              accessor: heading-of)
     (identifier accessor: id-of)))
  
  (define inner-turtle-counter ;turtlesの数を管理する sicpで手に入れた知識
    (let ((count -1))
      (define (inc-count!)
        (set! count (+ count 1))
        count)
      (define (dec-count!)
        (when (> count 0)
          (set! count (- count 1)))
        count)
      (define (clear-count!)
        (set! count 0)
        count)
      (define (get-count)
        count)
      (define (dispatch m)
        (cond ((eq? m 'inc) (inc-count!))
              ((eq? m 'dec) (dec-count!))
              ((eq? m 'clear) (clear-count!))
              ((eq? m 'get) (get-count))
              (else (error "Unknown operator: DISPATCH" m))))
      dispatch))

  
  (define (create-turtle #!key
                         (x (/ *width* 2)) (y (/ *height* 2)) (heading (random 360))
                         (pendown #f) 
                         (width 2) (color (rgb (random 255) (random 255) (random 255))))    
    (let ((new-turtle (make <turtle>
                        'x x 'y y 'heading heading 'pendown pendown
                        'identifier (inner-turtle-counter 'inc)
                        'width width 'color color)))
      (set! turtles (cons new-turtle turtles))))
  (define (copy t #!key
                (x (x-of t)) (y (y-of t)) (heading (heading-of t))
                (pendown (pendown-of t)) 
                (width (width-of t)) (color (color-of t)))    
    (let ((new-turtle (make <turtle>
                        'x x 'y y 'heading heading 'pendown pendown
                        'identifier (inner-turtle-counter 'inc)
                        'width width 'color color)))
      (set! turtles (cons new-turtle turtles))))

  
  (define (create-turtles number)
    (define (inner count lst)
      (cond ((zero? count) lst)
            (else (inner (sub1 count)
                         (cons (make <turtle>
                                 'identifier (inner-turtle-counter 'inc))
                               lst)))))
    (set! turtles (inner number turtles))
    #t)

  (define (clear-all)
    (inner-turtle-counter 'clear)
    (set! turtles '())
    (clear-canvas)
    #t)

  

  ;; メインとなるマクロ  -------------------------------------------------
  (define-syntax ask
    (syntax-rules (with)
      ((_ name proc)
       (begin (turtle-ask* name proc)
              #t))
      ((_ name proc with pred)
       (begin (turtle-ask-with* name proc pred)
              #t))))
  
  ;; versions which break hygiene to assign to 'self'
  (define-syntax turtle-ask*
    (ir-macro-transformer
     (lambda (expr inject compare)
       (let ((name (cadr expr))
             (proc (caddr expr)))
         `(begin (for-each (lambda (,(inject 'self)) ,proc)
                           ,name)
                 (redraw))))))

  (define-syntax turtle-ask-with*
    (ir-macro-transformer
     (lambda (expr inject compare)
       (let ((name (cadr expr))
             (proc (caddr expr))
             (pred (cadddr expr)))
         `(begin (for-each (lambda (,(inject 'self)) ,proc)
                           (filter (lambda (,(inject 'self)) ,pred)
                                   ,name)))))))
  
  ;; ask内で用いるturlteへの命令
  ;; killはちょっと工夫したというか無理やり
  ;; ここではcoopsのdefine-methodマクロを使っているが
  ;; ユーザー定義関数でも何の問題もない(はず)
  (define-generic (forward <turtle> num))
  (define-generic (left <turtle> num))
  (define-generic (right <turtle> num))
  (define-generic (kill <turtle>))
  (define-generic (pendown <turtle>))
  (define-generic (penup <turtle>))
  (define-generic (set-slot! <turtle> <procedure> val))

  ;; ここで描画しちゃうか
  (define-method (forward (t <turtle>) (num #t))
    (let* ((rad (deg2rad (- (heading-of t) 90)))
           (old-x (x-of t))
           (old-y (y-of t))
           (tmp-x (+ old-x (* (cos rad) num)))
           (tmp-y (+ old-y (* (sin rad) num)))
           (new-x (cond ((< *width* tmp-x) (set! old-x 0) 0)
                        ((< tmp-x 0) (set! old-x *width*) *width*)
                        (else tmp-x)))
           (new-y (cond ((< *height* tmp-y) (set! old-y 0) 0)
                        ((< tmp-y 0) (set! old-y *height*) *height*)
                        (else tmp-y))))
      (when (pendown-of t)
        (ezx-line-2d *canvas*
                     old-x old-y
                     new-x new-y (color-of t) (width-of t)))
      (set! (x-of t) new-x)
      (set! (y-of t) new-y)))
  (define-method (left (t <turtle>) (num #t))
    (set! (heading-of t) (let ((tmp (- (heading-of t) num)))
                          (if (> tmp 0)
                              tmp
                              (+ tmp 360)))))
  (define-method (right (t <turtle>) (num #t))
    (set! (heading-of t) (let ((tmp (+ (heading-of t) num)))
                          (if (< tmp 360)
                              tmp
                              (- tmp 360)))))
  (define-method (pendown (t <turtle>))
    (set! (pendown-of t) #t))
  (define-method (penup (t <turtle>))
    (set! (pendown-of t) #f))
  (define-method (kill (t <turtle>))
    (let ((id (id-of t)))
      (set! turtles
            (remove (lambda (x) (eq? id (id-of x))) turtles))))
  (define-method (set-slot! (t <turtle>) (accessor <procedure>) (val #t))
    (set! (accessor t) val))

  



  ;;描画 ------------------------------------------------------------
  ;; (start-canvas width height)
  (define-syntax start
    (syntax-rules ()
      ((_ width height)
       (begin (if *canvas* (end))
              (set! *canvas* (ezx-init width height "turtle graphics"))
              (set! *width* width)
              (set! *height* height)
              (clear-all)
              #t))))
  (define (redraw)
    (ezx-redraw *canvas*))
  (define (clear-canvas)
    (ezx-wipe *canvas*)
    (redraw))
  (define (end)
    (clear-all)
    (ezx-quit *canvas*)
    (set! *canvas* #f))
  
  )
