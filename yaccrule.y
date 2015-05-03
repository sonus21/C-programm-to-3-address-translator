%{
  #include "codegen.cpp"
/**
  @file yaccrule.y
  @brief This file includes grammar rule and their semantic action(s).
  @author sonu kumar , Roll no 127159 , section : A , Course B.tech(3/4) 
  @version 1.0
*/
  #define EMPTY -1
  using namespace std;
  extern FILE* yyin;
  extern int lineno;
  extern int colum;
  extern char *stream;
  int yylex(void);
  void yyerror(const char *);
  extern int nextInstr;
  int type;
  vector<YYSTYPE::BackpatchList*> breaklist;
  vector<YYSTYPE::BackpatchList*> continuelist;
  int break_current    = -1;
  int continue_current = -1;
  extern bool assign ;
%}
%token IF
%token ELSE
%token WHILE
%token SWITCH
%token CASE DEFAULT
%token INT FLOAT BOOL UNSIGNED SIGNED
%token ASSIGN PLUSEQ MINUSEQ TIMESEQ DIVIDEQ
%token PLUS MINUS TIMES DIVIDE EXP
%token IOR IAND INOT XOR
%token OR AND NOT
%token EQ NEQ LT LEQ GT GEQ
%token LP RP
%token LB RB
%token COMMA
%token SEMICOLON COLON
%token DOUBLENUM INTNUM TRUE FALSE ID
%token PLUSPLUS
%token MINUSMINUS
%token CONTINUE BREAK

%union{
  int type;
  struct marks{
    int instr;
  }mark;
  struct BackpatchList{
    int ins;
    BackpatchList *next;
  };
  struct info{
    char *addr;
    short  type;
    BackpatchList *tlist;
    BackpatchList *flist;
  }exp;
  struct nextL{
      int instr; /**Instruction number */
      BackpatchList *nextList; /**Linked list of Backpatch*/
  }List;
  /**
    Linked list of switch instruction which have to backpatch
  */
  struct switchL{
    int instr;     /**Instruction number*/
    int lineno;    /**Line number where this list was found*/
    switchL *next; /**Next pointer of switch list*/
    bool stype;    /**default or case statement*/
    char *val;     /**Case value*/
  };
  switchL *switchList;
  char *str;
}

%type<str> RELOP
%type<type> var-type declaration init-declarator-list
%type<exp>  assignment-expression unary-expression postfix-expression primary-expression ID
logical-OR-expression logical-AND-expression inclusive-OR-expression  inclusive-AND-expression
equality-expression relational-expression Literals exponentiation-expression multiplicative-expression
additive-expression exclusive-OR-expression if_prefix

%type<mark> marker continue-marker
%type<List> statement Next selection-statement compound-statement iteration-statement jump-statement statement-list
%type<switchList> switch-statement case-list default-statement

%start Program
%%
Program:
translation-unit{}
;

translation-unit:
  external-declaration{}
  |translation-unit external-declaration{}
;

external-declaration:
  function{/**Function definition*/}
  |declaration-list{/** Global declaration*/}
  |expression-list {/*Gloabal initiliazation*/}
;

/*Function  without argument e.g. int main(){}*/
function:
  var-type ID LP  RP compound-statement{
  	  /*ResetSymbolTable();*/
	  backpatch($5.nextList,nextInstr);
	  genCode("ret",0);
  }
;

/**
    Compound statement
    e.g. { some code }
*/
compound-statement:
   LB statement-list RB{$$.nextList = $2.nextList;}
;

statement-list:
  statement-list marker statement{
    backpatch($1.nextList,$2.instr);
    $$.nextList = $3.nextList;
  }
  |statement {$$.nextList = $1.nextList;}
  |{/**Suffice for empty block statement*/
       $$.nextList = NULL;
  }
;

statement:
  expression-list{
    $$.nextList=NULL;
  }
  |declaration-list{
    $$.nextList=NULL;
  }
  |compound-statement{
    $$.nextList = $1.nextList;
  }
  |selection-statement{
    $$.nextList = $1.nextList;
  }
  |iteration-statement{
    $$.nextList = $1.nextList;
  }
  |jump-statement{
    $$.nextList = NULL;
  }
;

/**
    Expression  e.g. a=b+c; , ;
*/
expression-list:
  SEMICOLON { }
  |expression SEMICOLON{}
;

/**
    Declaration list e.g. int a,b=a+b;
*/
declaration-list:
  declaration{}
  |declaration-list declaration{}
;
declaration:
   var-type init-declarator-list SEMICOLON{}
;
var-type:
  INT {type = 1;}
  |SIGNED {type = 2;}
  |SIGNED INT {type= 3;}
  |UNSIGNED {type = 4;}
  |UNSIGNED INT { type=5;}
  |FLOAT {type=6;}
  |SIGNED FLOAT{type=7; }
  |UNSIGNED FLOAT{type=8; }
  |BOOL { type=9;}
;
init-declarator-list:
  ID {
  	InsertId($1.addr,lineno,type);
  }
  |ID ASSIGN assignment-expression {
  	InsertId($1.addr,lineno,type);
  	genCode($1.addr,$3.addr);
  }
  |init-declarator-list COMMA ID {
  	InsertId($3.addr,lineno,type);
  }
  |init-declarator-list COMMA ID ASSIGN assignment-expression {
  	InsertId($3.addr,lineno,type);
  	genCode($3.addr,$5.addr);
  }
;

/**Selection statement e.g. if (E) {} else { } , switch(E){ },if (E){} e.t.c*/
selection-statement:
	if_prefix marker statement {
	  backpatch($1.tlist,$2.instr);
	  $$.nextList = mergeList($1.flist,$3.nextList);
	}
	|if_prefix marker statement ELSE Next statement {
	    backpatch($1.tlist,$2.instr);
	    backpatch($1.flist,$5.instr);
	    YYSTYPE::BackpatchList *temp = mergeList($3.nextList,$5.nextList);
	    $$.nextList = mergeList(temp,$6.nextList);
	}
	|SWITCH LP Next assignment-expression RP LB break-marker switch-statement RB Next{
	  YYSTYPE::switchL *l=NULL;
	  YYSTYPE::switchL *ll;
	  int in=nextInstr;
	  while($8!=NULL){
	    if($8->stype == true){
	      ll = $8;
	      genCode("if",$4.addr," == ",$8->val,"goto",$8->instr);
	      delete ll;
	    }
	    else{
	       l = $8;
	    }
	    $8=$8->next;
	  }
	  if(l!=NULL){
	    genCode("goto",l->instr);
	    delete l;
	  }
	  backpatch($3.nextList,in); //Backpatch start of switch-statement
	  backpatch($10.nextList,nextInstr);//Backpatch end of switch-statement
	  backpatch(breaklist[break_current],nextInstr); //Backpatch break statement(s)
	  break_current--;
	}
;

if_prefix: IF LP assignment-expression RP {
  /**
  	Special case when expression is just ID or some arithmatic expression
  */
    if($3.flist  ==  NULL  && $3.tlist  ==  NULL ){
      $$.tlist = makeList(nextInstr);
      $$.flist = makeList(nextInstr+1);
      genCode("if",$3.addr,"!=","0","goto",EMPTY);
      genCode("goto",EMPTY);
   }
   else{
     $$.tlist = $3.tlist;
     $$.flist = $3.flist;
   }
}
;


/**Switch statement */
switch-statement:
  case-list{$$=$1;}
  |case-list default-statement {
  	$$ = mergeSwitchList($1,$2);
  }
  |default-statement case-list {
  	$$ = mergeSwitchList($1,$2);
  }
  |case-list default-statement case-list{
  	$$ = mergeSwitchList(mergeSwitchList($1,$2),$3);
  }
;
default-statement:
  DEFAULT COLON marker statement-list {
    $$=makeList($3.instr,false,NULL,EMPTY);
  }
;
case-list:
  CASE Literals COLON  marker statement-list {
    $$=makeList($4.instr,true,$2.addr,lineno);
  }
  |case-list CASE Literals COLON marker statement-list {
    $$ = makeList($5.instr,true,$3.addr,lineno);
    int line;
    if( (line=IsDuplicateCaseLabel($1,$3.addr)) != -1 ){
      AddError("duplicate case label",lineno,ERROR);
      AddError("previously used here",line,ERROR);
    }
    $$ = mergeSwitchList($1,$$);
  }
;

Next:{
  $$.nextList = makeList(nextInstr);
  genCode("goto",EMPTY);
  $$.instr = nextInstr;
}
;
/**Iteration statement*/
iteration-statement:
  WHILE continue-marker LP
  assignment-expression {
    /**
      Special case when programmar has used
      while(a)
      while(a+b)
    */
    if($4.tlist  ==  NULL  && $4.flist  ==  NULL ){
      $4.tlist = makeList(nextInstr);
      genCode("if",$4.addr,"!=","0","goto",EMPTY);
      $4.flist = makeList(nextInstr);
      genCode("goto",EMPTY);
    }
  }
  RP marker break-marker  statement{
    backpatch($9.nextList,$2.instr);
    backpatch($4.tlist,$7.instr);
    backpatch(continuelist[continue_current],$2.instr);
    $$.nextList = $4.flist;
    genCode("goto",$2.instr);
    backpatch(breaklist[break_current],nextInstr);
    break_current--;
    continue_current--;
}
;

break-marker:
{
  break_current++;
  breaklist.push_back(NULL);
}
;
continue-marker:
{
$$.instr = nextInstr;
continue_current++;
continuelist.push_back(NULL);
}
;

/**continue or break statement*/
jump-statement:
   BREAK SEMICOLON {
    if(break_current!=EMPTY){
      genCode("goto",EMPTY);
      if( (breaklist.size() == 0) || ( (signed)breaklist.size() == break_current-1) )
        breaklist.push_back(makeList(nextInstr-1));
      else
        breaklist[break_current]=mergeList(makeList(nextInstr-1),breaklist[break_current]);
    }
    else{
      AddError("break is not in loop or switch statement",lineno,ERROR);
    }
  }
  |CONTINUE SEMICOLON{
    if(continue_current!=-1){
      genCode("goto",EMPTY);
      if( (continuelist.size() == 0) || ( (signed)continuelist.size() == continue_current-1) )
        continuelist.push_back(makeList(nextInstr-1));
      else
        continuelist[continue_current]=mergeList(makeList(nextInstr-1),continuelist[continue_current]);
    }
    else{
      AddError("continue is not in loop statement",lineno,ERROR);
    }
  }
;

/*Expression list a=b,a=b+c;a+=b+=c;**/
expression:
  assignment-expression{
  }
  |expression COMMA assignment-expression{
  }
;

/**Assignment expression e.g. constants , */
assignment-expression:
  logical-OR-expression{
      $$.addr  = $1.addr;
      $$.type  = $1.type;
      $$.tlist = $1.tlist;
      $$.flist = $1.flist;
  }
  |assignment-expression ASSIGN assignment-expression {
        /**
          Check for temporary name if it's temp then raise an error
        */
        if($1.addr[0] == '_' && $1.addr[1] == '_'){
          AddError((char*)"lvalue required as left operand of assignment",lineno,ERROR);
        }
        genCode($1.addr,$3.addr);
        $$.flist = NULL;
        $$.tlist = NULL;
  }
  |assignment-expression PLUSEQ assignment-expression {
        /**
          Check for temporary name if it's temp then raise an error
        */
        if($1.addr[0] == '_' && $1.addr[1] == '_'){
          AddError((char*)"lvalue required as left operand of assignment",lineno,ERROR);
        }
        $$.flist = NULL;
        $$.tlist = NULL;
        $$.addr  = newTemp();
        genCode($$.addr  ,$1.addr,"+",$3.addr);
        genCode($1.addr,$$.addr );
        $$.addr  = $1.addr;
  }
  |assignment-expression MINUSEQ assignment-expression {
       $$.flist = NULL;
       $$.tlist = NULL;
        /**
          Check for temporary name if it's temp then raise an error
        */
        if($1.addr[0] == '_' && $1.addr[1] == '_'){
          AddError((char*)"lvalue required as left operand of assignment",lineno,ERROR);
        }
        $$.addr  = newTemp();
        genCode($$.addr  ,$1.addr,"-",$3.addr);
        genCode($1.addr,$$.addr );
        $$.addr  = $1.addr;
  }
  |assignment-expression TIMESEQ assignment-expression {
       $$.flist = NULL;
       $$.tlist = NULL;

       /**
          Check for temporary name if it's temp then raise an error
        */
        if($1.addr[0] == '_' && $1.addr[1] == '_'){
          AddError((char*)"lvalue required as left operand of assignment",lineno,ERROR);
        }
        $$.addr  = newTemp();
        genCode($$.addr  ,$1.addr,"*",$3.addr);
        genCode($1.addr,$$.addr );
        $$.addr  = $1.addr;
  }
  |assignment-expression DIVIDEQ assignment-expression {
       $$.flist = NULL;
       $$.tlist = NULL;
       /**
          Check for temporary name if it's temp then raise an error
        */
        if($1.addr[0] == '_' && $1.addr[1] == '_'){
          AddError((char*)"lvalue required as left operand of assignment",lineno,ERROR);
        }
        $$.addr  = newTemp();
        genCode($$.addr  ,$1.addr,"/",$3.addr);
        genCode($1.addr,$$.addr );
        $$.addr  = $1.addr;
  }
;

logical-OR-expression:
  logical-AND-expression{
      $$.addr  = $1.addr;
      $$.type  = $1.type;
      $$.flist = $1.flist;
      $$.tlist = $1.tlist;
  }
  |logical-OR-expression {
	    if($1.tlist  ==  NULL  && $1.flist   ==  NULL ){
	        genCode("if",$1.addr,"!=","0","goto",EMPTY);
	            genCode("goto",EMPTY);
	            $1.tlist = makeList(nextInstr-2);
	            $1.flist = makeList(nextInstr-1);
	    }
    }OR marker logical-AND-expression{
      if($5.tlist  ==  NULL  && $5.flist   ==  NULL ){
        genCode("if",$5.addr,"!=","0","goto",EMPTY);
            genCode("goto",EMPTY);
            $5.tlist = makeList(nextInstr-2);
            $5.flist = makeList(nextInstr-1);
      }
      backpatch($1.flist,$4.instr);
      $$.flist = $5.flist;
      $$.tlist = mergeList($1.tlist,$5.tlist);
  }
;

logical-AND-expression:
  inclusive-OR-expression{
      $$.addr  = $1.addr;
      $$.type  = $1.type;
      $$.flist = $1.flist;
      $$.tlist = $1.tlist;
  }
  |logical-AND-expression {
        if($1.tlist  ==  NULL  && $1.flist   ==  NULL ){
            genCode("if",$1.addr,"!=","0","goto",EMPTY);
            genCode("goto",EMPTY);
            $1.tlist = makeList(nextInstr-2);
            $1.flist = makeList(nextInstr-1);
    	}

    } AND marker inclusive-OR-expression{
      if($5.tlist  ==  NULL  && $5.flist   ==  NULL ){
            genCode("if",$5.addr,"!=","0","goto",EMPTY);
            genCode("goto",EMPTY);
            $5.tlist = makeList(nextInstr-2);
            $5.flist = makeList(nextInstr-1);
      }
      backpatch($1.tlist,$4.instr);
      $$.tlist = $5.tlist;
      $$.flist = mergeList($1.flist,$5.flist);
  }
;

inclusive-OR-expression:
  exclusive-OR-expression{
      $$.addr  = $1.addr;
      $$.type  = $1.type;
      $$.type  = $1.type;
      $$.flist = $1.flist;
      $$.tlist = $1.tlist;
  }
  |inclusive-OR-expression IOR exclusive-OR-expression{
      $$.addr  = newTemp();
      $$.type  = $1.type;
      $$.flist = NULL;
      $$.tlist = NULL;
      genCode($$.addr ,$1.addr,"|",$3.addr);
  }
;


exclusive-OR-expression:
inclusive-AND-expression{
    $$.addr  = $1.addr;
    $$.type  = $1.type;
    $$.flist = $1.flist;
    $$.tlist = $1.tlist;
}
|exclusive-OR-expression XOR inclusive-AND-expression{
    $$.addr  = newTemp();
    $$.flist = NULL;
    $$.tlist = NULL;
    genCode($$.addr ,$1.addr,"XOR",$3.addr);
}
;


inclusive-AND-expression:
  equality-expression{
    $$.addr  = $1.addr;
    $$.type  = $1.type;
    $$.flist = $1.flist;
    $$.tlist = $1.tlist;
  }
  | inclusive-AND-expression IAND equality-expression{
      $$.addr  = newTemp();
      $$.flist = NULL;
      $$.tlist = NULL;
      genCode($$.addr ,$1.addr,"&",$3.addr);
  }
;


equality-expression:
  relational-expression{
      $$.addr   = $1.addr;
      $$.type   = $1.type;
      $$.tlist  = $1.tlist;
      $$.flist  = $1.flist;
  }
  |equality-expression EQ relational-expression{
      $$.tlist = makeList(nextInstr);
      $$.flist = makeList(nextInstr+1);
      genCode("if",$1.addr," == ",$3.addr,"goto",EMPTY);
      genCode("goto",EMPTY);
  }
  |equality-expression NEQ relational-expression{
      $$.tlist = makeList(nextInstr);
      $$.flist = makeList(nextInstr+1);
      genCode("if",$1.addr,"!=",$3.addr,"goto",EMPTY);
      genCode("goto",EMPTY);
  }
;

relational-expression:
  additive-expression{
    $$.addr   = $1.addr;
    $$.type   = $1.type;
    $$.tlist  = $1.tlist;
    $$.flist  = $1.flist;
  }
  |relational-expression RELOP  additive-expression{
      $$.tlist = makeList(nextInstr);
      $$.flist = makeList(nextInstr+1);
      genCode("if",$1.addr,$2,$3.addr,"goto",EMPTY);
      genCode("goto",EMPTY);
  }
;

 /** Having same priority */
RELOP:
     GT  {$$=(char*)">";}
   | GEQ {$$ =(char*)">=";}
   | LT  {$$ =(char*)"<";}
   | LEQ {$$ =(char*)"<=";}
;

additive-expression:
  multiplicative-expression{
      $$.addr   = $1.addr;
      $$.type   = $1.type;
      $$.tlist  = $1.tlist;
      $$.flist  = $1.flist;
  }
  |additive-expression PLUS multiplicative-expression{
      $$.addr   = newTemp();
      $$.type   = $1.type;
      $$.tlist  = NULL;
      $$.flist  = NULL;
      genCode($$.addr  ,$1.addr,"+",$3.addr);
  }
  |additive-expression MINUS multiplicative-expression{
      $$.addr   = newTemp();
      $$.type   = $1.type;
      $$.tlist  = NULL;
      $$.flist  = NULL;
      genCode($$.addr  ,$1.addr,"-",$3.addr);
  }
  ;

  multiplicative-expression:
    exponentiation-expression{
      $$.addr   = $1.addr;
      $$.type   = $1.type;
      $$.tlist  = $1.tlist;
      $$.flist  = $1.flist;
  }
  | multiplicative-expression TIMES exponentiation-expression{
      $$.addr   = newTemp();
      $$.type   = $1.type;
      $$.tlist  = NULL;
      $$.flist  = NULL;
      genCode($$.addr  ,$1.addr,"*",$3.addr);
  }
  | multiplicative-expression DIVIDE exponentiation-expression{
      $$.addr   = newTemp();
      $$.type   = $1.type;
      $$.tlist  = NULL;
      $$.flist  = NULL;
      genCode($$.addr  ,$1.addr,"/",$3.addr);
  }
;

exponentiation-expression :
  unary-expression {
    $$.addr   = $1.addr;
    $$.type   = $1.type;
    $$.flist  = $1.flist;
    $$.tlist  = $1.tlist;
  }
  | unary-expression EXP exponentiation-expression{
    $$.addr   = newTemp();
    $$.type   = $1.type;
    $$.tlist  = NULL;
    $$.flist  = NULL;
    genCode($$.addr  ,$1.addr,"@",$3.addr);
  }

;

unary-expression:
  postfix-expression{
    $$.addr   = $1.addr;
    $$.tlist  = $1.tlist;
    $$.flist  = $1.flist;
  }
  |PLUSPLUS unary-expression{
     $$.addr   = newTemp();
     $$.tlist  = $2.tlist;
     $$.flist  = $2.flist;
     genCode($$.addr ,$2.addr,"+","1");
     genCode($2.addr,$$.addr );
  }
  |MINUSMINUS unary-expression{
     $$.addr   = newTemp();
     $$.tlist  = $2.tlist;
     $$.flist  = $2.flist;
     genCode($$.addr ,$2.addr,"-","1");
     genCode($2.addr,$$.addr );
  }
  |PLUS unary-expression{
      $$.addr   = $2.addr;
      $$.tlist  = $2.tlist;
      $$.flist  = $2.flist;
    }
  |MINUS unary-expression{
      $$.addr   = newTemp();
      $$.tlist  = $2.tlist;
      $$.flist  = $2.flist;
      genCode($$.addr ,"-1","*",$2.addr);
  }
  |INOT  unary-expression{
      $$.addr   = newTemp();
      $$.tlist  = $2.tlist;
      $$.flist  = $2.flist;
      genCode($$.addr ,"~",$2.addr);
  }
  |NOT unary-expression{
      if($2.tlist  ==  NULL  && $2.flist   ==  NULL ){
        genCode("if",$2.addr,"!=","0","goto",EMPTY);
            genCode("goto",EMPTY);
            $2.tlist = makeList(nextInstr-2);
            $2.flist = makeList(nextInstr-1);
    }
      $$.addr   = newTemp();
      $$.tlist  = $2.flist;
      $$.flist  = $2.tlist;
  }
;

postfix-expression:
  primary-expression{
    $$.addr   = $1.addr;
    $$.tlist  = $1.tlist;
    $$.flist  = $1.flist;
  }
  |postfix-expression PLUSPLUS{
    $$.addr   = newTemp();
    $$.tlist  = $1.tlist;
    $$.flist  = $1.flist;
    genCode($$.addr ,$1.addr);
    genCode($1.addr,$$.addr ,"+","1");
  }
  |postfix-expression MINUSMINUS{
    $$.addr   = newTemp();
    $$.tlist  = $1.tlist;
    $$.flist  = $1.flist;
    genCode($$.addr ,$1.addr);
    genCode($1.addr,$$.addr ,"-","1");
  }
;

primary-expression:
 ID{
  $$.addr   = $1.addr;
  $$.tlist  = NULL;
  $$.flist  = NULL;
  if(!IsPresent($1.addr)){
    char *errmsg =  new char[256];
    strcpy(errmsg,"'");
    strcat(errmsg,$$.addr);
    strcat(errmsg,"' was not declared");
    AddError(errmsg,lineno,ERROR);
    delete errmsg;
  }

 }
  |Literals{
    $$.addr   = $1.addr;
    $$.tlist  = $1.tlist;
    $$.flist  = $1.flist;
  }
  |LP assignment-expression RP{
    $$.addr  = $2.addr;
    $$.flist  = $2.flist;
    $$.tlist  = $2.tlist;
  }
;

/*********************************************************************************************
  Literals / constants
***********************************************************************************************/
Literals:
  INTNUM {
    /**
      This temp contains value of the const
      e.g. 5
      temp->5
    */
    $$.type  = INTNUM;
    $$.flist = NULL;
    $$.tlist = NULL;
  }
  | DOUBLENUM {
    $$.type  = DOUBLENUM;
    $$.flist = NULL;
    $$.tlist = NULL;
  }
  | TRUE {
    $$.addr = new char[2];
    $$.addr = (char*)"1";
    $$.type = BOOL;
    if(!assign){
    	 $$.tlist = makeList(nextInstr);
	     $$.flist = NULL;
	     genCode("goto",EMPTY);
    }
    else{
		assign = false;
	}
  }
  | FALSE {
    $$.addr = new char[2];
    $$.addr = (char*)"0";
    $$.type   = BOOL;
    if(!assign){
	    $$.flist = makeList(nextInstr);
	    $$.tlist = NULL;
	    genCode("goto",EMPTY);
	}
	else{
		assign = false;
	}
  }
;

marker:
{$$.instr = nextInstr;}
;
%%

void yyerror(const char *s){
  AddError((char*)" ... is missing",lineno,ERROR);
}

int main(int argc,char *argv[ ]){

  FILE* fp=NULL;
  if(argc<2){
    fprintf(stderr,"No input file\n");
    return 0;
  }
  if(argc == 2){
    fp=fopen(argv[1],"r");
  }
  if(fp==NULL){
        fprintf(stderr, "Error opening file: %s\n", strerror(errno));
        return 0;
  }
  yyin=fp;
  InitializeSymbolTable();
  Error = NULL;

  while(!feof(yyin)){
    yyparse();
  }
  fclose(fp);

  DeleteSymbolTable();

  if(Error  ==  NULL ) printCode();
  else{
    printError();
  }
  return 0;
}
