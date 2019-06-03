%{

#include <stdio.h>
#include <inttypes.h>
#include <string.h>

#include "libprocmap.h"
#include "libprocmap.yy.h"

void yyerror(char *s);

static void (*callback)(struct memmap*);

%}

%union
{
		uint64_t number;
		struct perms perms;
		char *string;
		struct memmap map;
}

%start lines

%token <perms> perms
%token <number> number

%token <string> pathname
%token <string> heap
%token <string> stack
%token <string> vvar
%token <string> vdso
%token <string> vsyscall

%type <map> line
%type <string> path

%%

lines : line
	  | lines line
	  ;

line : number'-'number perms number number':'number number path '\n'
	{
		$$.start = $1;
		$$.end = $3;
		$$.perms = $4;
		$$.offset = $5;
		$$.dev.major = $6;
		$$.dev.minor = $8;
		$$.inode = $9;
		if ($10 != NULL)
			strcpy($$.pathname, $10);
		else
			$$.pathname[0] = '\0';

		callback(&$$);
	}
	;

path : pathname
	| heap		{ $$ = $1; }
	| stack		{ $$ = $1; }
	| vvar		{ $$ = $1; }
	| vdso		{ $$ = $1; }
	| vsyscall	{ $$ = $1; }
	| %empty	{ $$ = NULL; }
	;

%%

int get_proc_map(int pid, void (*cb)(struct memmap*))
{
	char fname[32];

	sprintf(fname, "/proc/%d/maps", pid);
	printf("Will open: %s\n", fname);

	yyin = fopen(fname, "r");
	if (yyin == NULL)
		return 1;

	printf("Starting...\n");
	callback = cb;
	return yyparse();
}

void yyerror(char *str)
{
	fprintf(stderr, "%s at line %d (%s)\n", str, yylineno, yytext);
}


