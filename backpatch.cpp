#include "rule.h"
/**
  @file  backpatch.cpp
  @brief This file includes functions which manages Backpatching of goto instruction .
  @author sonu kumar 
  @version 1.0
*/
typedef YYSTYPE::BackpatchList patchList;
typedef YYSTYPE::switchL switchLR;
/**
    Create a new backpatchList
    @param jump_instruction_number int
    @return backpatchList patchList*
*/
patchList *makeList(int i){
 patchList *temp =  new patchList();
 temp->ins  = i;
 temp->next = NULL;
 return temp;
}
/**
    Merge two backpatchList
    @param backpatchList_1 patchList*
    @param backpatchList_2 patchList*
    @return backpatchList_3 patchList*
*/
patchList *mergeList(patchList *l1,patchList *l2){
    if(l1==NULL)return l2;
    if(l2==NULL)return l1;
    patchList *t = l1;
    while(t->next!=NULL)t=t->next;
    t->next=l2;
    return l1;
}
/**
    Backpatch  goto instruction
    @param backpatchList patchList*
    @param target_instruction_number int
    @return void None
*/
void backpatch(patchList *p,int i){
    patchList *t = p;
    patchList *t2;
    while(t!=NULL){
        quadruple[t->ins].label = i;
        t2=t;
        t=t->next;
        delete t2;
    }
}
/**
    Create backpatchList of switch statement
    @param instruction_number int
    @param switch_statement_type  bool
    @param case_value(default:NULL) char*
    @param line_number int
    @return new_switch_list switchL*
*/
switchLR*  makeList(int label,bool type,char* val,int lineno){
    switchLR *temp = new switchLR;
    temp->instr  = label;
    temp->stype   = type;
    temp->val    = val;
    temp->lineno = lineno;
    temp->next   = NULL;
    return temp;
}
/**
    Merge two switchList
    @param SwitchList_1 switchL*
    @param SwitchList_2 switchL*
    @return SwitchList_3 switchL*
*/
switchLR* mergeSwitchList(switchLR *l1,switchLR *l2){
    if(l1==NULL)return l2;
    if(l2==NULL)return l1;
    switchLR *t = l1;
    while(t->next!=NULL)t = t->next;
    t->next = l2;
    return l1;
}
