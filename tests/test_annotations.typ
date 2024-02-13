#import "test_setup.typ": * 

// Basic annotation test
#let test_annotation_simple = test(title: "simple", ```typst
#bytefield(
  note(left)[0x00],
  group(right,2)[group],
  bytes(4)[some thing],

  note(left)[0x04],
  bytes(4)[some other thing],
)
```)

// skipping notes and mapping to row test
#let test_annotation_skipping = test(title: "skipping",```typst
#bytefield(
  note(left, level: 1)[note 1],
  note(left, level: 0)[note 0],
  bytes(3,
    fill: red.lighten(30%)
  )[Test],
  bytes(3)[Break],
  bits(16,
    fill: green.lighten(30%)
  )[Fill],
  bytes(12)[Addr],
  note(left)[note 2 [l]],
  note(right)[note 2 [r]],

  padding(
    fill: purple.lighten(40%)
  )[Padding],
)
```)