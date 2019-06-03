%{

#include <stdlib.h>

#include "libprocmap.h"
#include "libprocmap.tab.h"

extern void yyerror(char *str);

%}

%%

[0-9]+				{	/* decimal */
						//printf("Found decimal: %s\n", yytext);

						yylval.number = strtol(yytext, NULL, 10);
						return number;
					}

[0-9a-f]+			{	/* hexadecimal */
						//printf("Found hex: %s\n", yytext);

						yylval.number = strtol(yytext, NULL, 16);
						return number;
					}

[r|-][w|-][x|-][s|p] {	/* permissions */
						//printf("Found permissions: %s\n", yytext);

						yylval.perms.read = yytext[0] == 'r';
						yylval.perms.write = yytext[1] == 'w';
						yylval.perms.execute = yytext[2] == 'x';
						yylval.perms.shared = yytext[3] == 's';

						return perms;
					}

\/[a-zA-Z0-9\/\-_\.]+	{ yylval.string = yytext; return pathname; }

"[heap]"			{ yylval.string = yytext; return heap; }
"[stack]"			{ yylval.string = yytext; return stack; }
"[vvar]"			{ yylval.string = yytext; return vvar; }
"[vdso]"			{ yylval.string = yytext; return vdso; }
"[vsyscall]"		{ yylval.string = yytext; return vsyscall; }

[ \t]				;

[-:]				{ return yytext[0]; }
[\n]				{
						yylineno++;
						return yytext[0];
					}

.					{ ECHO; printf("unexpected character: %c\n", yytext[0]); }


%%

int yywrap(void) { return 1; }
