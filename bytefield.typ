
// Bytefield - generate protcol headers and more
// Feel free to contribute with any features you think are missing.
// Still a WIP - alpha stage and a bit hacky at the moment

#import "tablex.typ": *
#set text(font: "IBM Plex Mono")

#let bfcell(
  len, // lenght of the fields in bits 
  content, 
  fill: none, // color to fill the field
  height: auto // height of the field
) = cellx(colspan: len, fill: fill)[#box(height: height)[#content]]


#let bytefield(bits: 32, rowheight: 24pt, bitheader: auto, ..fields) = {
  // state variables
  let col_count = 0
  let cells = ()

  // calculate cells
  for (idx, field) in fields.pos().enumerate() {
    let (length, content, fill, ..) = field;
    let remaining_cols = bits - col_count;
    // if no length was specified
    if length == none {
      length = remaining_cols
      content = content + sym.star
    }
    // calculation based on the length
    if length > bits and remaining_cols == bits {
      // CASE 1 - starting from col 0
      let row_count = calc.floor(length/bits)
      let rem = calc.rem(length - remaining_cols, bits)
      
      cells.push(bfcell(bits, fill: fill, height: rowheight * row_count)[#content#if rem > 0 [...]])
      // last cell
      if rem > 0 {
        cells.push(bfcell(rem, fill: fill, height: rowheight)[...#content])
      }
    } else if length > remaining_cols {
      // CASE 2 - Next field overflows the row
      let row_count = calc.floor((length - remaining_cols)/bits)
      let rem = calc.rem(length - remaining_cols, bits)
      // Cell filling the row
      cells.push(bfcell(remaining_cols, fill: fill, height: rowheight)[#content...])
      // middle cell
      if row_count > 0 {
        cells.push(bfcell(bits, fill: fill, height: rowheight * row_count)[...#content#if rem > 0 [...]])
      }
      // last cell
      if rem > 0 {
        cells.push(bfcell(rem, fill: fill, height: rowheight)[...#content])
      }
    } else {
      // CASE 3
      cells.push(bfcell(length, fill: fill, height: rowheight)[#content])
    }
    col_count = calc.rem(col_count + length, bits);
  }

  bitheader = if bitheader == auto { 
    range(bits).map(i => if calc.rem(i,8) == 0 or i == (bits - 1) { text(9pt)[#i] } else { none }) 
  } else if bitheader != none {
    assert(type(bitheader) == "array", message: "header must be an array or none")
    range(bits).map(i => if i in bitheader { text(9pt)[#i] } else {none})
  }
  
  box[
    #show grid: set block(below: 0pt)
    #if bitheader != none [
      #gridx(
        columns: range(bits).map(i => 1fr),  
        align: center + horizon, 
        ..bitheader
      )
    ]
    #tablex(
      columns: range(bits).map(i => 1fr),
      align: center + horizon,
      //inset:0pt,
      ..cells,
    )
  ]
}


#let bitbox(length, content, fill: none) = {
  (length, content, fill)
}

#let bit(..args) = bitbox(1, ..args)
#let bits(len, ..args) = bitbox(len, ..args)
#let byte(..args) = bitbox(8, ..args)
#let bytes(len, ..args) = bitbox(len * 8, ..args)
#let rest(..args) = bitbox(none, ..args)


// Common network protocols
#let ipv4 = bytefield(
  bits(4)[Version], bits(4)[TTL], bytes(1)[TOS], bytes(2)[Total Length],
  bytes(2)[Identification], bits(3)[Flags], bits(13)[Fragment Offset],
  bytes(1)[TTL], bytes(1)[Protocol], bytes(2)[Header Checksum],
  bytes(4)[Source Address],
  bytes(4)[Destination Address],
  bytes(3)[Options], bytes(1)[Padding]
)

#let ipv6 = bytefield(
  bits(4)[Version], bytes(1)[Traffic Class], bits(20)[Flowlabel],
  bytes(2)[Payload Length], bytes(1)[Next Header], bytes(1)[Hop Limit],
  bytes(128/8)[Source Address],
  bytes(128/8)[Destination Address],
)

#let icmp = bytefield(
  header: (0,8,16,31),
  byte[Type], byte[Code], bytes(2)[Checksum],
  bytes(2)[Identifier], bytes(2)[Sequence Number],
  rest[Optional Data ]
)

#let icmpv6 = bytefield(
  header: (0,8,16,31),
  byte[Type], byte[Code], bytes(2)[Checksum],
  rest[Internet Header + 64 bits of Original Data Datagram  ]
)

#let dns = bytefield(
  bytes(2)[Identification], bytes(2)[Flags],
  bytes(2)[Number of Questions], bytes(2)[Number of answer RRs],
  bytes(2)[Number of authority RRs], bytes(2)[Number of additional RRs],
  bytes(8)[Questions],
  bytes(8)[Answers (variable number of resource records) ],
  bytes(8)[Authority (variable number of resource records) ],
  bytes(8)[Additional information (variable number of resource records) ],
)

#let tcp = bytefield(
  bytes(2)[Source Port], bytes(2)[ Destinatino Port],
  bytes(4)[Sequence Number],
  bytes(4)[Acknowledgment Number],
  bits(4)[Data Offset],bits(6)[Reserved], bits(6)[Flags], bytes(2)[Window],
  bytes(2)[Checksum], bytes(2)[Urgent Pointer],
  bytes(3)[Options], byte[Padding],
  rest[...DATA...]
)

#let flagtext(text) = align(end,pad(-3pt,rotate(270deg,text)))

#let tcp_detailed = bytefield(
  bytes(2)[Source Port], bytes(2)[ Destinatino Port],
  bytes(4)[Sequence Number],
  bytes(4)[Acknowledgment Number],
  bits(4)[Data Offset],bits(6)[Reserved], bit[#flagtext("URG")], bit[#flagtext("ACK")], bit[#flagtext("PSH")], bit[#flagtext("RST")], bit[#flagtext("SYN")], bit[#flagtext("FIN")], bytes(2)[Window],
  bytes(2)[Checksum], bytes(2)[Urgent Pointer],
  bytes(3)[Options], byte[Padding],
  rest[...DATA...]
)

#let udp = bytefield(
  bitheader: (0,16,31),
  bytes(2)[Source Port], bytes(2)[ Destinatino Port],
  bytes(2)[Length], bytes(2)[Checksum],
  rest[...DATA...]
)