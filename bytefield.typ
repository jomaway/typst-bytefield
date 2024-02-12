// Bytefield - generate protocol headers and more
// Feel free to contribute with any features you think are missing.
// Still a WIP - alpha stage and a bit hacky at the moment

#import "@preview/tablex:0.0.6": tablex, cellx, gridx
#import "@preview/oxifmt:0.2.0": strfmt

#set text(font: "IBM Plex Mono")

#let assert_data_field(field) = {
  assert(type(field) == dictionary, message: strfmt("expected field to be a dictionary, found {}", type(field)));
  assert(type(field.size) == int or field.size == auto, message: strfmt("expected auto or integer for parameter size, found {} ", type(field.size)))
}

#let calc_field_bounds(data_fields) = {
  let bounds = ();
  let idx = 0;

  for (i,field) in data_fields.enumerate() {
    assert_data_field(field)
    field.size = if (field.size == auto) { 32 - calc.rem(idx, 32) } else { field.size }  // 32 is a workaround and causes errors. will be fixed soon.
    let start = idx;
    idx += field.size;

    bounds.push((
      type: "field-meta-data",
      index: i,
      size: field.size,
      start: start,
      end: idx -1,
    ));
  }

  return bounds
}

#let convert_data_fields_to_table_cells(data_fields, metadata) = {
  let row_width = metadata.bits_per_row;
  let pre_size = metadata.pre.levels;
  let post_size = metadata.post.levels;

  let _cells = ();
  let idx = 0;

  for field in data_fields {
    assert_data_field(field)
    let len = if (field.size == auto) { row_width - calc.rem(idx, row_width); } else { field.size }

    while len > 0 {
      let rem_space = row_width - calc.rem(idx, row_width);
      let cell_size = calc.min(len, rem_space);
      
      _cells.push((
        type: "data-cell",
        len: cell_size,
        x: calc.rem(idx,row_width) + pre_size,
        y: int(idx/row_width) + 1,  // +1 because of the bitheader 
        content: field.content,
        fill: field.fill,
        stroke: (0.7pt + black) // prepare for multirow fields without strokes in between.
      ))

      field.content = "..."

      // prepare for next cell
      idx += cell_size;
      len -= cell_size;
    }
  }

  // map data-cell to tablex-dict-type cell
  return _cells.map(c => {
    cellx(
      x: c.x,
      y: c.y,
      colspan: c.len,
      inset: 0pt,
      fill: c.fill,
    )[
      #box(height: 2.5em, width: 100%, stroke: c.stroke)[#c.content]  // ToDo: make height changeable again.
    ]
  })
}

#let header_cell(num, pos: auto,  align: center) = (
  type: "header-cell",
  label: str(num),
  x: if (pos == auto) {num} else { pos },
  y: 0,
  align: align,
)


#let convert_bitheader_to_table_cells(bitheader, metadata) = {
  let bitheader_font_size = 9pt;
  let msb_first = metadata.msb

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
    _cells  = range(metadata.bits_per_row, step: bitheader)
  } else if (header_type == array) {
    // show header numbers from array
    _cells = bitheader
  } else if (header_type == str) {
    // string
    if (bitheader == "bounds") {
      if msb_first {
        _cells = metadata.field_data.map(f => (f.start, f.end)).flatten().filter(value => value < metadata.bits_per_row).map(value => { value = (metadata.bits_per_row -1) - value; value })
      } else {
        _cells = metadata.field_data.map(f => (f.start, f.end)).flatten().filter(value => value < metadata.bits_per_row)
      }
      
    } else if (bitheader == "smart") {
      if msb_first {
        _cells = metadata.field_data.map(f => f.start).filter(value => value < metadata.bits_per_row).map(value => { value = (metadata.bits_per_row -1) - value; value })
      } else {
        _cells = metadata.field_data.map(f => f.start).filter(value => value < metadata.bits_per_row)
      }
    } else if (bitheader == "all") {
      _cells = range(metadata.bits_per_row)
    }
    
  }  

  if (header_type != dictionary) {
    // Add last one in all cases
    if (_cells.find(c => c == metadata.bits_per_row - 1) == none) {
      _cells.push(metadata.bits_per_row -1)
    }
    // Add first one in any case 
    if (_cells.find(c => c == 0) == none) {
      _cells.push(0)
    }

    if msb_first == true {
      // reverse bit order
      _cells = _cells.map(value => header_cell(value, pos: (metadata.bits_per_row -1) - value))
    } else {
      _cells = _cells.map(value => { header_cell(value) })
    }

    return _cells.map(c => {
      cellx(x: c.x + metadata.pre.levels , y: c.y)[#text(bitheader_font_size,c.label)]
    })
  }
  
  if (header_type == dictionary) {
    // custom dict
    let numbers = bitheader.at("numbers",default:none) 
    return  range(metadata.bits_per_row).map(i => [
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

#let convert_annotations_to_table_cells(annotations, pre, post, bits) = {
  let _cells = ()

  // calculate cells
  // let current_row = if (bitheader != none) { 1 } else { 0 };
  let current_row_counter = (1,1)

  for field in annotations {
    let (side, level, args, body) = field;

    let current_row = if (side == left) { 
      let tmp = current_row_counter.at(0)
      if ( level == 0 ) {current_row_counter.at(0) += 1;}
      tmp;
    } else {
      let tmp = current_row_counter.at(1)
      if ( level == 0 ) {current_row_counter.at(1) += 1;}
      tmp;
    }
    
    let y = int(current_row)
    let x = if (side == left) {
      pre.len() - level - 1
    } else {
      pre.len() + bits + level
    }

    _cells.push((
      type: "annotation-cell",
      x:x,
      y:y,
      label: body,
      args: args,
    ))
    
  }
  return _cells.map(c => cellx(
    x:c.x,
    y:c.y,
    ..(c.args),
  )[#box(height:100%)[#c.label]])

}

#let calc_annotation_levels(annotations) = {
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
    pre: (levels: left_max_level +1),
    post: (levels: right_max_level +1),
  )
}

#let bytefield(
  bits: 32, 
  rowheight: 2.5em, 
  bitheader: auto, 
  msb_first: false,
  pre: auto,
  post: auto,
  ..fields
) = {
  // filter data cells 
  let data_fields = fields.pos().filter(f => f.type == "bitbox")
  let annotations = fields.pos().filter(f => f.type == "annotation")
  // collect metadata into an dictionary
  let meta = (
    bits_per_row: bits,
    msb: msb_first, // if msb_first { "big" } else { "little" }
    field_data: calc_field_bounds(data_fields),
    ..calc_annotation_levels(annotations),
  )
  // return meta.field_data
  // convert auto pre and post columns 
  if (pre == auto) {
    pre = (auto,)*meta.pre.levels
  }
  if (post == auto) {
    post = (auto,)*meta.post.levels
  }

  // convert 
  let data_cells = convert_data_fields_to_table_cells(data_fields, meta);
  let annotation_cells = convert_annotations_to_table_cells(annotations, pre, post, bits);

  let _bitheader = convert_bitheader_to_table_cells(bitheader, meta);
  let _bitheader = ([],)*meta.pre.levels + _bitheader + ([],)*meta.post.levels
  
  

  // wrap inside a box
  box(width: 100%)[
    #gridx(
      columns:  pre + range(bits).map(i => 1fr) + post,
      align: center + horizon,
      inset: (x:0pt, y: 4pt),
      .._bitheader,
      ..data_cells,
      ..annotation_cells,
    )
  ]
}


// Low level API
#let bitbox(length_in_bits, content, fill: none, stroke: auto) = (
  type: "bitbox",
  size: length_in_bits,   // length of the field 
  fill: fill,
  stroke: stroke,
  content: content,
  show_size: false,
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




