complie: yacc lex
		g++ y.tab.c -std=c++11 -Wall
yacc: minipy-lab.y
		yacc -d minipy-lab.y
lex: minipy-lab.l
		lex minipy-lab.l