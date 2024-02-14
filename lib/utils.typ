#import "asserts.typ": *

// insert a value into an dict and return the dict
#let dict_insert_and_return(dict, key, value) = {
  assert.eq(type(dict), dictionary);
  assert.eq(type(key), str);
  dict.insert(key,value);
  return dict
}

// Check if a given field is a data-field
#let is-data-field(field) = {
  assert_bf-field(field);
  field.at("field-type", default: none) == "data-field"
}

// Check if a given field is a note-field
#let is-note-field(field) = {
  assert_bf-field(field);
  field.at("field-type", default: none) == "note-field"
}

// Return the index of the next data-field
#let _get_index_of_next_data_field(idx, fields) = {
  let res = fields.find(f => f.field-index > idx and is-data-field(f))
  if res != none { res.field-index } else { none }
}

// calculates the cell position, based on the start_bit and the column count.
#let _get_cell_position(start, columns: 32, pre_cols: 1, header_rows: 1) = {
  let x = calc.rem(start,columns) + pre_cols
  let y = int(start/columns) + header_rows 
  return (x,y)
}

// Getters 
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

#let _get_index_of_prev_bitfield(idx, fields) = {
  let res = fields.rev().find(f => f.bf-idx < idx and f.type == "bitbox")
  if res != none { res.bf-idx  } else { none }
}

#let _get_index_of_next_bitfield(idx, fields) = {
  let res = fields.find(f => f.bf-idx > idx and f.type == "bitbox")
  if res != none { res.bf-idx } else { none }
}

#let _get_field_from_index(fields, idx) = {
  return fields.filter(f => f.bf-idx == idx)
}

#let _get_pre_cols_len(meta) = {
  assert(type(meta.cols.pre) == int or type(meta.cols.pre) == array, message: "expected int or array, found {}")
  if (type(meta.cols.pre) == int) {
    return meta.cols.pre
  } else if (type(meta.cols.pre) == array) {
    return meta.cols.pre.len()
  } 
}

#let _get_post_cols_len(meta) = {
  assert(type(meta.cols.post) == int or type(meta.cols.post) == array, message: "expected int or array, found {}")
  if (type(meta.cols.post) == int) {
    return meta.cols.post
  } else if (type(meta.cols.post) == array) {
    return meta.cols.post.len()
  } 
}

// warning: not yet implemented
#let _get_pre_cols(meta) = {
  return meta.args.pre
}

// warning: not yet implemented
#let _get_post_cols(meta) = {
  return meta.args.post
}

// ------------
//   Setters
// ------------
#let _set_anchor(field,anchor_idx) = {
  dict_insert_and_return(field, "anchor", anchor_idx)
}