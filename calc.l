%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "calc.h"
#include "calc.tab.h"

#define YY_USER_ACTION yylloc.first_line = yylloc.last_line = yylineno;
%}

%option yylineno

register	r[0-9]?[0-9]
digit		[0-9]
comment		"//".*"\n"

%%

"mov"			{return(T_MOV);}
"out"			{return(T_OUT);}
"add"			{return(T_ADD);}
"sub"			{return(T_SUB);}
","			{return(T_COMM);}
{digit}+		{sscanf(yytext, "%d", &(yylval.int_val)); return(T_NUM);}
{register}		{yylval.reg_val=malloc(strlen(yytext)+1); strcpy(yylval.reg_val, yytext); return(T_REG);}
{comment}		{/** Ignore comments **/}
[\n]+			{return(T_NLN);}
[\t ]+			{/** Ignore space chars **/}
.			{printf("lexical analysis error: '%s' at %d \n", yytext, yylloc.first_line); exit(0);}


%%
