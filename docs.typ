#import "@preview/tidy:0.2.0"

= Bytefield documentation

#let docs = tidy.parse-module(read("lib/api.typ"), name: "User API")
#tidy.show-module(docs, style: tidy.styles.default, show-outline:false)