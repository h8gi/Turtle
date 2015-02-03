#turtle
chicken-scheme用のシンプルなタートルグラフィックスライブラリです
##Usage
```scheme
(use turtle)
```
##Requirements
[ezxdisp](http://wiki.call-cc.org/eggref/4/ezxdisp "ezxdisp")  
ちょっとしたグラフィックをいじるのにちょうどいいeggです  
とても重宝しています  
[coops](http://wiki.call-cc.org/eggref/4/coops "coops")  

##Reference
### start
[syntax]  
```scheme
(start width height)
```  
描画用キャンバスのサイズを指定します  
###end
[procedure]
```scheme
(end)
```
キャンバスを閉じます  
###clear-canvas
[procedure]
```scheme
(clear-canvas)
```
キャンバスをクリアします  
### create-turtle
[procedure]  
```scheme
(create-turtle)
```  
引数に
### create-turtles
[procedure]  
```scheme
(create-turtles number)
```
指定された数の亀をつくります  
### clear-all
[procedure]  
```scheme
(clear-all)
```  
亀を殺してキャンバスをクリアします  
### ask
[syntax]  
```scheme
(ask turtles expr)  
(ask turtles expr1 with expr2)  
```  
exprの中には亀がselfとして渡されます  
with以降の式は条件指定です  
pythonの気持ちが少しわかったように思います  
```scheme
(ask turtles (forward self 10) with (> (t-x self) (/ *width* 2)))
```  

##----[procedures for ask]----  
#### forward
#### left
#### right
#### die
#### pendown
#### penup
#### set-slot!
#### copy
##----[accessors]----  
#### color-of
#### width-of
#### pendown-of
#### x-of
#### y-of
#### heading-of
#### id-of


## Examples

```scheme
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
```



```scheme
    (use turtle)
    
    (define (tree b-length b-deg n)
      (cond ((zero? n) #t)
            (else (ask turtles (begin (forward self b-length)
                  (copy self heading: (- (t-heading self) b-deg))
                  (right self b-deg)))
                  (tree b-length b-deg (sub1 n)))))
    ;;; draw tree 
    (start 600 400)
    (create-turtles 1)
    (ask turtles (set! (t-heading self) 0))
    (ask turtles (set! (t-y self) (sub1 *height*)))
    (ask turtles (pendown self))
    (tree 40 10 10)
    (sleep 5)
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
    (ask turtles (spiral self sp-rad 0.3 5000))
    (sleep 5)
    (end)
```


