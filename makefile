ARCHIVE_FILES := jot-manual.pdf jot.cls paper.tex jot-manual.tex manual
ARCHIVE_NAME := jot-latex
.PHONY: all clean archive realclean

all: archive clean

archive: ${ARCHIVE_NAME}.zip

${ARCHIVE_NAME}.zip: jot/jot-manual.pdf
	ln -s jot ${ARCHIVE_NAME}
	zip -r $@ ${ARCHIVE_FILES:%=${ARCHIVE_NAME}/%}
	rm ${ARCHIVE_NAME}

jot/jot-manual.pdf: jot/jot.cls jot/jot-manual.tex jot/latexmkrc jot/manual/*
	cd jot && latexmk jot-manual

clean:
	cd jot \
		&& latexmk -c \
		&& rm -f jot-manual.bbl # latexmk fails to find it...

realclean: clean
	rm -f jot/jot-manual.pdf
	rm -f ${ARCHIVE_NAME}.zip
