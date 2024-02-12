#import "bytefield.typ" as bf
#import "@preview/codelst:2.0.0": sourcecode

#let example(columns:2,source) = box(grid(
  columns:columns,
  gutter: 5pt,
  align(horizon,sourcecode(source)),
  align(horizon,eval(source.text, mode:"markup", scope: (
    "bytefield" : bf.bytefield,
    "bitheader" : bf.bitheader,
    "byte" : bf.byte,
    "bytes" : bf.bytes,
    "bit" : bf.bit,
    "bits" : bf.bits,
    "padding" : bf.padding,
    "flagtext" : bf.flagtext,
    "note" : bf.note,
    "group" : bf.group,
    "ipv4" : bf.ipv4,
    "ipv6": bf.ipv6,
    "icmp": bf.icmp,
    "icmpv6": bf.icmpv6,
    "dns": bf.dns,
    "tcp": bf.tcp,
    "tcp_detailed": bf.tcp_detailed,
    "udp": bf.udp,
  )))
))



= Bytefield
== Colored Example

#example(```typst
#bytefield(
  bitheader(),
  bytes(3,
    fill: red.lighten(30%)
  )[Test],
  bytes(2)[Break],
  bits(24,
    fill: green.lighten(30%)
  )[Fill],
  bytes(12)[Addr],
  padding(
    fill: purple.lighten(40%)
  )[Padding],
)
```)

== Show all bits in the bitheader

Show all bit headers with `bitheader: "all"` 

#example(```typst
#bytefield(
    bits:16,
    msb_first: true,
    bitheader("all"),
    ..range(16).map(
      i => bit[#flagtext[B#i]]
    ).rev(),
)
```)

== Smart bit header

Show start and end bit of each bitbox with `bitheader: "smart"`.

#example(```typst
#bytefield(
  bits: 16,
  bitheader("smart"),
  // same as
  // bitheader(0,2,7,8,13,15),
  bits(8)[opcode],
  bits(5)[rd],
  bits(5)[rs1],
  bits(5)[rs2],
  padding()[]
)
```)

== Bounds bit header

Show start bit of each bitbox with `bitheader: "bounds"`.

#example(```typst
#bytefield(
  bits: 16,
  bitheader("bounds"),
  bits(8)[opcode],
  bits(5)[rd],
  bits(5)[rs1],
  bits(5)[rs2],
  padding()[]
)
```)

== Reversed bit order

Select `msb_first: true` for a reversed bit order. 
#example(```typst
#bytefield(
    bits: 16,
    msb_first: true,
    bitheader: "smart",
    byte[MSB],
    bytes(2)[Two],
    bit[#flagtext("URG")],
    bits(7)[LSB],
)
```)

== Custom bit header

Pass an `array` to specify each number.

#example(```typst
#bytefield(
    bits:16,
    bitheader(0,5,6,7,8,12,15),
    bits(6)[First],
    bits(2)[Duo],
    bits(5)[Five],
    bits(3)[Last],
)
```)

Pass an `integer` to show all multiples of this number.

#example(```typst
#bytefield(
    bits:16,
    bitheader(3),
    bits(6)[First],
    bits(2)[Duo],
    bits(5)[Five],
    bits(3)[Last],
)
```)

== Text header instead of numbers  [*WIP*]

Pass an `dictionary` as bitheader. Example: 
#example(
```typst
#bytefield(
  bits: 16,
  bitheader(
    0, [LSB_starting_at_bit_0], 
    5, [test], 
    9, [next_field_at_bit_9], 
    15,[MSB], 
    angle: -40deg,
    marker: auto // or none
  ),
  bit[F],
  byte[Start],
  bytes(2,
    fill: red.lighten(30%)
  )[Test],
  bit[H],
  bits(5,
    fill: purple.lighten(40%)
  )[CRC],
  bit[T],
)
```)

== Text header and numbers  [*WIP*]

You can also show labels and indexes by specifying `numbers`.
`numbers` accepts the same string arguments as `bitheader`.
You may also specify an array of indexes to show
or simply `true` to show the index for each specified label. 

#example(```typst
#bytefield(
  bits: 16,
  bitheader(
    0, [LSB_starting_at_bit], 
    5, [tes], 
    9, [next_field_at_bit], 
    15,[MS], 
    autofill: true,
    angle: -40deg,
    marker: auto // or none
  ),
  bit[F],
  byte[Start],
  bytes(2,
    fill: red.lighten(30%)
  )[Test],
  bit[H],
  bits(5,
    fill: purple.lighten(40%)
  )[CRC],
  bit[T],
)
```)

#example(```typst
#bytefield(
  bits: 16,
  bitheader(
    0, [LSB_starting_at_bit], 
    5, [tes], 
    9, [next_field_at_bit], 
    15,[MS], 
    autofill: "bounds",
    angle: -40deg,
    marker: auto // or none
  ),
  bit[F],
  byte[Start],
  bytes(2,
    fill: red.lighten(30%)
  )[Test],
  bit[H],
  bits(5,
    fill: purple.lighten(40%)
  )[CRC],
  bit[T],
)
```)

== Annotations

Define annotations in columns left or right of the bitfields current row with the helpers `note` and `group`.

The needed number of columns is determined automatically,
but can be forced with the `pre` and `post` arguments.

The helper `note` takes the side it should appear on as first argument, an optional `rowspan` for the number of rows it should span
and an optional `level` for the nesting level.

The helper `group` takes the side it should appear on as first argument, as second argument `rowspan` for the number of rows it should span
and an optional `level` for the nesting level.

#example(```typst
#bytefield(
  bits:32,

  note(left)[0x00],
  group(right,2)[group],
  bytes(4)[some thing],

  note(left)[0x04],
  bytes(4)[some other thing],
)
```)

#example(```typst
#bytefield(
  bits:32,
  pre: (1cm,auto),
  post: (auto,1cm),

  note(left, rowspan:3, level:1)[
    #flagtext[spanning_3_rows]
  ],
  note(left)[0x00],
  group(right,2)[group],
  bytes(4)[some thing],

  note(left)[0x04],
  group(right,2,level:1)[another group],
  bytes(4)[some other thing],
  note(left)[0x08],
  bytes(4)[some third thing],
)
```)

= Some predefined network protocols

== IPv4
#example(
  columns:(1fr,4fr),
```typst
#ipv4
```)

== IPv6
#example(
  columns:(1fr,4fr),
```typst
#ipv6
```)

== ICMP
#example(
  columns:(1fr,4fr),
```typst
#icmp
```)

== ICMPv6
#example(
  columns:(1fr,4fr),
```typst
#icmpv6
```)

== DNS
#example(
  columns:(1fr,4fr),
```typst
#dns
```)

== TCP
#example(
  columns:(1fr,4fr),
```typst
#tcp
```)
#example(
  columns:(1fr,4fr),
```typst
#tcp_detailed
```)

== UDP
#example(
  columns:(1fr,4fr),
```typst
#udp
```)