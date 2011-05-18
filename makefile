.PHONY: all pdf tag clean realclean

T = jot-latex-template

all: pdf clean

pdf: jot/jot-manual.pdf

jot/jot-manual.pdf: jot/jot.cls jot/jot-manual.tex jot/latexmkrc jot/manual/*
	cd jot \
		&& latexmk jot-manual

tag:
	git tag v${shell date "+%Y%m%d"}

clean:
	cd jot \
		&& latexmk -c \
		&& rm -f jot-manual.bbl # latexmk fails to find it...
	-rm -rf $T $T.zip
	-rm -f jot/*.out jot/*.aux jot/*.out jot/*.log

realclean: clean
	rm -f jot/jot-manual.pdf

# For the online version

zip :
	-rm -rf $T $T.zip
	mkdir $T
	cd jot; cp -r README.* jot.cls *.bib *.tex jot-manual.pdf figures ../$T
	zip -y -r $T.zip $T
