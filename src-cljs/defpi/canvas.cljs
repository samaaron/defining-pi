(ns defpi.canvas
  (:require [defpi.dom :refer [by-id]]))


(def PI (.-PI js/Math))
(def TWO-PI (* PI 2))


(def canvas (js/Canvas. (by-id "cake-canvas") 600 300))
(def canvas-width (.-width canvas))
(def canvas-height (.-height canvas))

(defn mk-circle
  [attrs]
  (let [default-attrs {:id "circle"
                       :x (/ canvas-width 2)
                       :y (/ canvas-height 2)
                       :stroke "black"
                       :strokeWidth 10
                       :endAngle TWO-PI
                       :radius 100}
        attrs (merge default-attrs attrs)]
    (js/Circle.
     (:radius attrs)
     (cljs.core/clj->js attrs))))

(def circle-1 (mk-circle {:radius 10
                          :stroke "green"
                          :strokeWidth 3}))

(defn draw-circle [opts]
  (.append canvas (mk-circle opts)))

(defn ^:export drawRandCircle []
  (.append canvas (mk-circle {:x (rand-int canvas-width)
                              :y (rand-int canvas-height)
                              :radius (rand-int 10)
                              :strokeWidth (rand-int 5)})))

(defn draw []
  (.append canvas circle-1)
)

;; window.onload = function()
;; {
;; 	var CAKECanvas = new Canvas(document.body, 600, 400);

;; 	var circle1 = new Circle(100,
;; 		{
;; 			id: 'myCircle1',
;; 			x: CAKECanvas.width / 3,
;; 			y: CAKECanvas.height / 2,
;; 			stroke: 'cyan',
;; 			strokeWidth: 20,
;; 			endAngle: Math.PI*2
;; 		}
;; 	);

;; 	circle1.addFrameListener(
;; 		function(t, dt)
;; 		{
;; 			this.scale = Math.sin(t / 1000);
;; 		}
;; 	);

;; 	CAKECanvas.append(circle1);

;; 	var circle2 = new Circle(100,
;; 		{
;; 			id: 'myCircle2',
;; 			x: CAKECanvas.width / 3 * 2,
;; 			y: CAKECanvas.height / 2,
;; 			stroke: 'red',
;; 			strokeWidth: 20,
;; 			endAngle: Math.PI*2
;; 		}
;; 	);

;; 	circle2.addFrameListener(
;; 		function(t, dt)
;; 		{
;; 			this.scale = Math.cos(t / 1000);
;; 		}
;; 	);

;; 	CAKECanvas.append(circle2);

;; 	var hello = new ElementNode(E('h2', 'Hello, world!'),
;; 		{
;; 			fontFamily: 'Arial, Sans-serif',
;; 			noScaling: true,
;; 			color: 'black',
;; 			x: CAKECanvas.width / 2,
;; 			y: CAKECanvas.height / 2,
;; 			align: 'center',
;; 			valign: 'center'
;; 		}
;; 	);

;; 	hello.every(1000,
;; 		function()
;; 		{
;; 			this.color = 'magenta';
;; 			this.after(200,
;; 				function()
;; 				{
;; 					this.color = 'blue';
;; 				}
;; 			);
;; 		},
;; 		true
;; 	);

;; 	CAKECanvas.append(hello);
;; };
