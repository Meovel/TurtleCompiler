/*
 * Turtle Compiler
 * symbol_table.c
 * Hao Zhang
 * Isobel Stobo
 
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "symbol_table.h"


func_table *func_head = NULL;
var_table *var_head = NULL;

func_table *getFunc(char *name)
{
    func_table *ptr;
    for (ptr = func_head; ptr != NULL; ptr = ptr->next)
    {
        if (strcmp(name, ptr->node.name) == 0)	//returns first entry with same name
        {
            return ptr;		
        }
    }
    return NULL; // returns NULL if not in symbol table
}

func_table *addFunc(char *name, int address)
{
    if (getFunc(name)) //check if function name already exists in table 
    {
        return NULL;	
    }
    func_table *new = NULL;
    new = malloc(sizeof(*new));
    if (NULL == new)		
    {
        return NULL;
    }
	
    new->node.name = name;
    new->node.address = address;
    new->node.params = 0;    //I think this will need to be increased as parametres are evaluated.
    new->next = func_head;
    func_head = new;

    return new;
}

func_table *increase_parameters(char *name){
    func_table *ptr = getFunc(name);
    if (!ptr){
        return NULL;
    }
    ptr->node.params += 1;
    return ptr;
}

var_table *getVar(char *name, func *scope)
{
    var_table *ptr;
    for (ptr = var_head; ptr != NULL; ptr = ptr->next) //looks through function symbol table
    {
        if (strcmp(name, ptr->node.name) == 0)	//checks for variables and parameters with the same name in the same scope
        {
            if (scope == ptr->node.scope)
            {
                return ptr;
            }		
        }
    }
    return NULL; // returns NULL if not in symbol table
}

var_table *addVar(char *name, func *scope, int address)
{
    if (getVar(name, scope))		//check if a variable or parameter name already exists within a given scope. Do not allow duplicates.
    {
        return NULL;	
    }
    var_table *new = NULL;
    new = malloc(sizeof(*new));
    if (NULL == new)		
    {
        return NULL;
    }
	
    new->node.name = name;
    new->node.scope = scope;
    new->node.address = address;
    new->next = var_head;
    var_head = new;

    return new;
}


