#ifndef  STABLE_H
#define  STABLE_H

#include "error.cpp"
/**
    Maximum symboltable size
*/
#define MOD 997

/**
    Symbol table attributes
*/

struct Attributes{
   /**
        Variable type
    */
    int type;
   /**
        Where this identifier was found?
   */
    int lineno;
};
/**
    Symbol table node structure
*/
struct SymbolTable{
/**
    Identifier name
*/
 char *Identifier;

 /**
    Next pointer to symbol table
    If collision occurs then identfier will be added here
 */
 SymbolTable *next;

/**
    Symbol table attributes
*/
 Attributes  *attr;
};

SymbolTable Table[MOD];

short hashCode(char *s);
SymbolTable *newTable(char *,int);
void InsertId(char *,int,int);
void InitializeSymbolTable();
void DeleteSymbolTable();
bool IsPresent(char *);
int getLine(char *);
short getType(char *);
void getType(char *errmsg,int type);
#endif
