(ns defpi.canvas
  (:require [defpi.dom :refer [by-id]]))


(def PI (.-PI js/Math))
(def TWO-PI (* PI 2))

(def stage-width 600)
(def half-stage-width (/ stage-width 2))
(def stage-height 300)
(def half-stage-height (/ stage-height 2))

(def default-layer (js/Kinetic.Layer. ) )

(def stage (js/Kinetic.Stage.
            (cljs.core/clj->js {:container "my-stage"
                                :width stage-width
                                :height stage-height})))

 (.add stage default-layer)
;; (defn set-line-width! [width]
;;   (set! (.-lineWidth can2d) width))

(defn draw-circle [opts]
  (let [default-opts {:x           half-stage-width
                      :y           half-stage-height
                      :radius      100
                      :draggable true
                      :strokeWidth 10}
        attrs        (merge default-opts opts)
        circle       (js/Kinetic.Circle.
                      (cljs.core/clj->js attrs) )]

    (.add default-layer circle)
    (.add stage default-layer)))

(defn draw-image [opts]
  (let [img     (js/Image.)
        img-src (if (keyword? (:src opts))
                  (str "media/" (name (:src opts)) ".png")
                  (:src opts))]
    (set! (.-onload img)
          (fn []
            (let [default-opts {:x         0
                                :y         0
                                :image     img
                                :width     (.-width img)
                                :height    (.-height img)
                                :draggable true}
                  attrs        (merge default-opts opts)
                  image        (js/Kinetic.Image.
                                (cljs.core/clj->js attrs)) ]
              (.add default-layer image)
              (.add stage default-layer))))
    (set! (.-src img) img-src)))

;; (set-line-width! 8)

;; (defn mk-circle
;;   [attrs]
;;   (let [default-attrs {:id "circle"
;;                        :x (/ canvas-width 2)
;;                        :y (/ canvas-height 2)
;;                        :stroke "black"
;;                        :strokeWidth 10
;;                        :endAngle TWO-PI
;;                        :radius 100}
;;         attrs (merge default-attrs attrs)]
;;     (js/Circle.
;;      (:radius attrs)
;;      (cljs.core/clj->js attrs))))

;; (defn draw-circle [opts]
;;   (.append canvas (mk-circle opts)))

;; (defn ^:export drawRandCircle []
;;   (.append canvas (mk-circle {:x (rand-int canvas-width)
;;                               :y (rand-int canvas-height)
;;                               :radius (rand-int 10)
;;                               :strokeWidth (rand-int 5)})))

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
