(ns defpi.ws
  (:require [defpi.dom :refer [by-id by-class set-html! get-html]]
            [goog.events :as events]
            [goog.events.EventType]
            [cljs.reader :as reader]
            [defpi.canvas :as c]))

(def ws (js/WebSocket. (str "ws://" (.-host (.-location js/window)))))

(defn show-msg
  [val]
  (let [msgs    (by-id "msgs")
        content (str val "<br />" (get-html msgs))]
    (js/console.log (str "show: " content))
    ;(set-html! msgs content)
    ))

(defn show-sketch
  [msg]
  (c/draw-circle msg))


(defmulti handle-message :type)

(defmethod handle-message :message
  [msg]
  (show-msg (:val msg)))

(defmethod handle-message :sketch
  [msg]
  (show-sketch (:opts msg)))

(defn add-ws-handlers
  []
  (set! (.-onclose ws) #(show-msg "Websocket Closed"))
  (set! (.-onmessage ws) (fn [m]
                           (js/console.log "hi there")
                           (js/console.log (.-data m))
                           (js/console.log "how are you?")
                           (handle-message (reader/read-string (.-data m))))))

(defn ^:export sendCode
  []
  (.send ws {:cmd "run-code"
             :val (.getValue js/editor)}))


(defn ^:export stopCode
  []
  (.send ws {:cmd "stop"
             :val (.getValue js/editor)}))

(defn ^:export takePhoto
  []
  (js/alert "soon, i'll be able to take a photo..."))
