// #import "bytefield.typ": *
// #import "common.typ" as common
#import "@local/bytefield:0.0.4": *

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
    gutter: 1em,
    box(align(horizon,eval(source.text, mode:"markup", scope: (
      "bytefield" : bytefield,
      "byte" : byte,
      "bytes" : bytes,
      "bit" : bit,
      "bits" : bits,
      "padding" : padding,
      "flag": flag,
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
    )))),
    box(align(horizon,sourcecode(showrange: showlines,source))),
  )
)

#set page(margin: 2cm)

= Bytefield gallery

== Colored Example

#set text(9.5pt);

#example(```typst
#bytefield(
  // Config the header
  bitheader(
    msb:right,  // left | right  (default: right)
    "bytes",    // adds every multiple of 8 to the header. 
    0, [start], // number with label
    5,          // number without label
    12, [#text(14pt, fill: red, "test")], 
    23, [end_test], 
    24, [start_break], 
    36, [Fix],  // will not be shown 
    marker: auto, // auto or none (default: auto)
    angle: -50deg, // angle  (default: -60deg)
    text-size: 8pt,  // length  (default: global header_font_size or 9pt)
  ),
  // Add data fields (bit, bits, byte, bytes) and notes
  // A note always aligns on the same row as the start of the next data field. 
  note(left)[#text(16pt, fill: blue, font: "Consolas", "Testing")], 
  bytes(3,fill: red.lighten(30%))[Test],
  note(right)[#set text(9pt); #sym.arrow.l This field \ breaks into 2 rows.],  
  bytes(2)[Break],
  note(left)[#set text(9pt); and continues \ here #sym.arrow],
  bits(24,fill: green.lighten(30%))[Fill],
  group(right,3)[spanning 3 rows],
  bytes(12)[#set text(20pt); *Multi* Row],
  note(left, bracket: true)[Flags],
  bits(4)[#text(8pt)[reserved]],
  flag[#text(8pt)[SYN]],
  flag(fill: orange.lighten(60%))[#text(8pt)[ACK]],
  flag[#text(8pt)[BOB]],
  bits(25, fill: purple.lighten(60%))[Padding],
  // padding(fill: purple.lighten(40%))[Padding],
  bytes(2)[Next], 
  bytes(8, fill: yellow.lighten(60%))[Multi break],
  note(right)[#emoji.checkmark Finish],
  bytes(2)[_End_], 
)
```)

#pagebreak()
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
  post: (auto,1.8cm, 1cm),
  note(left, rowspan:3, level:1)[
    #align(center,rotate(270deg)[spanning_3_rows])
  ],
  group(right,3, level:2, bracket: false)[
    #align(center,rotate(270deg)[spanning_3_rows])
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

#pagebreak()
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
    bitheader("all"),
    ..range(16).map(i => flag[B#i])
)
```)

#example(showlines: (3,3),```typst
#bytefield(
    bits:16,
    bitheader("all", msb: left),
    ..range(16).map(i => flag[B#i]).rev(),
)
```)

== Smart bit header

Show start and end bit of each bitbox with `bitheader("smart")`.

#example(```typst
#bytefield(
  bitheader("smart"),
  byte[LSB],
  bytes(2)[Two],
  flag("URG"),
  bits(7)[MSB],
)
```)

#example(```typst
#bytefield(
  bitheader("smart", msb: left),
  byte[MSB],
  bytes(2)[Two],
  flag("URG"),
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
  flag("URG"),
  bits(7)[MSB],
)
```)

#example(```typst
#bytefield(
  bitheader("bounds", msb:left),
  byte[MSB],
  bytes(2)[Two],
  flag("URG"),
  bits(7)[LSB],
)
```, showlines: (2,2))

== Custom bit header

#example(showlines: (2,2), ```typst
#bytefield(
  bitheader(0,7,8, 24, 31),
  byte[LSB],
  bytes(2)[Two],
  flag("URG"),
  bits(7)[MSB],
)
```)

#example(showlines: (2,2), ```typst
#bytefield(
  bitheader(..range(16,step:3)),
  byte[LSB],
  bytes(2)[Two],
  flag("URG"),
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
    17,19,
  ),
  byte[LSB],
  bytes(2)[Two],
  flag("URG"),
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
    17, 19,  // those get ommited as well.
    numbers: none,
  ),
  byte[LSB],
  bytes(2)[Two],
  flag("URG"),
  bits(7)[MSB],
)
```)

#pagebreak()
= Other use cases 

== Memory map 

Workaround with bits. Better support will follow.

#example(
```typst
#bytefield(
  bits: 1,
  group(right,4)[On Chip Memory],
  section("0x2002 0000", "0x2002 1fff"),
  bit[RX Descriptor Memory],
  bit[],
  section("0x2000 7fff", "0x2000 0000", span: 2),
  bits(2)[Bootloader],
  group(right,4)[ext. DDR3 RAM],
  section("0x1fff ffff", "0x0000 0000", span: 4),
  bits(4)[App],
)
```
)

== Register definitions *!WIP*

Register definitions such as shown can be defined with a bit of a hack for the header and two bytefields.
This will be improved once rowheaders are implemented.

#show: bf-config.with(
  row_height: 2cm,
)

#example(```typst 
#let reg_field(body, size: 1, rw: "rw") = {
  bits(size,
    table(
      columns: (1fr),
      rows: (2fr, auto),
      body,
      rw
    )
  )
}

#let reserved(size) = bits(size)[Reserved]

#set text(8pt)
#bytefield(
  bits: 16,
  msb: left,
  bitheader(range: (16,32), ..range(16,32), msb: left),
  reserved(4),
  reg_field(rw: "r")[PLL I2S RDY],
  reg_field[PLL I2S ON],
  reg_field(rw: "r")[PLL RDY],
  reg_field[PLL ON],
  reserved(4),
  reg_field[CSS ON],
  reg_field[HSE BYP],
  reg_field(rw: "r")[HSE RDY],
  reg_field[HSE ON],
)
#bytefield(
  bits: 16,
  msb: left,
  bitheader("all", msb: left),
  reg_field(size:8, rw: "r")[HSICAL[7:0]],
  reg_field(size:5)[HSITRIM[4:0]],
  reg_field[Res.],
  reg_field(rw: "r")[HSI RDY],
  reg_field[HSION],
)
```)

#pagebreak()
#set text(12pt)
== Network Protocols 

#show: bf-config.with(
  row_height: 2em,
)

=== IPv4 
#example(```typst
#bytefield(
  bits(4)[Version], bits(4)[TTL], bytes(1)[TOS], bytes(2)[Total Length],
  bytes(2)[Identification], bits(3)[Flags], bits(13)[Fragment Offset],
  bytes(1)[TTL], bytes(1)[Protocol], bytes(2)[Header Checksum],
  bytes(4)[Source Address],
  bytes(4)[Destination Address],
  bytes(3)[Options], bytes(1)[Padding]
)
```)

== Some predefined network protocols

=== IPv4
#example(

```typst
#ipv4
```)

=== IPv6
#example(

```typst
#ipv6
```)

=== ICMP
#example(

```typst
#icmp
```)

=== ICMPv6
#example(

```typst
#icmpv6
```)

=== DNS
#example(

```typst
#dns
```)

=== TCP
#example(

```typst
#tcp
```)
#example(

```typst
#tcp_detailed
```)

=== UDP
#example(

```typst
#udp
```)