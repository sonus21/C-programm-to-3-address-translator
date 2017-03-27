# C-programm-to-3-address-translator
  <h3><b>It takes a subset of C programming language and generates intermediate (3 address)  code .</b></h3>

### Subset of C programming language is defined as below
		 Binary Operators: + , - , * , / ,exponentiation operator (denote it as @) 
		 Data types:  int , unsigned , signed , bool , float 
		 Bitwise operators : | , & , ~ , ^(XOR) 
		 Logical Operators : || , && , ! 
		 Relational Operators : ==, !=, <, <=, >, >= 
		 Assignment Operators : = , += , -= , *= , /= 
		 Unary opeartors : + , - 
		 Postfix / Prefix Operators : ++ , -- 
		 Identifiers:Simple identifiers without special characters (starts with alphabet)
		 
##### Control Structures:
		 Assignment Statement 
	 	 Expressions: 
	 	 	  infix expressions 
		 Iterative  
		 Conditional: 
			  if-else
			  else-if
			  switch 
		 Repetitive: 
			  while
		 Jump :
	  		  continue
	  		  break

###### Note:
          It follows C operators precedence , syntax rule.
          There is no scope rule  for identifiers .
          There is no function call.
          Functions shouldn't have argument(s).
          It reports following error messages
			lval requirement
			case  label duplication
			Variable is not defined  
			Redeclaration of variable
# I/O
         Input  
   			 -  C program which follows synatx rule as described above
         Output
   			 -  3 address code , Output will be displayed on  terminal/cmd and it's also available in file output.txt
	   		 
# Download
	$ git clone https://github.com/sonus21/C-programm-to-3-address-translator.git 
or 	 	
        [trans](https://codeload.github.com/sonus21/C-programm-to-3-address-translator/zip/master)<br/>
        $ unzip C-programm-to-3-address-translator-master.zip<br/>
$ cd C-programm-to-3-address-translator<br/>

# Installation 
   [1] If you are having binary file name <b>trans</b> 
  
	$ ./trans filename
	e.g. $ ./trans test.c
	    	   
   [2] If you are having source code of the program . 
	
	Requirements
		[1]  GNU make utilities
		[2]  GNU flex/LEX
		[3]  GNU YACC/Bison
		[4]  g++ >=4.8 
	$ cd C-programm-to-3-address-translator
	$ make 
# Support
Please report problems and bugs to  [trans](https://github.com/sonus21/C-programm-to-3-address-translator/issues) issue tracker.

# License
The content of this project  is licensed under the
[Creative Commons Attribution 3.0 license](http://creativecommons.org/licenses/by/3.0/us/deed.en_US)

	        
