/*
 * Turtle Compiler
 * codegen.c
 * Hao Zhang
 * Isobel Stobo
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "codegen.h"

unsigned short genBuffer[65536];
addr currentAddress = 0;


addr gen(unsigned short instruction)
{
    genBuffer[currentAddress] = instruction;
    return currentAddress++;
}

addr gen2(unsigned short instruction_1, unsigned short instruction_2)
{
    gen(instruction_1);
    return gen(instruction_2);
}

addr gen_offset(unsigned short instruction, unsigned short offset)
{
    return gen(instruction+offset);
}

addr getAddress()
{
    return currentAddress;
}
void backpatch(addr location, addr jump_target)
{
    genBuffer[location] = jump_target;
}

void write_code(char *file)
{
    FILE *code_file = fopen(file, "w");
    int i = 0;
    for (i = 0; i < currentAddress; i++)
    {
        fprintf(code_file, "%d\n",genBuffer[i]);
    }
    fclose(code_file);
    
}