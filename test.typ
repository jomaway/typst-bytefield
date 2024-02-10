#import "bytefield.typ": *

#bytefield(
  bits:8,
  // pre:(1cm,auto),
  // post:(3cm,3cm),
  bitheader(numbers:"bounds"),
  note(left,level:1)[NL0],
  note(left,level:0)[NL1],
  group(right,2)[GR0],
  byte[A],

  group(right,2,level:1)[GR1],
  byte[B],
  bits(3)[C],
  bits(3)[D],
  bits(2)[E],
  group(left,2)[GL0],
  byte[F],
  byte[G],
)