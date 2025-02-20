#import "../bytefield.typ": *
#import "@preview/tidy:0.4.1"
#import "@preview/gentle-clues:1.1.0": abstract, info
#import "@preview/codly:1.2.0": *
#show: codly-init.with()

// extract version from typst.toml package file.
#let pkg-data = toml("../typst.toml").package
#let version = pkg-data.at("version")
#let import_statement = raw(block: true, lang: "typ", "#import \"@preview/bytefield:" + version +"\": *")


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

#set text(font: "Rubik", weight: 300);
// only show numbers for heading level 1 and 2
#set heading(numbering: (..args) => {
	let nums = args.pos()
	if nums.len() < 3 { numbering("1.", ..nums)}
})
#show link: set text(blue);
#show ref: set text(blue);
#show raw.where(block: false): it => tag(fill: luma(230))[#it]

#let user-api = tidy.show-module(
	tidy.parse-module(read("../lib/api.typ"), name: "User API",),
	style: tidy.styles.default,
	show-outline:true,
	sort-functions: none,
)

#let scope = (
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
    )

#let example(columns:1,source, showlines: none) = {
	set text(0.8em);
  grid(
    columns:columns,
    gutter: 1em,
    box(align(horizon,source)),
    box(align(horizon,eval(source.text, mode:"markup", scope: scope))),
  )
}

#set page("a4", margin: 2cm)

// title
#align(center, text(24pt, weight: 500)[bytefield manual])

#abstract[
	#link("https://github.com/jomaway/typst-bytefield")[*bytefield*] is a package for creating _network protocol headers_, _memory maps_, _register definitions_	and more in typst.

	Version: #pkg-data.version \
	Authors: #link("https://github.com/jomaway","jomaway") + community contributions. \
	License: #pkg-data.license
]

#outline(depth: 2, indent: 2em)

= Example
#block[
	#show: bf-config.with(
		row-height: 2em,
	)

#figure(
	bytefield(
		msb:right,  // left | right  (default: right)
		// Config the header
		bitheader(
			"bytes",    // adds every multiple of 8 to the header.
			0, [start], // number with label
			5,          // number without label
			-12, [#text(14pt, fill: red, "test")], //label without number
			23, [end_test],
			24, [start_break],
			36, [Fix],  // will not be shown
			marker: true, // true or false (default: auto)
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
	),
	caption: "Random example of a colored bytefield.",
	supplement: "Bytefield"
)

	Source and more examples can be found #link("https://github.com/jomaway/typst-bytefield/tree/main/examples")[here].
]



= Usage
Import the package from the official package manager

#import_statement

or download the package and put it inside the folder for local packages.

= Features

== Data fields

By default a bytefield shows 32 bits per row. This can be changed by using the `bpr` argument. For example `bpr:16` changes the size to 16 bits per row.

You can add fields of different size to the bytefield by using one of the following field functions.

`bit`, `bits`, `byte`, `bytes`, `flag`

  - Fields can be colored with a `fill` argument.

Multirow and breaking fields are supported. This means if a field does not fit into one row it will break automatically into the next one.

== Annotations

Define annotations in columns left or right of the bitfields current row with the helpers `note` and `group`.

The needed number of columns is determined automatically,
but can be forced with the `pre` and `post` arguments.

The helper `note` takes the side it should appear on as first argument, an optional `rowspan` for the number of rows it should span
and an optional `level` for the nesting level.

The helper `group` takes the side it should appear on as first argument, as second argument `rowspan` for the number of rows it should span and an optional `level` for the nesting level.

// add in future version
// The helper `section` takes a `start_addr` and a `end_addr` as string values and displays those on the left side of a row. The `start_addr` is aligned to the top and the `end_addr` is aligned to the bottom.

#example(```typst
#bytefield(
  pre: (1cm,auto),
  post: (auto,1.8cm),
  note(left, rowspan:3, level:1)[
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

#pagebreak()
== Headers [WIP]

#emoji.warning The new bitheader api is still a work in progress and might change a bit in the next version.

The current API is described here:

The `bitheader` function defines which bit-numbers and text-labels are shown as a header.
Currently *only the first* `bitheader` per `bytefield` is processed, all others will be ignored.

There are some #named arguments and an arbitrary amount of #positional arguments which you can pass to a header.

Showing a number. #positional
- Just add an `int` value with the number you would like to show.

Showing a text label for a number #positional
- Add a content field after the int value which the label belongs to.
- To show a label without the number use the negativ number. _Example: (-5) instead of (5)_

#info[
Set the order of the bits with the `msb` argument directly on the `bytefield`.
 - `msb:right` displays the numbers from (left)  0 --- to --- msb (right)  #default
 - `msb:left`  displays the numbers from (left) msb --- to --- 0 (right)
]

Show or hide numbers
- `numbers: none` hide all numbers
- `numbers: auto` show all specified numbers #default

Some common use cases can be set by adding a `string` value. #positional
- `"all"` will show numbers for all bits.
- `"bytes"` will show every multiple of 8 and the last bit.
- `"bounds"` will show begin and end of each field in the first row.
- `"offsets"` will show begin of each field in the first row.

You can use #named arguments to adjust the header styling.

- `fill` argument adds an background color to the header.
- `text-size` sets the size of the text.
- `stroke` defines the border style.
- `marker` [bool] defines if there is a marker line shown below the label.
	- `marker: true`: shows a marker on each label.
	- `marker: false`: no marker is shown at all.
	- `marker: (true,false)`: shows markers only on labels with numbers.
	- `marker: (false, true)`: shows markers only on labels without numbers.


=== Numbers and Labels example
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
  ),
  byte[LSB],
  bytes(2)[Two],
  flag("URG"),
  bits(7)[MSB],
)
```)


== Styling

You can use the `row` argument on the `bytefield` to specify custom row heights. #emoji.warning This does not affect the header row.
Usage is equal to _typst_ table or grid row argument.

See @reg-def as an example.

== Global config

You can set some global default values which affect all `bytefields` by using a show rule.

*Example:*
```typst
#show: bf-config.with(
  field_font_size: 15.5pt,
  note_font_size: 6pt,
  header_font_size: 12pt,
  header_background: luma(200),
  header_border: luma(80),
)
```

#pagebreak()
= Use cases<chap:use-cases>

== Protocol Headers

Generate protocol headers like the one from the *ipv4* protocol.


#figure(
	example(
		columns: 2,
	```typst
	#bytefield(
		bitheader("bytes"),
		bits(4)[Version], bits(4)[IHL], bytes(1)[TOS], bytes(2)[Total Length],
		bytes(2)[Identification], bits(3)[Flags], bits(13)[Fragment Offset],
		bytes(1)[TTL], bytes(1)[Protocol], bytes(2)[Header Checksum],
		bytes(4)[Source Address],
		bytes(4)[Destination Address],
		bytes(3)[Options], bytes(1)[Padding]
	)
	```),
	caption: "Common IPv4 Header.",
	supplement: "Bytfield",
)

== Memory Maps

Generate memory maps. Currently possible with a little workaround using bits. Better support is on the roadmap.


#figure(
	example(columns: 2,
	```typst
	#bytefield(
		bpr: 1,
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
	),
	caption: "A memory map example.",
	supplement: "Bytefield",
)

#pagebreak()
== Register Definitions<reg-def>

Creating register definition like @bf-reg is currently possible by using two `bytefields` and tweaking the header accordingly.


// #show: bf-config.with(
//   row_height: 2cm,
// )

#figure(
	example(
	```typst
	#let reg_field(body, size: 1, rw: "rw") = {
		bits(size,table(columns: 1fr,rows: (2fr, auto),body,rw))
	}

	#let reserved(size) = bits(size)[Reserved]

	#set text(8pt)
	#bytefield(
		bpr: 16,
		msb: left,
		rows: 2cm,
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
		bpr: 16,
		msb: left,
		rows: 2cm,
		bitheader("all", msb: left),
		reg_field(size:8, rw: "r")[HSICAL[7:0]],
		reg_field(size:5)[HSITRIM[4:0]],
		reg_field[Res.],
		reg_field(rw: "r")[HSI RDY],
		reg_field[HSION],
	)
	```),
	caption: [Register Definition from the STM32 manual recreated with `bytefield`],
	supplement: "Bytfield",
)<bf-reg>


#pagebreak()
= Reference

#show heading.where(level:2): set text(18pt) // module names
#show heading.where(level:3): set text(16pt, fill: red.darken(20%)) // function names

#user-api<user-api>
