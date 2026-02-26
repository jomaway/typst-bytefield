#import "test_setup.typ": * 

#let default_fields = (byte[First], bytes(2)[Second], byte[Third],
  bytes(2)[Fourth],bytes(2)[Fifth])

#let test_bitheader_auto = test(title: "auto",```typ
#bytefield(
  bitheader: auto,
  byte[First], bytes(2)[Second], byte[Third],
  bytes(2)[Fourth],bytes(2)[Fifth],
)
```)


#let test_bitheader_bounds = test(title: "bounds",```typ
#bytefield(
  bitheader: "bounds",
  byte[First], bytes(2)[Second], byte[Third],
  bytes(2)[Fourth],bytes(2)[Fifth],
)
```)

#let test_bitheader_custom_array = test(title: "custom array",```typ
#bytefield(
  bitheader: (1,2,5,15,29,30,31),
  byte[First], bytes(2)[Second], byte[Third],
  bytes(2)[Fourth],bytes(2)[Fifth],
)
```)





