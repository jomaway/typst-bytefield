
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

#let header_cell(num, pos: auto, align: center + horizon, meta) = {
  bf-cell(
    "header-cell",
    cell-idx: none,
    x: (if (pos == auto) {num} else { pos }) + meta.cols.pre,
    y: 0,
    label: str(num),
    format: (
      align: align,
      inset: (x: 0pt, y: 6pt),
    )
  )
}