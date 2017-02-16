#include "database.h"

int main()
{
	CodeKata codeKata("High Five!", "/home/ryan/rc/codedojo/highfive");
	
	Table katas;
	katas.insert(codeKata);

	katas.list();

	return 0;
}
