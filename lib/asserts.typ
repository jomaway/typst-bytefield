#import "@preview/oxifmt:0.2.0": strfmt

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