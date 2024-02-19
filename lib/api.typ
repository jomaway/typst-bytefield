#import "gen.typ": *
#import "types.typ": *

/// Create a new bytefield.
///
/// - bits (int): Number of bits which are shown per row.
/// - pre (auto, int , relative , fraction , array): This is specifies the columns for annotations on the *left* side of the bytefield
/// - post (auto, int , relative , fraction , array): This is specifies the columns for annotations on the *right* side of the bytefield
///
/// - ..fields (_field, annotation, bitheader): arbitrary number of data fields, annotations and headers which build the bytefield. 
/// -> bytefield
#let bytefield(
  bpr: 32, 
  msb: right,
  pre: auto,
  post: auto,
  ..fields
) = {

  let args = (
    bpr: bpr,
    msb: msb,
    side: (left_cols: pre, right_cols: post)
  )

  let meta = generate_meta(fields.pos(), args)
  let fields = finalize_fields(fields.pos(), meta)
  let cells = generate_cells(meta, fields)
  let table = generate_table(meta, cells)
  return table
}

/// Base for bit, bits, byte, bytes functions
///
/// This is just a base function which is used by the other functions and should not be called directly
#let _field(size, fill: none, body) = {
  data-field(none, size, none, none, body, format: (fill: fill))
}

/// Add a bit to the bytefield
#let bit(..args) = _field(1, ..args)
/// Add multiple bits to the bytefield
#let bits(len, ..args) = _field(len, ..args)
/// Add a byte to the bytefield
#let byte(..args) = _field(8, ..args)
/// Add multiple bytes to the bytefield
#let bytes(len, ..args) = _field(len * 8, ..args)
/// Add a flag to the bytefield.
#let flag(text,..args) = _field(1,align(center,rotate(270deg,text)),..args)
/// Add a field which extends to the end of the row
///
/// Warning! This can cause problems with msb:left
#let padding(..args) = _field(auto, ..args)


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

  let body = if (bracket == false) { content } else {
    grid(
      columns:2,
      gutter: inset,
      _first,
      _second
    )
  }

  let format = (
    inset: if (bracket == false) { inset } else { (x:2pt, y:1pt) },
    align:_align+horizon,
  )

  return note-field(none, none, side, level:level, body, format: format, rowspan: rowspan)
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
  note(
    left, 
    rowspan: span, 
    inset: (x:5pt, y:2pt), 
    box(height:100%, [
      #set text(0.8em, font: "Noto Mono", weight: 100)
      #align(top + end)[#start_addr]
      #align(bottom + end)[#end_addr]
    ]))
}

/// Bitheader
///
/// - msb (left, right):  This sets the bit order
/// - numbers (auto, none): 
///
#let bitheader(
  msb: right,
  // Defines the range of numbers which should be shown.
  range: (auto,auto),  // only for debugging will be removed later.
  autofill: auto,
  numbers: auto,  
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
      last += step
    }
    if numbers != none { numbers = _numbers }
  }

  let format = (
    angle: args.named().at("angle", default: -60deg),
    text-size: args.named().at("text-size",default: auto),
    marker: args.named().at("marker", default: true),
  )
  
  return header-field(
      start: range.at(0, default: auto),  // todo. fix this
      end: range.at(1, default: auto),    // todo. fix this
      msb: msb,
      autofill: autofill,
      numbers: numbers,
      labels: labels,
      ..format
    )
}
