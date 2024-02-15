// bf-field
#let bf-field(type, index, data: none) = (
  bf-type: "bf-field",
  field-type: type, 
  field-index: index,
  data: data, 
)

// data-field holds information about an field inside the main grid.
#let data-field(index, size, start, end, label, format: none) = {
  bf-field("data-field", index,
    data: (
      size: size,
      range: (start: start, end: end),
      label: label,
      label_format: format,
    )
  )
}

// note-field holds information about an field outside (left or right) the main grid.
#let note-field(index, anchor, side, level:0, label, format: none, rowspan: 1) = {
  bf-field("note-field", index,
    data: (
      anchor: anchor,
      side: side,
      level: level,
      label: label,
      format: format,  // TODO
      rowspan: rowspan,
    )
  )
}

// header-field hold information about a complete header row. Usually this is the top level header.
#let header-field(start: 0, end: 32, msb: false, numbers: true, labels: (:), ..args) = {
  // header-field must have index 0.
  bf-field("header-field", none,
    data: (
      // This is at the moment always 0 - (bpr), but in the future there might be header fields between data rows. 
      range: (start: start, end: end),
      // Defines the order of the bits. false: start - end, true: end - start
      msb: msb,
      // Defines if the numbers should be shown.
      numbers: numbers,
      labels: labels,
      format: (
        angle: 40deg,
        text-size: auto, // connect to global setting
        marker: true, // false
      )
    )
  )
}

// bf-cell holds all information which are necessary for cell positioning inside the table. 
#let bf-cell(type, grid: center, x: auto, y: auto, colspan:1, rowspan:1, label: none, cell-idx: (auto, auto) ,format: auto) = (
  bf-type: "bf-cell",
  cell-type: type,
  cell-index: cell-idx,  // cell index is a tuple (field-index, slice-index)
  // has-next-slice: false,  // indicates if a cell follows which belongs to the same field.
  position: (
    grid: grid,
    x: x,
    y: y,
  ),
  span: (
    rows: rowspan,
    cols: colspan,
  ),
  label: label,
  format: format,  // fill, stroke, align, inset, ...
  data: none,
)

#let header_cell(num, label: none, pos: auto, align: center + horizon, meta) = {
  bf-cell(
    "header-cell",
    cell-idx: none,
    x: (if (pos == auto) {num} else { pos }) + meta.cols.pre,
    y: 0,
    label: (
      num: str(num),
      text: label,
    ),
    format: (
      marker: auto,
      angle: -60deg,
      align: align,
      inset: (x: 0pt, y: 4pt),
    )
  )
}