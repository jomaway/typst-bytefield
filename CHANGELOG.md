
# Changelog

## v0.0.4 (upcoming)

This release is a complete refactor of the bytefield package.

Functions are grouped and separated into multiple files.

**`bytefield.typ`**

Contains now only the entry points to the package and exposes the user facing api and a collection of common network protocols

**`lib/api.typ`**

Contains the user facing api and internal low level api which the user api gets mapped to.

**`lib/gen.typ`**

Holds all functions for the new generation pipeline system. 
As of now the this contains.
- generation of meta data which is necessary for further processing.
- generation of bf-field from the low level api fields.
- generation of bf-cells from the bf-fields
- generation of the final outcome by mapping bf-cells to tablex cells 

**`lib/types.typ`**

Contains all type definitions and creator functions.

The following types are defined: `bf-field`, `data-field`, `note-field`, `bf-cell`, `header_cell`

**`lib/states.typ`**

Contains states which are used for global config with `bf-config`

- Added state for defining the `row_height` of the table
- Added state for defining the `header-font-size`

**`lib/asserts.typ`**

Contains some assertion functions

**`lib/utils.typ`**

Contains some utility functions 


## v0.0.3

- Added "smart" bit headers thanks to [hgruniaux](https://github.com/hgruniaux)
  - Added "smart-firstline" to only consider the first row for calculation.
- Added option to pass an `int` as bitheader, which shows all multiples of this number.
- Added experimental "text_header" support by passing a `dictionary` to bitheader.
- Fixed bitheader number alignment on edge cases. (This could be improved and extended in a future version.)



## v0.0.2

- Added support for reversed bitheader order with `msb_first:true`.
- Quick way to show all headerbits with `bitheader: "all"`.
- Updated `flagtext` center alignment.


## v0.0.1

Initial Release

- Added `bytefield`, as main function to create an new bytefield diagram. 
- Added `bit`, `bits`, `byte`, `bytes`, `padding`, as high level API for adding fields to a bytefield. 
- Added `flagtext` as a utility function to create rotate text for short flag descriptions.
- Added `ipv4`, `ipv6`, `icmp`, `icmpv6`, `dns`, `tcp`, `udp` as predefined diagrams.
