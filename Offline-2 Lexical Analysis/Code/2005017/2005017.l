%option noyywrap

%x Single_Comment_state
%x Multiline_comment_state
%x String_state
%x Character_state
%x Ignore_newlines


%{
#include"SymbolTable.h"
#include"helper.h"
#include<stdio.h>
#include<stdlib.h>
#include<fstream>
#include<cmath>


int line_count=1;

// FILE *logFileOutput;
// FILE *tokelFileOutput;

ofstream logFileOutput;
ofstream tokelFileOutput;


int bucket_size=10;
SymbolTable* symbolTable=new SymbolTable(bucket_size);


int expected_tab=0;
int error_count=0;
int warning_count=0;
int newlines_count=0;

int tab_count=0;
int v_count=0;
int f_count=0;
int r_count=0;
int space_count=0;



string comment_content;

string char_const;
string char_const_printable;

bool unrec_slash;

string str_const;
string str_const_printable;

void resetWhitespaceCounts(){
	tab_count=0;
	v_count=0;
	f_count=0;
	r_count=0;
	space_count=0;
}

void updateWhiteSpaceCounts(){

	for (int i = 0; yytext[i] != '\0'; i++) {
		//cout<<"yytexti="<<yytext[i]<<endl;
		if(yytext[i]=='\n'){
			resetWhitespaceCounts();
			line_count++;

		}
        if (yytext[i] ==' ') {
            space_count++;
        } else if (yytext[i] == '\t') {
            tab_count++;
        }
		// else if (yytext[i] == '\v') {
        //     v_count++;
        // }
		// else if (yytext[i] == '\r') {
        //     r_count++;
        // }
		// else if (yytext[i] == '\f') {
        //     f_count++;
        // }
		
    }
}

void showIndentationWarning(){
	//logFileOutput<<"LINE# "<<line_count<<"tabs,spaces= "<<tab_count<<' '<<space_count<<endl;
	if(tab_count!=expected_tab && space_count==0) {
		warning_count++;
		logFileOutput<<"Line# "<<line_count<<": warning, "<<expected_tab<<" of tabs needed but got "<<tab_count<<" tabs."<<endl;

	}
	else if(space_count>0){
		warning_count++;
		logFileOutput<<"Line# "<<line_count<<": Warning, tab requrired but got space.\n";
	}


}

%}


WHITESPACE [ \t\f\r\v]+
LETTER [a-zA-Z]
DIGIT [0-9]
NOT_DIGIT [^0-9\n]
NEWLINE [\r]?\n
Id_first [a-zA-Z_]
Id_content [a-zA-Z_0-9]
AlphaNumeric [a-zA-Z0-9]





KEYWORDS 	if|else|for|while|do|break|int|char|float|double|void|return|switch|case|default|continue
IDENTIFIER {Id_first}{Id_content}*
INTEGER [+-]?{DIGIT}+
NUMBER ([+-]?{DIGIT}+((\.{DIGIT}+)?([Ee][+-]?{DIGIT}+)?)?)|([+-]?((\.{DIGIT}+)([Ee][+-]?{DIGIT}+)?))
ILLFORMED_NUMBER ([+-]?{DIGIT}*((\.{DIGIT}+)([Ee][+-]?{DIGIT}+(\.{DIGIT}*))))|([+-]?{DIGIT}+((\.{DIGIT}+)?([Ee][+-]?{DIGIT}+(\.{DIGIT}*))))
ILLFORMED_NUMBER2 ([+-]?{DIGIT}*((\.{DIGIT}+)([Ee][+-]?{DIGIT}*(\.{DIGIT}*))))|([+-]?{DIGIT}+((\.{DIGIT}+)?([Ee][+-]?{DIGIT}*(\.{DIGIT}*))))
TOO_MANY_DECIMAL_POINTS ([+-]?{DIGIT}*(\.{DIGIT}*)(\.{DIGIT}*)+(([Ee][+-]?{DIGIT}+))?)
TOO_MANY_DECIMAL_POINTS_TRIAL ([+-]?{DIGIT}*(\.{DIGIT}*)(\.{DIGIT}*)+(([Ee][+-]?{DIGIT}+)*)?)
INVALID_ID_SUFFIX_NUM_PREFIX ((([+-]?{DIGIT}*(\.{DIGIT}+([Ee][+-]?{DIGIT}+)?))|([+-]?{DIGIT}+(\.{DIGIT}+([Ee][+-]?{DIGIT}+)?)?)|[+-]?\.{DIGIT}+([Ee][+-]?{DIGIT}+)?){LETTER}{Id_content}*)
INVALID_ID_SUFFIX_NUM_PREFIX_test ({Id_first}+(({DIGIT}*(\.{DIGIT}+([Ee][+-]?{DIGIT}+)?)?)| (\.{DIGIT}+([Ee][+-]?{DIGIT}+)?)))

ADDOP "+"|"-"
MULOP "*"|"/"|"%"
INCOP "++"|"--"
RELOP "<"|"<="|">"|">="|"=="|"!="
LOGICOP "&&"|"||"
BITOP "&"|"|"|"^"|"<<"|">>"
NEXTLINE {NEWLINE}{WHITESPACE}*

%%
^{WHITESPACE}* {
	resetWhitespaceCounts();
	updateWhiteSpaceCounts();
	showIndentationWarning();
	//cout<<"called at line "<<line_count<<endl;
}



{WHITESPACE} {

}



{NEXTLINE}* {
	//line_count++;
	resetWhitespaceCounts();
	updateWhiteSpaceCounts();
	showIndentationWarning();
}



{NEXTLINE}+"}" {
	//line_count++;
	expected_tab--;
	resetWhitespaceCounts();
	updateWhiteSpaceCounts();
	showIndentationWarning();

	tokelFileOutput << "<RCURL, }>\n";
    logFileOutput << "Line# " << line_count << ": Token <RCURL> Lexeme } found\n";
	symbolTable->exitScope();
	

}





{KEYWORDS}	{
				tokelFileOutput<<"<"<<toUppercase(yytext)<<", "<<yytext<<">\n";
				logFileOutput<<"Line# "<< line_count <<": Token " <<"<"<<toUppercase(yytext)<< ">"<<" Lexeme "<<yytext<<" found\n";
	 		}

{INTEGER} {
	int value = atoi(yytext);
    int absoluteValue = abs(value);

    tokelFileOutput<<"<CONST_INT, "<<absoluteValue<<">\n";
	logFileOutput<<"Line# "<< line_count <<": Token " <<"<CONST_INT>"<<" Lexeme "<<absoluteValue<<" found\n";
    
}



{NUMBER} {
	  float value = atof(yytext); 
      float absoluteValue = fabs(value);
	  if(yytext[0]=='+' || yytext[0]=='-'){
		yytext++;
	  }
	  tokelFileOutput<<"<CONST_FLOAT, "<<yytext<<">\n";
	  //string present="";
	  
	  logFileOutput<<"Line# "<< line_count <<": Token " <<"<CONST_FLOAT>"<<" Lexeme "<<yytext<<" found\n";

}

{ILLFORMED_NUMBER}|{ILLFORMED_NUMBER2} {
	error_count++;
	logFileOutput<<"Error at line# "<<line_count<<": ILLFORMED_NUMBER "<<yytext<<endl;
}


 
{TOO_MANY_DECIMAL_POINTS} {
	error_count++;
	logFileOutput<<"Error at line# "<<line_count<<": TOO_MANY_DECIMAL_POINTS "<<yytext<<endl;

}







\'\'(\')+ {
	logFileOutput<<"Error at line# "<<line_count<<": UNRECOGNIZED_CHAR "<<yytext<<endl;
	error_count++;

}
\"\"(\")+ {
	logFileOutput<<"Error at line# "<<line_count<<": UNRECOGNIZED_CHAR "<<yytext<<endl;
	error_count++;

}








\' {
	char_const.clear();
	char_const_printable.clear();
	unrec_slash=false;
	
	BEGIN Character_state;
	

}
<Character_state>\\\' {
	char_const+="\'";
	char_const_printable+="\\\'";
}
<Character_state>\\\" {
	char_const+="\"";
	char_const_printable+="\\\"";
	
}
<Character_state>{NEXTLINE}* {
	error_count++;
	
	string error_msg="'";
	error_msg+=char_const_printable;

	logFileOutput<<"Error at line# "<<line_count<<": UNFINISHED_CONST_CHAR "<<error_msg<<endl;
	
	
	//line_count++;
	resetWhitespaceCounts();
	updateWhiteSpaceCounts();
	showIndentationWarning();


	BEGIN INITIAL;
}

<Character_state>\\t {
	char_const+="\t";
	char_const_printable+="\\t";
	
}

<Character_state>\\\\ {
	char_const+="\\";
	char_const_printable+="\\\\";
	
}

<Character_state>\\a {
	char_const+="\a";
	char_const_printable+="\\a";
	
}
<Character_state>\\f {
	char_const+="\f";
	char_const_printable+="\\f";
	
}
<Character_state>\\r {
	char_const+="\r";
	char_const_printable+="\\r";
	
}

<Character_state>\\b {
	char_const+="\b";
	char_const_printable+="\\b";
	
}

<Character_state>\\v {
	char_const+="\v";
	char_const_printable+="\\v";
	
}

<Character_state>\\0 {
	char_const+="\0";
	char_const_printable+="\\0";
	
}

<Character_state>\\n {
	char_const+="\n";
	char_const_printable+="\\n";
	
}
<Character_state>\\. {
	char_const+="\?";
	char_const_printable+=yytext;
	unrec_slash=true;
}





<Character_state>\' {
	if(char_const.length()>1){
		error_count++;
		string error_msg="\'";
		error_msg+=char_const_printable;
		error_msg+="\'";
		logFileOutput<<"Error at line# "<<line_count<<": MULTICHAR_CONST_CHAR "<<error_msg<<endl;
	}
	else if(char_const.length()==1 && unrec_slash){
		error_count++;
		string error_msg="\'";
		error_msg+=char_const_printable;
		error_msg+="\'";
		logFileOutput<<"Error at line# "<<line_count<<": UNRECOGNIZED_CHAR "<<error_msg<<endl;
	}
	else if(char_const.length()==1 || (char_const.length()==0 && char_const_printable=="\\0")){
		
	tokelFileOutput<<"<CONST_CHAR, "<<char_const<<">\n";
	logFileOutput<<"Line# "<< line_count <<": Token " <<"<CONST_CHAR>"<<" Lexeme "<<char_const<<" found\n";
	}
	else{
		error_count++;
		logFileOutput<<"Error at line# "<<line_count<<": EMPTY_CONST_CHAR \'\'"<<endl;

	}


	BEGIN INITIAL;
}

<Character_state><<EOF>> {
	error_count++;
	
	string error_msg="'";
	error_msg+=char_const_printable;

	logFileOutput<<"Error at line# "<<line_count<<": UNFINISHED_CONST_CHAR "<<error_msg<<endl;
	
	BEGIN INITIAL;


}

<Character_state>. {
char_const+=yytext;
char_const_printable+=yytext;


}








	
{ADDOP} {
			tokelFileOutput<<"<ADDOP, "<<yytext<<">\n";
			logFileOutput<<"Line# "<<line_count<<": Token <ADDOP> Lexeme "<<yytext<<" found\n";
		
			
		}


{MULOP} {
			tokelFileOutput<<"<MULOP, "<<yytext<<">\n";
			logFileOutput<<"Line# "<<line_count<<": Token <MULOP> Lexeme "<<yytext<<" found\n";
			
		}

{INCOP} {
			tokelFileOutput<<"<INCOP, "<<yytext<<">\n";
			logFileOutput<<"Line# "<<line_count<<": Token <INCOP> Lexeme "<<yytext<<" found\n";
		
			
		}		
{RELOP} {
tokelFileOutput<<"<RELOP, "<<yytext<<">\n";
logFileOutput<<"Line# "<<line_count<<": Token <RELOP> Lexeme "<<yytext<<" found\n";

}

"=" {
	tokelFileOutput<<"<ASSIGNOP, "<<yytext<<">\n";
			logFileOutput<<"Line# "<<line_count<<": Token <ASSIGNOP> Lexeme "<<yytext<<" found\n";
}

{LOGICOP} {
    tokelFileOutput << "<LOGICOP, " << yytext << ">\n";
    logFileOutput << "Line# " << line_count << ": Token <LOGICOP> Lexeme " << yytext << " found\n";
}


{BITOP}  {
    tokelFileOutput << "<BITOP, " << yytext << ">\n";
    logFileOutput << "Line# " << line_count << ": Token <BITOP> Lexeme " << yytext << " found\n";
}


"!" {
    tokelFileOutput << "<NOT, " << yytext << ">\n";
    logFileOutput << "Line# " << line_count << ": Token <NOT> Lexeme " << yytext << " found\n";
}

"(" {
    tokelFileOutput << "<LPAREN, " << yytext << ">\n";
    logFileOutput << "Line# " << line_count << ": Token <LPAREN> Lexeme " << yytext << " found\n";
}

")" {
    tokelFileOutput << "<RPAREN, " << yytext << ">\n";
    logFileOutput << "Line# " << line_count << ": Token <RPAREN> Lexeme " << yytext << " found\n";
}

"{" {
    tokelFileOutput << "<LCURL, " << yytext << ">\n";
    logFileOutput << "Line# " << line_count << ": Token <LCURL> Lexeme " << yytext << " found\n";
	
	symbolTable->enterScope();
	expected_tab++;
}
"}" {
	
	expected_tab--;
	tokelFileOutput << "<RCURL, }>\n";
    logFileOutput << "Line# " << line_count << ": Token <RCURL> Lexeme } found\n";
	symbolTable->exitScope();
}


"[" {
    tokelFileOutput << "<LSQUARE, " << yytext << ">\n";
    logFileOutput << "Line# " << line_count << ": Token <LSQUARE> Lexeme " << yytext << " found\n";
}

"]" {

	tokelFileOutput << "<RSQUARE, " << yytext << ">\n";
    logFileOutput << "Line# " << line_count << ": Token <RSQUARE> Lexeme " << yytext << " found\n";
}


"," {
    tokelFileOutput << "<COMMA, " << yytext << ">\n";
    logFileOutput << "Line# " << line_count << ": Token <COMMA> Lexeme " << yytext << " found\n";
}

";" {
    tokelFileOutput << "<SEMICOLON, "<< yytext << ">\n";
    logFileOutput << "Line# " << line_count << ": Token <SEMICOLON> Lexeme " << yytext << " found\n";
}







{IDENTIFIER} {
	 tokelFileOutput << "<ID, " << yytext << ">\n";
    logFileOutput << "Line# " << line_count << ": Token <ID> Lexeme " << yytext << " found\n";
	if(symbolTable->insert(yytext,"ID")){
		symbolTable->printAll(logFileOutput);
	}
	else{
		logFileOutput <<"\t"<< yytext<<" already exists in the current ScopeTable\n";
	}

}

{INVALID_ID_SUFFIX_NUM_PREFIX} {
	error_count++;
	logFileOutput<<"Error at line# "<<line_count<<": INVALID_ID_SUFFIX_NUM_PREFIX "<<yytext<<endl;
}








\" {
	str_const.clear();
	str_const_printable.clear();
    newlines_count=0;

	BEGIN String_state;
	

}
<String_state>\\\' {
	str_const+="\'";
	str_const_printable+="\\\'";
}
<String_state>\\\" {
	str_const+="\"";
	str_const_printable+="\\\"";
	
}

<String_state>{NEXTLINE}* {
	error_count++;
	
	string error_msg="\"";
	error_msg+=str_const_printable;
	

	logFileOutput<<"Error at line# "<<line_count+newlines_count<<": UNFINISHED_STRING "<<error_msg<<endl;
	//newlines_count++;
	line_count+=newlines_count;
	newlines_count=0;
	resetWhitespaceCounts();
	updateWhiteSpaceCounts();
	showIndentationWarning();
	BEGIN INITIAL;
}

<String_state>\\t {
	str_const+="\t";
	str_const_printable+="\\t";
	
}

<String_state>\\\\ {
	str_const+="\\";
	str_const_printable+="\\\\";
	
}

<String_state>\\a {
	str_const+="\a";
	str_const_printable+="\\a";
	
}
<String_state>\\f {
	str_const+="\f";
	str_const_printable+="\\f";
	
}
<String_state>\\r {
	str_const+="\r";
	str_const_printable+="\\r";
	
}

<String_state>\\b {
	str_const+="\b";
	str_const_printable+="\\b";
	
}

<String_state>\\v {
	str_const+="\v";
	str_const_printable+="\\v";
	
}

<String_state>\\0 {
	str_const+="\0";
	str_const_printable+="\\0";
	
}

<String_state>\\n {
	str_const+="\n";
	str_const_printable+="\\n";
	
}

<String_state>\\ {

	BEGIN Ignore_newlines;
	str_const_printable+="\\";

}

<Ignore_newlines>{NEWLINE} {
	newlines_count++;
	str_const_printable+="\n";
	BEGIN String_state;
}
<Ignore_newlines>. {
	//cout<<"multiline string not like this"<<endl;
	str_const+=yytext;
	str_const_printable+=yytext;
	BEGIN String_state;

}

<String_state>\" {
	
	//tokelFileOutput<<"<STRING, "<<str_const<<">\n";
	string written="\"";
	written+=str_const_printable;
	written+="\"";
	string name="SINGLE LINE STRING";
	if(newlines_count>0)name="MULTI LINE STRING";
	tokelFileOutput<<"<"<<name<<", "<<str_const<<">"<<endl;
	logFileOutput<<"Line# "<< line_count <<": Token <" <<name<<"> Lexeme "<<written<<" found\n";
	line_count+=newlines_count;
	newlines_count=0;
	BEGIN INITIAL;
}

<String_state><<EOF>> {
	error_count++;
	
	string error_msg="\"";
	error_msg+=str_const_printable;

	logFileOutput<<"Error at line# "<<line_count+newlines_count<<": UNFINISHED_STRING   "<<error_msg<<endl;
	line_count+=newlines_count;
	newlines_count=0;

	BEGIN INITIAL;


}

<String_state>. {
str_const+=yytext;
str_const_printable+=yytext;

}










\/\/ {
newlines_count=0;
comment_content.clear();
BEGIN Single_Comment_state;

}
<Single_Comment_state>\\{NEWLINE} {
	newlines_count++;
	comment_content+="\\\n";

}
<Single_Comment_state>{NEXTLINE}* {
	
	//newlines_count++;
	logFileOutput<<"Line# "<<line_count<<": Token <SINGLE LINE COMMENT> Lexeme //"<<comment_content<<" found"<<endl;
	line_count+=newlines_count;
	resetWhitespaceCounts();
	updateWhiteSpaceCounts();
	showIndentationWarning();
	newlines_count=0;
	BEGIN INITIAL;
}



<Single_Comment_state><<EOF>> {
	/*error_count++;
	
	string error_msg="//";
	error_msg+=comment_content;

	logFileOutput<<"Error at line# "<<line_count+newlines_count<<": UNFINISHED_COMMENT "<<error_msg<<endl;
	*/
	logFileOutput<<"Line# "<<line_count<<": Token <SINGLE LINE COMMENT> Lexeme //"<<comment_content<<" found"<<endl;
	line_count+=newlines_count;
	newlines_count=0;

	BEGIN INITIAL;


}

<Single_Comment_state>. {
	comment_content+=yytext;
}








\/\* {
	comment_content.clear();
	newlines_count=0;
	BEGIN Multiline_comment_state;
	
}
<Multiline_comment_state>{NEWLINE} {
	newlines_count++;
	comment_content+="\n";
}
<Multiline_comment_state>\*\/ {
	logFileOutput<<"Line# "<<line_count<<": Token <MULTI LINE COMMENT> Lexeme /*"<<comment_content<<"*/ found"<<endl;
	line_count+=newlines_count;
	newlines_count=0;
	BEGIN INITIAL;

}

<Multiline_comment_state><<EOF>> {
	error_count++;
	
	string error_msg="/*";
	error_msg+=comment_content;


	logFileOutput<<"Error at line# "<<line_count+newlines_count<<": UNFINISHED_COMMENT "<<error_msg<<endl;
	line_count+=newlines_count;
	newlines_count=0;

	BEGIN INITIAL;


}
<Multiline_comment_state>. {
	comment_content+=yytext;
}








<<EOF>> {

symbolTable->printAll(logFileOutput);
logFileOutput<<"Total lines: "<<line_count<<endl;
logFileOutput<<"Total errors: "<<error_count<<endl;
logFileOutput<<"Total warnings: "<<warning_count<<endl;
delete symbolTable;//this is line should be commented if We need to use the SymbolTable Later


return 0;

}





. {
    
	logFileOutput<<"Error at line# "<<line_count<<": UNRECOGNIZED_CHAR "<<yytext<<endl;
	error_count++;
}





			

%%

int main(int argc,char *argv[]){
	
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	/* logFileOutput= fopen("log.txt","w");
	tokelFileOutput= fopen("token.txt","w"); */

	logFileOutput.open("2005017_log.txt");
	tokelFileOutput.open("2005017_token.txt");

	yyin= fin;
	yylex();
	fclose(yyin);
	/* fclose(tokelFileOutput);
	fclose(logFileOutput); */
	logFileOutput.close();
	tokelFileOutput.close();

	return 0;
}
