#include<iostream>
#include<fstream>
#include<string>
#include<vector>
using namespace std;

class ParserNode{
    int firstLine;
    int lastLine;
    string matchedRule;
    string dataType,value;
    vector<ParserNode*> subordinates;
    bool isNonTerminal,isError,isErrRootPrinted;

    public:
    ParserNode(int firstLine, int lastLine,string matchedRule,string dataType="",string value=""){
        this->firstLine = firstLine;
        this->lastLine = lastLine;
        this->matchedRule = matchedRule;
        this->dataType = dataType;
        this->value = value;
        vector<ParserNode*> children;
        subordinates=children;
        isNonTerminal=false;
        isErrRootPrinted=false;
        isError=false;
            // size_t found = matchedRule.find("error");
            // isError|= (found != std::string::npos);
    // If found is not equal to std::string::npos, it means "error" was found
    
    }
    ~ParserNode(){
        for(auto p:subordinates){
            delete p;
        }

    }
    ParserNode* setErrorFlag(){
        isError=true;
    }
    bool isErrorFlag(){
        return isError;
    }
    ParserNode* addSubordinate(ParserNode* child){
        isNonTerminal=true;
        subordinates.push_back(child);
        isError=child->isErrorFlag()|isError;
        isErrRootPrinted=child->isErrorPrinted()|isErrRootPrinted;

        return this;
    }
    bool isErrorPrinted(){
        return isErrRootPrinted;
    }
    void print(ofstream& out,int offset=0){
        for(int i=0;i<offset;i++){
            out<<" ";
        }
        if(!isNonTerminal){
            out<<matchedRule<<" \t"<<"<Line: "<<firstLine<<">\n";
            return;
        }
        out<<matchedRule<<" \t"<<"<Line: "<<firstLine<<"-"<<lastLine<<">\n";
        if(subordinates.size()==0){return;}
        
        for(int i=0;i<subordinates.size();i++){
            ParserNode* p = subordinates[i];
            p->print(out,offset+1);
        }
        

    }
    void setDataType(string dataType){
        this->dataType = dataType;
    }
    string getDataType(){
        return this->dataType;
    }
    int getFirstLine(){return this->firstLine;}
    void setValue(string val){value=val;}
    string getValue(){return this->value;}





};