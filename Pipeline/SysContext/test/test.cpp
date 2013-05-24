/**************************************************************************
 * @doc TEST
 *
 * Copyright 1998 by MetraTech Corporation
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
#include <iostream>
#include <threadtest.h>

#include <mtcom.h>

using std::cout;
using std::endl;

#import <MTPipelineLib.tlb> rename ("EOF", "RowsetEOF") no_function_mapping

static ComInitialize gComInit;


class SysConThreadTest : public ThreadTest
{
public:
	SysConThreadTest(int aThreads, int aSerialCount, int aParallelCount)
		: ThreadTest(aThreads, aSerialCount, aParallelCount)
	{ }

	virtual BOOL Test();

	virtual BOOL Setup(int argc, char * * argv);
private:
	MTPipelineLib::IMTSystemContextPtr mSysCon;
	MTPipelineLib::IMTNameIDPtr mNameID;

	_bstr_t mTestStr1;
	_bstr_t mTestStr2;
	_bstr_t mTestStr3;

	long mTestID1;
	long mTestID2;
	long mTestID3;
};

BOOL SysConThreadTest::Setup(int argc, char * * argv)
{
	try
	{
		if (FAILED(mSysCon.CreateInstance("MetraPipeline.MTSystemContext.1")))
			return FALSE;

		mTestStr1 = "TestString1";
		mTestStr2 = "fooooooBBBar";
		mTestStr3 = "x";

		mNameID = mSysCon;

		mTestID1 = mNameID->GetNameID(mTestStr1);
		mTestID2 = mNameID->GetNameID(mTestStr2);
		mTestID3 = mNameID->GetNameID(mTestStr3);
	}
	catch (_com_error err)
	{
		cout << "failed: " << err.Error() << endl;
		return FALSE;
	}
	return TRUE;
}

BOOL SysConThreadTest::Test()
{
	try
	{
		// get a fresh interface to the name ID class all the time
		// to simulate heavy usage
		MTPipelineLib::IMTNameIDPtr nameid = mSysCon;

		long testid1 = mNameID->GetNameID(mTestStr1);
		long testid2 = mNameID->GetNameID(mTestStr2);
		long testid3 = mNameID->GetNameID(mTestStr3);

		ASSERT(testid1 == mTestID1);
		ASSERT(testid2 == mTestID2);
		ASSERT(testid3 == mTestID3);
	}
	catch (_com_error err)
	{
		cout << "failed: " << err.Error() << endl;
		return FALSE;
	}
	return TRUE;
}


int main(int argc, char * argv[])
{
	//_CrtSetReportMode(_CRT_WARN, _CRTDBG_MODE_DEBUG);

	// threads, serial, parallel
	SysConThreadTest test(10, 100, 500);
	test.RunTest(argc, argv);
	cout << "Test passed" << endl;
	return 0;
}
