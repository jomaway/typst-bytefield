#import "bytefield.typ" : *

= Bytefield
== Colored Example
#bytefield(
  bytes(3, fill: red.lighten(30%))[Test],
  bytes(2)[Break],
  bits(24, fill: green.lighten(30%))[Fill],
  bytes(12)[Addr],
  padding(fill: purple.lighten(40%))[Padding],
)


== Show all bits in the bitheader

Show all bit headers with `bitheader: "all"` 

#bytefield(
    bits:32,
    msb_first: true,
    bitheader: "all",
    ..range(32).map(i => bit[#flagtext[B#i]]).rev(),
)

== Smart bit header

Show start bit of each bitbox with `bitheader: "smart"`.

#bytefield(
  bits: 32,
  // same as bitheader: (0,8,13,18,23,31),
  bitheader: "smart",
  bits(8)[opcode],
  bits(5)[rd],
  bits(5)[rs1],
  bits(5)[rs2],
  padding()[]
)

== Bounds bit header

Show start bit of each bitbox with `bitheader: "bounds"`.

#bytefield(
  bits: 32,
  // same as bitheader: (0,7,8,12,13,17,18,22,23,30,31),
  bitheader: "bounds",
  bits(8)[opcode],
  bits(5)[rd],
  bits(5)[rs1],
  bits(5)[rs2],
  padding()[]
)

== Reversed bit order

Select `msb_first: true` for a reversed bit order. 

#bytefield(
    msb_first: true,
    bitheader: "smart",
    byte[MSB],bytes(2)[Two], bit[#flagtext("URG")], bits(7)[LSB],
)

== Custom bit header

Pass an `array` to specify each number.

#bytefield(
    bits:16,
    bitheader: (0,5,6,7,8, 12,15),
    bits(6)[First],
    bits(2)[Duo],
    bits(5)[Five],
    bits(3)[Last],
)

Pass an `integer` to show all multiples of this number.

#bytefield(
    bits:16,
    bitheader: 3,
    bits(6)[First],
    bits(2)[Duo],
    bits(5)[Five],
    bits(3)[Last],
)

== Text header instead of numbers  [*WIP*]

Pass an `dictionary` as bitheader. Example: 
```typst
#bytefield(
  bitheader: (
    "0": "LSB_starting_at_bit_0", 
    "13": "test", 
    "24": "next_field_at_bit_24", 
    "31":"MSB", 
    angle: -40deg,
    marker: auto // or none
  ),
  bits: 32,
  bit[F],
  byte[Start],
  bytes(2, fill: red.lighten(30%))[Test],
  bit[H],
  bits(5, fill: purple.lighten(40%))[CRC],
  bit[T],
)
```

#box(width: 100%)[ 
#bytefield(
  bitheader: (
    "0": "LSB_starting_at_bit_0", 
    "13": "test", 
    "24": "next_field_at_bit_24", 
    "31":"MSB", 
    angle: -40deg,
    marker: auto // or none
  ),
  bits: 32,
  bit[F],
  byte[Start],
  bytes(2, fill: red.lighten(30%))[Test],
  bit[H],
  bits(5, fill: purple.lighten(40%))[CRC],
  bit[T],
)
]

#box(width: 100%)[
You can also show labels and numbers
```typst
#bytefield(
  bitheader: (
  "0": "LSB_starting_at_bit_0", 
  "13": "test", 
  "24": "next_field_at_bit_24", 
  "31":"MSB", 
  numbers:"smart", // the numbers to show
  angle: -40deg,
  marker: auto // or none
),
  bits: 32,
  bit[F],
  byte[Start],
  bytes(2, fill: red.lighten(30%))[Test],
  bit[H],
  bits(5, fill: purple.lighten(40%))[CRC],
  bit[T],
)
```
#bytefield(
  bitheader: (
  "0": "LSB_starting_at_bit_0", 
  "13": "test", 
  "24": "next_field_at_bit_24", 
  "31":"MSB", 
  numbers:"smart", // the numbers to show
  angle: -40deg,
  marker: auto // or none
),
  bits: 32,
  bit[F],
  byte[Start],
  bytes(2, fill: red.lighten(30%))[Test],
  bit[H],
  bits(5, fill: purple.lighten(40%))[CRC],
  bit[T],
)
]

== Pre/Post columns

Define additional columns with before the bitfield with `pre` or behind the bitfield with `post`
and pass any tablex object.

You can use the helpers `left_aligned` and `right_aligned` for left and right aligned text.

```typst
#bytefield(
  bits:1,
  pre:(auto,),
  post:(auto,),
  right_aligned[0x0],
  bit[some thing],
  left_aligned[first word],
  right_aligned[0x10],
  bit[some other thing],
  left_aligned[second word],
)
```

#bytefield(
  bits:1,
  bitheader: none,
  pre:(auto,),
  post:(auto,),
  right_aligned[0x0],
  bit[some thing],
  left_aligned[first word],
  right_aligned[0x10],
  bit[some other thing],
  left_aligned[second word],
)

= Some predefined network protocols

== IPv4
#ipv4

== IPv6
#ipv6

== ICMP
#icmp

== ICMPv6
#icmpv6

== DNS
#dns

== TCP
#tcp
#tcp_detailed

== UDP
#udp