#import "gen.typ": *

// -------------
//   bytefield
// -------------
#let bytefield(
  bits: 32, 
  bitheader: auto, 
  msb_first: false,
  pre: auto,
  post: auto,
  ..fields
) = {

  let args = (
    bpr: bits,
    msb: msb_first,
    bitheader: bitheader,
    side: (left_cols: pre, right_cols: post)
  )

  let meta = generate_meta(args, fields.pos())
  let fields = generate_bf-fields(fields.pos(), meta)
  let cells = generate_cells(meta, fields)
  let table = generate_table(meta, cells)
  return table
}

// -------------
// Low level API - for internal - will be changed soon
// -------------
#let bitbox(size, fill: none, body) = (
  type: "bitbox",
  size: size,   // length of the field in bits
  format: (
    fill: fill,
    stroke: stroke,
  ),
  body: body
)

#let annotation(side, level:0, rowspan: 1, ..args, body) = (
  type: "annotation",
  side: side,
  level: level,
  rowspan: rowspan,
  format: args.named(),
  body: body
)

// -------------
// High level API - for users 
// -------------
#let bit(..args) = bitbox(1, ..args)
#let bits(len, ..args) = bitbox(len, ..args)
#let byte(..args) = bitbox(8, ..args)
#let bytes(len, ..args) = bitbox(len * 8, ..args)
#let flag(..args,text) = bitbox(1,..args,flagtext(text))
#let padding(..args) = bitbox(auto, ..args)

#let flagtext(text) = align(center,rotate(270deg,text)) // Rotating text for flags

#let note(side,rowspan:1,level:0,content) = {
  let _align = if (side == left) { right } else { left }
  annotation(side,level:level,rowspan:rowspan,inset:5pt,align:_align+horizon,content)
}

#let group(side,rowspan,level:0,content) = {
  let _align  = none
  let _first  = none
  let _second = none

  if (side == left) {
    _align  = right
    _first  = box(height:100%,content)
    _second = box(height:100%,inset:(right:5pt),layout(size => {math.lr("{",size:size.height)}))
  } else {
    _align  = left
    _first  = box(height:100%,inset:(left:5pt),layout(size => {math.lr("}",size:size.height)}))
    _second = box(height:100%,content)
  }

  annotation(
    side,
    level:level,
    rowspan:rowspan,
    align:_align+horizon,
    inset:0pt,
    grid(
        columns:2,
        gutter:5pt,
        _first,
        _second
      )
    )
}
