#import "@preview/oxifmt:0.2.0": strfmt


#let assert_bf-field(field) = {
  assert.eq(type(field),dictionary, message: strfmt("expected field to be a dictionary, found {}", type(field)));
  let bf-type = field.at("bf-type", default: none)
  assert.eq(bf-type, "bf-field", message: strfmt("expected bf-type of 'bf-field', found {}",bf-type));
  let field-type = field.at("field-type", default: none)
  assert.ne(field-type, none, message: strfmt("could not find field-type at bf-field {}", field));
}

#let assert_data-field(field) = {
  assert_bf-field(field);
  let field-type = field.at("field-type", default: none)
  assert.eq(field-type, "data-field", message: strfmt("expected field-type == data-field, found {}",field-type))
  let size = field.data.size;
  assert(type(size) == int, message: strfmt("expected integer for parameter size, found {} ", type(size)))
}

#let assert_field(field) = {
  assert.eq(type(field),dictionary, message: strfmt("expected field to be a dictionary, found {}", type(field)));
  assert.ne(field.at("type", default: none), none, message: "Could not find field.type")
}

#let _get_field_type(field) = {
  assert_field(field);
  return field.at("type", default: none);
}

#let assert_data_field(field) = {
  assert_field(field);
  assert.eq(_get_field_type(field), "bitbox", message: strfmt("expected field.type to be 'bitbox', found {}",_get_field_type(field)));
  assert(type(field.size) == int or field.size == auto, message: strfmt("expected auto or integer for parameter size, found {} ", type(field.size)))
}

#let assert_annotation(field) = {
  assert_field(field);
  assert.eq(_get_field_type(field), "annotation", message: strfmt("expected field.type to be 'annotation', found {}",_get_field_type(field)));
}