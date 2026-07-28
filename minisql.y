%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    int yylex(void);
    void yyerror(const char *s);

    /* Buffers to store parsed info */
    char current_table[100];
    char selected_columns[500];
    char where_clause[500];
%}

%union {
    int ival;
    char *sval;
}

/* Tokens */
%token SELECT FROM WHERE AND OR
%token STAR
%token COMMA
%token SEMI
%token LPAREN RPAREN
%token EQ LT GT LE GE NE
%token <sval> ID
%token <ival> NUMBER

/* Non-terminal types */
%type <sval> condition expr comp_op value

%left OR
%left AND
%nonassoc EQ LT GT LE GE NE

%%

query
    : SELECT select_list FROM ID opt_where SEMI
        {
            /* Save table name */
            strncpy(current_table, $4, sizeof(current_table)-1);
            current_table[sizeof(current_table)-1] = '\0';

            printf("\n✅ Valid SQL query.\n");
            printf("   Table   : %s\n", current_table);
            printf("   Columns : %s\n", selected_columns);
            printf("   WHERE   : %s\n", where_clause[0] ? where_clause : "(none)\n");

            free($4);
        }
    ;

select_list
    : STAR
        {
            strcpy(selected_columns, "*");
        }
    | column_list
        {
            /* column_list already filled selected_columns */
        }
    ;

column_list
    : ID
        {
            strcpy(selected_columns, $1);
            free($1);
        }
    | column_list COMMA ID
        {
            strcat(selected_columns, ", ");
            strcat(selected_columns, $3);
            free($3);
        }
    ;

opt_where
    : /* empty */
        {
            where_clause[0] = '\0';  /* no WHERE */
        }
    | WHERE condition
        {
            strncpy(where_clause, $2, sizeof(where_clause)-1);
            where_clause[sizeof(where_clause)-1] = '\0';
            free($2);
        }
    ;

/* condition builds a string like:
   age >= 18
   age >= 18 AND marks > 50
   (age >= 18 OR grade = A)
*/
condition
    : expr
        {
            $$ = $1;
        }
    | condition AND condition
        {
            char *buf = malloc(strlen($1) + strlen($3) + 6);
            sprintf(buf, "%s AND %s", $1, $3);
            free($1);
            free($3);
            $$ = buf;
        }
    | condition OR condition
        {
            char *buf = malloc(strlen($1) + strlen($3) + 5);
            sprintf(buf, "%s OR %s", $1, $3);
            free($1);
            free($3);
            $$ = buf;
        }
    | LPAREN condition RPAREN
        {
            char *buf = malloc(strlen($2) + 3);
            sprintf(buf, "(%s)", $2);
            free($2);
            $$ = buf;
        }
    ;

/* Single comparison:  col op value  */
expr
    : ID comp_op value
        {
            char *buf = malloc(strlen($1) + strlen($2) + strlen($3) + 3);
            sprintf(buf, "%s %s %s", $1, $2, $3);
            free($1);
            free($2);
            free($3);
            $$ = buf;
        }
    ;

comp_op
    : EQ  { $$ = strdup("=");  }
    | LT  { $$ = strdup("<");  }
    | GT  { $$ = strdup(">");  }
    | LE  { $$ = strdup("<="); }
    | GE  { $$ = strdup(">="); }
    | NE  { $$ = strdup("<>"); }
    ;

value
    : NUMBER
        {
            char tmp[50];
            sprintf(tmp, "%d", $1);
            $$ = strdup(tmp);
        }
    | ID
        {
            $$ = $1;
        }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "❌ Syntax error: %s\n", s);
}

int main(void) {
    printf("MiniSQL - SELECT-FROM-WHERE Parser\n");
    printf("Example queries:\n");
    printf("  SELECT name, age FROM students WHERE age >= 18;\n");
    printf("  SELECT * FROM teachers;\n\n");
    printf("Enter your SQL query:\n\n");

    yyparse();
    return 0;
}
