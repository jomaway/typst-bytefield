#import "gen.typ": *


/// Create a new bytefield.
///
/// - bits (int): Number of bits which are shown per row.
/// - pre (auto, int , relative , fraction , array): This is specifies the columns for annotations on the *left* side of the bytefield
/// - post (auto, int , relative , fraction , array): This is specifies the columns for annotations on the *right* side of the bytefield
///
/// - ..fields (bitbox, annotation, bitheader): arbitrary number of data fields, annotations and headers which build the bytefield. 
/// -> bytefield
#let bytefield(
  bits: 32, 
  pre: auto,
  post: auto,
  ..fields
) = {

  let args = (
    bpr: bits,
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

#let bitheader(
  msb: right,
  autofill: auto,
  numbers: auto,  // or none
  // labels: (:),
  ticks: auto,     // not working
  fontsize: auto,  // not working 
  angle: auto,     // not working
  marker: auto,    // not working
  ..args
) = {
  // let _numbers = ()
  let labels = (:)
  let _numbers = ()
  let last = 0
  let step = 1
  for arg in args.pos() {
    if type(arg) == int {
      _numbers.push(arg)
      last = arg
      step = arg
    } else if type(arg) == str {
      autofill = arg
    } else if type(arg) == content { 
      labels.insert(str(last),arg)
      _numbers.push(last)
      last += step
    }
    if numbers != none { numbers = _numbers }
  }
  
  return (
    type: "bitheader",
    msb: msb,
    autofill: autofill,
    numbers: numbers,
    labels:labels,
    ticks:ticks,
    fontsize:fontsize,
    angle: angle,
    marker: marker,
  )
}

// -------------
// High level API - for users 
// -------------
/// Add a bit to the bytefield
#let bit(..args) = bitbox(1, ..args)
/// Add multiple bits to the bytefield
#let bits(len, ..args) = bitbox(len, ..args)
/// Add a byte to the bytefield
#let byte(..args) = bitbox(8, ..args)
/// Add multiple bytes to the bytefield
#let bytes(len, ..args) = bitbox(len * 8, ..args)
/// Add a field which extends to the end of the row
#let padding(..args) = bitbox(auto, ..args)
/// Rotating text for small flags
#let flagtext(text) = align(center,rotate(270deg,text)) // Rotating text for flags
/// Add a flag to the bytefield.
#let flag(text,..args) = bitbox(1,flagtext(text),..args)

/// Create a annotation
///
/// The note is always shown in the same row as the next data field which is specified. 
///
/// - side (left, right): Where the annotation should be displayed
/// - level (int): Defines the nesting level of the note.
/// - rowspan (int): Defines if the cell is spanned over multiple rows.
/// - inset (length): Inset of the the annotation cell.
/// - bracket (bool): Defines if a bracket will be shown for this note.
/// - content (content): The content of the note.
#let note(
  side,
  rowspan:1,
  level:0, 
  inset: 5pt, 
  bracket: false, 
  content
) = {
  let _align  = none
  let _first  = none
  let _second = none

  if (side == left) {
    _align  = right
    _first  = box(height:100%,content)
    _second = box(height:100%,inset:(right:0pt),layout(size => {math.lr("{",size:size.height)}))
  } else {
    _align  = left
    _first  = box(height:100%,inset:(left:0pt),layout(size => {math.lr("}",size:size.height)}))
    _second = box(height:100%,content)
  }

  annotation(
    side,
    level:level,
    rowspan:rowspan,
    inset: if (bracket == false) { inset } else { (x:2pt, y:1pt) },
    align:_align+horizon,
    if (bracket == false) { content } else {
      grid(
        columns:2,
        gutter: inset,
        _first,
        _second
      )
    }
  )
}

/// Shows a note with a bracket and spans over multiple rows.
///
/// Basically just a shortcut for a note.
#let group(side,rowspan,level:0, bracket:true,content) = {
  note(side,level:level,rowspan:rowspan,bracket: bracket,content)
}

/// Shows a special note with a start_addr (top aligned) and end_addr (bottom aligned) on the left of the associated row.
///
/// - start_addr (string, content):  The start address will be top aligned
/// - end_addr (string, content): The end address will be bottom aligned
#let section(start_addr, end_addr, span: 1) = {
  annotation(left, rowspan: span, inset: (x:5pt, y:2pt), box(height:100%, [
    #set text(0.8em, font: "Noto Mono", weight: 100)
    #align(top + end)[#start_addr]
    #align(bottom + end)[#end_addr]
    ]))
}

