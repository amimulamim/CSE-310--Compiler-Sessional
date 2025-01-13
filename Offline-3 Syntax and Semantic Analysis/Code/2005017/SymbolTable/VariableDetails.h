#include <string>
using namespace std;
class VariableDetails
{
private:
    string varType;
    int arrayLength;
public:
    VariableDetails(string varType, int arrayLength=-1){
        this->varType = varType;
        this->arrayLength = arrayLength;

    }
    VariableDetails(int arrayLength=-1){
        this->varType="";
        this->arrayLength = arrayLength;
    }
    ~VariableDetails(){};

    string getVarType() const { return varType; }
    int getArrayLength() const { return arrayLength; }

    void setVarType(string varType) { this->varType = varType;}
    void setArrayLength(int arrayLength) { this->arrayLength = arrayLength; }

};



