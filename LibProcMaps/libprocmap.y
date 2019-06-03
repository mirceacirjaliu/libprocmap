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
		char string[256];
		struct perms perms;
		struct memmap map;
}

%start lines

%token <perms> perms
%token <string> num

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

line : num'-'num perms num num':'num num path '\n'
	{
		$$.start = strtol($1, NULL, 16);
		$$.end = strtol($3, NULL, 16);
		$$.perms = $4;
		$$.offset = strtol($5, NULL, 16);
		$$.dev.major = strtol($6, NULL, 16);
		$$.dev.minor = strtol($8, NULL, 16);
		$$.inode = strtol($9, NULL, 10);
		strcpy($$.pathname, $10);

		callback(&$$);
	}
	;

path : pathname
	| heap		{ strcpy($$, $1); }
	| stack		{ strcpy($$, $1); }
	| vvar		{ strcpy($$, $1); }
	| vdso		{ strcpy($$, $1); }
	| vsyscall	{ strcpy($$, $1); }
	| %empty	{ $$[0] = '\0'; }
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

	// TODO: pass callback to parser, breaks reentrancy
	callback = cb;
	result = yyparse(scanner);

	yylex_destroy(scanner);

	return result;
}

extern void yyerror(YYLTYPE *yylloc, yyscan_t scanner, const char *str)
{
	fprintf(stderr, "%s\n", str);
}
