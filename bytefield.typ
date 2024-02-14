// Bytefield - generate protocol headers and more
// Feel free to contribute with any features you think are missing.
// Still a WIP - alpha stage and a bit hacky at the moment

#import "@preview/tablex:0.0.8": tablex, cellx, gridx, hlinex, vlinex
#import "lib/types.typ": *
#import "lib/utils.typ": *
#import "lib/asserts.typ": *
#import "lib/states.typ": *
#import "lib/api.typ": *

#set text(font: "IBM Plex Mono")

#let generate_meta(args,fields) = {
  // collect metadata into an dictionary

  let (pre_levels, post_levels) = _get_max_annotation_levels(fields.filter(f => f.type == "annotation"))
  let meta = (
    cols: (
      pre: pre_levels,
      main: args.bpr,
      post: post_levels,
    ),
    header: (
      rows: 1,
      msb: args.msb,
      data: args.bitheader,
    ),
    side: (
      left: (
        cols: if (args.side.left_cols == auto) { (auto,)*pre_levels } else { args.side.left_cols },
      ),
      right: (
        cols: if (args.side.right_cols == auto) { (auto,)*post_levels } else { args.side.right_cols },
      )
    )
  )
  return meta;
}

#let generate_bf-fields(fields, meta) = {
  let _fields = fields.enumerate().map(((idx, f)) => {
    assert_field(f);
    let type = if(f.type == "bitbox") { "data-field" } else if (f.type == "annotation") { "note-field" } else { "unknown" }
    bf-field(idx, type, f)
  })

  let bpr = meta.cols.main 
  let range_idx = 0;
  let fields = ();

  for f in _fields {
    fields.push(if (is-data-field(f)) {
      // index, size, start, end, label, format: none
      let size = if (f.data.size == auto) { bpr - calc.rem(range_idx, bpr) } else { f.data.size }  
      let start = range_idx;
      range_idx += size;
      let end = range_idx - 1;
      let _format = (fill: f.data.fill, stroke: f.data.stroke)
      data-field(f.field-index, size, start, end, f.data.content, format: _format)
    } else if is-note-field(f) {
      // index, anchor, side, level:0, label, format: none
      let anchor = _get_index_of_next_data_field(f.field-index, _fields)
      note-field(f.field-index, anchor, f.data.side, level: f.data.level, f.data.body)
    } else {
      // pass through
      f
    })
  }

  // _fields = _fields.map(f => {
  //   if (is-data-field(f)) {
  //     // index, size, start, end, label, format: none
  //     let size = if (f.data.size == auto) { bpr - calc.rem(range_idx, bpr) } else { f.data.size }  
  //     let start = range_idx;
  //     range_idx += size;
  //     let end = range_idx - 1;
  //     let _format = (fill: f.data.fill, stroke: f.data.stroke)
  //     data-field(f.field-index, size, start, end, f.data.content, format: _format)
  //   } else if is-note-field(f) {
  //     // index, anchor, side, level:0, label, format: none
  //     let anchor = _get_index_of_next_data_field(f.field-index, _fields)
  //     note-field(f.field-index, anchor, f.data.side, level: f.data.level, f.data.body)
  //   } else {
  //     // pass through
  //     f
  //   }
  // })

  return fields 
}

#let generate_data_cells(data_fields, meta) = {
  let bpr = meta.cols.main;

  let _cells = ();
  let idx = 0;

  for field in data_fields {
    assert_data-field(field)
    let len = field.data.size

    let slice_idx = 0;

    while len > 0 {
      let rem_space = bpr - calc.rem(idx, bpr);
      let cell_size = calc.min(len, rem_space);
      
      // calc stroke
      let _default_stroke = (1pt + black)
      let _stroke = (
        top: _default_stroke,
        bottom: _default_stroke,
        rest: _default_stroke,
      )
      
      if (len - cell_size) > 0 {
        _stroke.at("bottom") = field.data.label_format.fill
      }
      if (slice_idx > 0){
        _stroke.at("top") = none
      }

      _cells.push(
        (
          bf-cell-type: "data-cell",
          field-index: field.field-index,
          size: cell_size,
          range: field.data.range,
          label: field.data.label,
          cell-format: (
            fill: field.data.label_format.fill,
            stroke: _stroke,
          ),
          cell-position: (
            x: calc.rem(idx,bpr) + meta.cols.pre,
            y: int(idx/bpr) + meta.header.rows,
          ),
          slice-index: slice_idx,
          has_prev_slice: slice_idx > 0,
          has_next_slice: (len - cell_size) > 0,
        )
      )

      field.content = "..."

      // prepare for next cell
      idx += cell_size;
      len -= cell_size;
      slice_idx += 1;
    }
  }
  return _cells
}

#let generate_note_cells(fields, data_fields, meta) = {
  let note_fields = fields.filter(f => f.field-type == "note-field")
  let _cells = ()
  let bpr = meta.cols.main

  for field in note_fields {
    let side = field.data.side
    let level = field.data.level
    let label = field.data.label

    let anchor_field = data_fields.find(f => f.field-index == field.data.anchor) // _get_field_from_index(field_data, annotation.anchor);
    let row = meta.header.rows;
   
    if anchor_field != none {
       let anchor_start = anchor_field.data.range.start
       row = int(anchor_start/bpr) + meta.header.rows
    } else {
      // if no anchor could be found, fail silently
      continue
    }

    _cells.push((
      bf-cell-type: "note-cell",
      field-index: field.field-index,
      anchor: field.data.anchor,
      x: if (side == left) {
        meta.cols.pre - level - 1
      } else {
        meta.cols.pre + bpr + level
      },
      y: int(row),
      label: label,
      args: none,
    )) 
  }
  return _cells
}

#let generate_header_cells(data_fields, meta) = {
  let msb = meta.header.msb
  let bpr = meta.cols.main
  let bitheader = meta.header.data

  let _cells = ()
  let _values = ()
  //let _cells = range(metadata.bits_per_row).map(_ => none);
  if (bitheader == auto){
    // auto shows all offsets in the first row.
    bitheader = "smart"
  }

  let header_type = type(bitheader);
  if (header_type == none) {
    // don't show any bitheader at all.
    return () // quick path just return an empty array.
  } else if (header_type == int) {
    // show all multiples of the given value
    _values  = range(meta.cols.main, step: bitheader)
  } else if (header_type == array) {
    // show header numbers from array
    _values = bitheader
  } else if (header_type == str) {
    // string
    if (bitheader == "bounds") {
      _values = data_fields.map(f => if f.data.range.start == f.data.range.end { (f.data.range.start,) } else {(f.data.range.start, f.data.range.end)}).flatten()
      if msb {
        _values = _cells.filter(value => value < bpr).map(value => { value = (bpr -1) - value; value })
      } else {
        _values = _cells.filter(value => value < bpr)
      }
      
    } else if (bitheader == "smart") {
      if msb {
        _values = data_fields.map(f => f.data.range.start).filter(value => value < bpr).map(value => { value = (bpr -1) - value; value })
      } else {
        _values = data_fields.map(f => f.data.range.start).filter(value => value < bpr)
      }
    } else if (bitheader == "all") {
      _values = range(bpr)
    }
  }  

  if (header_type != dictionary) {
    _values = _values.dedup()
    // Add last one in all cases
    if (_values.find(c => c == bpr - 1) == none) {
      _values.push(bpr -1)
    }
    // Add first one in any case 
    if (_values.find(c => c == 0) == none) {
      _values.push(0)
    }

    if msb == true {
      // reverse bit order
      _cells = _values.map(value => header_cell(value, pos: (bpr -1) - value))
    } else {
      _cells = _values.map(value => { header_cell(value) })
    }

  }
  return _cells


  // TODO: refactor bitheader type
  // if (header_type == dictionary) {
  //   // custom dict
  //   let numbers = bitheader.at("numbers",default:none) 
  //   return  range(bpr).map(i => [
  //     #set align(start + bottom)
  //     #let h_text = bitheader.at(str(i),default: "");
  //     #style(styles => {
  //       let size = measure(h_text, styles).width
  //       return [
  //         #box(height: size,inset:(left: 50%))[
  //         #if (h_text != "" and bitheader.at("marker", default: auto) != none){ place(bottom, line(end:(0pt, 5pt))) }
  //         #rotate(bitheader.at("angle", default: -60deg), origin: left, h_text)
  //         ]
  //         #if (type(numbers) == bool and numbers and h_text != "") {
  //             v(-0.5em)
  //             align(center, text(bitheader_font_size)[#i])
  //         } else if (numbers == "all") {
  //           v(-0.5em)
  //           align(center, text(bitheader_font_size)[#i])
  //         } else if (numbers in ("smart","smart-firstline","bounds")) {
  //           if (i in _cells.map(c => c.x)) {
  //             v(-0.5em)
  //             align(center, text(bitheader_font_size)[#i])
  //           }
  //         } else if (type(numbers) == array) {
  //           if (i in array) {
  //             v(-0.5em)
  //             align(center, text(bitheader_font_size)[#i])
  //           }
  //         }
  //       ]  
  //     })
  //   ])
  // }
}

#let generate_cells(meta, fields) = {
  // data fields 
  let data_fields = fields.filter(f => f.field-type == "data-field")
  let data_cells = generate_data_cells(data_fields, meta);
  // note fields
  let note_fields = fields.filter(f => f.field-type == "note-field")
  let note_cells = generate_note_cells(fields, data_fields, meta);
  // bitheader cells
  let header_cells = generate_header_cells(data_fields, meta);

  return (header_cells, data_cells, note_cells).flatten()
}

#let map_data_cells_to_tablex_cells(cell) = {
  cellx(
    x: cell.cell-position.x,
    y: cell.cell-position.y,
    colspan: cell.size,
    inset: 0pt,
    fill: cell.cell-format.fill,
  )[
    #box(
      height: 100%, 
      width: 100%,
      stroke: cell.cell-format.stroke,
      )[#cell.label]  // debug output: #c.content (#c.x,#c.y) sl:#c.slice_idx, #c.next_slice
  ]
}

#let map_note_cells_to_tablex_cells(cell) = {
  cellx(x:cell.x,y:cell.y,..(cell.args),)[#box(height:100%)[#cell.label]]
}

#let map_header_cells_to_tablex_cells(cell, meta) = {
  cellx(x: cell.x + meta.cols.pre, y: cell.y)[
    #locate(loc => {
      text(_get_header_font_size(loc),cell.label)
    })
  ]
}

#let generate_table(meta, cells) = {
  let cells = cells.map(c => {
    let cell_type = c.at("bf-cell-type", default: none)
    if (cell_type == "data-cell") {
      map_data_cells_to_tablex_cells(c)
    } else if (cell_type == "note-cell") {
      map_note_cells_to_tablex_cells(c)
    } else if (cell_type == "header-cell") {
      map_header_cells_to_tablex_cells(c, meta)
    }
  })

  // TODO: new grid with subgrids.
  let table = locate(loc => {
      gridx(
        columns:  meta.side.left.cols + range(meta.cols.main).map(i => 1fr) + meta.side.right.cols,
        rows: (auto, _get_row_height(loc)),
        align: center + horizon,
        inset: (x:0pt, y: 4pt),
        // ..bitheader,
        ..cells
      )
    })
  return table
}

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

