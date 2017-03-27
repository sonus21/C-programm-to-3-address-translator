#ifndef CODEGEN_H
#define CODEGEN_H
#include <bits/stdc++.h>
int nextInstr=0;
int tempGenerated=0;
/**
    Structure which hold generated  code
*/
struct Quadruple{
	char *result; //result
	char *addr1;  //address 1
	char *op;     //operator
	char *addr2;  //address 2
	char *addr3;  // address 3
	int  label;   //jump instuction number
};
Quadruple quadruple[5000];
char* newTemp();
void printCode();
void genCode(const char*result,const char *addr1,const char *op,const char *addr2,const char *addr3,int label);
void genCode(const char *result,const char*addr1,const char *op,const char *addr2);
void genCode(const char *result,const char *unop,const char*addr1);
void genCode(const char *result,const char *addr1);
void genCode(const char *result,int label);

#endif
