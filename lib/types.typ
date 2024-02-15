
#let bf-field(index, type, data) = (
  bf-type: "bf-field",
  field-index: index,
  field-type: type, 
  data: data, 
)

#let data-field(index, size, start, end, label, format: none) = (
  bf-type: "bf-field",
  field-index: index,
  field-type: "data-field", 
  data: (
    size: size,
    range: ("start": start, "end": end),
    label: label,
    label_format: format,
  )
)

#let note-field(index, anchor, side, level:0, label, format: none, rowspan: 1) = (
  bf-type: "bf-field",
  field-index: index,
  field-type: "note-field", 
  data: (
    anchor: anchor,
    side: side,
    level: level,
    label: label,
    format: format,  // TODO
    rowspan: rowspan,
  )
)

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

#let data_cell() = {
  (
    bf-type: "bf-cell",
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
}

#let note_cell() = {
  (
    bf-type: "bf-cell",
    bf-cell-type: "note-cell",
    field-index: annotation.bf-idx,
    anchor: annotation.anchor,
    x: if (side == left) {
      meta.cols.pre - level - 1
    } else {
      meta.cols.pre + bpr + level
    },
    y: int(row),
    label: body,
    args: args,
  )
}

