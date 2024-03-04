# set aliases
self := justfile_directory()

[private]
default:
	just --list

# generate example pdf
gen-example:
	typst compile --root {{ self }} examples/example.typ 

# generate bytefield manual
gen-docs:
	typst compile docs/docs.typ --root {{ self }}

# watch examples and docs
watch:
	typst watch docs/docs.typ --root {{ self }} & \
	typst watch examples/example.typ --root {{ self }} \
	&& fg

# open the bytefield manual
open-docs:
	@xdg-open docs/docs.pdf

# open the example-pdf
open-example:
	@xdg-open examples/example.pdf

# generate example and manual
gen: gen-docs gen-example
