#import "../bytefield.typ": *
#import "../common.typ" as common
// #import "@local/bytefield:0.0.4": *

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
    box(align(horizon,sourcecode(showrange: showlines,source))),
    box(align(horizon,eval(source.text, mode:"markup", scope: (
      "bytefield" : bytefield,
      "byte" : byte,
      "bytes" : bytes,
      "bit" : bit,
      "bits" : bits,
      "flag": flag,
      "note" : note,
      "group" : group,
      "section": section,
      "bitheader": bitheader,
      "common": common,
      "common.ipv4" : common.ipv4,
      "common.ipv6": common.ipv6,
      "common.icmp": common.icmp,
      "common.icmpv6": common.icmpv6,
      "common.dns": common.dns,
      "common.tcp": common.tcp,
      "common.tcp_detailed": common.tcp_detailed,
      "common.udp": common.udp,
    )))),
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
= Header Examples

#emoji.warning The new bitheader api is still a work in progress.

== Show all bits
#example(```typst
#bytefield(
    bpr:16,
    bitheader("all"),
    ..range(16).map(i => flag[B#i])
)
```)

#example(showlines: (3,4),```typst
#bytefield(
    bpr:16,
    msb: left,
    bitheader("all"),
    ..range(16).map(i => flag[B#i]).rev(),
)
```)

== Show offsets

Show start and end bit of each bitbox with `bitheader("offsets")`.

#example(```typst
#bytefield(
  bitheader("offsets"),
  byte[LSB],
  bytes(2)[Two],
  flag("URG"),
  bits(7)[MSB],
)
```)

#example(```typst
#bytefield(
  msb: left,
  bitheader("offsets"),
  byte[MSB],
  bytes(2)[Two],
  flag("URG"),
  bits(7)[LSB],
)
```, showlines: (2,3))

== Show bounds

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
  msb:left,
  bitheader("bounds"),
  byte[MSB],
  bytes(2)[Two],
  flag("URG"),
  bits(7)[LSB],
)
```, showlines: (2,3))

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
  bitheader(..range(32,step:5)),
  byte[LSB],
  bytes(2)[Two],
  flag("URG"),
  bits(7)[MSB],
)
```)

== Numbers and Labels
You can also show labels and indexes by specifying a `content` after an `number` (`int`).

#example(showlines: (2,8), ```typst
#bytefield(
  bitheader(
    0,[LSB], 
    5, [test], 
    8, [next_field], 
    24, [important FLAG], 
    31, [MSB],
    17,19,
    text-size: 8pt,
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
    0,[LSB], 
    5, [test], 
    8, [next_field], 
    24, [important_FLAG], 
    31, [MSB], 
    17, 19,  // those get ommited as well.
    numbers: none,
    text-size: 8pt,
  ),
  byte[LSB],
  bytes(2)[Two],
  flag("URG"),
  bits(7)[MSB],
)
```)

#pagebreak()
== Styling the header

You can use #named arguments to adjust the header styling.

- `fill` argument adds an background color to the header.
- `text-size` sets the size of the text.
- `stroke` defines the border style.

=== Fancy orange header with big font
#example(showlines: (2,2), ```typst
#bytefield(
  bitheader("bytes", fill: orange.lighten(60%), text-size: 16pt, stroke: red),
  byte[LSB],
  bytes(2)[Two],
  flag("URG"),
  bits(7)[MSB],
)
```)

=== Gray and boxed header
#example(showlines: (3,3),```typst
#bytefield(
  bpr: 8,
  bitheader("all", fill: luma(200), stroke: black),
  bits(4)[Session Key Locator],
  bits(4, fill: luma(200))[Reserved],
  bytes(2)[MAC input data],
  byte[...]
)
```)
 _info: example taken from discord discussion (author: \_\_Warez)_


== Set row height

The height of the rows can be set with the `rows` argument.

#example(showlines: (2,2), ```typst
#bytefield(
  rows: (3cm, 2cm, 1cm),
  bitheader("bytes", fill: luma(200), stroke: luma(140)),
  byte[LSB], bytes(2)[Two], flag("URG"), bits(7)[MSB],
  byte[LSB], bytes(2)[Two], flag("URG"), bits(7)[MSB],
  byte[LSB], bytes(2)[Two], flag("URG"), bits(7)[MSB],
  byte[LSB], bytes(2)[Two], flag("URG"), bits(7)[MSB],
)
```)



#pagebreak()
== Some predefined network protocols

=== IPv4
#example(

```typst
#common.ipv4
```)

=== IPv6
#example(

```typst
#common.ipv6
```)

=== ICMP
#example(

```typst
#common.icmp
```)

=== ICMPv6
#example(

```typst
#common.icmpv6
```)

=== DNS
#example(

```typst
#common.dns
```)

=== TCP
#example(

```typst
#common.tcp
```)
#example(

```typst
#common.tcp_detailed
```)

=== UDP
#example(

```typst
#common.udp
```)
