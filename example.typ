#import "@local/bytefield:0.0.2": *

= Bytefield
== Random Example
#bytefield(
  bits(32, fill: red.lighten(30%))[Test],
  bytes(5)[Break],
  bits(24, fill: green.lighten(30%))[Fill],
  bytes(12)[Addr],
  padding(fill: purple.lighten(40%))[Padding],
)

== Reversed bit order

Select `msb_first: true` for a reversed bit order. 

#bytefield(
    msb_first: true,
    all_header_bits: true,
    byte[MSB],bytes(2)[Two], bit[#flagtext("URG")], bits(7)[LSB],
)

== Show all bits in the bitheader

Show all bit headers with `bitheader: "all"` 

#bytefield(
    bits:16,
    msb_first: true,
    bitheader: "all",
    ..range(16).map(i => bit[#flagtext[B#i]]).rev(),
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

And with `msb_first: true`:

#bytefield(
  bits: 32,
  msb_first: true,
  // same as bitheader: (0,8,13,18,23,31),
  bitheader: "smart",
  bits(8)[opcode],
  bits(5)[rd],
  bits(5)[rs1],
  bits(5)[rs2],
  padding()[]
)

== Custom bit header

#bytefield(
    bits:16,
    bitheader: (0,5, 7, 12,15),
    bits(6)[First],
    bits(2)[Duo],
    bits(5)[Five],
    bits(3)[Last],
)


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