// states
#let __default_row_height = state("bf-row-height", 2.5em);
#let __default_header_font_size = state("bf-header-font-size", 9pt);

#let _get_row_height(loc) = {
  __default_row_height.at(loc)
}

#let _get_header_font_size(loc) = {
  __default_header_font_size.at(loc)
}