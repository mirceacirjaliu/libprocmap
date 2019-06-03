%{

#include <stdio.h>
#include <inttypes.h>
#include <string.h>

// TODO: fix circular dependency between headers
typedef void* yyscan_t;

#include "libprocmap.h"
#include "libprocmap.tab.h"
#include "libprocmap.yy.h"

extern void yyerror(YYLTYPE *yylloc, yyscan_t scanner, const char *str);

static void (*callback)(struct memmap*);

%}

%define api.pure full
%locations
%lex-param {yyscan_t scanner}
%parse-param {yyscan_t scanner}

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
	FILE *in;
	yyscan_t scanner;
	int result;

	sprintf(fname, "/proc/%d/maps", pid);
	printf("Will open: %s\n", fname);

	in = fopen(fname, "r");
	if (in == NULL)
		return 1;

	yylex_init(&scanner);
	yyset_in(in, scanner);

	printf("Starting...\n");
	callback = cb;
	result = yyparse(scanner);

	yylex_destroy(scanner);

	return result;
}

extern void yyerror(YYLTYPE *yylloc, yyscan_t scanner, const char *str)
{
	fprintf(stderr, "%s\n", str);
}
