/**
  @file codegen.cpp
  @brief This file includes functions which generates 3 address code and temporary variable name and store in
   Quadruple .
  @author sonu kumar
  @version 1.0
 */

#include "codegen.h"
#include "backpatch.cpp"
#include "stable.cpp"
extern Quadruple tuple[5000];
/**
    generate new temporary variable name
    @param void None
    @return newtemp char*
*/
char* newTemp(){
	char *temp= new char[10];
	snprintf(temp,10,"__t%d__",tempGenerated);
	tempGenerated++;
	return temp;
}
/**
    print code to the console after completion of parsing
    and store in  file name 'output.txt' for future use
    @param void None
    @return void None
*/
void printCode(){
    FILE * file = fopen("output.txt","w");
	for(int i=0;i<nextInstr-1;i++){
	     printf("\n");
	     fprintf(file,"\n");
        if(!strcmp(tuple[i].result,"if")){
            printf("%.4d : %s\t%s\t%s\t%s\t%s\t%.4d",i,tuple[i].result,tuple[i].addr1,tuple[i].op,tuple[i].addr2,tuple[i].addr3,tuple[i].label);
            fprintf(file,"%.4d : %s\t%s\t%s\t%s\t%s\t%.4d",i,tuple[i].result,tuple[i].addr1,tuple[i].op,tuple[i].addr2,tuple[i].addr3,tuple[i].label);
            continue;
        }
        if(!strcmp("goto",tuple[i].result)){
             printf("%.4d : %s\t%.4d",i,tuple[i].result,tuple[i].label);
             fprintf(file,"%.4d : %s\t%.4d",i,tuple[i].result,tuple[i].label);
        }
	    else{
            printf("%.4d : %s\t=\t%s",i,tuple[i].result,tuple[i].addr1);
            fprintf(file,"%.4d : %s\t=\t%s",i,tuple[i].result,tuple[i].addr1);
            if(tuple[i].op!=NULL){
                printf("\t%s",tuple[i].op);
                fprintf(file,"\t%s",tuple[i].op);
            }
            else continue;
            if(tuple[i].addr2!=NULL){
                printf("\t%s",tuple[i].addr2);
                fprintf(file,"\t%s",tuple[i].addr2);
            }
            else continue;
            if(tuple[i].addr3!=NULL){
                printf("\t%s",tuple[i].addr3);
                fprintf(file,"\t%s",tuple[i].addr3);
            }
            else continue;
            if(tuple[i].label!=0){
                printf("\t%d",tuple[i].label);
                fprintf(file,"\t%d",tuple[i].label);
            }
	    }
	}
	 printf("\n%.4d : %s\n",nextInstr-1,tuple[nextInstr-1].result);
	 fprintf(file,"\n%.4d : %s\n",nextInstr-1,tuple[nextInstr-1].result);
	 fclose(file);
	 printf("\nNote: Output is also available in file with name 'output.txt'\n\n");
}
/**
    Generate 3 address code and store in Quadrule table for binary expression
    e.g. a=t0+b;
    @param result char*
    @param address1 char*
    @param binary_operator char*
    @param address2 char*
    @return void None
*/
void genCode(const char *result,const char*addr1,const char *op,const char *addr2){
        tuple[nextInstr].result=(char*)result;
		tuple[nextInstr].addr1=(char*)addr1;
        tuple[nextInstr].op=(char*)op;
		tuple[nextInstr].addr2=(char*)addr2;
		tuple[nextInstr].addr3=NULL;
		tuple[nextInstr].label=0;
		nextInstr++;
}
/**
    Generate 3 address code and store in Quadrule table for unary expression
    e.g. a = -b;
    @param result    char*
    @param address1 char*
    @param unary_operator char*
    @return void None
*/
void genCode(const char *result,const char *unop,const char*addr1){
        tuple[nextInstr].result=(char*)result;
		tuple[nextInstr].addr1=NULL;
        tuple[nextInstr].op=(char*)unop;
		tuple[nextInstr].addr2=(char*)addr1;
		tuple[nextInstr].addr3=NULL;
		tuple[nextInstr].label=0;
		nextInstr++;
}
/**
    Generate 3 address code and store in Quadrule table for conditional jump
    @param "if" char*
    @param address1 char*
    @param relational_operator char*
    @param address2 char*
    @param "goto" char*
    @param jump_instruction_number int
    @return void None
*/
void genCode(const char*result,const char *addr1,const char *op,const char *addr2,const char *addr3,int label){

		tuple[nextInstr].result=(char*)result;
		tuple[nextInstr].addr1=(char*)addr1;
		tuple[nextInstr].op=(char*)op;
		tuple[nextInstr].addr2=(char*)addr2;
		tuple[nextInstr].addr3=(char*)addr3;
		tuple[nextInstr].label=label;
		nextInstr++;
}
/**
    Generate 3 address code and store in Quadrule table for assignement
    e.g. a = t0;
    @param result char*
    @param address2 char*
    @return void None
*/
void genCode(const char *result,const char *addr1){
		tuple[nextInstr].result = (char*)result;
		tuple[nextInstr].addr1 = (char*)addr1;
		tuple[nextInstr].addr2 = NULL;
		tuple[nextInstr].addr3 = NULL;
		tuple[nextInstr].label =0;
		nextInstr++;
}
/**
    Generate 3 address code and store in Quadrule table for goto target
    e.g. 'goto' -1
    @param "goto" char*
    @param jump_instruction_number int
    @return void None
*/
void genCode(const char *result,int label){
		tuple[nextInstr].result = (char*)result;
		tuple[nextInstr].addr1 = NULL;
		tuple[nextInstr].addr2 = NULL;
		tuple[nextInstr].addr3 = NULL;
		tuple[nextInstr].label = label;
		nextInstr++;
}
