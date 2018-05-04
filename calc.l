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
comment		";".*"\n"

%%

"mov"				{return(T_MOV);}
"out"				{return(T_OUT);}
"add"				{return(T_ADD);}
"sub"				{return(T_SUB);}
"store"				{return(T_STR);}
"cmp"				{return(T_CMP);}
"load"				{return(T_LOD);}
"halt"				{return(T_HLT);}
"bra"				{return(T_BRA);}
"jmp"				{return(T_JMP);}
"eq"				{return(T_EQ);}
"le"				{return(T_LE);}
"lt"				{return(T_LT);}
"ge"				{return(T_GE);}
"gt"				{return(T_GT);}
","				{return(T_COMM);}
{digit}+			{
					yylval.reg_val = (t_register*) malloc(sizeof(t_register)); 
					yylval.reg_val->value=atoi(yytext);
					yylval.reg_val->name="";
					yylval.reg_val->number=-1;
					return(T_NUM);
			
				}
{register}			{
					yylval.reg_val = (t_register*) malloc(sizeof(t_register));  
					yylval.reg_val->number = atoi(yytext+1);
					yylval.reg_val->name = (char*) malloc(strlen(yytext));
					yylval.reg_val->value = 0;
					strcpy(yylval.reg_val->name,yytext);
					return(T_REG);
				}
{comment}			{/** Ignore comments **/}
[A-Za-z]+[_A-Za-z0-9]*:		{
					yytext[strlen(yytext)-1] = '\0';
					yylval.label_val = (char*) malloc(strlen(yytext));
					strcpy(yylval.label_val,yytext);
					return(T_LBL);
				}
[A-Za-z]+[_A-Za-z0-9]*		{
					yylval.label_val = (char*) malloc(strlen(yytext));
					strcpy(yylval.label_val,yytext);
					return(T_TLBL);
				}
[\n]+				{/** Ignoring newlinews **/}
[\t ]+				{/** Ignore space chars **/}
.				{printf("lexical analysis error: '%s' at %d \n", yytext, yylloc.first_line); exit(0);}


%%
