// Bytefield - generate protocol headers and more
// Feel free to contribute with any features you think are missing.
// Still a WIP - alpha stage and a bit hacky at the moment

#import "@preview/tablex:0.0.6": tablex, cellx, gridx
#set text(font: "IBM Plex Mono")

#let bfcell(
  len, // lenght of the fields in bits 
  content, 
  fill: none, // color to fill the field
  height: auto, // height of the field
  stroke: 1pt + black,
  x: auto,
  y: auto,
) = cellx(colspan: len, fill: fill, inset: 0pt, x:x, y:y)[#box(height: height, width: 100%, stroke: stroke)[#content]]

#let bytefield(
  bits: 32, 
  rowheight: 2.5em, 
  bitheader: auto, 
  msb_first: false,
  pre: auto,
  post: auto,
  ..fields
) = {
  // state variables
  let col_count = 0
  let cells = ()

  // Define default behavior - show 
  if (bitheader == auto) { bitheader = "smart"}

  // Calculate needed pre/post columns
  if (pre == auto or post == auto) {
    let left_max_level = 0
    let right_max_level = 0
    for field in fields.pos() {
      if (type(field) == dictionary and field.at("type",default:none) == "annotation") {
        let (side, level, ..) = field;
        if (side == left) {
          left_max_level = calc.max(left_max_level,level)
        } else {
          right_max_level = calc.max(right_max_level,level)
        }
      }
    }
    if (pre == auto) { pre = (auto,)*(left_max_level+1)}
    if (post == auto) { post = (auto,)*(right_max_level+1)}
  }

  let compute_bounds = (bitheader == "bounds") or ( type(bitheader) == dictionary and bitheader.at("numbers",default:none) == "bounds" )

  // calculate cells
  let current_row = if (bitheader != none) { 1 } else { 0 };
  let current_offset = 0;
  let computed_offsets = ();
  for (idx, field) in fields.pos().enumerate() {
    let field_type = if type(field) == dictionary { field.at("type",default:none) } else { none }

    if (field_type not in ("bitbox","annotation")) {
      // forward unknown content to tablex (useful for pre/post)
      cells.push(field)
      continue
    }

    if (field_type == "annotation") {
      let (side, level, args, body) = field;
      let y = int(current_row)
      let x = if (side == left) {
        pre.len() - level - 1
      } else {
        pre.len() + bits + level
      }
      cells.push(cellx(
        x:x,
        y:y,
        ..args
      )[#box(height:100%)[#body]])
      continue
    }

    let (size, content, fill, ..) = field;
    let remaining_cols = bits - col_count;
    col_count = calc.rem(col_count + size, bits);
    // if no size was specified
    if size == none {
      size = remaining_cols
      content = content + sym.star
    }

    computed_offsets.push(if (bitheader == "smart-firstline") { current_offset } else { calc.rem(current_offset,bits) } );
    current_offset += size;
    if (compute_bounds) {
      let offset = calc.rem(current_offset - 1,bits)
      if (computed_offsets.last() != offset) {
        computed_offsets.push(offset)
      }
    }
    
    if size > bits and remaining_cols == bits and calc.rem(size, bits) == 0 {
      let x = int(bits - remaining_cols + pre.len())
      let y = int(current_row)
      content = content + " (" + str(size) + " Bit)"
      cells.push(bfcell(int(bits),fill:fill, height: rowheight * size/bits, x:x, y:y)[#content])
      current_row += 1
      size = 0
    }

    while size > 0 {
      let width = calc.min(size, remaining_cols);
      let x = int(pre.len() + bits - remaining_cols)
      let y = int(current_row)
      if (size >= remaining_cols) {
        current_row += 1
      }
      size -= remaining_cols
      remaining_cols = bits
      cells.push(bfcell(int(width),fill:fill, height: rowheight, x:x, y:y)[#content])
    }
  
  }
  
  computed_offsets.push(bits - 1);

  let bitheader_font_size = 9pt;
  let bh_num_text(num) = {
    let alignment = if (bitheader in ("all","bounds")) {center} 
    else {
      if (msb_first) {
        if (num == 0) {end} else if (num == (bits - 1)) { start } else { center }
      } else { 
        if (num == (bits - 1)) {end} else if (num == 0) { start } else { center }
      }
    }

    align(alignment, text(bitheader_font_size)[#num]);
  }


  let _bitheader = if ( bitheader == "all" ) {
    // Show all numbers from 0 to total bits.
    range(bits).map(i => bh_num_text(i))
  } else if ( bitheader in ("smart","smart-firstline","bounds")) {
    // Show nums aligned with given fields
    if msb_first == true {
      computed_offsets = computed_offsets.map(i => bits - i - 1);
    }
    range(bits).map(i => if i in computed_offsets { bh_num_text(i) } else {none})
  } else if ( type(bitheader) == array ) {
    // show given numbers from array
    range(bits).map(i => if i in bitheader { bh_num_text(i) } else {none})
  } else if ( type(bitheader) == int ) {
    // if an int is given show all multiples of this number
    let val = bitheader;
    range(bits).map(i =>
      if calc.rem(i,val) == 0 or i == (bits - 1) { bh_num_text(i) } 
      else { none })
  } else if ( bitheader == none ) {
    range(bits).map(_ => []);
  } else if (type(bitheader) == dictionary) {
    let numbers = bitheader.at("numbers",default:none) 
    if msb_first == true {
      computed_offsets = computed_offsets.map(i => bits - i - 1);
    }
    range(bits).map(i => [
      #set align(start + bottom)
      #let h_text = bitheader.at(str(i),default: "");
      #style(styles => {
        let size = measure(h_text, styles).width
        return [
          #box(height: size,inset:(left: 50%))[
          #if (h_text != "" and bitheader.at("marker", default: auto) != none){ place(bottom, line(end:(0pt, 5pt))) }
          #rotate(bitheader.at("angle", default: -60deg), origin: left, h_text)
          ]
          #if (type(numbers) == bool and numbers and h_text != "") {
              v(-0.5em)
              align(center, text(bitheader_font_size)[#i])
          } else if (numbers == "all") {
            v(-0.5em)
            align(center, text(bitheader_font_size)[#i])
          } else if (numbers in ("smart","smart-firstline","bounds")) {
            if (i in computed_offsets) {
              v(-0.5em)
              align(center, text(bitheader_font_size)[#i])
            }
          } else if (type(numbers) == array) {
            if (i in array) {
              v(-0.5em)
              align(center, text(bitheader_font_size)[#i])
            }
          }
        ]  
      })
    ])
  } else {
     panic("bitheader must be an integer,array, none, 'all' or 'smart'")
  }

  // revers bit order
  if msb_first == true {
    _bitheader = _bitheader.rev()
  }
  let _bitheader = ([],)*pre.len() + _bitheader + ([],)*post.len()

  box(width: 100%)[
    #gridx(
      columns: pre + range(bits).map(i => 1fr) + post,
      align: center + horizon,
      inset: (x:0pt, y: 4pt),
      .._bitheader,
      ..cells,
    )
  ]
}

// Low level API
#let bitbox(length_in_bits, content, fill: none, stroke: auto) = (
  type: "bitbox",
  size: length_in_bits,   // length of the field 
  fill: fill,
  stroke: stroke,
  content: content,
  var: false, 
  show_size: false,
)

#let annotation(side, level:0, ..args, body) = (
  type: "annotation",
  side: side,
  level: level,
  args: args,
  body: body
)

// High level API
#let bit(..args) = bitbox(1, ..args)
#let bits(len, ..args) = bitbox(len, ..args)
#let byte(..args) = bitbox(8, ..args)
#let bytes(len, ..args) = bitbox(len * 8, ..args)
#let padding(..args) = bitbox(none, ..args)
#let flag(..args,text) = bitbox(1,..args,flagtext(text))

#let note(side,rowspan:1,level:0,content) = {
  let _align = if (side == left) { right } else { left }
  annotation(side,level:level,rowspan:rowspan,inset:5pt,align:_align+horizon,content)
}

#let group(side,rowspan,level:0,content) = {
  let _align  = none
  let _first  = none
  let _second = none

  if (side == left) {
    _align  = right
    _first  = box(height:100%,content)
    _second = box(height:100%,inset:(right:5pt),layout(size => {math.lr("{",size:size.height)}))
  } else {
    _align  = left
    _first  = box(height:100%,inset:(left:5pt),layout(size => {math.lr("}",size:size.height)}))
    _second = box(height:100%,content)
  }

  annotation(
    side,
    level:level,
    rowspan:rowspan,
    align:_align+horizon,
    inset:0pt,
    grid(
        columns:2,
        gutter:5pt,
        _first,
        _second
      )
    )
}

// Rotating text for flags
#let flagtext(text) = align(center,rotate(270deg,text))

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
  padding[Optional Data ]
)

#let icmpv6 = bytefield(
  header: (0,8,16,31),
  byte[Type], byte[Code], bytes(2)[Checksum],
  padding[Internet Header + 64 bits of Original Data Datagram  ]
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
  padding[...DATA...]
)



#let tcp_detailed = bytefield(
  bytes(2)[Source Port], bytes(2)[ Destinatino Port],
  bytes(4)[Sequence Number],
  bytes(4)[Acknowledgment Number],
  bits(4)[Data Offset],bits(6)[Reserved], bit[#flagtext("URG")], bit[#flagtext("ACK")], bit[#flagtext("PSH")], bit[#flagtext("RST")], bit[#flagtext("SYN")], bit[#flagtext("FIN")], bytes(2)[Window],
  bytes(2)[Checksum], bytes(2)[Urgent Pointer],
  bytes(3)[Options], byte[Padding],
  padding[...DATA...]
)

#let udp = bytefield(
  bitheader: (0,16,31),
  bytes(2)[Source Port], bytes(2)[ Destinatino Port],
  bytes(2)[Length], bytes(2)[Checksum],
  padding[...DATA...]
)