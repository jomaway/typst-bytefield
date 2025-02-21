#import "test_setup.typ": * 

#let test_bitfield_all_colored = test(title: "colored version", ```typst
#bytefield(
  bitheader: 8,
  bytes(3,
    fill: red.lighten(60%)
  )[Test],
  bytes(3, fill: yellow.lighten(60%))[Break],
  bits(16,
    fill: green.lighten(60%)
  )[Fill],
  bytes(8, fill: blue.lighten(60%))[Multirow],
  bytes(2, fill: red.lighten(60%))[2 Bytes],
  bytes(12, fill: orange.lighten(60%))[Addr],
  padding(
    fill: purple.lighten(60%)
  )[Padding],
)
```)


#let test_bitfield_all = test(title: "black/white version",```typst
#bytefield(
  bitheader: 8,
  bytes(3)[Test],
  bytes(3)[Break],
  bits(16)[Fill],
  bytes(8)[Multirow],
  bytes(2)[2 Bytes],
  bytes(12)[Addr],
  padding[Padding],
)
```)