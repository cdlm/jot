.PHONY: all pdf tag clean realclean

all: pdf clean

pdf: jot/jot-manual.pdf

jot/jot-manual.pdf: jot/jot.cls jot/jot-manual.tex jot/latexmkrc jot/manual/*
	cd jot \
		&& latexmk jot-manual

tag:
	git tag v${DATE}

clean:
	cd jot \
		&& latexmk -c \
		&& rm -f jot-manual.bbl # latexmk fails to find it...

realclean: clean
	rm -f jot/jot-manual.pdf
