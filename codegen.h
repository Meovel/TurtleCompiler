#ifndef CODEGEN_H
#define CODEGEN_H

#define LOAD_GP  0x0600
#define LOAD_FP  0x0700
#define STORE_GP 0x0400
#define STORE_FP 0x0500
#define READ_FP  0x0200
#define READ_GP  0x0300

#define HALT	 0x0000
#define UP  	 0x0A00
#define DOWN	 0x0C00
#define MOVE     0x0E00
#define ADD      0x1000
#define SUB      0x1200
#define NEG      0x2200
#define MUL      0x1400
#define TEST     0x1600
#define RTS      0x2800

#define JSR      0x6800
#define JUMP     0x7000
#define JEQ      0x7200
#define JLT      0x7400
#define LOADI    0x5600
#define POP      0x5E00

typedef unsigned short addr;

addr gen(unsigned short instruction);

addr gen2(unsigned short instruction_1, unsigned short instruction_2);

addr gen_offset(unsigned short instruction, unsigned short offset);

addr getAddress();

void backpatch(addr location, addr jump_target);

void write_code(char *file);

#endif