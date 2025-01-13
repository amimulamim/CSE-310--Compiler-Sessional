#include "2005017_SymbolTable.h"
#include <sstream>

void solve()
{
    int n;
    cin >> n;
    SymbolTable* symbolTable=new SymbolTable(n);
    string line;
    cin>>std::ws;
    int cmd=1;
    while (getline(cin, line))
    {   
        cout<<"Cmd "<<cmd++<<": "<<line<<endl;
        char command;
        string argument1,argument2;
        istringstream iss(line);
        iss >> command;
        bool done;
        SymbolInfo *si;
        string printOption;
        try
        {
            switch (command)
            {
            case 'I':
                if (!(iss >> argument1 >> argument2) || !iss.eof())
                {
                    throw invalid_argument("Wrong number of arguments for the command I");
                }
                done =  symbolTable->insert(argument1, argument2);
                if (!done)
                {
                    cout<<"\t" << "'" << argument1 << "' already exists in the current ScopeTable# " <<  symbolTable->getCurrent()->getId() << endl;
                }
                break;
            case 'L':
                if (!(iss >> argument1) || !iss.eof())
                {
                    // cout<<"\t"<<"check1\n";
                    throw invalid_argument("Wrong number of arguments for the command L");
                }
                si =  symbolTable->lookup(argument1);
                if (si == nullptr)
                {
                    cout<<"\t" << "'" << argument1 << "' not found in any of the ScopeTables\n";
                }
                break;
            case 'P':
                if (!(iss >> printOption) || !iss.eof())
                {
                    throw invalid_argument("Wrong number of arguments or invalid argument for the command P");
                }
                if (printOption == "C")
                {
                     symbolTable->printCurrent();
                }
                else if (printOption == "A")
                {
                     symbolTable->printAll();
                }
                else
                {
                    throw invalid_argument("Invalid argument for the command P");
                }
                break;
            case 'D':
                
                if (!(iss >> argument1) || !iss.eof())
                {
                    throw invalid_argument("Wrong number of arguments for the command D");
                }
                
                done =  symbolTable->remove(argument1);
                
                if (!done)
                {
                    cout<<"\t" << "Not found in the current ScopeTable# " <<  symbolTable->getCurrent()->getId() << endl;
                }
                break;
            case 'S':
                iss>>std::ws;
                if (!iss.eof())
                {
                    throw invalid_argument("Wrong number of arguments for the command S");
                }
                 symbolTable->enterScope();
                break;
                
            case 'E':
                iss>>std::ws;
                if (!iss.eof())
                {
                    throw invalid_argument("Wrong number of arguments for the command E");
                }
                done =  symbolTable->exitScope();
                if (!done)
                {
                    cout<<"\t" << "ScopeTable# 1 cannot be deleted" << endl;
                }
                break;
            case 'Q':
                iss>>std::ws;
                if (!iss.eof())
                {
                    throw invalid_argument("Wrong number of arguments for the command Q");
                }
                delete symbolTable;
                break;
            default:
                cout<<"\t" << "Unknown command: " << command << endl;
                break;
            }
        }
        catch (const invalid_argument &e)
        {
            cout<<"\t" << e.what() << endl;
        }
    }
}

int main()
{
   
    freopen("input.txt", "r", stdin);
    freopen("output.txt", "w", stdout);
    solve();

    return 0;
}


