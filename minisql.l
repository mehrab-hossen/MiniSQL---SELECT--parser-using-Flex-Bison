%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "minisql.tab.h"
%}

digit      [0-9]
letter     [a-zA-Z_]
id         {letter}({letter}|[0-9_])*

%%

"SELECT"        { return SELECT; }
"FROM"          { return FROM; }
"WHERE"         { return WHERE; }
"AND"           { return AND; }
"OR"            { return OR; }

"*"             { return STAR; }
","             { return COMMA; }
";"             { return SEMI; }
"("             { return LPAREN; }
")"             { return RPAREN; }

"="             { return EQ; }
"<>"            { return NE; }
">="            { return GE; }
"<="            { return LE; }
">"             { return GT; }
"<"             { return LT; }

{digit}+        {
                    yylval.ival = atoi(yytext);
                    return NUMBER;
                }

{id}            {
                    yylval.sval = strdup(yytext);
                    return ID;
                }

[ \t\r\n]+      { /* ignore whitespace */ }

.               {
                    printf("Unknown character: %s\n", yytext);
                }

%%

int yywrap(void) {
    return 1;
}
