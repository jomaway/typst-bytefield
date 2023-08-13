# typst-bytefield (v.0.0.1)
A  !! WIP !! bytefield package for typst.

Currently a quick and dirty approach to create network protocol headers.
Using [tablex](https://github.com/PgBiel/typst-tablex) under the hood.

## Example

![ipv4 example](ipv4-example.png)

```typst  
bytefield(
  bits(4)[Version], bits(4)[TTL], bytes(1)[TOS], bytes(2)[Total Length],
  bytes(2)[Identification], bits(3)[Flags], bits(13)[Fragment Offset],
  bytes(1)[TTL], bytes(1)[Protocol], bytes(2)[Header Checksum],
  bytes(4)[Source Address],
  bytes(4)[Destination Address],
  bytes(3)[Options], bytes(1)[Padding]
)
```

## Usage

To use this library through the Typst package manager (for Typst v0.6.0+), import bytefield with `#import="@preview/bytefield:0.0.1": *` at the top of your file.

The package contains some of the most common network protocol headers: `ipv4`, `ipv6`, `icmp`, `icmpv6`, `dns`, `tcp`, `udp`.

Coloring fields is also possible. See `example.typ` ...

At the moment very limited features. Feel free to extend if you like.
