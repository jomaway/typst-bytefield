#import "bytefield.typ": *
#import "common.typ" as common

#import "@preview/codelst:2.0.0": sourcecode

#set text(font: "Rubik", weight: 300);



#let tag(value, fill: orange.lighten(45%)) = {
  box(
    inset: (x: 3pt, y: 0pt),
    outset: (y: 3pt),
    radius: 2pt,
    fill: fill
  )[#value]
}

#let default = tag[_default_]
#let positional = tag(fill: green.lighten(60%))[_positional_]
#let named = tag(fill: blue.lighten(60%))[_named_]

#let example(columns:1,source, showlines: none) = block(
  grid(
    columns:columns,
    gutter: 5pt,
    box(align(horizon,sourcecode(showrange: showlines,source))),
    box(align(horizon,eval(source.text, mode:"markup", scope: (
      "bytefield" : bytefield,
      "byte" : byte,
      "bytes" : bytes,
      "bit" : bit,
      "bits" : bits,
      "padding" : padding,
      "flagtext" : flagtext,
      "note" : note,
      "group" : group,
      "section": section,
      "bitheader": bitheader,
      "ipv4" : common.ipv4,
      "ipv6": common.ipv6,
      "icmp": common.icmp,
      "icmpv6": common.icmpv6,
      "dns": common.dns,
      "tcp": common.tcp,
      "tcp_detailed": common.tcp_detailed,
      "udp": common.udp,
    ))))
  )
)



= Bytefield

#show: bf-config.with(
  header_font_size: 8pt,
) 

== Colored Example

#example(```typst
#bytefield(
  bitheader("bytes", 0, [start], 12, [test], 23, [end_test], 24 ,[start_break],),
  note(left)[Testing],
  bytes(3,
    fill: red.lighten(30%)
  )[Test],
  note(right)[#set text(9pt); #sym.arrow.l This field \ breaks into 2 rows.],
  bytes(2)[Break],
  note(left)[#set text(9pt); and continues \ here #sym.arrow],
  bits(24,
    fill: green.lighten(30%)
  )[Fill],
  group(right,3)[spanning 3 rows],
  bytes(12)[Multi Row],
  note(left)[Last row],
  padding(
    fill: purple.lighten(40%)
  )[Padding],
)
```)

== Annotations

Define annotations in columns left or right of the bitfields current row with the helpers `note` and `group`.

The needed number of columns is determined automatically,
but can be forced with the `pre` and `post` arguments.

The helper `note` takes the side it should appear on as first argument, an optional `rowspan` for the number of rows it should span
and an optional `level` for the nesting level.

The helper `group` takes the side it should appear on as first argument, as second argument `rowspan` for the number of rows it should span and an optional `level` for the nesting level.

The helper `section` takes a `start_addr` and a `end_addr` as string values and displays those on the left side of a row. The `start_addr` is aligned to the top and the `end_addr` is aligned to the bottom.

#example(```typst
#bytefield(
  bits:32,
  pre: (1cm,auto),
  post: (auto,1.8cm),

  note(left, rowspan:3, level:1)[
    #flagtext[spanning_3_rows]
  ],
  note(left)[0x00],
  group(right,2)[group],
  bytes(4)[some thing],

  // note(left)[0x04],
  group(right,2,level:1)[another group],
  bytes(4)[some other thing],
  note(left)[0x08],
  bytes(4)[some third thing],
)
```)

#example(```typst
#bytefield(
  bits:32,

  section("0x00","0x0F"),
  group(right,2)[group],
  bytes(4)[some thing],
  section("0x10","0x1F"),
  bytes(4)[some other thing],
)
```)

= Headers [WIP]

! The new bitheader api is still a work in progress.

The `bitheader` function defines which bit-numbers and text-labels are shown as a header. 
Currently *only the first* `bitheader` per `bytefield` is processed, all others will be ignored.

There are some #named arguments and an arbitrary amount of #positional arguments which you can pass to a header.

Set the order of the header bits:  #named
 - `msb:right` displays the numbers from (left)  0 --- to --- msb (right)  #default
 - `msb:left`  displays the numbers from (left) msb --- to --- 0 (right)

Show or hide numbers
- `numbers: none` hide all numbers 
- `numbers: auto` show all specified numbers #default


Some common use cases can be set by adding a `string` value. #positional
- `"all"` will show numbers for all bits. 
- `"bytes"` will show every multiple of 8 and the last bit.
- `"bounds"` will show begin and end of each field in the first row.
- `"smart"` will show begin of each field in the first row.

Showing a number. #positional
- Just add an `int` value with the number you would like to show. 

Showing a text label for a number #positional
- Add a content field after the int value which the label belongs to.

== Header Examples 

#example(```typst
#bytefield(
    bits:16,
    bitheader("all", msb: left),
    ..range(16).map(
      i => bit[#flagtext[B#i]]
    ).rev(),
)
```)

== Smart bit header

Show start and end bit of each bitbox with `bitheader("smart")`.

#example(```typst
#bytefield(
  bitheader("smart"),
  byte[LSB],
  bytes(2)[Two],
  bit[#flagtext("URG")],
  bits(7)[MSB],
)
```)

#example(```typst
#bytefield(
  bitheader("smart", msb: left),
  byte[MSB],
  bytes(2)[Two],
  bit[#flagtext("URG")],
  bits(7)[LSB],
)
```, showlines: (2,2))

== Bounds bit header

Show start bit of each bitbox with `bitheader("bounds")`.

#example(showlines: (2,2), ```typst
#bytefield(
  bitheader("bounds"),
  byte[LSB],
  bytes(2)[Two],
  bit[#flagtext("URG")],
  bits(7)[MSB],
)
```)

#example(```typst
#bytefield(
  bitheader("bounds", msb:left),
  byte[MSB],
  bytes(2)[Two],
  bit[#flagtext("URG")],
  bits(7)[LSB],
)
```, showlines: (2,2))

== Custom bit header

#example(showlines: (2,2), ```typst
#bytefield(
  bitheader(0,7,8, 24, 31),
  byte[LSB],
  bytes(2)[Two],
  bit[#flagtext("URG")],
  bits(7)[MSB],
)
```)

#example(showlines: (2,2), ```typst
#bytefield(
  bitheader(..range(16,step:3)),
  byte[LSB],
  bytes(2)[Two],
  bit[#flagtext("URG")],
  bits(7)[MSB],
)
```)


== Text header  [*WIP*]

== Numbers and Labels
You can also show labels and indexes by specifying a `content` after an `number` (`int`).

#example(showlines: (2,8), ```typst
#bytefield(
  bitheader(
    0,[LSB_starting_at_bit_0], 
    5, [test], 
    8, [next_field], 
    24, [important FLAG], 
    31, [MSB], 
  ),
  byte[LSB],
  bytes(2)[Two],
  bit[#flagtext("URG")],
  bits(7)[MSB],
)
```)

=== No numbers, only labels
You can omit numbers by setting `numbers: none` inside the bitheader function. 
It's not possible to only omit numbers for certain labels right now. 

#example(showlines: (2,9), ```typst
#bytefield(
  bitheader(
    0,[LSB_starting_at_bit_0], 
    5, [test], 
    8, [next_field], 
    24, [important_FLAG], 
    31, [MSB], 
    numbers: none,
  ),
  byte[LSB],
  bytes(2)[Two],
  bit[#flagtext("URG")],
  bits(7)[MSB],
)
```)


// = Some predefined network protocols

// == IPv4
// #example(
//   columns:(1fr,4fr),
// ```typst
// #ipv4
// ```)

// == IPv6
// #example(
//   columns:(1fr,4fr),
// ```typst
// #ipv6
// ```)

// == ICMP
// #example(
//   columns:(1fr,4fr),
// ```typst
// #icmp
// ```)

// == ICMPv6
// #example(
//   columns:(1fr,4fr),
// ```typst
// #icmpv6
// ```)

// == DNS
// #example(
//   columns:(1fr,4fr),
// ```typst
// #dns
// ```)

// == TCP
// #example(
//   columns:(1fr,4fr),
// ```typst
// #tcp
// ```)
// #example(
//   columns:(1fr,4fr),
// ```typst
// #tcp_detailed
// ```)

// == UDP
// #example(
//   columns:(1fr,4fr),
// ```typst
// #udp
// ```)