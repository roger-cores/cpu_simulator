%{
#include <stdio.h>
#include <string.h>
#include "calc.h"
#include "calc.tab.h"

void exit(int val);

%}

%token T_MOV T_ADD T_SUB T_OUT T_STR T_LOD T_HLT T_CMP T_NUM T_REG T_COMM T_LBL T_TLBL T_EQ T_LT T_LE T_GT T_GE T_BRA T_JMP

%locations

%union{
	t_register*	reg_val;
	enum OP		op_val;
	t_instr_seq*	instr_val;
	char*		label_val;
	enum REL	rel_val;
}

/*%type <float_val> expr TOK_NUM*/
%type <reg_val>		T_NUM T_REG E
%type <op_val>		T_ADD T_MOV T_SUB T_OUT T_STR T_LOD T_HLT T_CMP T_BRA T_JMP
%type <instr_val>	ARG_TYPE0 ARG_TYPE1 ARG_TYPE2 ARG_TYPE3 ARG_TYPE4 ARG_TYPE5 OPCODE
%type <label_val>	T_LBL T_TLBL
%type <rel_val>		REL

%%

main:
	  INSTRUCTIONS

INSTRUCTIONS: 
	| T_LBL INSTRUCTIONS
	| OPCODE INSTRUCTIONS {
			if(instr_head==NULL){
				instr_head = $1;
				instr_head->next = NULL;
				current = instr_head;
			} else {
				current->next = $1;
				current = current->next;
			}
			program_size++;
		}

OPCODE:
	  T_MOV ARG_TYPE2 {
				$$ = $2;
				$$->opcode = MOV;
			  }
	| T_ADD ARG_TYPE3 {
				$$ = $2;
				$$->opcode = ADD;
			  }
	| T_SUB ARG_TYPE3 {
				$$ = $2;
				$$->opcode = SUB;
			  }
	| T_OUT ARG_TYPE1 {
				$$ = $2;
				$$->opcode = OUT;
			  }
	| T_STR ARG_TYPE2 {
				$$ = $2;
				$$->opcode = STR;
			  }
	| T_STR ARG_TYPE3 {
				$$ = $2;
				$$->opcode = STR;
			  }
	| T_LOD ARG_TYPE2 {
				$$ = $2;
				$$->opcode = LOD;
			  }
	| T_HLT ARG_TYPE0 {
				$$ = $2;
				$$->opcode = HLT;
			  }
	| T_CMP ARG_TYPE3 {
				$$ = $2;
				$$->opcode = CMP;
			  }
	| T_BRA ARG_TYPE4 {
				$$ = $2;
				$$->opcode = BRA;
			  }
	| T_JMP ARG_TYPE5 {
				$$ = $2;
				$$->opcode = JMP;
			  }



ARG_TYPE0:
		{
			$$ = (t_instr_seq*) malloc(sizeof(t_instr_seq));
			$$->is_oper_src = 0;
			$$->oper = NULL;
			$$->src1 = NULL;
			$$->src2 = NULL;
			$$->addr = yylloc.first_line;
		}

ARG_TYPE1:

	E 	{
			$$ = (t_instr_seq*) malloc(sizeof(t_instr_seq));
			$$->is_oper_src = 1;
			$$->oper = $1;
			$$->src1 = NULL;
			$$->src2 = NULL;
			$$->addr = yylloc.first_line;
		}

ARG_TYPE2:

	T_REG T_COMM E {

			$$ = (t_instr_seq*) malloc(sizeof(t_instr_seq));
			$$->is_oper_src = 0;
			$$->oper = $1;
			$$->src1 = $3;
			$$->src2 = NULL;
			$$->addr = yylloc.first_line;
		}

ARG_TYPE3:

	T_REG T_COMM E T_COMM E {

			$$ = (t_instr_seq*) malloc(sizeof(t_instr_seq));
			$$->is_oper_src = 0;
			$$->oper = $1;
			$$->src1 = $3;
			$$->src2 = $5;
			$$->addr = yylloc.first_line;
		}

ARG_TYPE4:
	REL T_COMM E T_COMM T_TLBL {
			$$ = (t_instr_seq*) malloc(sizeof(t_instr_seq));
			$$->is_oper_src = 0;
			$$->oper = NULL;
			$$->src1 = $3;
			$$->src2 = NULL;
			$$->addr = yylloc.first_line;
			$$->rel = $1;
			$$->target_label = $5;
			
		}

ARG_TYPE5:
	T_TLBL {
			$$ = (t_instr_seq*) malloc(sizeof(t_instr_seq));
			$$->is_oper_src = 0;
			$$->oper = NULL;
			$$->src1 = NULL;
			$$->src2 = NULL;
			$$->addr = yylloc.first_line;
			$$->target_label = $1;
		}

REL:
	  T_EQ {$$ = EQ;}
	| T_LT {$$ = LT;}
	| T_LE {$$ = LE;}
	| T_GE {$$ = GE;}
	| T_GT {$$ = GT;}

E:
	T_REG {$$ = $1;} | T_NUM {$$ = $1;}
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
	instr_head = NULL;
	program_size = 0;
}

int main()
{	
	initializeRegisters(32);
	yyparse();
	return 0;
}


