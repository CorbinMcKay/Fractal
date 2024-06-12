#lang racket
;----------------------------------------------------------------------------------------------------------------------------
; Corbin McKay
;
; Requirements
; Write code in racket that creates a series of images that zoom into a part of your fractal image.
; The end fram should be some window that image that is 1.0e-12 wide
; The animation should contain 600 images.
; Convert the images to a video using blender
;----------------------------------------------------------------------------------------------------------------------------

(require racket/draw)  ; graphics library
(require colors)       ; colors library

(define imageWidth 2048) ; image size
(define imageHeight 1152)

(define target (make-bitmap imageWidth imageHeight)) ; A bitmap
(define dc (new bitmap-dc% [bitmap target])) ; a drawing context

(send dc set-brush (make-color 0 0 0) 'solid)  ; draw background
(send dc draw-rectangle
      0 0   
      imageWidth imageHeight)


(define myPolygon (new dc-path%)) ; create myPolygon
(send myPolygon move-to 20 0)
(send myPolygon line-to 12 28)
(send myPolygon line-to 20 36)
(send myPolygon line-to 28 28)
(send myPolygon close)


; function to keep hsv values within range 0-.999
(define (check-hsv n)
  (if (< n 0)
      0.999
      (if (> n 0.999)
      0
      n)))

; function to make sequential file names
(define (makeoutputname testnum prefix) ; only good up to 999
  (let ((suffix 
  (cond
    [(< testnum 10) (format "00~v.png" testnum)]
    [(< testnum 100) (format "0~v.png" testnum)]
    [ (format "~v.png" testnum)])))
    (string-append prefix suffix)))


(define outName (makeoutputname 0  "testImage"))

;(send target save-file outName 'png) ; save image as png 

; draw polygon function; translates screen world coordinates
(define (drawToScreen myPolygon xScale yScale)
  (send myPolygon scale xScale yScale)
  (send myPolygon translate 1024 576)
  ; ran into issue with background changing color, struggled until realizing its probably a polygon that got so massive that it took over as being the background
  ; the easiest/laziest solution I could think of was to prevent drawing polygons that are capable of being the size of the screen, probably couldve chosen a lower value and saved more runtime, but I already fully ran the program
  (if (> (polyWidth myPolygon) imageWidth) 
      (begin
        (send myPolygon translate -1024 -576)        ; if massive skip drawing it, scale and translate back
        (send myPolygon scale (/ 1 xScale) (/ 1 yScale)))
      (begin                                        ; else, procede normally. Draw polygon, and revert translation and scaling
        (send dc draw-path myPolygon)
        (send myPolygon translate -1024 -576)
        (send myPolygon scale (/ 1 xScale) (/ 1 yScale)))))



; function to retrieve smallest polygon     
(define (polySize inpoly)
  (define-values (l t w h) (send inpoly get-bounding-box))
  (printf "bounding box: ~v ~v ~v ~v. \n" l t w h)
  (max w h))

; functions to retrieve width and height of polygon
(define (polyWidth inpoly)
  (define-values (l t w h) (send inpoly get-bounding-box))
  w)
(define (polyHeight inpoly)
  (define-values (l t w h) (send inpoly get-bounding-box))
  h)

; set random seed to maintain the same image. It was fun to go through all the seeds and see how much my fractal could vary
(random-seed 50)


; function to give direction changes
; I noticed translate -x -y shifts up-left, -x y down-left, x -y up-right, x y down-right
; by using this on xTran and yTran during triggered events, direction can be randomly changes to one of these four direction.
(define (random-trans x)
  (if (> (random) .75)
      (* x -1)
      x))


; fractal imagine function
(define (myFractal myPolygon counter rotation h s v xTran yTran xScale yScale)
  (if (= counter 0)
      (polySize myPolygon)   ; display smallest polygon when finished
      (begin
        ; scale, motion, rotate, change color, draw
        (send myPolygon scale 0.999 0.999)
        (send myPolygon translate (* xTran (polyWidth myPolygon)) (* yTran (polyHeight myPolygon)) )
        (send myPolygon rotate rotation)
        (send dc set-pen (hsv->color (hsv h s v)) 2 'solid)
        (send dc set-brush (hsv->color (hsv h s v)) 'solid)
        (drawToScreen myPolygon xScale yScale)
         ; a random number is used to give a half percent change of shifting rotation and direction during every function call
        (if (< (random) 0.005)   
            (myFractal myPolygon (- counter 1) (* rotation -1) (check-hsv (+ h .003)) (check-hsv (- s .001)) (check-hsv(+ v 0.001))
                       (random-trans xTran) (random-trans yTran) xScale yScale)
            (myFractal myPolygon (- counter 1) rotation (check-hsv (+ h .003)) (check-hsv (- s .001)) (check-hsv(+ v 0.001)) xTran yTran xScale yScale)))))



; function to create sequence of zoomed in images
(define (myZoomSequence myPolygon)
  (for ([i 600])
     ; ex) original image bounds for x is +-6, the new bounds for a 0.5 zoom are +-3. 6/3 = scale of 2. The next bounds would be +-1.5, resulting in a scale of 6/1.5 = 4... then 6/.75 = 8, and so on.
     ; the scale for each image can be calculated by using powers of 2, with iteration i as the exponent.
     ; Edit: Zooming by 0.5, I reached my last polygon by frame 107; After tinkering with the numbers, I found zooming by ~0.88125 to be the sweet spot
    (let ([xScale (expt (/ 1280 1128) i)]  
          [yScale (expt (/ 1280 1128) i)]
          [imageName (makeoutputname i  "myImage")])
      ; re-draw background
      (send dc set-brush (make-color 0 0 0) 'solid)  
      (send dc draw-rectangle
            0 0   
            imageWidth imageHeight)
      ; reset and re-initialize polygon
      (send myPolygon reset)
      (send myPolygon move-to 20 0)
      (send myPolygon line-to 12 28)
      (send myPolygon line-to 20 36)
      (send myPolygon line-to 28 28)
      (send myPolygon close)
      (send myPolygon scale 4 4)
      (send myPolygon translate 512 288)
      ; re-call the random seed to reset it so that the same fractal image is maintained
      (random-seed 50)
      ; calling fractal function, with new world bounds
      (myFractal myPolygon 75000 0.7 .444 1 .5 .25 -.25 xScale yScale)
      (send target save-file imageName 'png)
      (send dc clear)
      )))
      
          



; Call this and wait an eternity for images. 
(myZoomSequence myPolygon)


