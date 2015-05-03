LEX= flex
YACC= bison
LIBES= -lfl -lm
CXXFLAGS= -w
YFLAGS = -Wno
CC = g++

trans:lexrule.l yaccrule.y codegen.cpp stable.cpp error.cpp backpatch.cpp
	$(YACC) -o rule.c  -d  yaccrule.y $(YFLAGS)
	$(LEX) -o lex.c  lexrule.l
	$(CC) -o trans rule.c lex.c $(LIBES) $(CXXFLAGS)

.PHONY: clean    
clean:
	rm rule.c lex.c rule.h  trans