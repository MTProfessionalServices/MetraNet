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
#include <threadtest.h>

#include <mtcom.h>

#import "MTPipelineLib.tlb" rename ("EOF", "RowsetEOF") no_function_mapping

#include <time.h>
#include <conio.h>
#include <iostream>

#include <SetIterate.h>
#include <mtcomerr.h>
#include <vector>

using namespace std;

static ComInitialize gComInitialize;

typedef vector<long> LongVector;

class SessServerThreadTest : public ThreadTest
{
public:
	SessServerThreadTest(int aIDStart, int level, int aThreads,
											 int aSerialCount, int aParallelCount)
		: mLevel(level), ThreadTest(aThreads, aSerialCount, aParallelCount)
	{
		InitializeCriticalSection(&mIDGuard);
		mID = aIDStart;
	}

	~SessServerThreadTest()
	{
		DeleteCriticalSection(&mIDGuard);
	}

	virtual BOOL Test();

	virtual BOOL Setup(int argc, char * * argv);
private:
	MTPipelineLib::IMTSessionServerPtr mServer;

	int mLevel;

	CRITICAL_SECTION mIDGuard;
	long mID;

#if 0
	long GetRealID()
	{
		long id;

		EnterCriticalSection(&mIDGuard);
		id = mID++;
		LeaveCriticalSection(&mIDGuard);
		return id;
	}
#endif
};

BOOL SessServerThreadTest::Setup(int argc, char * * argv)
{
	srand((long) time(NULL));

	try
	{
		HRESULT hr = mServer.CreateInstance("MetraPipeline.MTSessionServer.1");
		if (FAILED(hr))
			return FALSE;

		long totalSize = 5 * 1024 * 1024;

		mServer->Init("c:\\temp\\sesstest.bin", "sessiontestview",
									totalSize);
	}
	catch (_com_error)
	{
		return FALSE;
	}
	return TRUE;
}

_COM_SMARTPTR_TYPEDEF(IUnknown, __uuidof(IUnknown));

BOOL SessServerThreadTest::Test()
{
	if (mLevel == 0)
	{
		for (int i = 0; i < 50; i++)
		{
			//long realId = GetRealID();
			long serviceId = 10;
			MTPipelineLib::IMTSessionPtr session = mServer->CreateTestSession(serviceId);
			//ASSERT(session->GetDatabaseID() == realId);
			ASSERT(session->GetServiceID() == serviceId);
			//	ASSERT(session->GetParentID() == parent);
			session = NULL;
		}
	}
	else if (mLevel == 1)
	{
		for (int i = 0; i < 50; i++)
		{
			//long realId = GetRealID();
			long serviceId = 10;
			MTPipelineLib::IMTSessionPtr session = mServer->CreateTestSession(serviceId);
			//ASSERT(session->GetDatabaseID() == realId);
			ASSERT(session->GetServiceID() == serviceId);
			//ASSERT(session->GetParentID() == parent);

			for (int j = 0; j < 10; j++)
				session->SetLongProperty(j + 100, j);

			for (int j = 0; j < 10; j++)
				ASSERT (session->GetLongProperty(j + 100) == j);

			session = NULL;
		}
	}
	else if (mLevel == 2)
	{
		//long realId = GetRealID();

		// simple set case
		for (int i = 0; i < 2; i++)
		{
			MTPipelineLib::IMTSessionSetPtr testset = mServer->CreateSessionSet();

			const long testVal = 12345;
			const long serviceId = 10;

			MTPipelineLib::IMTSessionPtr session = mServer->CreateTestSession(serviceId);

			//ASSERT(session->GetDatabaseID() == realId);
			ASSERT(session->GetServiceID() == serviceId);
			//ASSERT(session->GetParentID() == parent);

			session->SetLongProperty(100, testVal);

			testset->AddSession(session->GetSessionID(), session->GetServiceID());


			IUnknownPtr unk(testset->Get_NewEnum(), FALSE);
			session = NULL;
			testset = NULL;
			//unk->Release();
			unk = NULL;
		}
	}
	else if (mLevel == 3)
	{
		MTPipelineLib::IMTSessionSetPtr testset = mServer->CreateSessionSet();

		const int SESSION_COUNT = 50;
		const long testVal = 12345;
		const long serviceId = 10;

		for (int i = 0; i < SESSION_COUNT; i++)
		{
			//long realId = GetRealID();
			MTPipelineLib::IMTSessionPtr session = mServer->CreateTestSession(serviceId);
			//	ASSERT(session->GetDatabaseID() == realId);
			ASSERT(session->GetServiceID() == serviceId);
			//ASSERT(session->GetParentID() == parent);

			session->SetLongProperty(100, testVal);

			testset->AddSession(session->GetSessionID(), session->GetServiceID());

			session = NULL;
		}

		SetIterator<MTPipelineLib::IMTSessionSetPtr, MTPipelineLib::IMTSessionPtr> it;
		HRESULT hr = it.Init(testset);
		if (FAILED(hr))
		  throw hr;
	
		while (TRUE)
		{
		    MTPipelineLib::IMTSessionPtr session = it.GetNext();
		  	if (session == NULL)
			  break;

			long val = session->GetLongProperty(100);
			ASSERT(val == testVal);

			ASSERT(session->GetServiceID() == serviceId);
		}
	}


#if 0
		IUnknown * unk;
		HRESULT hr = testset->get__NewEnum(&unk);
		ASSERT(SUCCEEDED(hr));
		ASSERT(unk);
		IEnumVARIANTPtr ienum(unk);
		for (i = 0; i < 5; i++)
		{
			int count = 0;

			HRESULT hr;

			const int CHUNKSIZE = 7;
			VARIANT rgvar[CHUNKSIZE] = { 0 };
			do
			{
				ULONG cFetched;

				hr = ienum->Next(CHUNKSIZE, rgvar, &cFetched);
				if (FAILED(hr))
					ASSERT(0);

				for( ULONG i = 0; i < cFetched; i++ )
				{
					_variant_t var(rgvar[i]);

					MTPipelineLib::IMTSessionPtr session(var);

					// ---- do something with the session ----

					long val = session->GetLongProperty(100);
					ASSERT(val == testVal);

					ASSERT(session->GetServiceID() == serviceId);
					count++;

					// ---------------------------------------

					VariantClear(&rgvar[i]);
				}
			}
			while (hr == S_OK);

			ASSERT(count == SESSION_COUNT);

			ienum->Reset();
		}
	}
#endif
	// TODO: failures always assert - they should return -1
	return TRUE;
}


int main(int argc, char * argv[])
{
	if (argc > 1 && 0 == strcmp(argv[1], "-auto"))
	{
		int idstart;
		if (argc > 2)
			idstart = strtol(argv[2], NULL, 10);
		else
			idstart = 1000;

		int level;
		if (argc > 3)
			level = strtol(argv[3], NULL, 10);
		else
			level = 0;

		SessServerThreadTest test(idstart, level, 0, 100, 100);
		if (test.RunTest(argc, argv))
		{
			cout << "Test passed" << endl;
			return 0;
		}
		else
		{
			cout << "Test failed" << endl;
			return -1;
		}
	}

	return 0;
}

