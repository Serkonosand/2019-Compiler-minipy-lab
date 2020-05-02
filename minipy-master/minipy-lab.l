%{
#include <stdlib.h>
#include <stdio.h>
#include <iostream>
#include <string.h>
// #include "minipy-lab.h"
using namespace std;
// void yyerror(char*);
#include "y.tab.h"

/*  any C declaration  */
%}

letter    [a-zA-Z]

digit     [0-9]

number   {digit}+

id       {letter}({letter}|{digit})*

real     {number}"."{number}?|{number}?"."{number}

%%
[ \t]+              { /*do nothing , just skip */ }
{number}            {
                        yylval.type = INT;
                        yylval.ival = atoi( yytext );
	                    return INT;
                    }
{real}              {
                        yylval.type = REAL;
                        yylval.fval = atof( yytext );
                        return REAL;
                    }
{id}                {
                        yylval.type = ID;
                        int length = strlen(yytext);
                        yylval.idname = (char*)malloc(sizeof(char)*(length+1));
                        strncpy(yylval.idname, yytext, length+1);
                        return ID;
                    }
\"(\\.|[^\\"])*\"   {
                        yylval.type = STRING_LITERAL;
                        yytext++;
                        int length = strlen(yytext);
                        yylval.strval = (char*)malloc(sizeof(char)*(length+1));
                        strncpy(yylval.strval, yytext, length-1);
                        yylval.strval[length] = '\0';
                        return STRING_LITERAL;
                    }
.|\n                {
                        yylval.type = INT;
                        return yylval.ival = yytext[0];
                    }
%%