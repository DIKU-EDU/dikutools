.PHONY: clean all pdf

all: ov15-vm.html osm16-vm.html

pdf: ov15-vm.pdf osm16-vm.pdf

%.html: %.asciidoc
	asciidoctor $*.asciidoc

%.pdf: %.asciidoc
	asciidoctor-pdf -a allow-uri-read $*.asciidoc

clean:
	rm -f *.html
	rm -f *.pdf
	rm -f *.pdfmarks
