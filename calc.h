int yyerror(char *s);
int yylex();

enum OP{MOV, ADD, SUB, OUT};

typedef struct s_register {
	char *name;
	int number;
	int value;
}t_register;

t_register *register_file;
int register_size;

typedef struct s_instruction_sequence {
	enum OP opcode;
	t_register oper;
	t_register src1;
	t_register src2;
}t_inst_seq;
