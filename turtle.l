/* Turtle Compiler */
/* turtle.l */
/* Hao Zhang */
/* Isobel Stobo */

%{
	#include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
	
	#include "codegen.h"
	#include "symbol_table.h"
    #include "turtle.tab.h"
%}

DIGIT [0-9]
LETTER [A-Za-z]
LETTERNUM [A-Za-z0-9_]


%%

\/\/.*\n 


turtle  return TURTLE;
up      return UP;
down    return DOWN;
moveto  return MOVETO;
var     return VAR;
fun     return FUN;
read    return READ;
if      return IF;
else    return ELSE;
while   return WHILE;
return  return RETURN;


\+      return PLUS;
\-      return MINUS;
\*      return MULT;
\(      return LPAREN;
\)      return RPAREN;
\{      return LBRACE;
\}      return RBRACE;
\,      return COMMA;
\<       return LT;
=       return ASSN;
==      return EQ;

{DIGIT}+ {
            yylval.val = atoi(yytext);  
            return NUM;
         }

{LETTER}{LETTERNUM}* {
                        yylval.var = strdup(yytext);
                        return IDENT;
                     }

[ \n\t\r]+  /*skip white-space*/

<<eof>>     { yyterminate(); }
