%{
#include <stdio.h>
#include <string.h>
#include "calc.h"
#include "calc.tab.h"

void exit(int val);

%}

%token T_MOV T_ADD T_SUB T_OUT T_NUM T_REG T_COMM T_NLN

%locations

%union{
        int		int_val;
	char*		reg_val;
	t_register	reg_obj;
}

/*%type <float_val> expr TOK_NUM*/
%type <int_val> T_NUM
%type <reg_val> T_REG

%%

main:
	INSTRUCTIONS

INSTRUCTIONS: 
	| OPCODE T_NLN INSTRUCTIONS

OPCODE: 
	OP1 E | OP2 T_REG T_COMM E  | OP3 T_REG T_COMM E T_COMM E

OP1:
	T_OUT
OP2:
	T_MOV

OP3:
	T_ADD | T_SUB

E:
	T_REG | T_NUM
;

%%

int yyerror(char *s)
{
	char *t = "syntax error";
	if(strcmp(s, t) == 0){
		printf("Parsing error: line %d\n", yylloc.first_line);
	} else {
		printf("%s\n", s);
	}
	exit(1);
}

void initializeRegisters(int size){
	register_size = size;
	int i=0;
	for(i=0; i<register_size; i++){
		t_register* current = register_file + i;
		current = (t_register*) malloc(sizeof(t_register));
		current->value = 0;
		current->number = i;
		current->name = (char*) malloc(5);
		sprintf(current->name, "r%d", i);
	}
}

int main()
{	
	initializeRegisters(32);
	yyparse();
	return 0;
}


