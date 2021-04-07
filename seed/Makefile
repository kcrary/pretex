
SOURCES = main.tex defs.tex document.ptex.tex

all : dvi

dvi : main.dvi

pdf : main.pdf

main.dvi : $(SOURCES)
	latex main

main.pdf : $(SOURCES)
	pdflatex main

%.ptex.tex : %.ptex pretex/bin/pretex
	pretex/bin/pretex $<

pretex/bin/pretex : lexer.cmlex custom.sml
	cd pretex && make

clean :
	rm *.dvi *.aux *.log *.ptex.tex
	cd pretex && make clean
