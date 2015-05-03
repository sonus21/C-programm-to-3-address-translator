#include<bits/stdc++.h>
#include "stable.h"
using namespace std;
/**
  @file stable.cpp
  @brief This file includes functions which manages symbol tables .
  @author sonu kumar 
  @version 1.0
*/

/**
    Generate Hashcode for a given string
    @param  string char*
    @return hashcode short
*/
short hashCode(char *str){
    short h = 0;
    for(u_int8_t i = 0 ; str[i]!='\0' ; i++){
        h = ((h<<5) + short(str[i]))%MOD;
    }
    return h;
}

/**
    This function create a new node for symbol table entry
    @param identifier_name char*
    @param line_number int
    @param type int
    @return SymbolTable_node SymbolTable*
*/
SymbolTable *newTable(char *id ,int lineno,int type ){
    SymbolTable * temp = new SymbolTable;
    temp->Identifier = new char[strlen(id)];
    temp->attr = new Attributes;
    temp->attr->lineno = lineno;
    temp->attr->type = type;
    strcpy(temp->Identifier,id);
    temp->next = NULL;
    return temp;
}
/**
    Insert New identifier in Symbol table
    @param identifier_name char*
    @param line_number int
    @param type int
    @return void None
*/
void InsertId(char *id,int lineno,int type){
    short k;
    char *temp;
    if( IsPresent(id) ){
        k = getType(id);
        temp = new char[256];
        if(k==type){

            strcpy(temp,"redeclaration of '");
            getType(temp,type);
            strcat(temp,id);
            strcat(temp,"' ");
            AddError(temp,lineno,ERROR);

            temp[0]='\'';
            temp[1]='\0';
            getType(temp,type);
            strcat(temp,id);
            strcat(temp,"' previously declared here");
        }
        else{
            strcpy(temp,"Conflicting declaration  '");
            getType(temp,type);
            strcat(temp,id);
            strcat(temp,"' ");
            AddError(temp,lineno,ERROR);

            strcpy(temp,"previously declaration as '");
            getType(temp,getType(id));
            strcat(temp,id);
            strcat(temp,"' ");
        }
        AddError(temp,getLine(id),NOTE);
        delete temp;
        return;
    }

    k = hashCode(id);
    /**
        Check whether Symbol table Entry is empty or not ?
        1. If it's empty then insert id
        2. else follow next pointer
    */
    if(Table[k].Identifier==NULL){
        Table[k].Identifier = new char[strlen(id)];
        Table[k].attr = new Attributes;

        Table[k].attr->lineno = lineno;
        Table[k].attr->type = type;
        strcpy(Table[k].Identifier,id);
    }
    else{
        /**
            Check whether next pointer is NULL or not ?
            1. If it's NULL then insert create a new Symbol table and insert id
            2. else follow next pointer of next
        */
        if(Table[k].next==NULL){
            Table[k].next = newTable(id,lineno,type);
        }
        SymbolTable *temp = Table[k].next;
        while(temp->next!=NULL)temp = temp->next;
        temp->next = newTable(id,lineno,type);
    }
}

/**
    Initialize Symbol table for future use
    @param void None
    @return void None
*/
void InitializeSymbolTable(){
    for(size_t i=0;i<MOD;i++){
       Table[i].Identifier =NULL;
       Table[i].attr=NULL;
       Table[i].next=NULL;
    }
}
/**
    Delete symbol table
    @param void None
    @return void None
*/
void DeleteSymbolTable(){
    SymbolTable *temp;
    SymbolTable *temp2;
    for(size_t i=0;i<MOD;i++){
       if(Table[i].Identifier!=NULL){
            delete Table[i].Identifier;
            delete Table[i].attr;
            temp = Table[i].next;
            while(temp!=NULL){
               temp2=temp;
               temp=temp->next;
               delete temp2->attr;
               delete temp2;
            }
        }
    }
}

/**
    Check whether an identifier is present in Symbol table or not
    @param identifier char*
    @return true/false bool
*/
bool IsPresent(char *id){
    short k = hashCode(id);
    /**
        1 . If symbol table is empty then return not found
        2 . Check symbol table if necessary then follow next pointer
    */
    if(Table[k].Identifier==NULL){
        return false;
    }
    else{
        if(!strcmp(id,Table[k].Identifier))return true;
        SymbolTable *temp = Table[k].next;
        while(temp!=NULL){
            if(!strcmp(id,temp->Identifier))return true;
            temp = temp->next;
        }
        return false;
    }
}

/**
    Get line no where given identifier was found .
    @param identifier char*
    @return line_number int
*/

int getLine(char *id){
    short k = hashCode(id);
    if(!strcmp(id,Table[k].Identifier))return Table[k].attr->lineno;
    SymbolTable *temp = Table[k].next;
    while(temp!=NULL){
        if(!strcmp(id,temp->Identifier))return temp->attr->lineno;
        temp = temp->next;
    }
    return -1;
}

/**
    Get variable type of a given identifier
    @param identifier char*
    @return variable_type int
*/
short getType(char *id){
    short k = hashCode(id);
    if(!strcmp(id,Table[k].Identifier))return Table[k].attr->type;
    SymbolTable *temp = Table[k].next;
    while(temp!=NULL){
        if(!strcmp(id,temp->Identifier))return temp->attr->type;
        temp = temp->next;
    }
    return -1;
}
/**
    Generate variable type of a given identifier in string format
    @param errmsg char*
    @param type int
    @return void None
*/
void getType(char *errmsg,int type){
    switch(type){
        case 1:
            strcat(errmsg,"int ");
            break;
        case 2:
            strcat(errmsg,"signed");
            break;
        case 3:
            strcat(errmsg,"signed int");
            break;
        case 4:
              strcat(errmsg,"unsigned");
              break;
        case 5:
           strcat(errmsg,"unsigned int ");
            break;
        case 6:
             strcat(errmsg,"float");
             break;
        case 7:
            strcat(errmsg,"signed float");
            break;
        case 8:
            strcat(errmsg,"unsigned float");
            break;
        case 9:
            strcat(errmsg,"bool");
            break;
    }
}

