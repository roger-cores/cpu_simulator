all: calc

calc.tab.c calc.tab.h: calc.y calc.h
	bison -dv calc.y

lex.yy.c: calc.l calc.tab.h
	flex -l calc.l

calc: lex.yy.c calc.tab.c calc.tab.h
	gcc -g -o calc calc.tab.c lex.yy.c -lfl
	rm calc.tab.c calc.tab.h lex.yy.c calc.output

clear: 
	rm calc
