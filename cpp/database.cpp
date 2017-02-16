#include "database.h"

#include <iostream>

const string attr_space = "\t\t\t";

CodeKata::CodeKata(string n, string d)
{
	name = n;
	directory = d;
}

string CodeKata::getName() const
{
	return name;
}

string CodeKata::getDirectory() const
{
	return directory;
}

Table::Table() {}

void Table::list() const
{
	cout << "Name" << attr_space << "Directory" << endl;
	for (auto& record : records)
	{
		cout << record.getName() << attr_space 
			 << record.getDirectory() << endl;
	}
}

void Table::insert(CodeKata codeKata)
{
	records.push_back(codeKata);
}
