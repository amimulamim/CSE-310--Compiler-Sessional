#include<iostream>
#include<string>
using namespace std;


class SymbolInfo
{
private:
     string Name;
    string Type;
    SymbolInfo* next;
    
public:
    SymbolInfo(string& name,string& type);
    SymbolInfo(const SymbolInfo& other):Name(other.Name),Type(other.Type),next(other.next){
        
    }
    ~SymbolInfo();

    string getName() const{ return Name;}
    string getType() const{ return Type;}
    SymbolInfo* getNext() const{ return next;}

    void setName(const string& name) { Name = name; }
    void setType(const string& type) { Type = type; }
    void setNext(SymbolInfo* next) { this->next = next;}

    //int getHashIndex(int bucket,) const { return

};

SymbolInfo::SymbolInfo(string& name,string& type)
{
    this->Name = name;
    this->Type=type;
    next = nullptr;
}

SymbolInfo::~SymbolInfo()
{
}
