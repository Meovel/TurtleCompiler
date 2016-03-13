/*
 * Turtle Compiler
 * turtle_main.c
 * Hao Zhang
 * Isobel Stobo
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "codegen.h"
#include "symbol_table.h"
#include "turtle.tab.h"



extern FILE *yyin;

int main(int argc, char * argv[])
{
    if(argc < 3)
    {
        printf("usage: ./turtle turtle.t code.p \n");
        exit(0);
    }
    
    FILE *turtle_file;
    
    turtle_file = fopen(argv[1],"r");
    if(turtle_file == NULL){
        perror("Unable to open input file.");
        exit(1);
    }
    
    yyin = turtle_file;
    yyparse();
    write_code(argv[1]);
    fclose(turtle_file);
}


