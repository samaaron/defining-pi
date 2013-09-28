(defproject defining-pi "0.0.0-SNAPSHOT"
  :description "Defining Pi ClojureScript source"
  :dependencies [[org.clojure/clojure "1.5.1"]
                 [prismatic/dommy "0.1.1"]
                 [org.clojure/clojurescript "0.0-1896"]
                ]
  :plugins [[lein-cljsbuild "0.3.3"]]
  :source-paths ["src-cljs"]
  :profiles {:dev {:plugins [[com.cemerick/austin "0.1.1"]]}}
  :cljsbuild {
              :builds [{:source-paths ["src-cljs"]
                        :compiler {:output-to "public/js/cljs-main.js"
                                   :optimizations :whitespace
                                   :pretty-print true}}]})
