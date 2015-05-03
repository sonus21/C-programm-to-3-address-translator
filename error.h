#ifndef  ERROR_H
#define  ERROR_H
/**
    Predefined constants for error message
*/
#define ERROR 1
#define NOTE 2
#define WARNING 3
/**
    This records error message(s)
*/
struct er{
    int8_t ertype;
    int lineno;
    char *errmsg;
    er *next;
};
er *Error;
er *newerNode(const char *errmsg,int lineno);
void AddError(const char *errmsg,int lineno,int8_t ertype);
void printError();
#endif
