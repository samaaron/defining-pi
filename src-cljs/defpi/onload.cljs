(ns defpi.onload
  (:require [defpi.ws :refer [add-ws-handlers]]
            [defpi.canvas :refer [draw]]))

(set! (.-onload js/window)
      (fn []
        (add-ws-handlers ws)
        (draw)))
