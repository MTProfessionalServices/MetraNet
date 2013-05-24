
#include <metra.h>
#include <mtcom.h>
#include <ExtendedProp.h>

#include <mtcomerr.h>

using namespace std;

ComInitialize gComInit;

class ExtendedPropTest
{
public:
	BOOL Init();
	BOOL Test(BOOL aAdd);

private:
	ExtendedPropCollection mCollection;
};

BOOL ExtendedPropTest::Init()
{
	return mCollection.Init();
}

BOOL ExtendedPropTest::Test(BOOL aAdd)
{
	if (aAdd)
	{
		if (!mCollection.CreateTables())
		{
			cout << "Unable to create tables" << endl;
			return FALSE;
		}
		cout << "Tables added" << endl;
	}
	else
	{
		if (!mCollection.DropTables())
		{
			cout << "Unable to drop tables" << endl;
			return FALSE;
		}
		cout << "Tables dropped" << endl;
	}
	
	return TRUE;

}

int main(int argc, char * argv[])
{
	try
	{
		ExtendedPropTest test;
		if (!test.Init())
		{
			cout << "Init failed" << endl;
			return -1;
		}

		BOOL add = TRUE;
		if (argc == 2 && 0 == strcmp(argv[1], "-drop"))
			add = FALSE;

		if (!test.Test(add))
		{
			cout << "Test failed" << endl;
			return -1;
		}
	}
	catch (_com_error & err)
	{ 
		std::string buffer;
		StringFromComError(buffer, "exception thrown", err);
		cout << buffer.c_str();
		return -1;
	}


	return 0;
}
