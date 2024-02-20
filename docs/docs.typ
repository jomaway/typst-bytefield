#import "@preview/tidy:0.2.0"
#import "@preview/gentle-clues:0.6.0": abstract

#let version = toml("../typst.toml").package.version

= Bytefield manual

#abstract[
	typst-bytefield is a package to create network protocol headers, memory maps, register definitions and more in typst.
]

#let docs = tidy.parse-module(read("../lib/api.typ"), name: "User API")
#tidy.show-module(docs, style: tidy.styles.default, show-outline:false)
