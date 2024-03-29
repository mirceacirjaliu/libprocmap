%{

#include <stdio.h>
#include <inttypes.h>
#include <string.h>
#include <errno.h>

// TODO: fix circular dependency between headers
typedef void* yyscan_t;

#include "libprocmap.h"
#include "libprocmap.tab.h"
#include "libprocmap.yy.h"

void yyerror(YYLTYPE *yylloc, yyscan_t scanner, vma_map_cb cb, void *env, const char *str);

%}

%define api.pure full
%locations
%param {yyscan_t scanner}
%parse-param {vma_map_cb cb}
%parse-param {void *env}

%union
{
		char string[256];
		struct perms perms;
		struct vma_map map;
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
%token <string> deleted

%type <map> line
%type <string> path

%%

lines : lines line
	  | %empty
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

		cb(env, &$$);
	}
	;

path : pathname			{ strcpy($$, $1); }
	| pathname deleted	{ strcpy($$, $1); strcat($$, " "); strcat($$, $2); }
	| heap		{ strcpy($$, $1); }
	| stack		{ strcpy($$, $1); }
	| vvar		{ strcpy($$, $1); }
	| vdso		{ strcpy($$, $1); }
	| vsyscall	{ strcpy($$, $1); }
	| %empty	{ $$[0] = '\0'; }
	;

%%

int direct_parse(const char *fname, vma_map_cb cb, void *env)
{
	FILE *in;
	yyscan_t scanner;
	int result;

	in = fopen(fname, "r");
	if (in == NULL)
		return 1;

	yylex_init(&scanner);
	yyset_in(in, scanner);

	result = yyparse(scanner, cb, env);

	yylex_destroy(scanner);
	fclose(in);

	return result;
}

int get_proc_map(int pid, vma_map_cb cb, void *env)
{
	char fname[32];

	sprintf(fname, "/proc/%d/maps", pid);

	return direct_parse(fname, cb, env);
}

void yyerror(YYLTYPE *yylloc, yyscan_t scanner, vma_map_cb cb, void *env, const char *str)
{
	fprintf(stderr, "%s @ %d, %d\n", str, yylloc->first_line, yylloc->first_column);
	errno = EINVAL;
}
