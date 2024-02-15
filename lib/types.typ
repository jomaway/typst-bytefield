
#let bf-field(type, index, data: none) = (
  bf-type: "bf-field",
  field-type: type, 
  field-index: index,
  data: data, 
)

#let data-field(index, size, start, end, label, format: none) = {
  bf-field("data-field", index,
    data: (
      size: size,
      range: ("start": start, "end": end),
      label: label,
      label_format: format,
    )
  )
}

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

#let bf-cell(type, grid, x, y, label, idx ,format: auto) = (
  bf-type: "bf-cell",
  cell-type: type,
  cell-index: idx,  // cell index is a tuple (field-index, slice-index)
  has-next-slice: false,  // indicates if a cell follows which belongs to the same field.
  position: (
    grid: grid,
    x: x,
    y: y,
  ), 
  label: label,
  format: format,  // fill, stroke, align, inset, ...
  data: none,
)

#let header_cell(num, pos: auto, align: center) = (
  bf-type: "bf-cell",
  bf-cell-type: "header-cell",
  label: str(num),
  x: if (pos == auto) {num} else { pos },
  y: 0,
  align: align,
)
