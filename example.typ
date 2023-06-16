#import "bytefield.typ": *


= Bytefield
== Random Example
#bytefield(
  bits(32, fill: red.lighten(30%))[Test],
  bytes(5)[Break],
  bits(24, fill: green.lighten(30%))[Fill],
  bytes(12)[Addr (12 Byte)],
  rest(fill: purple.lighten(40%))[Optional],
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