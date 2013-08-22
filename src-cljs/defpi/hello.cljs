(ns defpi.hello
  (:require
    [goog.events :as events]
    [goog.events.EventType]))

(def ws (js/WebSocket. (str "ws://" (.-host (.-location js/window)))))

(defn by-id
  "Extract a dom element by id"
  [id]
  (.getElementById js/document id))

(defn set-html!
  "Set the inner html of a specific dom element el to s"
  [el s]
  (set! (.-innerHTML el) s))

(defn get-html [el]
  (.-innerHTML el))

(defn show-msg
  [msg]
  (let [msgs    (by-id "msgs")
        content (str msg "<br />" (get-html msgs))]
    (set-html! msgs content)))

(defn add-ws-handlers
  [ws]
  (set! (.-onclose ws) #(show-msg "Websocket Closed"))
  (set! (.-onmessage ws) #(show-msg (.-data msg))))

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

(set! (.-onload js/window)
      (fn []
        (add-ws-handlers ws)))
