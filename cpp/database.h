#include <vector>
#include <string>

using namespace std;

class CodeKata {
public:
	CodeKata(string n, string d);
	//CodeKata(const CodeKata & other);
	
	string getName() const;
	string getDirectory() const;

private:
	string name;
	string directory;
};
		

class Table {
public:
	Table();
	
	void list() const;
	void insert(CodeKata codeKata);

private:
	vector<CodeKata> records;
};
		
