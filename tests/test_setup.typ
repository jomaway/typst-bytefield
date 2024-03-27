#import "../bytefield.typ": *
#import "@preview/codelst:2.0.0": sourcecode


#let eval_bytefield(source) = eval(
  source.text, mode:"markup", 
  scope: (
    "bytefield" : bytefield,
    "byte" : byte,
    "bytes" : bytes,
    "bit" : bit,
    "bits" : bits,
    "padding" : padding,
    "flagtext" : flagtext,
    "note" : note,
    "group" : group,
  )
)

#let test(title: "Test", columns:(1fr,1fr),source) = {
  block[
    == Test: #title
    #grid(
      columns:columns,
      gutter: 10pt,
      box(inset: (y: 1em),sourcecode(source)),
      align(horizon,eval_bytefield(source))
    )
    #eval_bytefield(source)
  ]
}
