%{
#include <stdio.h>
#include <string.h>
#include "calc.h"
#include "calc.tab.h"

void exit(int val);

const char* OPNAMES[] = {"MOV", "ADD", "SUB", "OUT", "STR", "LOD", "HLT", "CMP", "BRA", "JMP"};
const char* RELNAMES[] = {"EQ", "LT", "LE", "GT", "GE"};

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
	| T_LBL INSTRUCTIONS {
			instr_head[current_instr_head] = (t_instr_seq*) malloc(sizeof(t_instr_seq));
			instr_head[current_instr_head]->opcode = -1;
			instr_head[current_instr_head]->is_oper_src = 0;
			instr_head[current_instr_head]->oper = NULL;
			instr_head[current_instr_head]->src1 = NULL;
			instr_head[current_instr_head]->src2 = NULL;
			instr_head[current_instr_head]->addr = current_instr_head;
			instr_head[current_instr_head]->target_label = NULL;
			instr_head[current_instr_head]->label = $1;
			instr_head[current_instr_head]->rel = -1;

			current_instr_head++;
			program_size++;
			
		}
	| OPCODE INSTRUCTIONS {
			instr_head[current_instr_head] = $1;
			instr_head[current_instr_head]->addr = current_instr_head;
			current_instr_head++;
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
				//printf("%s\n", $$->oper->name);
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
			$$->target_label = NULL;
			$$->label = NULL;
			$$->rel = -1;
		}

ARG_TYPE1:

	E 	{
			$$ = (t_instr_seq*) malloc(sizeof(t_instr_seq));
			$$->is_oper_src = 1;
			$$->oper = $1;
			$$->src1 = NULL;
			$$->src2 = NULL;
			$$->target_label = NULL;
			$$->label = NULL;
			$$->rel = -1;
		}

ARG_TYPE2:

	T_REG T_COMM E {

			$$ = (t_instr_seq*) malloc(sizeof(t_instr_seq));
			$$->is_oper_src = 0;
			$$->oper = $1;
			$$->src1 = $3;
			$$->src2 = NULL;
			$$->target_label = NULL;
			$$->label = NULL;
			$$->rel = -1;
		}

ARG_TYPE3:

	T_REG T_COMM E T_COMM E {

			$$ = (t_instr_seq*) malloc(sizeof(t_instr_seq));
			$$->is_oper_src = 0;
			$$->oper = $1;
			$$->src1 = $3;
			$$->src2 = $5;
			$$->target_label = NULL;
			$$->label = NULL;
			$$->rel = -1;
		}

ARG_TYPE4:
	REL T_COMM E T_COMM T_TLBL {
			$$ = (t_instr_seq*) malloc(sizeof(t_instr_seq));
			$$->is_oper_src = 0;
			$$->oper = NULL;
			$$->src1 = $3;
			$$->src2 = NULL;
			$$->rel = $1;
			$$->target_label = $5;
			$$->label = NULL;
			
		}

ARG_TYPE5:
	T_TLBL {
			$$ = (t_instr_seq*) malloc(sizeof(t_instr_seq));
			$$->is_oper_src = 0;
			$$->oper = NULL;
			$$->src1 = NULL;
			$$->src2 = NULL;
			$$->target_label = $1;
			$$->label = NULL;
			$$->rel = -1;
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
	instr_head = (t_instr_seq**) malloc(sizeof(t_instr_seq*));
}



void printProgram(){
	int i;
	printf("%05d>\n", 0);
	for(i=program_size-1; i>=0; i--){
		t_instr_seq* curr = instr_head[i];
		printf("%05d>\t", (program_size - curr->addr));
		if(curr->opcode == -1){
			printf("%s:\n", curr->label);
		} else {
			printf("\t%s", OPNAMES[curr->opcode]);
			if(curr->oper != NULL)
				if(curr->oper->number != -1) printf("\t%s", curr->oper->name);
				else printf("\t%d", curr->oper->value);
			else if(curr->rel != -1) printf("\t%s", RELNAMES[curr->rel]);
			if(curr->src1 != NULL)
				if(curr->src1->number != -1) printf("\t%s", curr->src1->name);
				else printf("\t%d", curr->src1->value);
			if(curr->src2 != NULL)
				if(curr->src2->number != -1) printf("\t%s", curr->src2->name);
				else printf("\t%d", curr->src2->value);
			else if(curr->target_label != NULL) printf("\t%s", curr->target_label);
		}
		
		

		printf("\n");
	}
}

int main()
{	
	initializeRegisters(32);
	yyparse();
	printProgram();
	return 0;
}


