/*
 * Turtle Compiler
 * symbol_table.h
 * Hao Zhang
 * Isobel Stobo
 
 */

#ifndef SYMBOL_TABLE_H_  
#define SYMBOL_TABLE_H_ 

//Function Symbol Table implemented as Linked List.
typedef struct func_t 
{
    char *name; //function name
    int address; // entry address
    int params; //number of parameters
} func;

typedef struct func_table_t
{
    func node;
    struct func_table_t *next;
} func_table;

//Searches the Function Symbol Tables for functions with given name. Returns NULL if nothing is found.
func_table *getFunc(char *name);

//Adds a function to the Function Symbol Table. Does not allow duplicates. Returns NULL if name already in table.
func_table *addFunc(char *name, int address);

func_table *increase_parameters(char *name);

//Parameter and Variable Symbol Table implemented as Linked List.
typedef struct var_t 
{
    char *name; //variable/parameter name
    func *scope; //the function where the variable is defined or NULL if a global variable.
    int address; // entry address
} var;

typedef struct var_table_t
{
    var node;
    struct var_table_t *next;
} var_table;

//Searches the Parameter and Variable Symbol Table for functions with given name in given scope. Returns NULL if nothing is found.
var_table *getVar(char *name, func *scope);

//Adds a parameter or variable to the Parameter and Variable Symbol Table. Does not allow duplicates withing the same scope.
//Returns NULL if a name within the given scope is already in table.
var_table *addVar(char *name, func *scope, int address);

#endif