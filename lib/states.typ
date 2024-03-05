// states
#let __default_row_height = state("bf-row-height", 2.5em);
#let __default_header_font_size = state("bf-header-font-size", 9pt);
#let __default_field_font_size = state("bf-field-font-size", auto);
#let __default_note_font_size = state("bf-note-font-size", auto);

// function to use with show rule
#let bf-config(
  row_height: 2.5em,
  header_font_size: 9pt,
  field_font_size: auto,
  note_font_size: auto,
  content
  ) = {
  __default_row_height.update(row_height);
  __default_header_font_size.update(header_font_size)
  __default_field_font_size.update(field_font_size)
  __default_note_font_size.update(note_font_size)
  content
}


#let _get_row_height(loc) = {
  __default_row_height.at(loc)
}

#let _get_header_font_size(loc) = {
  __default_header_font_size.at(loc)
}

#let _get_field_font_size(loc) = {
  __default_field_font_size.at(loc)
}

#let _get_note_font_size(loc) = {
  __default_note_font_size.at(loc)
}