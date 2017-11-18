;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname q1) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
;; q1.rkt
(require rackunit)
(require "extras.rkt")
(require 2htdp/universe)
(require 2htdp/image)

(provide
 animation
 initial-world
 world-after-tick
 world-after-key-event
 world-after-mouse-event
 world-paused?
 world-doodads-star
 world-doodads-square
 doodad-x
 doodad-y
 doodad-vx
 doodad-vy
 doodad-color
 doodad-age
 doodad-selected?)

(check-location "05" "q1.rkt")

;;;           DATA DEFINITION

;; Color is one of
;; -- Gray
;; -- OliveDrab
;; -- Khaki
;; -- Orange
;; -- Crimson
;; -- Gold
;; -- Green
;; -- Blue

;; color-fn : Color -> ??
;; (define (color-fn c)
;; (cond
;; [(string=? c "Gray") ...]
;; [(string=? c "OliveDrab") ...]
;; [(string=? c "Khaki") ...]
;; [(string=? c "Orange") ...]
;; [(string=? c "Crimson") ...]
;; [(string=? c "Gold") ...]
;; [(string=? c "Green") ...]
;; [(string=? c "Blue") ...])) 

;; Type is one of
;; -- star
;; -- string

;; type-fn : Type -> ??
;; (define (type-fn t)
;; (cond
;; [(string=? t "Star") ...]
;; [(string=? t "Square") ...]))

(define-struct doodad (age type x y vx vy mx my w h color selected?))
;; A Doodad is a
;; (make-doodad Int Type Int Int Int Int Color Boolean)
;; Interpretation:
;; age is the age of the doodad since its creation. Counted in
;; terms of no of ticks in the given animation
;; type is the type of doodad image, which is either a radial
;; star or a square image. It is one of two strings "star" or "square"
;; x and y are the center co-ordinates of the given doodad image moving
;; around in the animation.
;; vx and vy are the velocities with which the given doodad image moves
;; in the respective x and y directions
;; mx and my are the x and y co-ordinates
;; of mouse events that we keep track of
;; in case the doodads are dragged by the users.
;; w and h are the width and height of the doodad image

;; selected? gives an indication whether the doodad has been
;; selected by the mouse or not
;; template:
;; doodad-fn : Doodad -> ??
#|
(define (doodad-fn d)
 (... (doodad-age d)
   (doodad-type d)
   (doodad-x d)
   (doodad-y d) 
   (doodad-vx d)
   (doodad-vy d)
   (doodad-mx d)
   (doodad-my d)
   (doodad-w d)
   (doodad-h d)
   (doodad-color d)
   (doodad-selected? d))
|#

;; A ListOfDoodads (LOD) is either
;; -- empty
;; -- (cons Doodad LOD)

;; lod-fn : ListofDoodad -> ??
;; (define (lod-fn lod)
;;   (cond
;;     [(empty? lod) ...]
;;     [else (...
;;             (first lod))
;;             (lod-fn (rest lod)))]))


(define-struct world (doodads-star doodads-square star-counter
                                   sq-counter paused?)) 
;; A World is a
;; (make-world ListofDoodads ListofDoodads PosInt PosInt Boolean)
;; Interpretation: 
;; doodads-star and doodads-square are the 2 types of
;; doodads moving around. The total no in the scene of the animation
;; come under the umbrella of the world through lists
;; star-counter represents the count of new star doodads created
;; by pressing the t key
;; sq-counter represents the count of new square doodads
;; created by pressing the q key 
;; paused? describes whether or not the scene is paused.

;; template:
;; world-fn : World -> ??
#|
(define (world-fn w)
 (... (world-doodads-star w)
   (world-doodads-square w)
   (world-star-counter w)
   (world-sq-counter w)
   (world-paused? w)))
|#

;;;  GRAPHICAL CONSTANTS DEFINITION

;; define the width of the animation canvas
(define CANVAS-WIDTH  601)

;; define the height of the animation canvas
(define CANVAS-HEIGHT  449)

;; define the velocity in x direction of star doodad
(define STAR-XVELOCITY 10)

;; define the negated x component velocity of star doodad
(define NSTAR-XVELOCITY -10)

;; define the position in x direction of star doodad
(define STAR-XPOSITION 125)

;; define the velocity in y direction of star doodad
(define STAR-YVELOCITY 12)

;; define the negated y component velocity of star doodad
(define NSTAR-YVELOCITY -12)

;; define the position in y direction of star doodad
(define STAR-YPOSITION 120)

;; define the width of given radial star doodad image
(define STAR-WIDTH 91)

;; define the height of given radial star doodad image
(define STAR-HEIGHT 91)

;; define the velocity in x direction of square doodad
(define SQUARE-XVELOCITY -13)

;; define the negated x component velocity of square doodad
(define NSQUARE-XVELOCITY 13)

;; define the position in x direction of square doodad
(define SQUARE-XPOSITION 460)

;; define the velocity in y direction of square doodad
(define SQUARE-YVELOCITY -9)

;; define the negated y component velocity of square doodad
(define NSQUARE-YVELOCITY 9)

;; define the position in y direction of square doodad
(define SQUARE-YPOSITION 350)

;; define the width of given square doodad image
(define SQUARE-WIDTH 71)

;; define the height of given square doodad image
(define SQUARE-HEIGHT 71)

;; Defines an empty canvas used to create a scene
(define EMPTY-CANVAS (empty-scene CANVAS-WIDTH CANVAS-HEIGHT))

;; A list of possibilities for adding a star doodad 
;; according to the number of times t has been
;; pressed, in a cycle of 4 possibilites

(define LIST-STAR
  (list (make-doodad 0 "star"
                     STAR-XPOSITION STAR-YPOSITION
                     NSTAR-YVELOCITY STAR-XVELOCITY
                     0 0
                     STAR-WIDTH STAR-HEIGHT
                     "Gold" false)
        (make-doodad 0 "star"
                     STAR-XPOSITION STAR-YPOSITION
                     NSTAR-XVELOCITY NSTAR-YVELOCITY
                     0 0
                     STAR-WIDTH STAR-HEIGHT
                     "Gold" false)
        (make-doodad 0 "star"
                     STAR-XPOSITION STAR-YPOSITION
                     STAR-YVELOCITY NSTAR-XVELOCITY
                     0 0
                     STAR-WIDTH STAR-HEIGHT
                     "Gold" false)
        (make-doodad 0 "star"
                     STAR-XPOSITION STAR-YPOSITION
                     STAR-XVELOCITY STAR-YVELOCITY
                     0 0
                     STAR-WIDTH STAR-HEIGHT
                     "Gold" false)))         

;; A list of possibilities of adding a square doodad 
;; according to the number of times t has been
;; pressed, in a cycle of 4 possibilites

(define LIST-SQUARE
  (list (make-doodad 0 "square"
                     SQUARE-XPOSITION SQUARE-YPOSITION
                     NSQUARE-YVELOCITY SQUARE-XVELOCITY
                     0 0
                     SQUARE-WIDTH SQUARE-HEIGHT
                     "Gray" false)
        (make-doodad 0 "square"
                     SQUARE-XPOSITION SQUARE-YPOSITION
                     NSQUARE-XVELOCITY NSQUARE-YVELOCITY
                     0 0
                     SQUARE-WIDTH SQUARE-HEIGHT
                     "Gray" false)
        (make-doodad 0 "square"
                     SQUARE-XPOSITION SQUARE-YPOSITION
                     SQUARE-YVELOCITY NSQUARE-XVELOCITY
                     0 0
                     SQUARE-WIDTH SQUARE-HEIGHT
                     "Gray" false)
        (make-doodad 0 "square"
                     SQUARE-XPOSITION SQUARE-YPOSITION
                     SQUARE-XVELOCITY SQUARE-YVELOCITY
                     0 0
                     SQUARE-WIDTH SQUARE-HEIGHT
                     "Gray" false)))
  

;;;   FUNCTION DEFINITION

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; c-event-doodad: Doodad -> Doodad
;; GIVEN: A doodad d
;; RETURNS: The doodad that should follow
;; after a 'c' key event, if the doodad has been selected
;; EXAMPLES: 
;; (c-event-doodad
;;  (first (world-doodads-square color-world1))) =
;;  (first (world-doodads-square color-world1-new))
;; STRATEGY: Make use of color-in-bounce function
;; to update the color variable

(define (c-event-doodad d)
 (make-doodad (doodad-age d)
              (doodad-type d)
              (doodad-x d) (doodad-y d)
              (doodad-vx d) (doodad-vy d)
              (doodad-mx d) (doodad-my d)         
              (doodad-w d) (doodad-h d) 
              (color-in-bounce d) (doodad-selected? d)))

;; age-doodad: Doodad -> Doodad
;; GIVEN: A doodad d
;; RETURNS: A doodad with the age increased
;; by 1 to reflect a tick
;; EXAMPLES: 
;; (age-doodad selected-square-doodad-at-20-90)
;; = age-square-doodad-at-20-90 
;; STRATEGY: simple function composition
;; to update the age variable

(define (age-doodad d)
 (make-doodad (+ 1 (doodad-age d))
              (doodad-type d)
              (doodad-x d) (doodad-y d)
              (doodad-vx d) (doodad-vy d)
              (doodad-mx d) (doodad-my d)         
              (doodad-w d) (doodad-h d) 
              (doodad-color d) (doodad-selected? d)))

;; new-doodad: Doodad String String -> Doodad
;; GIVEN: A Doodad d and String s1 and s2
;; RETURNS: A Doodad that has been updated
;; according to the state of world-after-tick
;; The strings s1 and s2 can be one of 
;; these strings: "A", "B", "C" 
;; WHERE:
;; "A" represents the valid condition where the tentative 
;; co-ordinate is within the constraints
;; "B" represents the case where the tentative co-ordinate 
;; exceeds the canvas height/width according to x or y
;; "C" represents the condition where the tentative 
;; co ordinate becomes negative
;; EXAMPLES: See tests for doodad-after-tick
;; STRATEGY: Use the itemization data for if conditional
;; and call upon helper function accordingly

(define (new-doodad d s1 s2)
 (if (and (string=? s1 "A")
          (string=? s2 "A"))
  (make-doodad
  (+ 1 (doodad-age d)) (doodad-type d)
  (tentative-x d s1) (tentative-y d s2)
  (new-vx d s1) (new-vy d s2)
  (doodad-mx d) (doodad-my d)
  (doodad-w d) (doodad-h d)
  (doodad-color d) (doodad-selected? d))
  (make-doodad
  (+ 1 (doodad-age d)) (doodad-type d)
  (tentative-x d s1) (tentative-y d s2)
  (new-vx d s1) (new-vy d s2)
  (doodad-mx d) (doodad-my d)
  (doodad-w d) (doodad-h d)
  (color-in-bounce d) (doodad-selected? d))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; animation : PosReal -> World
;; GIVEN: the speed of the animation, in seconds per tick
;;     (so larger numbers run slower)
;; EFFECT: runs the animation, starting with the initial world as
;;     specified in the problem set
;; RETURNS: the final state of the world
;; EXAMPLES:
;;     (animation 1) runs the animation at normal speed
;;     (animation 1/4) runs at a faster than normal speed
;;STRATEGY: Make use of big-bang library function to incorporate a world

(define (animation tick)
  (big-bang (initial-world 0)
            (on-tick world-after-tick tick)
            (on-draw world-to-scene)
            (on-key world-after-key-event)
            (on-mouse world-after-mouse-event)))

;; initial-world : Any -> World
;; GIVEN: any value (ignored)
;; RETURNS: the initial world specified for the animation
;; EXAMPLE: (initial-world -174)
;; STRATEGY: Use the template of Doodad to initialise the
;; parameters to begin the animation

(define (initial-world initial-pos)
  (make-world
   (cons (make-doodad 0 "star"
                      STAR-XPOSITION STAR-YPOSITION
                      STAR-XVELOCITY STAR-YVELOCITY
                      0 0
                      STAR-WIDTH STAR-HEIGHT "Gold" false)
         empty)
   (cons (make-doodad 0 "square"
                      SQUARE-XPOSITION SQUARE-YPOSITION
                      SQUARE-XVELOCITY SQUARE-YVELOCITY
                      0 0
                      SQUARE-WIDTH SQUARE-HEIGHT "Gray" false)
         empty)
   0 0
   false))

(begin-for-test
  (check-equal?
   (initial-world -174)
  (make-world
   (cons (make-doodad 0 "star"
                      STAR-XPOSITION STAR-YPOSITION
                      STAR-XVELOCITY STAR-YVELOCITY
                      0 0
                      STAR-WIDTH STAR-HEIGHT "Gold" false)
         empty)
   (cons (make-doodad 0 "square"
                      SQUARE-XPOSITION SQUARE-YPOSITION
                      SQUARE-XVELOCITY SQUARE-YVELOCITY
                      0 0
                      SQUARE-WIDTH SQUARE-HEIGHT "Gray" false)
         empty)
   0 0
   false)
  "Retrun the same world"))

;; world-after-tick : World -> World
;; GIVEN: any World that's possible for the animation
;; RETURNS: the World that should follow the given World
;; after a tick
;; EXAMPLES:  doodads moving around:
;; (world-after-tick unpaused-world-at-20) = unpaused-world-at-20-after-tick
;; doodads paused:
;; (world-after-tick paused-world-at-20) = paused-world-at-20
;; STRATEGY: Use template for World on w and make use of helper functions

(define (world-after-tick w)
  (if (world-paused? w)
      (make-world
       (update-age (world-doodads-star w)) 
       (update-age (world-doodads-square w)) 
       (world-star-counter w)
       (world-sq-counter w)
       (world-paused? w))
      (make-world
       (doodad-after-tick (world-doodads-star w)) 
       (doodad-after-tick (world-doodads-square w)) 
       (world-star-counter w)
       (world-sq-counter w)      
       (world-paused? w))))

(begin-for-test
  (check-equal?
    (world-after-tick
     paused-world-at-20)
    paused-world-at-20-after-tick
    "Age not proper!")
  (check-equal?
    (world-after-tick
     unpaused-world-at-20)
    unpaused-world-at-20-after-tick
    "Age not proper!"))

;; update-age : ListofDoodads -> ListofDoodads
;; GIVEN: A list of Doodads, either star doodads
;; or square doodads
;; RETURNS: the set of doodads with updated age
;; oomponent for all of them even when the world is paused
;; EXAMPLES:  doodads moving around:
;; (world-after-tick unpaused-world-at-20) = unpaused-world-at-20-after-tick
;; doodads paused:
;; (world-after-tick paused-world-at-20) = paused-world-at-20
;; STRATEGY: Use HOF map and age-doodad helper function on
;; ListofDoodads

#;(define (update-age d) 
 (cond
   [(empty? d) empty] 
   [else (cons (age-doodad (first d))
         (update-age (rest d)))])) 

(define (update-age d)
  (map age-doodad d))
  
;; doodad-after-tick : ListofDoodads -> ListofDoodads
;; GIVEN: the state of list of doodads d
;; RETURNS: the state of the given list of doodads  
;; after a tick if it were in an unpaused world.
;; INTERPRETATION:
;; The state of doodads after a tick depends on
;; a list of conditions that are to be satisfied for
;; the doodad to move to a valid next state
;; EXAMPLES: see tests below
;; STRATEGY: Use HOF map and helper function
;; update-doodad-tick on ListofDoodads

#;(define (doodad-after-tick d) 
  (cond
    [(empty? d) empty]
    [else
     (cons (update-doodad-tick (first d))
           (doodad-after-tick (rest d)))]))


(define (doodad-after-tick d) 
  (cond
    [(empty? d) empty]
    [else
     (map update-doodad-tick d)]))

(begin-for-test
  (check-equal?
    (doodad-after-tick (list selected-square-doodad-at-20-90))
    (list age-square-doodad-at-20-90)
    "selected doodad shouldn't move")
  (check-equal? 
    (doodad-after-tick (list unselected-star-doodad-at-20-40))
    (list age-star-doodad-at-30-52)
    "unselected Doodad should move by Vx and Vy pixels and remain unselected")
   (check-equal? 
    (doodad-after-tick (list unselected-square-doodad-at-5-9))
    (list n-square-doodad-at-8-0)
    "unselected Doodad should move by Vx and Vy pixels and remain unselected")
  (check-equal? 
    (doodad-after-tick (list unselected-star-doodad-at-598-445))
    (list new-star-doodad-at-592-439)
    "unselected Doodad should move by Vx and Vy pixels and remain unselected")
  (check-equal?
    (doodad-after-tick empty)
      empty
    "List should be empty!")
  (check-equal? 
    (doodad-after-tick (list unselected-square-doodad-at-100-8))
    (list tick-square-doodad-at-87-1)
    "unselected Doodad should move by Vx and Vy pixels and remain unselected")
  (check-equal? 
    (doodad-after-tick (list unselected-square-doodad-at-8-8))
    (list tick-square-doodad-at-5-1)
    "unselected Doodad should move by Vx and Vy pixels and remain unselected")
  (check-equal? 
    (doodad-after-tick (list unselected-star-doodad-at-595-100))
    (list tick-star-doodad-at-595-112)
    "unselected Doodad should move by Vx and Vy pixels and remain unselected")
  (check-equal? 
    (doodad-after-tick (list unselected-star-doodad-at-595-8))
    (list tick-star-doodad-at-595-4)
    "unselected Doodad should move by Vx and Vy pixels and remain unselected")
  (check-equal? 
    (doodad-after-tick (list unselected-square-doodad-at-8-100))
    (list tick-square-doodad-at-5-91)
    "unselected Doodad should move by Vx and Vy pixels and remain unselected")
  (check-equal? 
    (doodad-after-tick (list unselected-square-doodad-at-8-445))
    (list tick-square-doodad-at-5-442)
    "unselected Doodad should move by Vx and Vy pixels and remain unselected")
  (check-equal? 
    (doodad-after-tick (list unselected-square-doodad-at-20-445))
    (list tick-square-doodad-at-7-442)
    "unselected Doodad should move by Vx and Vy pixels and remain unselected")  
  )

;; update-doodad-tick Doodad -> Doodad
;; GIVEN: A Doodad d
;; RETURNS: the state of the given doodad  
;; after a tick if it were in an unpaused world.
;; WHERE: The state of doodad after a tick depends on
;; a list of conditions that are to be satisfied for
;; the doodad to move to a valid next state
;; INTERPRETATION:
;; Make use of the itemization defined in the tentative-x
;; tentative-y functions as a base and provide the new doodad
;; with updated variables after tick
;; "A" represents the valid condition where the tentative 
;; x/y co-ordinate is within the constraints
;; "B" represents the case where the tentative x/y co-ordinate 
;; exceeds the canvas width
;; "C" represents the condition where the tentative x/y
;; co ordinate becomes negative
;; EXAMPLES:
;; Doodad selected:
;; (update-doodad-tick selected-square-doodad-at-20-90) 
;;                   =selected-square-doodad-at-20-90
;; Doodad paused:
;; (update-doodad-tick unselected-star-doodad-at-20-40)
;;                   = unselected-star-doodad-at-30-52
;; STRATEGY: Make use of conditionals and pass status
;; of itemization data given in the interpretation above
;; to make a doodad acoording to required variables

(define (update-doodad-tick d)
 (cond
   [(doodad-selected? d)
    (age-doodad d)]
   [(and (string=? (doodad-x-in-scene d) "A")
         (string=? (doodad-y-in-scene d) "A"))
    (new-doodad d "A" "A")] 
   [(and (string=? (doodad-x-in-scene d) "A")
         (string=? (doodad-y-in-scene d) "B"))
    (new-doodad d "A" "B")]       
   [(and (string=? (doodad-x-in-scene d) "A")
         (string=? (doodad-y-in-scene d) "C"))
    (new-doodad d "A" "C")]
   [(and (string=? (doodad-x-in-scene d) "B")
         (string=? (doodad-y-in-scene d) "A"))
    (new-doodad d "B" "A")]
   [(and (string=? (doodad-x-in-scene d) "B")
         (string=? (doodad-y-in-scene d) "B"))
    (new-doodad d "B" "B")]
   [(and (string=? (doodad-x-in-scene d) "B")
         (string=? (doodad-y-in-scene d) "C"))
    (new-doodad d "B" "C")]
   [(and (string=? (doodad-x-in-scene d) "C")
         (string=? (doodad-y-in-scene d) "A"))
    (new-doodad d "C" "A")]
   [(and (string=? (doodad-x-in-scene d) "C")
         (string=? (doodad-y-in-scene d) "B"))
    (new-doodad d "C" "B")]
   [(and (string=? (doodad-x-in-scene d) "C")
         (string=? (doodad-y-in-scene d) "C"))
    (new-doodad d "C" "C")]))
   
;; new-vx: Doodad String -> Doodad
;; GIVEN: A Doodad d and String s
;; RETURNS: A Doodad that has been updated
;; according to the state of world-after-tick
;; The strings s can be one of 
;; these strings: "A", "B", "C" 
;; WHERE:
;; "A" represents the valid condition where the tentative 
;; x co-ordinate is within the constraints
;; "B" represents the case where the tentative x co-ordinate 
;; exceeds the canvas width
;; "C" represents the condition where the tentative x
;; co ordinate becomes negative
;; EXAMPLES:
;; STRATEGY:

(define (new-vx d s)
  (cond
    [(string=? s "A") (doodad-vx d)]
    [else (- 0 (doodad-vx d))]))

;; new-vy: Doodad String -> Doodad
;; GIVEN: A Doodad d and String s
;; RETURNS: A Doodad that has been updated
;; according to the state of world-after-tick
;; The strings s can be one of 
;; these strings: "A", "B", "C" 
;; WHERE:
;; "A" represents the valid condition where the tentative 
;; y co-ordinate is within the constraints
;; "B" represents the case where the tentative y co-ordinate 
;; exceeds the canvas height
;; "C" represents the condition where the tentative y
;; co ordinate becomes negative
;; EXAMPLES:
;; STRATEGY:

(define (new-vy d s)
  (cond
    [(string=? s "A") (doodad-vy d)]
    [else (- 0 (doodad-vy d))]))

;; doodad-x-in-scene : Doodad -> String
;; GIVEN: A doodad d
;; RETURNS: A string which describes the state of the x co-ordinate 
;; of the doodad to check for the core bounce condition.
;; The string can be one of 3 strings: "A", "B", "C" 
;; WHERE:
;; "A" represents the valid condition where tentative x
;; co-ordinate is within the constraints
;; "B" represents the case where the tentative x co-ordinate 
;; exceeds the canvas width
;; "C" represents the condition where the tentative x 
;; co ordinate becomes negative
;; EXAMPLES: 
;; (doodad-x-in-scene selected-square-doodad-at-7-81) = "C"
;; (doodad-x-in-scene
;;    selected-star-doodad-at-595-100) = "B"
;; STRATEGY: use template for Doodad on d and make use of
;; logic functions to match the conditional expressions

(define (doodad-x-in-scene d)
  (cond [(and (>= (+ (doodad-x d) (doodad-vx d)) 0)
              (< (+ (doodad-vx d) (doodad-x d)) CANVAS-WIDTH)) "A"]
        [(>= (+ (doodad-vx d) (doodad-x d)) CANVAS-WIDTH) "B"]
        [(< (+ (doodad-x d) (doodad-vx d)) 0) "C"]))

(begin-for-test
  (check-equal?
    (doodad-x-in-scene selected-square-doodad-at-7-81)
    "C"
    "It should fall in range of the given x constraints")

  (check-equal? 
    (doodad-x-in-scene selected-star-doodad-at-595-100)
    "B"
    "It will be at the right end of the given x constraints")
  )

;; doodad-y-in-scene : Doodad -> String
;; GIVEN: A doodad d
;; RETURNS: A string which describes the state of the y co-ordinate 
;; of the doodad to check for the core bounce condition.
;; The string can be one of 3 strings: "A", "B", "C" 
;; WHERE:
;; "A" represents the valid condition where tentative y
;; co-ordinate is within the constraints
;; "B" represents the case where the tentative y co-ordinate 
;; exceeds the canvas height
;; "C" represents the condition where the tentative y 
;; co ordinate becomes negative
;; EXAMPLES: 
;; (doodad-y-in-scene selected-square-doodad-at-7-81) = "A"
;; (doodad-y-in-scene
;;    unselected-square-doodad-at-100-8) = "C"
;; STRATEGY: use template for Doodad on d and make use of
;; logic functions to match the conditional expressions

(define (doodad-y-in-scene d)
  (cond [(and (>= (+ (doodad-y d) (doodad-vy d)) 0)
              (< (+ (doodad-vy d) (doodad-y d)) CANVAS-HEIGHT)) "A"]
        [(>= (+ (doodad-vy d) (doodad-y d)) CANVAS-HEIGHT) "B"]
        [(< (+ (doodad-y d) (doodad-vy d)) 0) "C"]))

(begin-for-test
  (check-equal?
    (doodad-y-in-scene selected-square-doodad-at-7-81)
    "A"
    "It should fall in range of the given y constraints")

  (check-equal? 
    (doodad-y-in-scene unselected-square-doodad-at-100-8)
    "C"
    "It will be at the top end of the given y constraints")
  )

;; tentative-x : Doodad String -> Integer
;; GIVEN: A Doodad d and a String s 
;; RETURNS: A positive integer that gives the tentative 
;; position of the doodad in the x-direction.
;; INTERPRETATION:
;; The string can be one of 3 strings: "A", "B", "C" 
;; "A" represents the valid condition where tentative x
;; co-ordinate is within the constraints
;; "B" represents the case where the tentative x co-ordinate 
;; exceeds the canvas width
;; "C" represents the condition where the tentative x 
;; co ordinate becomes negative
;; EXAMPLES: 
;; STRATEGY: use template for Doodad on d and make use of
;; conditional expressions to match cases on s

(define (tentative-x d s)
  (cond
    [(string=? s "A")
     (+ (doodad-x d) (doodad-vx d))]
    [(string=? s "B")
     (- 1200
        (+ (doodad-x d) (doodad-vx d)))]
    [(string=? s "C")
     (abs (+ (doodad-x d) (doodad-vx d)))]))

(begin-for-test
  (check-equal?
   (tentative-x
    unselected-star-doodad-at-20-40 "A")
    30
    "It should be 30!")
  (check-equal?
   (tentative-x
    selected-square-doodad-at-7-81 "C")
    6
    "It should be 6!")    
  (check-equal?
   (tentative-x
    unselected-star-doodad-at-595-100 "B")
    595
    "It should be 595!"))

;; tentative-y : Doodad String -> Integer
;; GIVEN: A Doodad d and a String s 
;; RETURNS: A positive integer that gives the tentative 
;; position of the doodad in the y-direction.
;; INTERPRETATION:
;; The string can be one of 3 strings: "A", "B", "C" 
;; "A" represents the valid condition where tentative y
;; co-ordinate is within the constraints
;; "B" represents the case where the tentative y co-ordinate 
;; exceeds the canvas height
;; "C" represents the condition where the tentative y 
;; co ordinate becomes negative
;; EXAMPLES: 
;; STRATEGY: use template for Doodad on d and make use of
;; conditional expressions to match cases on s

(define (tentative-y d s)
  (cond
    [(string=? s "A")
     (+ (doodad-y d) (doodad-vy d))]
    [(string=? s "B")
     (- 896
        (+ (doodad-y d) (doodad-vy d)))]
    [(string=? s "C")
     (abs (+ (doodad-y d) (doodad-vy d)))]))

(begin-for-test
  (check-equal?
   (tentative-y
    unselected-star-doodad-at-20-40 "A")
    52
    "It should be 52!")
  (check-equal?
   (tentative-y
    unselected-square-doodad-at-100-8 "C")
    1
    "It should be 1!"))    

;; color-in-bounce : Doodad -> Color
;; GIVEN: A Doodad d
;; RETURNS: A Color which describes the color of the  
;; doodad to be displayed for the core bounce condition,
;; where the string can be one of a total of 8 possible
;; colors: Gray, OliveDrab, Khaki, Orange, Crimson
;; Gold, Green, Blue
;; EXAMPLES: 
;; (color-in-bounce
;;   unselected-square-doodad-at-100-8) = "Orange"
;; (color-in-bounce
;;   selected-star-doodad-at-595-100) = "Blue"
;; STRATEGY: use template for Doodad on d and make use of
;; string compare functions to match the conditional expressions

(define (color-in-bounce d)
  (cond [(string=? (doodad-color d) "Gray") "OliveDrab"]                     
        [(string=? (doodad-color d) "OliveDrab") "Khaki"]                     
        [(string=? (doodad-color d) "Khaki") "Orange"]
        [(string=? (doodad-color d) "Orange") "Crimson"] 
        [(string=? (doodad-color d) "Crimson") "Gray"]
        [(string=? (doodad-color d) "Gold") "Green"]
        [(string=? (doodad-color d) "Green") "Blue"]
        [(string=? (doodad-color d) "Blue") "Gold"])) 

(begin-for-test
  (check-equal?
    (color-in-bounce unselected-square-doodad-at-100-8)
    "Orange"
    "It should Be Orange")

  (check-equal? 
    (color-in-bounce selected-star-doodad-at-595-100)
    "Blue"
    "It should Be Blue")
  (check-equal?
    (color-in-bounce unselected-star-doodad-at-20-40)
    "Green"
    "It should Be Green")
  (check-equal?
    (color-in-bounce selected-square-doodad-at-20-90)
    "Gray"
    "It should Be Gray")
  (check-equal?
    (color-in-bounce new-square-doodad-at-8-0)
    "OliveDrab"
    "It should Be OliveDrab")
  )

;; Sq-Doodad : Color -> Image
;; GIVEN: A Color d-color that describes the color of the doodad
;; RETURNS: an Image of square doodad in the described color
;; Color can be Gray, OliveDrab, Khaki, Orange, Crimson
;; for the Square Doodad
;; EXAMPLE: (Sq-Doodad "Gray") = (square 71 "solid" "Gray")
;; STRATEGY: call the square function to produce a square image 
;; of given dimensions

(define (Sq-Doodad d-color) (square 71 "solid" d-color)) 

(begin-for-test
  (check-equal?
    (Sq-Doodad "Gray") (square 71 "solid" "Gray")
    "Returned incorrect image"))

;; Star-Doodad : Color -> Image
;; GIVEN: A Color d-color that describes the color of the doodad
;; RETURNS: an Image of star doodad in the described color
;; Color can be Gold, Blue or Green
;; for the star doodad
;; EXAMPLE: (Star-Doodad "Gold") = (radial-star 8 10 50 "solid" "Gold")
;; STRATEGY: call the radial-star function to produce a star image of given
;; dimensions

(define (Star-Doodad d-color) (radial-star 8 10 50 "solid" d-color))   

(begin-for-test
  (check-equal?
    (Star-Doodad "Gold") (radial-star 8 10 50 "solid" "Gold")
    "Returned incorrect image"))

; A Circle for identifying mouse pointer in jerkless dragging
(define CIRCLE (circle 3 "solid" "Black"))

;; world-to-scene : World -> Scene
;; GIVEN: a World w
;; RETURNS: a Scene that portrays the given world.
;; EXAMPLE: (world-to-scene paused-world-at-20) should return a canvas with
;; two doodads, one at (20,40) and one at (20,90)
;;          
;; STRATEGY: Use template for World on w and make
;; use of helper functions to place multiple images

(define (world-to-scene w)
  (place-doodad
   (append (world-doodads-star w)
           (world-doodads-square w))
   EMPTY-CANVAS))

(begin-for-test
 (check-equal? 
   (world-to-scene
    (make-world
    (list unselected-star-doodad-at-20-40)
    (list unselected-square-doodad-at-100-8)
    0 0
    false))
   image1-at-20
   "Returned unexpected image")
 )

;; required output to do the testing
(define ST-DOODAD (radial-star 8 10 50 "solid" "Gold"))
(define SQR-DOODAD (square 71 "solid" "Khaki"))

(define image-of-paused-world-at-20
  (place-image ST-DOODAD 20 40
               (place-image SQR-DOODAD 20 90
                            EMPTY-CANVAS)))


;; place-star : Scene Doodad -> Scene
;; RETURNS: a scene like the given one, but with the given 
;; star-doodad painted on it.
;; INTERPRETATION:
;; If the given doodad has been selected, then it returns
;; an image of star overlapped with the circle representing
;; the mouse pointer
;; EXAMPLES: See below tests
;; STRATEGY: Use the doodad template on place image function
;; by using an if conditional

(define (place-star d s)
  (if (doodad-selected? d)
      (place-image CIRCLE (doodad-mx d)
                   (doodad-my d)
                   (place-image (Star-Doodad (doodad-color d))
                                (doodad-x d) (doodad-y d) s))
      (place-image (Star-Doodad (doodad-color d))
                   (doodad-x d) (doodad-y d) s)))     

;; place-square : Scene Doodad -> Scene
;; RETURNS: a scene like the given one, but with the given 
;; square-doodad painted on it.
;; INTERPRETATION:
;; If the given doodad has been selected, then it returns
;; an image of square overlapped with the circle representing
;; the mouse pointer
;; EXAMPLES: See below tests
;; STRATEGY: Use the doodad template on place image function
;; by using an if conditional

(define (place-square d s)
  (if (doodad-selected? d)
      (place-image CIRCLE (doodad-mx d)
                   (doodad-my d)
                   (place-image (Sq-Doodad (doodad-color d))
                                (doodad-x d) (doodad-y d) s))
      (place-image (Sq-Doodad (doodad-color d))
                   (doodad-x d) (doodad-y d) s)))

;; place-doodad : ListofDoodads Scene -> Scene
;; GIVEN: A list of Doodads and a Scene
;; RETURNS: a scene like the given one, but with the given 
;; star and square doodads painted on it.
;; EXAMPLES: See below tests
;; STRATEGY: Use HOF foldr on ListofDoodads 

#;(define (place-doodad d s)
 (cond
  [(empty? d) s]
  [(empty? (rest d))
   (if (string=? (doodad-type (first d)) "star")
   (place-star (first d) s)                                         
   (place-square (first d) s))]                                        
  [else
   (if (string=? (doodad-type (first d)) "star")
       (place-star (first d)                                             
       (place-doodad (rest d) s))
       (place-square (first d)                                              
       (place-doodad (rest d) s)))]))

(define (place-doodad d s)
  (if (empty? d)
      s
      (foldr
       ;; Doodad Scene -> Scene
       ;; RETURNS: the Scene s with the given
       ;; doodad d painted on it.
       ;; The star or square doodad helper function
       ;; is called according to type of d
       (lambda (elt s)
         (if (string=? (doodad-type elt) "star")
             (place-star elt s)
             (place-square elt s)))
        s d)))

;; tests

;;; check this visually to make sure it's what you want
(define image1-at-20 (place-image ST-DOODAD 20 40
                      (place-image SQR-DOODAD 100 8 EMPTY-CANVAS)))

(define image2-at-20 (place-image CIRCLE 20 40 image1-at-20))

(define image3-at-20 (place-image CIRCLE 100 8 image1-at-20))

(define image4-at-20 EMPTY-CANVAS)

;;; note: these only test whether world-to-scene calls place-image properly.
;;; it doesn't check to see whether image-at-20 is the right image!

(begin-for-test
 (check-equal? 
   (place-doodad
    (list unselected-star-doodad-at-20-40 
          unselected-square-doodad-at-100-8) EMPTY-CANVAS)
   image1-at-20
   "Returned unexpected image")
 (check-equal? 
   (place-doodad
    empty EMPTY-CANVAS)
   image4-at-20
   "Should return empty image")
 (check-equal? 
   (place-doodad
    (list selected-star-doodad-at-20-40 
          unselected-square-doodad-at-100-8) EMPTY-CANVAS)
    image2-at-20
    "Returned unexpected Image!")
 (check-equal? 
   (place-doodad
    (list unselected-star-doodad-at-20-40 
          selected-square-doodad-at-100-8) EMPTY-CANVAS)
   image3-at-20
   "Returned unexpecte Image!")
 )  

;; world-after-key-event : World KeyEvent -> World
;; GIVEN: a World w and a KeyEvent kev where the KeyEvents
;; of interest are " ", "c", "t", "q", "." 
;; RETURNS: the world that should follow the given world
;; after the given key events.
;; INTERPRETATION:
;; on space, toggle paused?, on "c" do color change if
;; any of the doodads are selected, on "t", add a new
;; star doodad. on "q", add a new square doodad
;; on ".", delete the oldest doodads from the scene
;;-- ignore all others
;; EXAMPLES: see tests below
;; STRATEGY: Cases on whether the kev is
;; one of the above events

(define (world-after-key-event w kev)
  (cond
    [(key=? kev " ") (world-with-paused-toggled w)]
    [(key=? kev "c") (core-bounce-effect w)]
    [(key=? kev "t") (create-star-doodad w)]
    [(key=? kev "q") (create-sq-doodad w)]
    [(key=? kev ".") (delete-doodads w)]
    [else w]))    

;; delete-doodads: World  -> World
;; GIVEN: a World w 
;; RETURNS: the world that should follow the given world
;; after the given key event ".".
;; INTERPRETATION:
;; on ".", delete the oldest doodads from the scene
;; If there are several doodads with the same age
;; delete all of them. If list is empty, return as is
;; Hence need to check for individual cases
;; and then create a world accordingly
;; EXAMPLES: see tests below
;; STRATEGY: use conditionals. Check if the list of
;; doodads is empty or not and call on the World
;; template accordingly

(define (delete-doodads w)
  (cond
    [(and
      (empty? (world-doodads-star w))
      (empty? (world-doodads-square w)))
     w]
    [(empty? (world-doodads-star w))
     (make-world
      (world-doodads-star w)
      (del-doodad
       (world-doodads-square w)               
       (apply max
              (map doodad-age
                   (world-doodads-square w)))) 
      (world-star-counter w)
      (world-sq-counter w)
      (world-paused? w))]
    [(empty? (world-doodads-square w))
     (make-world
      (del-doodad
       (world-doodads-star w)               
       (apply max
              (map doodad-age
                   (world-doodads-star w))))
      (world-doodads-square w)
      (world-star-counter w)
      (world-sq-counter w)
      (world-paused? w))]
    [else
     (make-world
      (del-doodad
       (world-doodads-star w)               
       (apply max
              (map doodad-age
                   (world-doodads-star w))))
      (del-doodad
       (world-doodads-square w)               
       (apply max
              (map doodad-age
                   (world-doodads-square w)))) 
      (world-star-counter w)
      (world-sq-counter w)
      (world-paused? w))]))

(begin-for-test
  (check-equal?
   (delete-doodads color-world1)
    color-world2
   "It should return proper world")
  (check-equal?
   (delete-doodads
    (make-world
      empty empty
      0 0 false))
    (make-world
      empty empty
      0 0 false)
   "It should return proper world")
  )

;; del-doodad: ListofDoodads PosInt -> ListofDoodads
;; GIVEN: A ListofDoodads l and an PosInt
;; i representing the maximum age in the
;; given list of doodads
;; RETURNS: A ListofDoodads where the doodads
;; matching i have been removed
;; EXAMPLES: see tests below
;; STRATEGY: use HOF filter on ListofDoodads

#;(define (del-doodad d i)       
 (cond
  [(empty? (rest d))
   (if (= i (doodad-age (first d)))
    empty
    d)]
 [else
  (if (= i (doodad-age (first d)))
  (del-doodad (rest d) i)
  (cons (first d)   
  (del-doodad (rest d) i)))]))

(define (del-doodad d i)
 (filter
  ;; Doodad -> Boolean
  ;; RETURNS: True if age of given Doodad
  ;; matches i
  (lambda (elt) (not (= i (doodad-age elt))))
    d))

;; create-star-doodad: World -> World
;; GIVEN: A World on press of "t"
;; KeyEvent
;; RETURNS: A World with a new star doodad
;; given according to the condition of
;; frequency of key event
;; EXAMPLES: see tests below
;; STRATEGY: use World template 
;; add doodad with helper function

(define (create-star-doodad w)
  (make-world
   (add-star (world-doodads-star w) (world-star-counter w))
   (world-doodads-square w)
   (+ 1 (world-star-counter w))
   (world-sq-counter w)
   (world-paused? w)))

(begin-for-test
  (check-equal?
   (create-star-doodad
    (make-world 
    (list unselected-star-doodad-at-20-40
        unselected-star-doodad-at-20-100) 
     (list color-square-doodad-at-20-90
          color-square-doodad-at-7-81)
     1 1 false))
  (make-world
     (list
        (make-doodad 0 "star"
         STAR-XPOSITION STAR-YPOSITION
         NSTAR-XVELOCITY NSTAR-YVELOCITY
         0 0
         STAR-WIDTH STAR-HEIGHT
         "Gold" false)
        unselected-star-doodad-at-20-40
        unselected-star-doodad-at-20-100)
     (list color-square-doodad-at-20-90
           color-square-doodad-at-7-81)
    2 1 false)
  "Nope! Sorry wrong struct!"))

;; add-star: Doodad PosInt -> Doodad
;; GIVEN: A Doodad and a
;; positive integer which corresponds
;; to the counter value stored in the
;; world structure
;; INTERPRETATION:
;; The 1st press of "t" corresponds to
;; 0 and returns first element of the list.
;; The 2nd press of "t" corresponds to
;; 1 and returns first element of the list.
;; The 3rd press of "t" corresponds to
;; 2 and returns first element of the list.
;; The 4th press of "t" corresponds to
;; 3 and returns first element of the list.
;; The 5th occurance of "t" will produce
;; the val 0 and the sequence follows again
;; RETURNS: A doodad according to the
;; frequency of occurance of "t" event
;; of the first element of the list and so
;; on and so forth
;; EXAMPLES: see tests below
;; STRATEGY: Cycle through the combinations
;; by comparing state of val

(define (add-star d val)
  (cond
    [(= (modulo val 4) 0)
     (cons (first LIST-STAR) d)]
    [(= (modulo val 4) 1)
     (cons (second LIST-STAR) d)]
    [(= (modulo val 4) 2)
     (cons (third LIST-STAR) d)]
    [(= (modulo val 4) 3)
     (cons (fourth LIST-STAR) d)]))

(begin-for-test
  (check-equal?
   (add-star
     (list unselected-star-doodad-at-20-40
      unselected-star-doodad-at-20-100) 0)
     (list
        (make-doodad 0 "star"
         STAR-XPOSITION STAR-YPOSITION
         NSTAR-YVELOCITY STAR-XVELOCITY
         0 0
         STAR-WIDTH STAR-HEIGHT
         "Gold" false)
        unselected-star-doodad-at-20-40
        unselected-star-doodad-at-20-100)
     "Wrong structure inserted!")
  (check-equal?
   (add-star
     (list unselected-star-doodad-at-20-40
      unselected-star-doodad-at-20-100) 1)
     (list
        (make-doodad 0 "star"
         STAR-XPOSITION STAR-YPOSITION
         NSTAR-XVELOCITY NSTAR-YVELOCITY
         0 0
         STAR-WIDTH STAR-HEIGHT
         "Gold" false)
        unselected-star-doodad-at-20-40
        unselected-star-doodad-at-20-100)
     "Wrong structure inserted!")
  (check-equal?
   (add-star
     (list unselected-star-doodad-at-20-40
      unselected-star-doodad-at-20-100) 2)
     (list
        (make-doodad 0 "star"
         STAR-XPOSITION STAR-YPOSITION
         STAR-YVELOCITY NSTAR-XVELOCITY
         0 0
         STAR-WIDTH STAR-HEIGHT
         "Gold" false)
        unselected-star-doodad-at-20-40
        unselected-star-doodad-at-20-100)
     "Wrong structure inserted!")
  (check-equal?
   (add-star
     (list unselected-star-doodad-at-20-40
      unselected-star-doodad-at-20-100) 3)
     (list
        (make-doodad 0 "star"
         STAR-XPOSITION STAR-YPOSITION
         STAR-XVELOCITY STAR-YVELOCITY
         0 0
         STAR-WIDTH STAR-HEIGHT
         "Gold" false)
        unselected-star-doodad-at-20-40
        unselected-star-doodad-at-20-100)
     "Wrong structure inserted!")
  )

;; create-sq-doodad: World -> World
;; GIVEN: A World on press of "q"
;; KeyEvent
;; RETURNS: A World with a new star doodad
;; given according to the condition of
;; frequency of key event
;; EXAMPLES: see tests below
;; STRATEGY: use World template 
;; add doodad with helper function

(define (create-sq-doodad w)
  (make-world
   (world-doodads-star w)
   (add-sq (world-doodads-square w) (world-sq-counter w))
   (world-star-counter w)
   (+ 1 (world-sq-counter w))    
   (world-paused? w)))

(begin-for-test
  (check-equal?
   (create-sq-doodad
    (make-world 
    (list unselected-star-doodad-at-20-40
        unselected-star-doodad-at-20-100) 
     (list color-square-doodad-at-20-90
          color-square-doodad-at-7-81)
     1 1 false))
  (make-world
     (list unselected-star-doodad-at-20-40
        unselected-star-doodad-at-20-100)
     (list (make-doodad 0 "square"
           SQUARE-XPOSITION SQUARE-YPOSITION
           NSQUARE-XVELOCITY NSQUARE-YVELOCITY
           0 0
           SQUARE-WIDTH SQUARE-HEIGHT
           "Gray" false)
    color-square-doodad-at-20-90
    color-square-doodad-at-7-81)
    1 2 false)
  "Nope! Sorry wrong struct!")) 

;; add-sq: Doodad PosInt -> Doodad
;; GIVEN: A Doodad and a
;; positive integer which which correspond
;; to the counter value in my world structure
;; INTERPRETATION:
;; The 1st press of "q" corresponds to
;; 0 and returns first element of the list.
;; The 2nd press of "q" corresponds to
;; 1 and returns first element of the list.
;; The 3rd press of "q" corresponds to
;; 2 and returns first element of the list.
;; The 4th press of "q" corresponds to
;; 3 and returns first element of the list.
;; The 5th occurance of "q" will produce
;; the val 0 and the sequence follows again
;; EXAMPLES: see tests below
;; STRATEGY: Cycle through the combinations
;; by comparing state of val

(define (add-sq d val)
  (cond
    [(= (modulo val 4) 0)
     (cons (first LIST-SQUARE) d)]
    [(= (modulo val 4) 1)
     (cons (second LIST-SQUARE) d)]
    [(= (modulo val 4) 2)
     (cons (third LIST-SQUARE) d)]
    [(= (modulo val 4) 3)
     (cons (fourth LIST-SQUARE) d)]))

(begin-for-test
  (check-equal?
   (add-sq
    (list color-square-doodad-at-20-90
          color-square-doodad-at-7-81) 3)
    (list (make-doodad 0 "square"
           SQUARE-XPOSITION SQUARE-YPOSITION
           SQUARE-XVELOCITY SQUARE-YVELOCITY
           0 0
           SQUARE-WIDTH SQUARE-HEIGHT
           "Gray" false)
    color-square-doodad-at-20-90
    color-square-doodad-at-7-81)
     "Wrong structure inserted!")
  (check-equal?
   (add-sq
    (list color-square-doodad-at-20-90
          color-square-doodad-at-7-81) 2)
    (list (make-doodad 0 "square"
           SQUARE-XPOSITION SQUARE-YPOSITION
           SQUARE-YVELOCITY NSQUARE-XVELOCITY
           0 0
           SQUARE-WIDTH SQUARE-HEIGHT
           "Gray" false)
    color-square-doodad-at-20-90
    color-square-doodad-at-7-81)
     "Wrong structure inserted!")
  (check-equal?
   (add-sq
    (list color-square-doodad-at-20-90
          color-square-doodad-at-7-81) 1)
    (list (make-doodad 0 "square"
           SQUARE-XPOSITION SQUARE-YPOSITION
           NSQUARE-XVELOCITY NSQUARE-YVELOCITY
           0 0
           SQUARE-WIDTH SQUARE-HEIGHT
           "Gray" false)
    color-square-doodad-at-20-90
    color-square-doodad-at-7-81)
     "Wrong structure inserted!")
  (check-equal?
   (add-sq
    (list color-square-doodad-at-20-90
          color-square-doodad-at-7-81) 0)
    (list (make-doodad 0 "square"
           SQUARE-XPOSITION SQUARE-YPOSITION
           NSQUARE-YVELOCITY SQUARE-XVELOCITY
           0 0
           SQUARE-WIDTH SQUARE-HEIGHT
           "Gray" false)
    color-square-doodad-at-20-90
    color-square-doodad-at-7-81)
     "Wrong structure inserted!")  
  )

;; core-bounce-effect : World -> World
;; GIVEN: a World w 
;; RETURNS: the world that should follow the given world
;; whenever 'c' KeyEvent happens and any doodad is selected.
;; INTERPRETATION:
;; This function produces the color change effect alone
;; of the core bounce effect
;; On pressing a "c", the selected doodad(s) move to their
;; next color state
;; The string can be one of 5 colors for the square doodad:
;; Gray, OliveDrab, Khaki, Orange, Crimson
;; The colors cycle in above sequence for core bounce
;; The string can be one of 3 colors for the star doodad:
;; Gold, Green, Blue
;; EXAMPLES: (core-bounce-effect color-world1)
;;                               = color-world1-new
;; STRATEGY: Apply world template and call on helper functions
                  
(define (core-bounce-effect w)
  (make-world
   (color-update (world-doodads-star w))
   (color-update (world-doodads-square w))
   (world-star-counter w)
   (world-sq-counter w)
   (world-paused? w)
   )
  )

(begin-for-test
 (check-equal? (core-bounce-effect color-world1)
               color-world1-new
               "after a 'c' key, selected doodad did not change color"))

;; color-update : ListofDoodads -> ListofDoodads
;; GIVEN: a LisofDoodads d
;; RETURNS: a ListofDoodads where the selected doodads in
;; the list have their colors upadted.
;; INTERPRETATION:
;; whenver 'c' KeyEvent happens and the Doodad is selected
;; we need to update its color to mirror a core-bounce effect
;; EXAMPLES: (color-update selected-square-doodad-at-20-90)
;;             = color-square-doodad-at-20-90
;; STRATEGY: Call HOF function map on ListofDoodads

#;(define (color-update d)
 (cond
 [(empty? (rest d))  
  (if (doodad-selected? (first d))
   (cons (c-event-doodad (first d))
    empty)
  d)]
 [else 
  (if (doodad-selected? (first d))
   (cons (c-event-doodad (first d))   
      (color-update (rest d)))
      (cons (first d) (color-update (rest d))))]))

(define (color-update d)
  (map
   ;; Doodad -> Doodad
   ;; RETURNS: A doodad following a 'c' event if
   ;; it is selected
   ;; if it is not selected, same doodad is returned
   (lambda (elt)
     (if (doodad-selected? elt)
         (c-event-doodad elt)
         elt))
   d))

(begin-for-test
  (check-equal?
    (color-update
      (world-doodads-square color-world1))
     (world-doodads-square color-world1-new)
    "after a 'c' key, selected doodad did not change color"))

;; world-with-paused-toggled : World -> World
;; GIVEN: a World w
;; RETURNS: a world just like the given one, but with paused? toggled
;; EXAMPLES: (world-with-paused-toggled
;;            paused-world-at-20) = unpaused-world-at-20
;; STRATEGY: Use template for World on w

(define (world-with-paused-toggled w)
  (make-world
   (world-doodads-star w)
   (world-doodads-square w)
   (world-star-counter w)
   (world-sq-counter w)
   (not (world-paused? w))))

(begin-for-test
 (check-equal? 
   (world-with-paused-toggled
    paused-world-at-20) unpaused-world-at-20
    "Return unpaused world"))

;; for world-after-key-event, we need 9 tests: a paused world, and an
;; unpaused world, and a pause-key-event, a "c" key event,
;;  "t", "q", "." key events
;; and a non-paused key event

(define pause-key-event " ")

(define c-key-event "c")

(define non-pause-key-event "r")

(define t-key-event "t")

(define q-key-event "q")

(define del-key-event ".")

(begin-for-test
  (check-equal?
    (world-after-key-event paused-world-at-20 pause-key-event)
    unpaused-world-at-20
    "after pause key, a paused world did not become unpaused")

  (check-equal?
    (world-after-key-event unpaused-world-at-20 pause-key-event)
    paused-world-at-20
    "after pause key, an unpaused world did not become paused")

  (check-equal?
    (world-after-key-event paused-world-at-20 non-pause-key-event)
     paused-world-at-20
    "after a non-pause key, a paused world was not unchanged")

  (check-equal?
    (world-after-key-event unpaused-world-at-20 non-pause-key-event)
     unpaused-world-at-20
    "after a non-pause key, an unpaused world was not unchanged")

    (check-equal?
    (world-after-key-event color-world1 c-key-event)
     color-world1-new
    "after a 'c' key, selected doodad did not change color")
    (check-equal?
    (world-after-key-event
     (make-world 
      (list unselected-star-doodad-at-20-40
        unselected-star-doodad-at-20-100) 
      (list color-square-doodad-at-20-90
           color-square-doodad-at-7-81)
       1 1 false)
      t-key-event)
    (make-world
     (list
        (make-doodad 0 "star"
         STAR-XPOSITION STAR-YPOSITION
         NSTAR-XVELOCITY NSTAR-YVELOCITY
         0 0
         STAR-WIDTH STAR-HEIGHT
         "Gold" false)
        unselected-star-doodad-at-20-40
        unselected-star-doodad-at-20-100)
      (list color-square-doodad-at-20-90
           color-square-doodad-at-7-81)
      2 1 false)
      "Should have added a star doodad!")
    (check-equal?
    (world-after-key-event
     (make-world 
      (list unselected-star-doodad-at-20-40
        unselected-star-doodad-at-20-100) 
      (list color-square-doodad-at-20-90
           color-square-doodad-at-7-81)
       1 1 false)
      q-key-event)
    (make-world 
      (list unselected-star-doodad-at-20-40
        unselected-star-doodad-at-20-100)    
     (list (make-doodad 0 "square"
           SQUARE-XPOSITION SQUARE-YPOSITION
           NSQUARE-XVELOCITY NSQUARE-YVELOCITY
           0 0
           SQUARE-WIDTH SQUARE-HEIGHT
           "Gray" false)
           color-square-doodad-at-20-90
           color-square-doodad-at-7-81)
    1 2 false)
    "Should have added square dooodad!") 
    (check-equal?
    (world-after-key-event
     (make-world 
      (list unselected-star-doodad-at-20-40
        unselected-star-doodad-at-20-100) 
      empty
      1 1 false)
      del-key-event)
    (make-world 
      (list unselected-star-doodad-at-20-40)
      empty
      1 1 false)
    "Should have deleted star dooodad!")
    (check-equal?
    (world-after-key-event
     (make-world
      empty
      (list color-square-doodad-at-20-90
           color-square-doodad-at-7-81)
      1 1 false)
      del-key-event)
    (make-world 
      empty
     (list color-square-doodad-at-7-81)
      1 1 false)
    "Should have deleted square dooodad!")    
    )


;; MOUSE EVENT INTEGRATIONS

;; world-after-mouse-event : World Integer Integer MouseEvent -> World
;; GIVEN: a world and a description of a mouse event
;; RETURNS: the world that should follow the given mouse event
;; EXAMPLES: See tests below
;; STRATEGY: use template for World on w

(define (world-after-mouse-event w mx my mev)
  (make-world
   (doodad-after-mouse-event (world-doodads-star w) mx my mev)
   (doodad-after-mouse-event (world-doodads-square w) mx my mev)
   (world-star-counter w)
   (world-sq-counter w)
   (world-paused? w)))

;; doodad-after-mouse-event:
;; ListofDoodads Integer Integer MouseEvent -> ListofDoodads
;; GIVEN: ListofDoodads and a description of a mouse event
;; RETURNS: The ListofDoodads updated to reflect
;; what should follow the given mouse event
;; EXAMPLES: See tests below
;; STRATEGY: HOF template map on ListofDoodads

#;(define (doodad-after-mouse-event d mx my mev)
 (cond
  [(empty? d) empty] 
  [(empty? (rest d))
   (mouse-event (first d) mev mx my)]
  [else
   (cons (mouse-event (first d) mev mx my)
         (doodad-after-mouse-event (rest d)
                                   mx my mev))]))

(define (doodad-after-mouse-event d mx my mev)
 (if (empty? d) empty
     (map
      ;; Doodad -> Doodad
      ;; RETURNS: Doodad that should follow
      ;; the mouse event mev
      (lambda (elt)
        (mouse-event elt mev mx my))
      d)))

;; mouse-event: Doodad Integer Integer MouseEvent -> Doodad 
;; GIVEN: A Doodad and a description of a mouse event
;; RETURNS: The Doodad updated to reflect
;; what should follow the given mouse event
;; EXAMPLES: See tests below
;; STRATEGY: Doodad templates
;; with Cases on mouse event mev

(define (mouse-event d mev mx my)
 (cond
   [(mouse=? mev "button-down")
     (doodad-after-button-down d mx my)]
   [(mouse=? mev "drag")
     (doodad-after-drag d mx my)]      
   [(mouse=? mev "button-up")
     (doodad-after-button-up d mx my)]
   [else d]))

;; doodad-after-button-down : Doodad Integer Integer -> Doodad
;; GIVEN: A Doodad and mouse co-ordianates x and y
;; RETURNS: the Doodad following a button-down at the given location.
;; EXAMPLES: see tests below
;; STRATEGY: Use template for Doodad on d

(define (doodad-after-button-down d x y)
  (if (in-doodad? d x y)
      (make-doodad (doodad-age d)
                   (doodad-type d)
                   (doodad-x d) (doodad-y d)
                   (doodad-vx d) (doodad-vy d)
                   x y                   
                   (doodad-w d) (doodad-h d)
                   (doodad-color d) true)
      d))

;; HALF-DOODAD-WIDTH Doodad -> Integer
;; GIVEN: A Doodad d
;; RETURNS: the width of the doodad-width
;; data divided by 2
;; STRATEGY: Use / operator

(define (HALF-DOODAD-WIDTH d)
  (/ (doodad-w d) 2))

;; HALF-DOODAD-HEIGHT Doodad -> Integer
;; GIVEN: A Doodad d
;; RETURNS: the height of the doodad-height
;; data divided by 2
;; STRATEGY: Use / operator

(define (HALF-DOODAD-HEIGHT d)
  (/ (doodad-h d) 2))

;; in-doodad? : Doodad Integer Integer -> Boolean
;; GIVEN: A doodad and mouse co-ordinates x and y
;; RETURNS: true iff the given coordinate is inside the bounding box of
;; the doodad.
;; EXAMPLES: see tests below
;; STRATEGY: use template for Doodad on d

(define (in-doodad? d x y)
  (and
   (<= 
    (- (doodad-x d) (HALF-DOODAD-WIDTH d))
    x
    (+ (doodad-x d) (HALF-DOODAD-WIDTH d)))
   (<= 
    (- (doodad-y d) (HALF-DOODAD-HEIGHT d))
    y
    (+ (doodad-y d) (HALF-DOODAD-HEIGHT d)))))

;; drag : PosInt PosInt PosInt -> PosInt
;; GIVEN: 3 positive integers
;; RETURNS: The new value of x based on
;; reference values
;; INTERPRETATION:
;; This is for the drag condition where the
;; relative position of mouse pointer with respect
;; to doodad doesnt change.
;; We compare the stored values of given doodad center
;; and the mouse pointer during the button down event
;; We then compute the difference and
;; add it to the respective mouse co ordinate
;; to get the relative image center
;; EXAMPLES: See tests below
;; STRATEGY: Use simple addition subtraction

(define (drag x ref1 ref2)
      (+ x (- ref1 ref2)));) 

;; doodad-after-drag : Doodad Integer Integer -> Doodad
;; GIVEN: A doodad and mouse co-ordinates x and y
;; RETURNS: the Doodad following a drag at the given location
;; EXAMPLES: See tests below
;; STRATEGY: Use template for Doodad on d

(define (doodad-after-drag d x y)
  (if (doodad-selected? d)
      (make-doodad (doodad-age d)
                   (doodad-type d)
                   (drag x (doodad-x d) (doodad-mx d))
                   (drag y (doodad-y d) (doodad-my d))
                   (doodad-vx d) (doodad-vy d)
                   x y
                   (doodad-w d) (doodad-h d)
                   (doodad-color d) true)
      d))

;; doodad-after-button-up : Doodad Integer Integer -> Doodad
;; GIVEN: A doodad and mouse co-ordinates x and y
;; RETURNS: the doodad following a button-up at the given location
;; EXAMPLES: See test below
;; STRATEGY: Use template for Doodad on d

(define (doodad-after-button-up d x y)
  (if (doodad-selected? d)
      (make-doodad (doodad-age d)
                   (doodad-type d)
                   (doodad-x d) (doodad-y d)
                   (doodad-vx d) (doodad-vy d)
                   (doodad-mx d) (doodad-my d)                   
                   (doodad-w d) (doodad-h d)
                   (doodad-color d) false)
      d))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;; EXAMPLES OF DOODADS, FOR TESTING

(define unselected-star-doodad-at-20-40 (make-doodad 10 "star"
                                         20 40
                                         STAR-XVELOCITY STAR-YVELOCITY
                                         20 40
                                         STAR-WIDTH STAR-HEIGHT
                                         "Gold" false))

(define aged-star-doodad-at-30-52 (make-doodad 11 "star"
                                         30 52
                                         STAR-XVELOCITY STAR-YVELOCITY
                                         20 40
                                         STAR-WIDTH STAR-HEIGHT
                                         "Gold" false))

(define unselected-star-doodad-at-20-100 (make-doodad 15 "star"
                                         20 100
                                         NSTAR-XVELOCITY NSTAR-YVELOCITY
                                         20 100
                                         STAR-WIDTH STAR-HEIGHT
                                         "Gold" false))

(define age-star-doodad-at-20-40 (make-doodad 11 "star"
                                  20 40
                                  STAR-XVELOCITY STAR-YVELOCITY
                                  20 40
                                  STAR-WIDTH STAR-HEIGHT
                                  "Gold" false))

(define selected-star-doodad-at-20-40 (make-doodad 10 "star"
                                         20 40
                                         STAR-XVELOCITY STAR-YVELOCITY
                                         20 40  
                                         STAR-WIDTH STAR-HEIGHT
                                         "Gold" true))

(define new-star-doodad-at-20-40 (make-doodad 10 "star"
                                         20 40
                                         STAR-XVELOCITY STAR-YVELOCITY
                                         17 45  
                                         STAR-WIDTH STAR-HEIGHT
                                         "Gold" true))

(define dragged-star-doodad-at-80-150 (make-doodad 10 "star"
                                         80 150
                                         STAR-XVELOCITY STAR-YVELOCITY
                                         80 150
                                         STAR-WIDTH STAR-HEIGHT
                                         "Gold" true))

(define selected-square-doodad-at-20-90 (make-doodad 32 "square"
                                         20 90
                                         SQUARE-XVELOCITY SQUARE-YVELOCITY
                                         20 90
                                         SQUARE-WIDTH SQUARE-HEIGHT
                                         "Crimson" true))

(define age-square-doodad-at-20-90 (make-doodad 33 "square"
                                    20 90
                                    SQUARE-XVELOCITY SQUARE-YVELOCITY
                                    20 90
                                    SQUARE-WIDTH SQUARE-HEIGHT
                                    "Crimson" true))

(define unselected-square-doodad-at-20-90 (make-doodad 32 "square"
                                         20 90
                                         SQUARE-XVELOCITY SQUARE-YVELOCITY
                                         20 90 
                                         SQUARE-WIDTH SQUARE-HEIGHT
                                         "Crimson" false))

(define unselected-square-doodad-at-5-9 (make-doodad 0 "square"
                                         5 9
                                         SQUARE-XVELOCITY SQUARE-YVELOCITY
                                         0 0 
                                         SQUARE-WIDTH SQUARE-HEIGHT
                                         "Crimson" false))

(define new-square-doodad-at-8-0 (make-doodad 1 "square"
                                         8 0
                                         SQUARE-XVELOCITY SQUARE-YVELOCITY
                                         0 0 
                                         SQUARE-WIDTH SQUARE-HEIGHT
                                         "Gray" false))

(define unselected-star-doodad-at-598-445 (make-doodad 0 "star"
                                         598 445
                                         STAR-XVELOCITY STAR-YVELOCITY
                                         0 0 
                                         STAR-WIDTH STAR-HEIGHT
                                         "Gold" false))

(define new-star-doodad-at-592-439 (make-doodad 1 "star"
                                         592 439
                                         NSTAR-XVELOCITY NSTAR-YVELOCITY
                                         0 0 
                                         STAR-WIDTH STAR-HEIGHT
                                         "Green" false))

(define n-square-doodad-at-8-0 (make-doodad 1 "square"
                                         8 0
                                         NSQUARE-XVELOCITY SQUARE-YVELOCITY
                                         0 0 
                                         SQUARE-WIDTH SQUARE-HEIGHT
                                         "Gray" false))

(define color-square-doodad-at-20-90 (make-doodad 32 "square"
                                         20 90
                                         SQUARE-XVELOCITY SQUARE-YVELOCITY
                                         20 90
                                         SQUARE-WIDTH SQUARE-HEIGHT
                                         "Gray" true))

(define unselected-star-doodad-at-30-52 (make-doodad 2 "star"
                                         30 52
                                         STAR-XVELOCITY STAR-YVELOCITY
                                         30 52
                                         STAR-WIDTH STAR-HEIGHT
                                         "Gold" false))

(define age-star-doodad-at-30-52 (make-doodad 11 "star"
                                         30 52
                                         STAR-XVELOCITY STAR-YVELOCITY
                                         20 40
                                         STAR-WIDTH STAR-HEIGHT
                                         "Gold" false))

(define selected-square-doodad-at-7-81 (make-doodad 24 "square"
                                        7 81
                                        SQUARE-XVELOCITY SQUARE-YVELOCITY
                                        7 81 
                                        SQUARE-WIDTH SQUARE-HEIGHT
                                        "Crimson" true))

(define color-square-doodad-at-7-81 (make-doodad 24 "square"
                                        7 81
                                        SQUARE-XVELOCITY SQUARE-YVELOCITY
                                        7 81 
                                        SQUARE-WIDTH SQUARE-HEIGHT
                                        "Gray" true))

(define selected-star-doodad-at-595-100 (make-doodad 42 "star"
                                         595 100
                                         STAR-XVELOCITY STAR-YVELOCITY
                                         595 100  
                                         STAR-WIDTH STAR-HEIGHT
                                         "Green" true))

(define unselected-star-doodad-at-595-100 (make-doodad 42 "star"
                                         595 100
                                         STAR-XVELOCITY STAR-YVELOCITY
                                         595 100  
                                         STAR-WIDTH STAR-HEIGHT
                                         "Green" false))

(define tick-star-doodad-at-595-112 (make-doodad 43 "star"
                                         595 112
                                         NSTAR-XVELOCITY STAR-YVELOCITY
                                         595 100  
                                         STAR-WIDTH STAR-HEIGHT
                                         "Blue" false))

(define unselected-star-doodad-at-595-8 (make-doodad 42 "star"
                                         595 8
                                         STAR-XVELOCITY NSTAR-YVELOCITY
                                         595 100  
                                         STAR-WIDTH STAR-HEIGHT
                                         "Blue" false))

(define tick-star-doodad-at-595-4 (make-doodad 43 "star"
                                         595 4
                                         NSTAR-XVELOCITY STAR-YVELOCITY
                                         595 100  
                                         STAR-WIDTH STAR-HEIGHT
                                         "Gold" false))

(define unselected-square-doodad-at-100-8 (make-doodad 47 "square"
                                           100 8
                                           SQUARE-XVELOCITY SQUARE-YVELOCITY
                                           100 8 
                                           SQUARE-WIDTH SQUARE-HEIGHT
                                           "Khaki" false))

(define tick-square-doodad-at-87-1 (make-doodad 48 "square"
                                           87 1
                                           SQUARE-XVELOCITY NSQUARE-YVELOCITY
                                           100 8 
                                           SQUARE-WIDTH SQUARE-HEIGHT
                                           "Orange" false))

(define unselected-square-doodad-at-8-8 (make-doodad 47 "square"
                                           8 8
                                           SQUARE-XVELOCITY SQUARE-YVELOCITY
                                           100 8 
                                           SQUARE-WIDTH SQUARE-HEIGHT
                                           "OliveDrab" false))

(define tick-square-doodad-at-5-1 (make-doodad 48 "square"
                                           5 1
                                           NSQUARE-XVELOCITY NSQUARE-YVELOCITY
                                           100 8 
                                           SQUARE-WIDTH SQUARE-HEIGHT
                                           "Khaki" false))

(define selected-square-doodad-at-100-8 (make-doodad 47 "square"
                                           100 8
                                           SQUARE-XVELOCITY SQUARE-YVELOCITY
                                           100 8
                                           SQUARE-WIDTH SQUARE-HEIGHT
                                           "Khaki" true))

(define new-square-doodad-at-100-8 (make-doodad 47 "square"
                                           100 8
                                           SQUARE-XVELOCITY SQUARE-YVELOCITY
                                           110 12
                                           SQUARE-WIDTH SQUARE-HEIGHT
                                           "Khaki" true))

(define dragged-square-doodad-at-80-150 (make-doodad 47 "square"
                                           80 150
                                           SQUARE-XVELOCITY SQUARE-YVELOCITY
                                           80 150
                                           SQUARE-WIDTH SQUARE-HEIGHT
                                           "Khaki" true))

(define unselected-square-doodad-at-8-100 (make-doodad 47 "square"
                                           8 100
                                           SQUARE-XVELOCITY SQUARE-YVELOCITY
                                           8 100 
                                           SQUARE-WIDTH SQUARE-HEIGHT
                                           "Crimson" false))

(define tick-square-doodad-at-5-91 (make-doodad 48 "square"
                                           5 91
                                           NSQUARE-XVELOCITY SQUARE-YVELOCITY
                                           8 100 
                                           SQUARE-WIDTH SQUARE-HEIGHT
                                           "Gray" false))

(define unselected-square-doodad-at-8-445 (make-doodad 47 "square"
                                           8 445
                                           SQUARE-XVELOCITY NSQUARE-YVELOCITY
                                           8 445 
                                           SQUARE-WIDTH SQUARE-HEIGHT
                                           "Crimson" false))

(define tick-square-doodad-at-5-442 (make-doodad 48 "square"
                                           5 442
                                           NSQUARE-XVELOCITY SQUARE-YVELOCITY
                                           8 445 
                                           SQUARE-WIDTH SQUARE-HEIGHT
                                           "Gray" false))

(define unselected-square-doodad-at-20-445 (make-doodad 47 "square"
                                           20 445
                                           SQUARE-XVELOCITY NSQUARE-YVELOCITY
                                           8 445 
                                           SQUARE-WIDTH SQUARE-HEIGHT
                                           "Orange" false))

(define tick-square-doodad-at-7-442 (make-doodad 48 "square"
                                           7 442
                                           SQUARE-XVELOCITY SQUARE-YVELOCITY
                                           8 445 
                                           SQUARE-WIDTH SQUARE-HEIGHT
                                           "Crimson" false))

;;; EXAMPLES OF WORLDS FOR TESTING

(define paused-world-at-20
  (make-world
    (list unselected-star-doodad-at-20-40)
    (list selected-square-doodad-at-20-90)
    0 0
    true))

(define paused-world-at-20-after-tick
  (make-world
    (list age-star-doodad-at-20-40)
    (list age-square-doodad-at-20-90)
    0 0
    true))

(define unpaused-world-at-20
  (make-world
    (list unselected-star-doodad-at-20-40)
    (list selected-square-doodad-at-20-90)
    0 0
    false))

(define unpaused-world-at-20-after-tick
  (make-world
   (list aged-star-doodad-at-30-52)
    (list age-square-doodad-at-20-90)
    0 0
    false))

(define color-world1
  (make-world
    (list unselected-star-doodad-at-20-40
          unselected-star-doodad-at-20-100)
    (list selected-square-doodad-at-20-90
          selected-square-doodad-at-7-81)
    0 0
    true))

(define color-world1-new
  (make-world
    (list unselected-star-doodad-at-20-40
          unselected-star-doodad-at-20-100)
    (list color-square-doodad-at-20-90
          color-square-doodad-at-7-81)
    0 0
    true))

(define color-world2
  (make-world
    (list unselected-star-doodad-at-20-40)
    (list selected-square-doodad-at-7-81)
    0 0
    true))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;; EXAMPLE MOUSE EVENTS FOR TESTING

(define button-down-event "button-down")

(define drag-event "drag")

(define button-up-event "button-up")

(define other-event "enter")

;; tests for button down

(begin-for-test

  ;; button-down:

  ;; button-down inside star-doodad
  (check-equal?
    (world-after-mouse-event 
      (make-world
        (list unselected-star-doodad-at-20-40)
        (list unselected-square-doodad-at-100-8)
        0 0
        false)
      17 45    ;; a coordinate inside star-doodad
      "button-down")
    (make-world
      (list new-star-doodad-at-20-40)
      (list unselected-square-doodad-at-100-8)
      0 0
      false)
    "button down inside star-doodad should
     select it but didn't")

  ;; button-down inside square doodad
  (check-equal?
    (world-after-mouse-event 
      (make-world
        (list unselected-star-doodad-at-20-40)
        (list unselected-square-doodad-at-100-8)
        0 0
        false)
      110 12    ;; a coordinate inside square doodad
      "button-down")
    (make-world
        (list unselected-star-doodad-at-20-40)
        (list new-square-doodad-at-100-8)
        0 0
      false)
    "button down inside square doodad should select it but didn't")

  ;; button-down not inside any doodad
  (check-equal?
    (world-after-mouse-event 
      (make-world
        (list unselected-star-doodad-at-20-40)
        (list unselected-square-doodad-at-100-8)
        0 0
        false)
        70 300    ;; a coordinate not inside either doodad
      "button-down")
    (make-world
        (list unselected-star-doodad-at-20-40)
        (list unselected-square-doodad-at-100-8)
        0 0
      false)
    "button down outside any doodad should
     leave world unchanged, but didn't")

  (check-equal?
    (world-after-mouse-event 
      (make-world
        (list unselected-star-doodad-at-20-40
              unselected-star-doodad-at-595-100)
        (list unselected-square-doodad-at-100-8
              color-square-doodad-at-7-81)
        0 0
        false)
        17 45    ;; a coordinate not inside either doodad
      "button-down")
    (make-world
        (list new-star-doodad-at-20-40
              unselected-star-doodad-at-595-100)
        (list unselected-square-doodad-at-100-8
              color-square-doodad-at-7-81)
        0 0
      false)
    "button down inside any doodad should
     move doodad, but didn't")  
  ;; tests for drag

  ;; don't care about paused, care only about which doodad is selected. 

  ;; no doodad selected: drag should not change anything
  (check-equal?
    (world-after-mouse-event
      (make-world
        (list unselected-star-doodad-at-20-40)
        (list unselected-square-doodad-at-100-8)
        0 0
        false)
       350 400    ;; a large motion
      "drag")
    (make-world
        (list unselected-star-doodad-at-20-40)
        (list unselected-square-doodad-at-100-8)
        0 0
        false)
    "drag with no doodad selected didn't leave world unchanged")
    
  ;; star doodad selected
  (check-equal?
    (world-after-mouse-event
      (make-world
        (list selected-star-doodad-at-20-40)
        (list unselected-square-doodad-at-100-8)
        0 0
        false)
        80 150    ;; a large motion
      "drag")
    (make-world
        (list dragged-star-doodad-at-80-150)
        (list unselected-square-doodad-at-100-8)
        0 0
      false)
    "drag when star doodad is selected
    should just move star doodad but didn't")

  ;; square doodad selected
  (check-equal?
    (world-after-mouse-event
      (make-world
        (list unselected-star-doodad-at-20-40)
        (list selected-square-doodad-at-100-8)
        0 0
        false)
        80 150    ;; a large motion
      "drag")
    (make-world
        (list unselected-star-doodad-at-20-40)
        (list dragged-square-doodad-at-80-150)
        0 0
      false)
    "drag when square doodad is selected
     should just move square doodad, but didn't")
  
  (check-equal?
    (world-after-mouse-event 
      (make-world
        (list selected-star-doodad-at-20-40
              unselected-star-doodad-at-595-100)
        (list unselected-square-doodad-at-100-8
              n-square-doodad-at-8-0)
        0 0
        false)
        80 150
        "drag")
    (make-world
        (list dragged-star-doodad-at-80-150
              unselected-star-doodad-at-595-100)
        (list unselected-square-doodad-at-100-8
              n-square-doodad-at-8-0)
        0 0
      false)
    "drag when star doodad selected should
     move star doodad, but didn't")  

  ;; tests for button-up

  ;; button-up always unselects both doodads

  ;; unselect star doodad
  (check-equal?
    (world-after-mouse-event
      (make-world
        (list selected-star-doodad-at-20-40)
        (list unselected-square-doodad-at-100-8)
        0 0
        true)
       100 100    ;; arbitrary location
      "button-up")
    (make-world
        (list unselected-star-doodad-at-20-40)
        (list unselected-square-doodad-at-100-8)
        0 0
        true)
    "button-up failed to unselect star doodad")

  ;; unselect square doodad
  (check-equal?
    (world-after-mouse-event
      (make-world
        (list unselected-star-doodad-at-20-40)
        (list selected-square-doodad-at-100-8)
        0 0
        true)
        20 20    ;; arbitrary location
      "button-up")
    (make-world
        (list unselected-star-doodad-at-20-40)
        (list unselected-square-doodad-at-100-8)
        0 0
        true)
    "button-up failed to unselect doodad2")
  
  ;; unselect when doodads not selected
  (check-equal?
    (world-after-mouse-event
      (make-world
        (list unselected-star-doodad-at-20-40)
        (list unselected-square-doodad-at-100-8)
        0 0
        true)
        10 15    ;; arbitrary location
      "button-up")
    (make-world
        (list unselected-star-doodad-at-20-40)
        (list unselected-square-doodad-at-100-8)
        0 0
        true)
    "button-up with two unselected doodads failed.")

  (check-equal?
    (world-after-mouse-event 
      (make-world
        (list selected-star-doodad-at-20-40
              unselected-star-doodad-at-595-100)
        (list unselected-square-doodad-at-100-8
              n-square-doodad-at-8-0)
        0 0
        false)
        100 100
        "button-up")
    (make-world
        (list unselected-star-doodad-at-20-40
              unselected-star-doodad-at-595-100)
        (list unselected-square-doodad-at-100-8
              n-square-doodad-at-8-0)
        0 0
      false)
    "drag when star doodad selected should
     move star doodad, but didn't")

  ;; tests for other mouse events

  (check-equal?
    (world-after-mouse-event unpaused-world-at-20 
      100 15    ;; arbitrary coordinate
      "move")
    unpaused-world-at-20
    "other mouse events should leave the world unchanged, but didn't")

  (check-equal?
    (world-after-mouse-event 
      (make-world
        empty
        empty
        0 0
        false)
      17 45    ;; a coordinate inside star-doodad
      "button-down")
    (make-world
      empty
      empty
      0 0
      false)
    "World should be empty!")
  
  (check-equal?
    (world-after-mouse-event 
      (make-world
        (list selected-star-doodad-at-20-40
              unselected-star-doodad-at-595-100)
        (list unselected-square-doodad-at-100-8
              n-square-doodad-at-8-0)
        0 0
        false)
        100 100
        "move")
      (make-world
        (list selected-star-doodad-at-20-40
              unselected-star-doodad-at-595-100)
        (list unselected-square-doodad-at-100-8
              n-square-doodad-at-8-0)
        0 0
        false)
    "Unrelated mouse events")
  )



