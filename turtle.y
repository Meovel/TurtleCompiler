/*
 * Turtle Compiler
 * turtle.y
 * Hao Zhang
 * Isobel Stobo
 */
 
%{
	#include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    
    #include "symbol_table.h"
    #include "codegen.h"
    
    func *scope = NULL;
    func *call = NULL;
%}

%union {
/* integer is the only data type */
    char *var;
    int val;
    addr address; 
    func_table *func;
}

/* Grammar */


%token <var> IDENT
%token <val> NUM
%token TURTLE

/*  */
%token UP
%token DOWN
%token MOVETO
%token VAR
%token FUN
%token READ
%token IF
%token ELSE
%token WHILE
%token RETURN

/*  */
%token PLUS
%token MINUS
%token MULT
%token LPAREN
%token RPAREN
%token LBRACE
%token RBRACE
%token COMMA
%token LT
%token EQ
%token ASSN

%type <func> fun_ident
%type <val> parameters_head
%type <val> parameters_tail
%type <val> args_head
%type <val> args_tail

%type <address> global_var_declarations
%type <address> compare
%type <address> elsepart
%type <address> whilepart
%%

start : TURTLE IDENT global_var_declarations fun_declarations {backpatch($3,getAddress());}
                     compound_statement                { gen(HALT); }
      ;
		  
/* variable declarations */

global_var_declarations: var_declarations {$$ = (gen2(JUMP,0)) - 1};

var_declarations
                 : var_declaration var_declarations
                 |
                 ;

var_declaration : VAR IDENT var_assign {
                                        var_table *v = addVar($2, scope, getAddress());
    
                                        /* if failed to add Variable */
                                        if (v == NULL)
                                        {
                                          yyerror("Variable already defined in scope");
                                         
                                         }
                                        }
                ;

var_assign : ASSN exp
           | /* empty = assign 0 */ {gen2(LOADI, 0);}
           ;


/* function definition */

fun_declarations : fun_declaration fun_declarations
                 |
                 ;

fun_declaration : fun_ident LPAREN parameters_head RPAREN var_declarations compound_statement {scope = NULL; gen(RTS); }
                ;

fun_ident : FUN IDENT  {func_table *f = addFunc($2, getAddress());
                        if (f == NULL)
                        {
                          yyerror("Function already defined");
                        }
                        scope = &f->node;
                       }
           ;

parameters_head : IDENT parameters_tail {
                  unsigned short address = (-2 - (scope->params));
                  var_table *v = addVar($1, scope, address);
                  if (v == NULL){
                    yyerror("Variable already defined in scope");
                  }else{
                    increase_parameters(scope->name);
                  }
                 }
                | {$$ = scope->params}
                ;

parameters_tail : COMMA IDENT parameters_tail {
                  unsigned short address = (-2 - (scope->params));
                  var_table *v = addVar($2, scope, address);
                  if (v == NULL){
                    yyerror("Variable already defined in scope");
                  }else{
                    increase_parameters(scope->name);
                  }
                 }
                | {$$ = scope->params}
                ;

/* compound statement */

compound_statement : LBRACE statements RBRACE;

statements : statement statements
           |
           ;

statement : UP                                 {gen(UP);}
          | DOWN                               {gen(DOWN);}
          | MOVETO LPAREN exp COMMA exp RPAREN {gen(MOVE);}
          | READ LPAREN IDENT RPAREN           {
              var_table *var = getVar($3, scope);
              if (var == NULL){
                yyerror("Undefined Variable");
              }else{
                if (var->node.scope){
                    gen_offset(READ_FP, var->node.address);
                }else{
                     gen_offset(READ_GP, var->node.address);
                }
              }
             }

          | IDENT ASSN exp {
                  var_table *var = getVar($1, scope);
                  if (var == NULL){
                      yyerror("Undefined Variable");
                  }else{
                      if (var->node.scope){
                          gen_offset(STORE_FP, var->node.address);
                      }else{
                          gen_offset(STORE_GP, var->node.address);
                      }
                  }
              }
          | IF LPAREN compare RPAREN statement                    {backpatch($3,getAddress());}
          | IF LPAREN compare RPAREN statement elsepart statement {backpatch($3,getAddress()-2);
                                                                   backpatch($6,getAddress());}
          | whilepart LPAREN compare RPAREN statement             {gen2(JUMP,$1);
                                                                   backpatch($3,getAddress());}
          | RETURN exp {
              if (scope == NULL){
                yyerror("Return statement illegal outside of function");
              }else{
                unsigned short address = -(scope->params)-2;
                gen_offset(STORE_FP, address);
              }
            }
		  | IDENT arguments {gen2(LOADI,0);
                             func_table *entry = getFunc($1);
                             call = &entry->node;}
          | compound_statement
          ;


elsepart: ELSE {$$ = gen2(JUMP,0)+1;};

whilepart: WHILE {$$ = getAddress(); };

/* expression */

exp : exp PLUS term   {gen(ADD);}
    | exp MINUS term  {gen(SUB);}
    | term
    ;

term : term MULT fact {gen(MUL);}
     | fact
     ;

fact : MINUS fact {gen(NEG);}
     | LPAREN exp RPAREN 
     | NUM  { int val = $1; gen2(LOADI,val); }
     | IDENT {var_table *var = getVar($1, scope);
               if (var == NULL){
                 yyerror("Undefined Variable");
                }else{
                  if (var->node.scope){
                      gen_offset(LOAD_FP, var->node.address);
                  }else{
                    gen_offset(LOAD_GP, var->node.address);
                  }
                 }
                }
| IDENT  arguments   {gen2(LOADI,0);
                      func_table *entry = getFunc($1);
                      call = &entry->node;}
     ;

/* logic */

arguments : LPAREN  args_head RBRACE {func_table *f = getFunc(call->name);
                                      if(f){
                                        if (f->node.params == $2){
                                          gen2(JSR, f->node.address);
                                          gen2(POP, f->node.params);
                                        }else{
                                          yyerror("Number of parameters given does not meet expected");
                                        }
                                    }else{
                                      yyerror("Undefined Function");
                                    }
                                    call = NULL;};

args_head : exp args_tail { $$ = $2 + 1;}
          |               { $$ = 0; }
          ;

args_tail : COMMA exp args_tail { $$ = $3 + 1;}
          |                     { $$ = 0; }
          ;


compare : exp EQ exp {gen(SUB);
                      gen(TEST);
                      gen2(POP,1);
                      gen2(JEQ, getAddress()+4);
                      $$ = gen2(JUMP,0) - 1;}

		| exp LT exp {gen(SUB);
                      gen(TEST);
                      gen2(POP,1);
                      gen2(JEQ, getAddress()+4);
                      $$ = gen2(JUMP,0) - 1;}
		;

%%
yyerror (char *s)  /* Called by yyparse on error */
{
    printf ("\terror: %s\n", s);
}
