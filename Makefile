
# Windows build

all : bin/pretex

lexer.cmlex.sml : lexer.cmlex
	cmlex lexer.cmlex

#SMLNJ=`which sml`
SMLNJ=/c/bin/sml

bin/pretex : pretex.sml custom.sml lexer.cmlex.sml make-smlnj.sml
	sml make-smlnj.sml
	bin/mknjexec-win $(SMLNJ) `pwd`/bin pretex-heapimg.x86-win32 pretex
