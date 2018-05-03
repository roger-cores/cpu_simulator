int yyerror(char *s);
int yylex();

enum OP{MOV, ADD, SUB, OUT, STR, LOD, HLT, CMP, BRA, JMP};
enum REL{EQ, LT, LE, GT, GE};

typedef struct s_register {
	char *name;
	int number;
	int value;
}t_register;

t_register *register_file;
int register_size;

typedef struct s_instruction_sequence {
	enum OP opcode;
	int is_oper_src;
	t_register* oper;
	t_register* src1;
	t_register* src2;
	int addr;
	enum REL rel;
	char* label;
	char* target_label;
	struct s_instruction_sequence* next;
}t_instr_seq;

t_instr_seq* instr_head;
t_instr_seq* current;
int program_size;
