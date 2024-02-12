// Bytefield - generate protocol headers and more
// Feel free to contribute with any features you think are missing.
// Still a WIP - alpha stage and a bit hacky at the moment

#import "@preview/tablex:0.0.6": tablex, cellx, gridx
#set text(font: "IBM Plex Mono")

// internal cells
#let bfcell(
  len, // lenght of the fields in bits 
  content, 
  fill: none, // color to fill the field
  height: auto, // height of the field
  stroke: 1pt + black,
  x: auto,
  y: auto,
) = cellx(colspan: len, fill: fill, inset: 0pt, x:x, y:y)[#box(height: height, width: 100%, stroke: stroke)[#content]]

// Calculate needed pre/post columns
#let config_extend_pre_post_columns(config, (idx,field)) = {
  let (side, level, ..) = field;
  if (side == left){
    let diff = level - config.pre.len() + 1
    if (diff > 0 ) {
      config.pre += (auto,)*diff
    } 
  } else if (side == right) {
    let diff = level - config.post.len() + 1
    if (diff > 0 ) {
      config.post.insert(0,auto)
    }
  }
  return config
}

// Calculate bitbox offsets
#let config_calc_offsets(config, (idx,field)) = {
  let (size, ..) = field

  let start = if config.offsets.len() == 0 { 0 } else  {
    let (start,end) = config.offsets.values().last()
    end + 1
  }

  let (colstart,rowstart) = if config.rows.len() == 0 { (0,0) } else {
    let (_,prev_rowend) = config.rows.values().last()
    let (_,prev_colend) = config.columns.values().last()
    let colstart = prev_colend + 1
    let rowstart = prev_rowend
    if colstart ==  config.bits {
      rowstart += 1
      colstart = 0
    }
    (colstart,rowstart)
  }

  if (size == none) {
    //we take remaining row
    size = config.bits - colstart
  } else if (colstart == 0 and calc.rem(size,config.bits) == 0) {
    //SPECIAL CASE
    //if we fit exactly into multiple rows,
    //we only take up a single rows, rest is handled in cell drawing 
    size = config.bits
  }

  let end = start + size - 1

  let end = start + size - 1
  config.offsets.insert(str(idx),(start,end))
  config.rows.insert(str(idx),(rowstart,rowstart+int((colstart + size - 1)/config.bits)))
  config.columns.insert(str(idx),(calc.rem(start,config.bits),calc.rem(end,config.bits)))
  return config
}

// Calculate bitbox offsets
#let config_calc_offsets_annotation(config, (idx,field)) = {
  let (rowspan,..) = field
  let start = if config.rows.len() == 0 { 0 } else {
    let (_,rowend) = config.rows.values().last()
    let (_,colend) = config.columns.values().last()
    if colend == config.bits - 1 {
      rowend += 1
    }
    rowend
  }
  let end = start + rowspan - 1
  config.annotated_rows.insert(str(idx),(start,end))
  return config
}

// Calculate bitheader offsets
#let config_calc_offsets_bitheader(config, (idx,field)) = {
  let start = if config.rows.len() == 0 { 0 } else {
    let (_,rowend) = config.rows.values().last()
    rowend + 1
  }
  config.rows.insert(str(idx),(start,start))
  config.columns.insert(str(idx),(0,config.bits - 1))
  return config
}

#let cell_bitbox(config, (idx, field)) = {
  let (size, fill, content, ..) = field

  if (size == none) {
    size = config.bits
  }

  // content = [#content (#idx)]

  let (start,end) = config.columns.at(str(idx))
  let (current_row,_) = config.rows.at(str(idx))
  let remaining_cols = config.bits - calc.rem(start,config.bits)
  let cells = ()
  if size > config.bits and remaining_cols == config.bits and calc.rem(size, config.bits) == 0 {
    let x = int(config.bits - remaining_cols + config.pre.len())
    let y = int(current_row)
    content = content + " (" + str(size) + " Bit)"
    cells.push(bfcell(int(config.bits),fill:fill, height: config.rowheight * size/config.bits, x:x, y:y)[#content])
    current_row += 1
    size = 0
  }

  while size > 0 {
    let width = calc.min(size, remaining_cols);
    let x = int(config.pre.len() + config.bits - remaining_cols)
    let y = int(current_row)
    if (size >= remaining_cols) {
      current_row += 1
    }
    size -= remaining_cols
    remaining_cols = config.bits
    cells.push(bfcell(int(width),fill:fill, height: config.rowheight, x:x, y:y)[#content])
  }
  return cells
}

#let cell_annotation(config, (idx, field)) = {
  let (side, level, rowspan, args, body) = field;
  let (y,_) = config.annotated_rows.at(str(idx))
  let x = if (side == left) {
    config.pre.len() - level - 1
  } else {
    config.pre.len() + config.bits + level
  }
  (cellx(
    x:x,
    y:y,
    rowspan:rowspan,
    ..args,
    body
    // [#body (#idx)]
  ),)
}

#let cell_bitheader(config, (idx,field)) = {
  let (msb,autofill,numbers,labels,ticks,angle,marker,fontsize) = field

  let msb_first = (msb == left)

  for (start,end) in config.columns.values() {
    if autofill == "bounds" {
      numbers.push(start)
      numbers.push(end)
    } else if autofill == "smart" {
      numbers.push(start)
    }
  }
  if autofill == "smart" {
    numbers.push(config.bits - 1)
  }

  if msb_first == true {
    computed_offsets = computed_offsets.map(i => bits - i - 1);
  }

  let bh_num_text(num) = {
    let alignment = if (autofill in ("all","bounds")) {center} 
    else {
      if (msb_first) {
        if (num == 0) {end} else if (num == (config.bits - 1)) { start } else { center }
      } else { 
        if (num == (config.bits - 1)) {end} else if (num == 0) { start } else { center }
      }
    }

    align(alignment, text(fontsize)[#num]);
  }

  let _bitheader = if labels == (:) {
    if ( autofill == "all" ) {
      // Show all numbers from 0 to total bits.
      range(config.bits).map(i => bh_num_text(i))
    } else if ( autofill in ("smart","smart-firstline","bounds")) {
      // Show nums aligned with given fields
      range(config.bits).map(i => if i in numbers { bh_num_text(i) } else {none})
    } else if ( numbers.len() > 1  ) {
      // show given numbers from array
      range(config.bits).map(i => if i in numbers { bh_num_text(i) } else {none})
    } else if ( numbers.len() == 1 ) {
      // if an int is given show all multiples of this number
      let val = numbers.first()
      range(config.bits).map(i =>
        if calc.rem(i,val) == 0 or i == (config.bits - 1) { bh_num_text(i) } 
        else { none })
    } else if ( numbers == () ) {
      range(config.bits).map(_ => []);
    }
  } else {
    // we have numbers and labels
    range(config.bits).map(i => [
      #set align(start + bottom)
      #let h_text = labels.at(str(i),default: "");
      #style(styles => {
        let size = measure(h_text, styles).width
        return [
          #box(height: size, width:100%, inset:(left: 50%))[
          #if (h_text != "" and marker != none){ place(bottom, line(end:(0pt, 5pt))) }
          #rotate(angle, origin: left, box(width:size,h_text))
          ]
          #if (autofill == "all") {
            v(-0.5em)
            align(center, text(fontsize)[#i])
          } else if (autofill in ("smart","smart-firstline","bounds")) {
            if (i in numbers) {
              v(-0.5em)
              align(center, text(fontsize)[#i])
            }
          } else if (autofill == true)  {
            if (i in numbers) {
              v(-0.5em)
              align(center, text(fontsize)[#i])
            }
          }
        ]  
      })
    ])
  }
  let (row,_) = config.rows.at(str(idx))
  _bitheader.enumerate().map(((i,c))=>cellx(x:config.pre.len()+i,y:row,c))
}

// construct arguments
#let config_pass(args, fields, ..pass) = {
  fields.enumerate().fold(args,
    (args,(idx,field)) => {
      args = pass.named().at(field.type, default:()).fold(args,(a,f)=> f(a,(idx,field)))
      args = pass.pos().fold(args,(a,f) => f(a,(idx,field)))
      return args
    }
  )
}

// construct cells
#let cell_pass(config, fields, ..pass) = {
  fields.enumerate().map(
    ((idx,field)) => (
      pass.named().at(field.type, default:()).map(f=> f(config,(idx,field))),
      pass.pos().map(f => f(config,(idx,field))),
    )
  ).flatten()
}

#let bytefield(
  ..args
) = {

  let (args, fields) = (args.named(), args.pos())

  // default values
  args = (
    bits: 32,
    rowheight: 2.5em,
    offsets: (:),
    rows: (:),
    columns: (:),
    annotated_rows: (:),
    pre: (),
    post: (),
    ..args
  )

  // args pass generates missing arguments
  let config = config_pass(args, fields,
    bitheader :  (config_calc_offsets_bitheader,),
    bitbox :     (config_calc_offsets,),
    annotation : (
      config_extend_pre_post_columns,
      config_calc_offsets_annotation,
    ),
  )
  
  // cell pass generates internal cells
  let cells = cell_pass(config, fields,
    bitheader :  (cell_bitheader,),
    bitbox :     (cell_bitbox,),
    annotation : (cell_annotation,),
  )

  // return fields
  box(width: 100%)[
    #gridx(
      columns: config.pre + range(config.bits).map(i => 1fr) + config.post,
      align: center + horizon,
      inset: (x:0pt, y: 4pt),
      // .._bitheader,
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

#let annotation(side, rowspan:1, level:0, ..args, body) = (
  type: "annotation",
  side: side,
  rowspan: rowspan,
  level: level,
  args: args,
  body: body
)

#let bitheader(
  msb: right,
  autofill: auto,
  numbers: (),
  labels: (:),
  ticks: auto,
  fontsize: 9pt,
  angle: -60deg,
  marker: stroke(),
  ..args
) = {
  let _numbers = ()
  let _labels = (:)
  let last = 0
  let step = 1
  for arg in args.pos() {
    if type(arg) == int {
      numbers.push(arg)
      last = arg
      step = arg
    } else if type(arg) in (str,bool) {
      autofill = arg
    } else if type(arg) == content { 
      labels.insert(str(last),arg)
      numbers.push(last)
      last += step
    }else if type(arg) in (left, right) {
      msb = arg
    } else if type(arg) == angle {
      angle = arg
    } else if type(arg) == stroke {
      marker = arg
    } 
    if type(arg) == length {
      fontsize = arg
    }
  }
  if (autofill == auto and numbers == ()) {
    autofill = "all"
  }
  (
    type: "bitheader",
    msb: msb,
    autofill: autofill,
    numbers: numbers,
    labels:labels,
    ticks:ticks,
    fontsize:fontsize,
    angle: angle,
    marker: marker,
  )
}

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