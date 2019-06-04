%{

#include <stdlib.h>
#include <string.h>

#include "libprocmap.h"
#include "libprocmap.tab.h"

extern void yyerror(YYLTYPE *yylloc, yyscan_t scanner, vma_map_cb cb, const char *str);

#define add_token_column(yylloc)					\
do {												\
	yylloc->first_column = yylloc->last_column;		\
	yylloc->last_column += yyleng;					\
} while(0)

#define inc_token_line(yylloc)						\
do {												\
	yylloc->first_column = yylloc->last_column = 1;	\
	yylloc->first_line++;							\
	yylloc->last_line++;							\
} while(0)

%}

%option bison-bridge bison-locations
%option reentrant

%%

[0-9a-f]+				{	/* number */
							strncpy(yylval->string, yytext, yyleng);
							yylval->string[yyleng] = '\0';

							add_token_column(yylloc);

							return num;
						}

[r|-][w|-][x|-][s|p]	{	/* permissions */
							yylval->perms.read = yytext[0] == 'r';
							yylval->perms.write = yytext[1] == 'w';
							yylval->perms.execute = yytext[2] == 'x';
							yylval->perms.shared = yytext[3] == 's';

							add_token_column(yylloc);

							return perms;
						}

\/[a-zA-Z0-9\/\-\+_\.]+	{
							strncpy(yylval->string, yytext, yyleng);
							yylval->string[yyleng] = '\0';

							add_token_column(yylloc);

							return pathname;
						}

"[heap]"				{
							strncpy(yylval->string, yytext, yyleng);
							yylval->string[yyleng] = '\0';

							add_token_column(yylloc);

							return heap;
						}

"[stack]"				{
							strncpy(yylval->string, yytext, yyleng);
							yylval->string[yyleng] = '\0';

							add_token_column(yylloc);

							return stack;
						}

"[vvar]"				{
							strncpy(yylval->string, yytext, yyleng);
							yylval->string[yyleng] = '\0';

							add_token_column(yylloc);

							return vvar;
						}

"[vdso]"				{
							strncpy(yylval->string, yytext, yyleng);
							yylval->string[yyleng] = '\0';

							add_token_column(yylloc);

							return vdso;
						}

"[vsyscall]"			{
							strncpy(yylval->string, yytext, yyleng);
							yylval->string[yyleng] = '\0';

							add_token_column(yylloc);

							return vsyscall;
						}

"(deleted)"				{
							strncpy(yylval->string, yytext, yyleng);
							yylval->string[yyleng] = '\0';

							add_token_column(yylloc);

							return deleted;
						}

[ \t]+					{
							add_token_column(yylloc);
						}

[-:]					{
							add_token_column(yylloc);

							return yytext[0];
						}

[\n]					{
							inc_token_line(yylloc);

							return yytext[0];
						}

.						{
							add_token_column(yylloc);

							return yytext[0];
						}

%%

int yywrap(yyscan_t yyscanner) { return 1; }
