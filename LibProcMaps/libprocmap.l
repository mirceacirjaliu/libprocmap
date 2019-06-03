%{

#include <stdlib.h>
#include <string.h>

#include "libprocmap.h"
#include "libprocmap.tab.h"

extern void yyerror(YYLTYPE *yylloc, yyscan_t scanner, vma_map_cb cb, const char *str);

%}

%option bison-bridge bison-locations
%option reentrant

%%

[0-9a-f]+			{	/* number */
						//printf("Found number: %s\n", yytext);

						strncpy(yylval->string, yytext, yyleng);
						yylval->string[yyleng] = '\0';

						return num;
					}

[r|-][w|-][x|-][s|p] {	/* permissions */
						//printf("Found permissions: %s\n", yytext);

						yylval->perms.read = yytext[0] == 'r';
						yylval->perms.write = yytext[1] == 'w';
						yylval->perms.execute = yytext[2] == 'x';
						yylval->perms.shared = yytext[3] == 's';

						return perms;
					}

\/[a-zA-Z0-9\/\-_\.]+	{
							strncpy(yylval->string, yytext, yyleng);
							yylval->string[yyleng] = '\0';

							return pathname;
						}

"[heap]"				{
							strncpy(yylval->string, yytext, yyleng);
							yylval->string[yyleng] = '\0';

							return heap;
						}

"[stack]"				{
							strncpy(yylval->string, yytext, yyleng);
							yylval->string[yyleng] = '\0';
							return stack;
						}

"[vvar]"				{
							strncpy(yylval->string, yytext, yyleng);
							yylval->string[yyleng] = '\0';

							return vvar;
						}

"[vdso]"				{
							strncpy(yylval->string, yytext, yyleng);
							yylval->string[yyleng] = '\0';

							return vdso;
						}

"[vsyscall]"			{
							strncpy(yylval->string, yytext, yyleng);
							yylval->string[yyleng] = '\0';

							return vsyscall;
						}

[ \t]				;

[-:]				{ return yytext[0]; }
[\n]				{
						yylineno++;
						return yytext[0];
					}

.					{ ECHO; printf("unexpected character: %c\n", yytext[0]); }


%%

int yywrap(yyscan_t yyscanner) { return 1; }
