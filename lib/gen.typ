#import "types.typ": *
#import "utils.typ": *
#import "asserts.typ": *
#import "states.typ": *

#import "@preview/tablex:0.0.8": tablex, cellx, gridx, hlinex, vlinex

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

#let generate_header_field(fields, meta) = {
    // This is a bit of a mess and needs a refactor after the new bitheader user api is defined. 
    let data_fields = fields.filter(f => f.field-type == "data-field")
    let msb = meta.header.msb
    let bpr = meta.cols.main
    let bitheader = meta.header.data
    let _values = ()

    if (bitheader == auto){
      // auto shows all offsets in the first row.
      bitheader = range(meta.cols.main, step: int(bpr/4)) + ((meta.cols.main -1),)
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

    let labels_from_values(values) = {
      values = values.map(val => (str(val): "") )
      values.join()
    }

    let labels = labels_from_values(_values) 

    let bh = header-field(
      end: bpr, 
      msb: msb, 
      labels: if (header_type == dictionary) { labels + bitheader.at("data", default: (:)) } else { labels },
    )

    return bh
}

#let _generate_labels_from_values(values) = {
  values = values.map(val => (str(val): "") )
  values.join()
}

#let _get_header_autofill_values(autofill, fields, meta) = {
  if (autofill == "bounds") {
    return fields.filter(f => f.field-type == "data-field").map(f => if f.data.range.start == f.data.range.end { (f.data.range.start,) } else {(f.data.range.start, f.data.range.end)}).flatten()
  } else if (autofill == "all") {
    return range(meta.cols.main)
  } else {
    return fields.filter(f => f.field-type == "data-field").map(f => f.data.range.start).filter(value => value < meta.cols.main).flatten()
  }
}

#let generate_bf-fields(fields, meta) = {

  // This part must be changed if the user low level api changes.
  let _fields = fields.enumerate().map(((idx, f)) => {
    assert.eq(type(f),dictionary, message: strfmt("expected field to be a dictionary, found {}", type(f)));
    assert.ne(f.at("type", default: none), none, message: "Could not find field.type")
    let type = if(f.type == "bitbox") { "data-field" } else if (f.type == "annotation") { "note-field" } else if (f.type == "bitheader") { "header-field" } else { "unknown" }
    bf-field(type, idx, data:f)
  })

  // Define some variables
  let bpr = meta.cols.main 
  let range_idx = 0;
  let fields = ();

  for f in _fields.filter(f => is-data-field(f)) {
    let size = if (f.data.size == auto) { bpr - calc.rem(range_idx, bpr) } else { f.data.size }  
    let start = range_idx;
    range_idx += size;
    let end = range_idx - 1;
    fields.push(data-field(f.field-index, size, start, end, f.data.body, format: f.data.format))
  }

  for f in _fields.filter(f => is-note-field(f)) {
    let anchor = _get_index_of_next_data_field(f.field-index, _fields)
    fields.push(note-field(f.field-index, anchor, f.data.side, level: f.data.level, f.data.body, rowspan: f.data.rowspan, format: f.data.format))
  }

  for f in _fields.filter(f => is-header-field(f)) {
    let autofill_values = _get_header_autofill_values(f.data.autofill, fields, meta);
    let labels = _generate_labels_from_values(autofill_values);
    labels += f.data.at("labels", default: (:))
    
    fields.push(header-field(
      end: bpr, 
      msb: f.data.msb == left,
      labels: labels,
    ))
  }


  // for f in _fields {
  //   fields.push(if (is-data-field(f)) {
  //     // index, size, start, end, label, format: none
  //     let size = if (f.data.size == auto) { bpr - calc.rem(range_idx, bpr) } else { f.data.size }  
  //     let start = range_idx;
  //     range_idx += size;
  //     let end = range_idx - 1;
  //     data-field(f.field-index, size, start, end, f.data.body, format: f.data.format)
  //   } else if is-note-field(f) {
  //     // index, anchor, side, level:0, label, format: none
  //     let anchor = _get_index_of_next_data_field(f.field-index, _fields)
  //     note-field(f.field-index, anchor, f.data.side, level: f.data.level, f.data.body, rowspan: f.data.rowspan, format: f.data.format)
  //   } else if is-header-field(f) {
  //     let autofill = f.data.autofill
  //     header-field(
  //       end: bpr, 
  //       msb: f.data.msb == left,
  //       labels: f.data.at("labels", default: (:)),
  //     )
  //   }
  //   else {
  //     // pass through
  //     f
  //   })
  // }

  return fields 
}

#let generate_data_cells(fields, meta) = {
  let data_fields = fields.filter(f => f.field-type == "data-field")
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

      let x = calc.rem(idx,bpr) + meta.cols.pre
      let y = int(idx/bpr) + meta.header.rows
      let cell_format = (
        fill: field.data.label_format.fill,
        stroke: _stroke,
      )
      let cell_index = (field.field-index, slice_idx)
      // new version.
      _cells.push(
        //type, grid, x, y, colspan:1, rowspan:1, label, idx ,format: auto
        bf-cell("data-cell", 
          x: calc.rem(idx,bpr) + meta.cols.pre, 
          y: int(idx/bpr) + meta.header.rows, 
          colspan: cell_size, 
          label: field.data.label, 
          cell-idx: (field.field-index, slice_idx), 
          format: cell_format 
        )
      )

      field.data.label = "..."

      // prepare for next cell
      idx += cell_size;
      len -= cell_size;
      slice_idx += 1;
    }
  }
  return _cells
}

#let generate_note_cells(fields, meta) = {
  let note_fields = fields.filter(f => f.field-type == "note-field")
  let _cells = ()
  let bpr = meta.cols.main

  for field in note_fields {
    let side = field.data.side
    let level = field.data.level

    let anchor_field = fields.find(f => f.field-index == field.data.anchor) // _get_field_from_index(field_data, annotation.anchor);
    let row = meta.header.rows;
   
    if anchor_field != none {
       let anchor_start = anchor_field.data.range.start
       row = int(anchor_start/bpr) + meta.header.rows
    } else {
      // if no anchor could be found, fail silently
      continue
    }

    _cells.push(
      bf-cell("note-cell", 
          cell-idx: (field.field-index, 0),
          x: if (side == left) {
            meta.cols.pre - level - 1
          } else {
            meta.cols.pre + bpr + level
          },
          y: int(row), 
          rowspan: field.data.rowspan,
          label: field.data.label, 
          format: field.data.format,
        )
    ) 
  }
  return _cells
}

#let generate_header_cells(fields, meta) = {
  let header_fields = fields.filter(f => f.field-type == "header-field")
  let bpr = meta.cols.main

  let _cells = ()

  for header in header_fields {
    // Todo: Maybe this can be improved
    let cell = header.data.at("labels", default: (:)).pairs().map(((num,text)) => (num: int(num), text: text)).filter(((num,_)) => num < header.data.range.end).dedup().map(((num, text)) => {
      if header.data.msb {
        header_cell(num, label: text, pos: (bpr -1) - num, meta)
      } else {
        header_cell(num, label: text, meta)
      }
    })

    _cells.push(cell)

  }

  return _cells
}

#let generate_cells(meta, fields) = {
  // data 
  let data_cells = generate_data_cells(fields, meta);
  // notes
  let note_cells = generate_note_cells(fields, meta);
  // bitheader 
  let header_cells = generate_header_cells(fields, meta);

  return (header_cells, data_cells, note_cells).flatten()
}

#let map_cells(cells) = {
  cells.map(c => {
    let cell_type = c.at("cell-type", default: none)

    let body = if (cell_type == "header-cell") {
      let label_text = c.label.text
      let label_num = c.label.num
      locate(loc => {
        style(styles => {
          set text(_get_header_font_size(loc))
          set align(center + bottom)
          let size = measure(label_text, styles).width
          stack(dir: ttb, spacing: 4pt,
            if is-not-empty(label_text) {
              box(height: size, inset: (left: 50%, rest: 0pt))[
                #set align(start)
                #rotate(c.format.at("angle", default: -60deg), origin: left, label_text)
              ]
            },
            if (is-not-empty(label_text) and c.format.at("marker", default: auto) != none){ line(end:(0pt, 5pt)) },
            label_num,
          )
          
        })
      }) 
    } else {
      box(
        height: 100%,
        width: if (cell_type == "data-cell") { 100% } else {auto},
        stroke: c.format.at("stroke", default: none),
        c.label
      )
    }

    return cellx(
      x: c.position.x,
      y: c.position.y,
      colspan: c.span.cols,
      rowspan: c.span.rows,
      inset: c.format.at("inset", default: 0pt),
      fill: c.format.at("fill", default: none),
      body
    )
  })
}

#let generate_table(meta, cells) = {
  let cells = map_cells(cells);

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