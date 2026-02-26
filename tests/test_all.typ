#import "../bytefield.typ": *



#let run_tests_global_config = true
#let run_bitfield_tests = true
#let run_bitheader_tests = true
#let run_annotation_tests = true




#if (run_tests_global_config) [
  = Test global settings with `bf-config`

  #show: bf-config.with(
    row_height: 3em,         // default is 2.5em
    header_font_size: 0.8em,  // default is 9pt
  )

  #locate(loc => [
    row height: #_get_row_height(loc) \
    header font size: #_get_header_font_size(loc)
  ])
]




#if (run_bitfield_tests) [
  #import "test_bitfields.typ": *
  = Test bitfields

  #test_bitfield_all_colored
  #test_bitfield_all
]

#if (run_bitheader_tests) [
  #import "test_bitheader.typ": *
  = Test bitheader
  #test_bitheader_auto
  #test_bitheader_bounds
  #test_bitheader_custom_array

]


#if (run_annotation_tests) [
  #import "test_annotations.typ": *
  = Test annotations
  #test_annotation_simple
  #test_annotation_skipping
]