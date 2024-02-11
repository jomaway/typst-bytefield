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

#let convert_data_fields_to_table_cells(data_fields, row_width: 32) = {
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
        x: calc.rem(idx,row_width),
        y: int(idx/row_width) + 1,  // +1 because of the bitheader 
        content: field.content,
        fill: field.fill,
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
      #box(height: 2.5em, width: 100%, stroke: 1pt + black)[#c.content]  // ToDo: make height changeable again.
    ]
  })
}

#let get_aligned_header_label(num, excludes) = {
  let bitheader_font_size = 9pt;
  let alignment = if (bitheader == "all") {center} 
  else {
    if (msb_first) {
      if (num == 0) {end} else if (num == (bits - 1)) { start } else { center }
    } else { 
      if (num == (bits - 1)) {end} else if (num == 0) { start } else { center }
    }
  }

  align(alignment, text(bitheader_font_size)[#num]);
}

#let calc_offsets(field_meta_data, bits_per_row, only_first_row: false) = {
  // compute offsets for bitheader
  let _offsets = field_meta_data.map(f => { f.start })

  if (only_first_row) { 
    _offsets.filter(value => value < bits_per_row ) 
  } else { 
    _offsets.map(value => calc.rem(value,bits_per_row))
  }
  
  _offsets.push(bits_per_row - 1);
  return _offsets
}

#let convert_bitheader_to_table_cells(bitheader, metadata) = {
  
  let bh_num_text(num) = text(9pt)[#num]
  let computed_offsets = calc_offsets(metadata.field_data, metadata.bits_per_row)
  let bits = metadata.bits_per_row
  let msb_first = metadata.msb

  let _bitheader =  if ( bitheader == "all" ) {
    // Show all numbers from 0 to total bits.
    range(bits).map(i => bh_num_text(i))
  } else if ( bitheader == "smart" or bitheader == "smart-firstline") {
    // Show nums aligned with given fields
    if msb_first == true {
      computed_offsets = computed_offsets.map(i => bits - i - 1);
    }
    range(bits).map(i => if i in computed_offsets { bh_num_text(i) } else {none})
  } else if ( type(bitheader) == array ) {
    // show given numbers from array
    range(bits).map(i => if i in bitheader { bh_num_text(i) } else {none})
  } else if ( type(bitheader) == int ) {
    // if an int is given show all multiples of this number
    let val = bitheader;
    range(bits).map(i =>
      if calc.rem(i,val) == 0 or i == (bits - 1) { bh_num_text(i) } 
      else { none })
  } else if ( bitheader == none ) {
    range(bits).map(_ => []);
  } else if (type(bitheader) == dictionary) {
    range(bits).map(i => [
      #set align(start + bottom)
      #let h_text = bitheader.at(str(i),default: "");
      #style(styles => {
        let size = measure(h_text, styles).width
        return box(height: size, inset:(left: 50%))[
          
          #if (h_text != "" and bitheader.at("marker", default: auto) != none){ place(bottom, line(end:(0pt, 5pt))) }
          #rotate(bitheader.at("angle", default: -60deg), origin: left, h_text)
        ]  
      })
    ])
  } else {
     panic("bitheader must be an integer,array, none, 'all' or 'smart'")
  }

  // revers bit order
  if msb_first == true {
    return _bitheader.rev()
  }

  return _bitheader
}

#let bytefield(
  bits: 32, 
  rowheight: 2.5em, 
  bitheader: auto, 
  msb_first: false,
  ..fields
) = {
  // Define default behavior - show 
  if (bitheader == auto) { bitheader = "smart"}
  
  // filter data cells 
  let data_fields = fields.pos().filter(f => f.type == "bitbox")

  // collect metadata into an dictionary
  let meta = (
    bits_per_row: bits,
    msb: msb_first, // if msb_first { "big" } else { "little" }
    field_data: calc_field_bounds(data_fields)
  )

  // convert 
  let data_cells = convert_data_fields_to_table_cells(data_fields, row_width: bits);
  let _bitheader = convert_bitheader_to_table_cells(bitheader, meta);
  
  // wrap inside a box
  box(width: 100%)[
    #gridx(
      columns: range(bits).map(i => 1fr),
      align: center + horizon,
      inset: (x:0pt, y: 4pt),
      .._bitheader,
      ..data_cells,
    )
  ]
}

// Low level API
#let bitbox(length_in_bits, content, fill: none) = (
  type: "bitbox",
  size: length_in_bits,   // length of the field 
  fill: fill,
  content: content,
  var: false, 
  show_size: false,
)

// High level API
#let bit(..args) = bitbox(1, ..args)
#let bits(len, ..args) = bitbox(len, ..args)
#let byte(..args) = bitbox(8, ..args)
#let bytes(len, ..args) = bitbox(len * 8, ..args)
#let padding(..args) = bitbox(auto, ..args)

// Rotating text for flags
#let flagtext(text) = align(center,rotate(270deg,text))
