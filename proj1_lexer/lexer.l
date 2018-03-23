%{
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

// globals
int n_errors;
FILE *buf_fp;

// forward declare
void skip_comment();
int identifier_lookup(char *);
void unrecognized_character(char *);
%}

%option noyywrap

%%
"+"                     { fprintf(buf_fp, "%s SOMA\n", yytext); }
"-"                     { fprintf(buf_fp, "%s SUB\n", yytext); }
"*"                     { fprintf(buf_fp, "%s MUL\n", yytext); }
"/"                     { fprintf(buf_fp, "%s DIV\n", yytext); }
"<="                    { fprintf(buf_fp, "%s MEIGUAL\n", yytext); }
"<"                     { fprintf(buf_fp, "%s MENOR\n", yytext); }
">="                    { fprintf(buf_fp, "%s MAIGUAL\n", yytext); }
">"                     { fprintf(buf_fp, "%s MAIOR\n", yytext); }
"!="                    { fprintf(buf_fp, "%s DIF\n", yytext); }
"=="                    { fprintf(buf_fp, "%s IGUAL\n", yytext); }
"="                     { fprintf(buf_fp, "%s ATRIB\n", yytext); }
";"                     { fprintf(buf_fp, "%s PV\n", yytext); }
","                     { fprintf(buf_fp, "%s V\n", yytext); }
"("                     { fprintf(buf_fp, "%s AP\n", yytext); }
")"                     { fprintf(buf_fp, "%s FP\n", yytext); }
"["                     { fprintf(buf_fp, "%s ACO\n", yytext); }
"]"                     { fprintf(buf_fp, "%s FCO\n", yytext); }
"{"                     { fprintf(buf_fp, "%s ACH\n", yytext); }
"}"                     { fprintf(buf_fp, "%s FCH\n", yytext); }
"/*"                    { skip_comment(); }
[a-zA-Z][a-zA-Z0-9]*    { if (!identifier_lookup(yytext))
                              fprintf(buf_fp, "%s ID\n", yytext);
                        }
[ \t\n]+                { ; }
.                       { unrecognized_character(yytext); }
%%

void skip_comment()
{
    int c;

    while (1) {
        c = input();

        switch(c) {

            case '*':
                if ((c = input()) == '/')
                    return;
                else
                    unput(c);
                break;

            case EOF:
                fprintf(buf_fp, "Erro: comentário multilinha não fechado\n");
                n_errors++;
                unput(c);
                return;

            default:
                break;
        }
    }
}

int identifier_lookup(char *name)
{
    if (strcmp(name, "else") == 0) {
        fprintf(buf_fp, "%s ELSE\n", name);
        return 1;
    } else if (strcmp(name, "if") == 0) {
        fprintf(buf_fp, "%s IF\n", name);
        return 1;
    } else if (strcmp(name, "int") == 0) {
        fprintf(buf_fp, "%s INT\n", name);
        return 1;
    } else if (strcmp(name, "void") == 0) {
        fprintf(buf_fp, "%s VOID\n", name);
        return 1;
    } else if (strcmp(name, "while") == 0) {
        fprintf(buf_fp, "%s WHILE\n", name);
        return 1;
    } else if (strcmp(name, "input") == 0) {
        fprintf(buf_fp, "%s INPUT\n", name);
        return 1;
    } else if (strcmp(name, "output") == 0) {
        fprintf(buf_fp, "%s OUTPUT\n", name);
        return 1;
    } else if (strcmp(name, "return") == 0) {
        fprintf(buf_fp, "%s RETURN\n", name);
        return 1;
    }

    return 0;
}

void unrecognized_character(char *text)
{
    fprintf(buf_fp, "Erro: caractere desconhecido: %s\n", text);
    n_errors++;
}

int main(int argc, char *argv[])
{
    buf_fp = fopen(".lexer.buf", "w+");
    n_errors = 0;

    yylex();

    printf("%d erro(s) encontrado(s)\n", n_errors);

    char buf[254];
    rewind(buf_fp);

    while(!feof(buf_fp)) {
        fgets(buf, 254, buf_fp);

        if (!feof(buf_fp))
            printf("%s", buf);
    }

    fclose(buf_fp);
    return EXIT_SUCCESS;
}
