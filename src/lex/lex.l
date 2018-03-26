%option noyywrap
%{
#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include "hash.h"

void push(char* name, std::string token);
void push_check_reserved(char* name);
void skip_comments();
void unsupported_char(char* name);

int line_num = 1;
int num_errors = 0;
std::ostringstream report_buffer;

%}


digit   [0-9]
num     {digit}{digit}*
alpha   [a-zA-Z]
id      {alpha}({alpha}|{digit})*
ws      [ \t\r]

%%
"+"                     { push(yytext, "SOMA");}
"-"                     { push(yytext, "SUB");}
"*"                     { push(yytext, "MUL");}
"/"                     { push(yytext, "DIV");}
"<="                    { push(yytext, "MEIGUAL");}
"<"                     { push(yytext, "MENOR");}
">="                    { push(yytext, "MAIGUAL");}
">"                     { push(yytext, "MAIOR");}
"=="                    { push(yytext, "IGUAL");}
"!="                    { push(yytext, "DIF");}
"="                     { push(yytext, "ATRIB");}
";"                     { push(yytext, "PV");}
","                     { push(yytext, "V");}
"("                     { push(yytext, "AP");}
")"                     { push(yytext, "FP");}
"["                     { push(yytext, "ACO");}
"]"                     { push(yytext, "FCO");}
"{"                     { push(yytext, "ACH");}
"}"                     { push(yytext, "FCH");}
{num}                   { push(yytext, "NUM");}
{id}                    { push_check_reserved(yytext); }
"/*"                    { skip_comments(); }
"\n"                    { line_num++; }
{ws}+                   { }
.                       { unsupported_char(yytext); }
%%

void push(char* name, std::string token) {
    report_buffer << name << " " << token << std::endl ;
}

void push_check_reserved(char* name) {
    switch (HASH(name)) {
        case CONST_HASH("else"): {      push(name, "ELSE");   } break;
        case CONST_HASH("if"): {        push(name, "IF");     } break;
        case CONST_HASH("int"): {       push(name, "INT");    } break;
        case CONST_HASH("return"): {    push(name, "RETURN"); } break;
        case CONST_HASH("void"): {      push(name, "VOID");   } break;
        case CONST_HASH("while"): {     push(name, "WHILE");  } break;
        case CONST_HASH("input"): {     push(name, "INPUT");  } break;
        case CONST_HASH("output"): {    push(name, "OUTPUT"); } break;

        default: { push(name, "ID"); } break;
    }
    
}

void unsupported_char(char* name) {
    report_buffer << name << " ERRO" << std::endl;
    num_errors++;
}

void skip_comments() {
    int c;
    bool ended = false;
    while (!ended && (c = yyinput()) != 0) {
        switch(c) {
            case '\n': {
                line_num++;
            } break;

            case '*': {
                if ((c = yyinput()) == '/') { ended = true; }
                else { unput(c); }
            } break;
        }
    }

    // reached end of file during comment
    if (!ended) {
        num_errors++;
    }
}

void report(const std::string& filename, const std::string& buf) {
    std::fstream fs (filename, std::fstream::trunc | std::fstream::out);
    fs << num_errors << " erro(s) encontrado(s)" << std::endl;
    fs << buf;
    fs.close();
}

int main(int argc, char **argv) {
    // decide input file
    if (argc >= 2) {
        FILE* in = fopen(argv[1], "r");
        if (in) {
            yyin = in;
        } else {
            std::cerr << argv[1] << " does not exist" << std::endl;
            return EXIT_FAILURE;
        }
    } else {
        yyin = stdin;
    }

    yylex();

    report("relatorio.txt", report_buffer.str());

    fclose(yyin);

    return EXIT_SUCCESS;
}

