
# Windows build

all : bin/pretex

custom.sml : ../custom.sml
	cp ../custom.sml .

lexer.cmlex.sml : ../lexer.cmlex
	cmlex ../lexer.cmlex -o lexer.cmlex.sml

#SMLNJ=`which sml`
SMLNJ=/c/bin/sml

bin/pretex : pretex.sml custom.sml lexer.cmlex.sml make-smlnj.sml
	sml make-smlnj.sml
	bin/mknjexec-win $(SMLNJ) `pwd`/bin pretex-heapimg.x86-win32 pretex

clean :
	rm -r custom.sml lexer.cmlex.sml bin/pretex bin/pretex-heapimg.x86-win32 .cm

installer :
	cd .. && tar cf pretex/install.tar custom.sml defs.tex document.ptex lexer.cmlex main.tex Makefile
