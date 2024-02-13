

// insert a value into an dict and return the dict
#let dict_insert_and_return(dict, key, value) = {
  assert.eq(type(dict), dictionary);
  assert.eq(type(key), str);
  dict.insert(key,value);
  return dict
}


// Getters 
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


// Setters
#let _set_anchor(field,anchor_idx) = {
  dict_insert_and_return(field, "anchor", anchor_idx)
}