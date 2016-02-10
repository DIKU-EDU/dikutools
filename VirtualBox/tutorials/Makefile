.PHONY: clean all

SRC=$(wildcard *.asciidoc)
HTML=$(subst .asciidoc,.html,$(SRC))

all: $(HTML)

%.html: %.asciidoc
	asciidoctor $*.asciidoc

clean:
	rm -f *.html
