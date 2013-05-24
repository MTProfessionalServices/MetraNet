/**************************************************************************
 * TEST
 *
 * Copyright 1997-2001 by MetraTech Corp.
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
 * NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech Corporation MAKES NO
 * REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
 * PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
 * DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
 * COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech Corporation,
 * and USER agrees to preserve the same.
 *
 * Created by: Derek Young
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include <metra.h>
#include <mtcom.h>
#include <ParamTable.h>
#include <mtcomerr.h>
using namespace std;

ComInitialize gComInit;

class ParamTableTest
{
public:
	BOOL Init();
	BOOL Test(BOOL aAdd);

private:
	ParamTableCollection mCollection;
};

BOOL ParamTableTest::Init()
{
	return mCollection.Init();
}

BOOL ParamTableTest::Test(BOOL aAdd)
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
		ParamTableTest test;
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
