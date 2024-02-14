// Bytefield - generate protocol headers and more
// Feel free to contribute with any features you think are missing.
// Still a WIP - alpha stage and a bit hacky at the moment

#import "@preview/tablex:0.0.8": tablex, cellx, gridx, hlinex, vlinex
#import "lib/utils.typ": *
#import "lib/asserts.typ": *
#import "lib/states.typ": *

#set text(font: "IBM Plex Mono")

#let bf-config(
  row_height: 2.5em,
  header_font_size: 9pt,
  content
  ) = {
  __default_row_height.update(row_height);
  __default_header_font_size.update(header_font_size)
  content
}

// calculates the cell position, based on the start_bit and the column count.
#let _get_cell_position(start, columns: 32, pre_cols: 1, header_rows: 1) = {
  let x = calc.rem(start,columns) + pre_cols
  let y = int(start/columns) + header_rows 
  return (x,y)
}

#let header_cell(num, pos: auto,  align: center) = (
  type: "header-cell",
  label: str(num),
  x: if (pos == auto) {num} else { pos },
  y: 0,
  align: align,
)

#let convert_bitheader_to_table_cells(bitheader, data_cells, meta) = {
  let bitheader_font_size = 9pt;
  let msb_first = meta.header.msb
  let bpr = meta.cols.main

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
      _values = data_cells.map(f => if f.range.start == f.range.end { (f.range.start,) } else {(f.range.start, f.range.end)}).flatten()
      if msb_first {
        _values = _cells.filter(value => value < bpr).map(value => { value = (bpr -1) - value; value })
      } else {
        _values = _cells.filter(value => value < bpr)
      }
      
    } else if (bitheader == "smart") {
      if msb_first {
        _values = data_cells.map(f => f.range.start).filter(value => value < bpr).map(value => { value = (bpr -1) - value; value })
      } else {
        _values = data_cells.map(f => f.range.start).filter(value => value < bpr)
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

    if msb_first == true {
      // reverse bit order
      _cells = _values.map(value => header_cell(value, pos: (bpr -1) - value))
    } else {
      _cells = _values.map(value => { header_cell(value) })
    }

    return _cells.map(c => {
      
        cellx(x: c.x + meta.cols.pre, y: c.y)[
          #locate(loc => {
            text(_get_header_font_size(loc),c.label)
          })]
      })
  }
  
  if (header_type == dictionary) {
    // custom dict
    let numbers = bitheader.at("numbers",default:none) 
    return  range(bpr).map(i => [
      #set align(start + bottom)
      #let h_text = bitheader.at(str(i),default: "");
      #style(styles => {
        let size = measure(h_text, styles).width
        return [
          #box(height: size,inset:(left: 50%))[
          #if (h_text != "" and bitheader.at("marker", default: auto) != none){ place(bottom, line(end:(0pt, 5pt))) }
          #rotate(bitheader.at("angle", default: -60deg), origin: left, h_text)
          ]
          #if (type(numbers) == bool and numbers and h_text != "") {
              v(-0.5em)
              align(center, text(bitheader_font_size)[#i])
          } else if (numbers == "all") {
            v(-0.5em)
            align(center, text(bitheader_font_size)[#i])
          } else if (numbers in ("smart","smart-firstline","bounds")) {
            if (i in _cells.map(c => c.x)) {
              v(-0.5em)
              align(center, text(bitheader_font_size)[#i])
            }
          } else if (type(numbers) == array) {
            if (i in array) {
              v(-0.5em)
              align(center, text(bitheader_font_size)[#i])
            }
          }
        ]  
      })
    ])
  }
}

#let _get_max_annotation_levels(annotations) = {
  let left_max_level = 0
  let right_max_level = 0
  for field in annotations {
    let (side, level, ..) = field;
    if (side == left) {
      left_max_level = calc.max(left_max_level,level)
    } else {
      right_max_level = calc.max(right_max_level,level)
    }
  }
  return (
    pre_levels: left_max_level +1,
    post_levels:  right_max_level +1,
  )
}


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
      msb: false,
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


#let generate_data_cells(data_fields, meta) = {
  let bpr = meta.cols.main;

  let _cells = ();
  let idx = 0;

  for field in data_fields {
    assert_data_field(field)
    let len = if (field.size == auto) { bpr - calc.rem(idx, bpr) } else { field.size }  
    
    // calc field bound range
    let start = idx;
    let end = (idx + len) - 1;
    field.insert("range", ("start": start, "end": end))

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
        _stroke.at("bottom") = field.fill
      }
      if (slice_idx > 0){
        _stroke.at("top") = none
      }

      _cells.push(
        (
          bf-cell-type: "data-cell",
          field-index: field.bf-idx,
          size: cell_size,
          range: ("start": start, "end": end),
          label: field.content,
          cell-format: (
            fill: field.fill,
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

#let generate_note_cells(fields, data_cells, meta) = {
  let note_fields = fields.filter(f => f.type == "annotation").map(a => {
    _set_anchor(a, _get_index_of_next_bitfield(a.bf-idx, fields))
  })
  let _cells = ()
  let bpr = meta.cols.main
  //let note_fields = fields.filter(f => f.type == "annotation");

  for annotation in note_fields {
    let (side, level, args, body) = annotation;
    let anchor_field = data_cells.find(f => f.field-index == annotation.anchor) // _get_field_from_index(field_data, annotation.anchor);
    let row = meta.header.rows;
   
    if anchor_field != none {
       let anchor_start = anchor_field.range.start
       row = int(anchor_start/bpr) + meta.header.rows
    } else {
      // if no anchor could be found, fail silently
      continue
    }

    _cells.push((
      bf-cell-type: "note-cell",
      field-index: annotation.bf-idx,
      x: if (side == left) {
        meta.cols.pre - level - 1
      } else {
        meta.cols.pre + bpr + level
      },
      y: int(row),
      label: body,
      args: args,
    )) 
  }
  return _cells
}

#let generate_cells(meta, fields) = {
  // data fields 
  let data_fields = fields.filter(f => f.type == "bitbox")
  let data_cells = generate_data_cells(data_fields, meta);
  // note fields
  let note_fields = fields.filter(f => f.type == "annotation").map(a => {
    _set_anchor(a, _get_index_of_next_bitfield(a.bf-idx, data_fields))
  })
  let note_cells = generate_note_cells(fields, data_cells, meta);
  return (data_cells, note_cells).flatten()
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

#let generate_table(meta, cells) = {
  let cells = cells.map(c => {
    let cell_type = c.at("bf-cell-type", default: none)
    if (cell_type == "data-cell") {
      map_data_cells_to_tablex_cells(c)
    } else if (cell_type == "note-cell") {
      map_note_cells_to_tablex_cells(c)
    }
  })

  let bitheader = convert_bitheader_to_table_cells(meta.header.data, cells.filter(c => c.at("bf-cell-type", default: none) == "data-cell"), meta);
  let bitheader = ([],)*meta.cols.pre + bitheader + ([],)*meta.cols.post

  let table = locate(loc => {
      gridx(
        columns:  meta.side.left.cols + range(meta.cols.main).map(i => 1fr) + meta.side.right.cols,
        rows: (auto, _get_row_height(loc)),
        align: center + horizon,
        inset: (x:0pt, y: 4pt),
        ..bitheader,
        ..cells
      )
    })
  return table
}



// bytefield
#let bytefield(
  bits: 32, 
  bitheader: auto, 
  msb_first: false,
  pre: auto,
  post: auto,
  ..fields
) = {
  // Index all fields
  let _fields = fields.pos().enumerate().map(((idx, f)) => {
    assert_field(f);
    f.insert("bf-idx", idx);
    f
  })

  let args = (
    bpr: bits,
    msb: msb_first,
    bitheader: bitheader,
    side: (left_cols: pre, right_cols: post)
  )

  let meta = generate_meta(args, _fields)
  let cells = generate_cells(meta, _fields)
  let table = generate_table(meta, cells)
  return table

  // filter data cells 
  let data_fields = _fields.filter(f => f.type == "bitbox")
  let note_fields = _fields.filter(f => f.type == "annotation").map(a => {
    _set_anchor(a, _get_index_of_next_bitfield(a.bf-idx, data_fields))
  })

  // collect metadata into an dictionary
  let meta = (
    bits_per_row: bits,
    header_data: (
      msb: msb_first, // if msb_first { "big" } else { "little" }
    ),
    field_data: calc_field_bounds(data_fields),
    annotations: calc_annotation_levels(note_fields),
  )

  // convert auto pre and post columns 
  if (pre == auto) {
    pre = (auto,)*meta.annotations.pre.levels
  }
  if (post == auto) {
    post = (auto,)*meta.annotations.post.levels
  }

  // convert 
  let data_cells = convert_data_fields_to_table_cells(data_fields, meta);
  let annotation_cells = convert_annotations_to_table_cells(note_fields, meta);
  let _bitheader = convert_bitheader_to_table_cells(bitheader, meta);
  let _bitheader = ([],)*meta.annotations.pre.levels + _bitheader + ([],)*meta.annotations.post.levels

  // wrap inside a box
  box(width: 100%)[
    #locate(loc => {
      gridx(
        columns:  pre + range(bits).map(i => 1fr) + post,
        rows: (auto, _get_row_height(loc)),
        align: center + horizon,
        inset: (x:0pt, y: 4pt),
        .._bitheader,
        ..data_cells,
        ..annotation_cells,
      )
    })
  ]
}


// Low level API
#let bitbox(length_in_bits, content, fill: none, stroke: auto) = (
  type: "bitbox",
  size: length_in_bits,   // length of the field 
  fill: fill,
  stroke: stroke,
  content: content,
)

#let annotation(side, level:0, ..args, body) = (
  type: "annotation",
  side: side,
  level: level,
  args: args,
  body: body
)

// High level API
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




