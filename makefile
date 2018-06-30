.PHONY: all pdf tag clean realclean zip

T = jot-latex-template

all: pdf clean

pdf: jot/jot-manual.pdf

jot/jot-manual.pdf: jot/jot.cls jot/jot-manual.tex jot/latexmkrc jot/figures/*
	cd jot \
		&& latexmk jot-manual

tag:
	git tag v${shell date "+%Y%m%d"}

clean:
	cd jot && latexmk -c jot-manual
	cd jot && latexmk -c paper-template
	-rm -rf $T $T.zip

realclean: clean
	rm -f jot/jot-manual.pdf
	rm -f jot/paper-template.pdf

# For the online version

zip : pdf
	-rm -rf $T $T.zip
	mkdir $T
	cd jot; cp -r README.* jot.cls *.bib *.bbl *.tex jot-manual.pdf figures ../$T
	zip -y -r $T.zip $T
