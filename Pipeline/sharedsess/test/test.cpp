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
 * $Header$
 ***************************************************************************/

#include <metra.h>

#include <MSIX.h>
#include <threadtest.h>
#include <sharedsess.h>
#include <iostream>

#include <conio.h>

#include <stdlib.h>
#include <time.h>

#include <vector>
using namespace std;

#define TEST_ASSERT(x) if (!(x)) { fprintf(stderr, "FAILURE on line %d", __LINE__); fflush(stderr); abort(); }
//#define TEST_ASSERT(x)

typedef vector<long> LongVector;

class SharedSessThreadTest : public ThreadTest
{
public:
	SharedSessThreadTest(int level, int aThreads, int aSerialCount, int aParallelCount)
		: mLevel(level), ThreadTest(aThreads, aSerialCount, aParallelCount)
	{
		InitializeCriticalSection(&mIDGuard);
	}

	~SharedSessThreadTest()
	{
		DeleteCriticalSection(&mIDGuard);
	}

	virtual BOOL Test();

	virtual BOOL Setup(int argc, char * * argv);

private:
	BOOL TestLevel(int aLevel);

private:
	SharedSessionMappedViewHandle mView;
	//SharedSessions mSessions;
	SharedSessionHeader * mpHeader;

	int mLevel;

	CRITICAL_SECTION mIDGuard;
	long mID;

	long GetRealID()
	{
		int id = rand();
		if (id == 0)
			return 1;
		if (id < 0)
			return -id;

		return id;
	}
};

BOOL SharedSessThreadTest::Setup(int argc, char * * argv)
{
	srand((long) time(NULL));

	mID = rand();

	if (argc > 2)
		mLevel = strtol(argv[2], NULL, 10);
	else
		mLevel = -1;

	long totalSize = 40485760;
//	long totalSize = 40 * 1024 * 1024;

	DWORD err = mView.Open("c:\\temp\\sessions.bin", "PipelineSessionView",
												totalSize, FALSE);
	if (err != NO_ERROR)
	{
		cout << "open failed: " << hex << err << dec << endl;
		return FALSE;
	}

	long spaceAvail = mView.GetAvailableSpace() - sizeof(SharedSessionHeader);

	mpHeader = SharedSessionHeader::Initialize(mView, // view
																						 mView.GetMemoryStart(),
																						 spaceAvail / 5, // session pool size
																						 spaceAvail / 5, // prop pool size
																						 spaceAvail / 5, // set pool size
																						 spaceAvail / 5, // set node pool size
																						 spaceAvail / 5, // string pool size
																						 FALSE);	// force reset
	if (!mpHeader)
	{
		cout << "initialize failed" << endl;
		return FALSE;
	}
	//_getch();

	return (mpHeader != NULL);
}



BOOL SharedSessThreadTest::Test()
{
	static int it = 0;

	if (mLevel != -1)
	{
		if (!TestLevel(mLevel))
			return FALSE;
	}
	else
	{
		for (int i = 0; i <= 6; i++)
			if (!TestLevel(i))
				return FALSE;
	}

	return TRUE;
}

BOOL SharedSessThreadTest::TestLevel(int aLevel)
{
	int i;

	LongVector ids;
	LongVector realIds;

	const int SESSIONS = 10;

	unsigned char uid[16];
	std::string uidString;

#if 0
	/*
	 * regression test
	 */

	MSIXUidGenerator::Generate(uidString);
	MSIXUidGenerator::Decode(uid, uidString);


	// real ID of -1 means test session
	SharedSession * testSess = SharedSession::Create(mpHeader, id,
																									 uid, -1);
	TEST_ASSERT(testSess);

	int count = testSess->Release(mpHeader);
	// no one else should have access to this session
	TEST_ASSERT(count == 0);

	long foundId;
	testSess = SharedSession::FindWithUID(mpHeader, foundId, uid);

	if (testSess)
	{
		TEST_ASSERT(0);
		testSess = SharedSession::FindWithUID(mpHeader, foundId, uid);
	}

#endif


	// create some sessions
	for (i = 0; i < SESSIONS; i++)
	{
		long id;

		// if this session already exists in the shared area, the test file should be deleted
		long testFoundID;

		MSIXUidGenerator::Generate(uidString);
		MSIXUidGenerator::Decode(uid, uidString);


		// generate a new real ID
		long realId = GetRealID();

		SharedSession * test = SharedSession::FindWithUID(mpHeader, testFoundID, uid);
		TEST_ASSERT(!test);

		SharedSession * sess = SharedSession::Create(mpHeader, id,
																								 uid, -1);
		TEST_ASSERT(sess);

		sess->SetRealID(realId);


		ids.push_back(id);
		realIds.push_back(realId);
	}

	if (aLevel == 0)
	{
		/*
		 * Level 0 test - empty sessions only
		 */

		// randomly attempt to access/verify them 50 times
		for (i = 0; i < 50; i++)
		{
			int index = rand() % SESSIONS;

			long id = ids[index];
			long realId = realIds[index];


			// reference by index
			SharedSession * sess = mpHeader->GetSession(id);
			TEST_ASSERT(sess);
			TEST_ASSERT(realId == sess->GetRealID());

#if 0
			// find by real ID
			long foundId;
			sess = SharedSession::FindWithRealID(mpHeader, foundId, realId);
			TEST_ASSERT(sess);
			TEST_ASSERT(foundId == id);
#endif
		}
	}
	else if (aLevel == 1)
	{
		/*
		 * Level 1 test - long properties only
		 */

		for (i = 0; i < 50; i++)
		{
			int index = rand() % SESSIONS;

			long id = ids[index];
			long realId = realIds[index];

			// reference by index
			SharedSession * sess = mpHeader->GetSession(id);
			TEST_ASSERT(sess);
			TEST_ASSERT(realId == sess->GetRealID());

			// 1-10 properties
			int props = rand() % 9 + 1;
			for (int j = 0; j < props; j++)
			{
				long propVal = realId + j;
				long nameId = propVal;
				TEST_ASSERT(nameId > 0);

				long propRef;
				// add a property to the sess
				// use j as the name ID
				SharedPropVal * prop = sess->AddProperty(mpHeader, propRef, nameId);
				TEST_ASSERT(prop);
				TEST_ASSERT(prop->GetNameID() == nameId);

				// long property with value == j
				prop->SetLongValue(propVal);

				// reference by index
				prop = mpHeader->GetProperty(propRef);

				TEST_ASSERT(prop->GetType() == SharedPropVal::LONG_PROPERTY);
				TEST_ASSERT(prop->GetLongValue() == propVal);
				TEST_ASSERT(prop->GetNameID() == nameId);

				// find by name ID
				const SharedPropVal * getProp = sess->GetReadablePropertyWithID(mpHeader, nameId);

				TEST_ASSERT(getProp->GetType() == SharedPropVal::LONG_PROPERTY);
				TEST_ASSERT(getProp->GetLongValue() == propVal);
				TEST_ASSERT(getProp->GetNameID() == nameId);

				// iterate through all props
				int hashBucket;
				const SharedPropVal * currentProp = NULL;
				sess->GetProps(mpHeader, &currentProp, &hashBucket);
				TEST_ASSERT(currentProp);						// must be at least one
				int propCount = 0;
				while (currentProp)
				{
					propCount++;

					// make sure the numbers are at least in the correct range
					TEST_ASSERT(currentProp->GetType() == SharedPropVal::LONG_PROPERTY);
					TEST_ASSERT(currentProp->GetLongValue() >= realId
								 && currentProp->GetLongValue() <= realId + j);
					TEST_ASSERT(currentProp->GetNameID() >= realId
								 && currentProp->GetNameID() <= realId + j);

					sess->GetNextProp(mpHeader, &currentProp, &hashBucket);
				}
				// should be j + 1 properties at this point
				TEST_ASSERT(propCount == j + 1);
			}

			// now remove the props
			sess->DeleteProps(mpHeader);

			// make sure they're gone
			int hashBucket;
			const SharedPropVal * currentProp = NULL;
			sess->GetProps(mpHeader, &currentProp, &hashBucket);
			TEST_ASSERT(!currentProp);
		}
	}
	else if (aLevel == 2)
	{
		/*
		 * Level 2 - sessions in sets
		 */

		LongVector setIndeces;

		// create 50 sets of different sizes
		for (i = 0; i < 50; i++)
		{
			// new set
			long setId;
			SharedSet * set = SharedSet::Create(mpHeader, setId);
			setIndeces.push_back(setId);
		}

		// all possible indeces
		LongVector indeces;
		for (int k = 0; k < (int) setIndeces.size(); k++)
			indeces.push_back(k);

		// delete sets in random order
		for (i = 0; i < (int) setIndeces.size(); i++)
		{
			// randomly choose which one to remove
			int indexChoice = rand() % indeces.size();
			int index = indeces[indexChoice];
			indeces.erase(indeces.begin() + indexChoice);
			int setid = setIndeces[index];

			SharedSet * set = mpHeader->GetSet(setid);

			TEST_ASSERT(set);
			TEST_ASSERT(set->mRefCount > 0);

			int count = set->Release(mpHeader);

			// no one else should be holding this set
			TEST_ASSERT(count == 0);
		}
	}
	else if (aLevel == 3)
	{
		/*
		 * Level 3 - sessions in sets
		 */

		LongVector setIndeces;

		// create 50 sets of different sizes
		for (i = 0; i < 50; i++)
		{
			// new set
			long setId;
			SharedSet * set = SharedSet::Create(mpHeader, setId);
			setIndeces.push_back(setId);


			// all possible indeces
			LongVector indeces;
			for (int k = 0; k < SESSIONS; k++)
				indeces.push_back(k);

			// set will hold 1-SESSIONS items
			int size = (rand() % SESSIONS) + 1;
			for (int j = 0; j < size; j++)
			{
				// randomly choose which one to remove
				int indexChoice = rand() % indeces.size();
				int index = indeces[indexChoice];
				indeces.erase(indeces.begin() + indexChoice);

				long id = ids[index];
				long realId = realIds[index];

				SharedSession * sess = mpHeader->GetSession(id);
				TEST_ASSERT(sess);
				TEST_ASSERT(realId == sess->GetRealID());

				set->AddToSet(mpHeader, id);

				// make sure it was added to the set
				const SharedSetNode * current = set->First(mpHeader);
				while (current)
				{
					long thisId = current->GetID();

					if (thisId == id)
						break;

					current = current->Next(mpHeader);
				}
				TEST_ASSERT(current && current->GetID() == id);
			}

			// make sure we have the correct number of items in the set
			int count = 0;
			const SharedSetNode * current = set->First(mpHeader);

			while (current)
			{
				count++;
				current = current->Next(mpHeader);
			}
			TEST_ASSERT(count == size);
		}

		// all possible indeces
		LongVector indeces;
		for (int k = 0; k < (int) setIndeces.size(); k++)
			indeces.push_back(k);

		// delete sets in random order
		for (i = 0; i < (int) setIndeces.size(); i++)
		{
			// randomly choose which one to remove
			int indexChoice = rand() % indeces.size();
			int index = indeces[indexChoice];
			indeces.erase(indeces.begin() + indexChoice);
			int setid = setIndeces[index];

			SharedSet * set = mpHeader->GetSet(setid);

			TEST_ASSERT(set);
			int count = set->Release(mpHeader);

			// no one else should be holding this set
			TEST_ASSERT(count == 0);
		}
	}
	else if (aLevel == 4)
	{
		/*
		 * Level 4 test - string properties
		 */

		char smallTestStr[] = "smallStr";
		char medTestStr[100];
		char largeTestStr[255];

		int ch;
		for (ch = 0; ch < sizeof(medTestStr) - 1; ch++)
		{
			medTestStr[ch] = 'M'; //'0' + (i % 10);
		}
		medTestStr[ch] = '\0';

		for (ch = 0; ch < sizeof(largeTestStr) - 1; ch++)
		{
			largeTestStr[ch] = 'L'; //'A' + (i % 20);
		}
		largeTestStr[ch] = '\0';

		for (i = 0; i < 50; i++)
		{
			int index = rand() % SESSIONS;

			long id = ids[index];
			long realId = realIds[index];

			// reference by index
			SharedSession * sess = mpHeader->GetSession(id);
			TEST_ASSERT(sess);
			TEST_ASSERT(realId == sess->GetRealID());

			// 1-10 properties
			int props = rand() % 9 + 1;
			for (int j = 0; j < props; j++)
			{
				long propVal = realId + j;
				long nameId = propVal;
				TEST_ASSERT(nameId > 0);

				long propRef;
				// add a property to the sess
				// use j as the name ID
				SharedPropVal * prop = sess->AddProperty(mpHeader, propRef, nameId);
				TEST_ASSERT(prop);
				TEST_ASSERT(prop->GetNameID() == nameId);



				long strRef;

				int choice = rand() % 3;
				const char * testStr;
				if (choice == 0)
					testStr = smallTestStr;
				else if (choice == 1)
					testStr = medTestStr;
				else if (choice == 2)
					testStr = largeTestStr;

				const char * allocated = mpHeader->AllocateString(testStr, strRef);
				TEST_ASSERT(allocated);
				TEST_ASSERT(0 == strcmp(testStr, allocated));

				const char * testGet = mpHeader->GetString(strRef);
				TEST_ASSERT(0 == strcmp(testStr, testGet));

				prop->SetAsciiIDValue(strRef);

				// reference by index
				prop = mpHeader->GetProperty(propRef);

				TEST_ASSERT(prop->GetType() == SharedPropVal::ASCII_PROPERTY);
				TEST_ASSERT(prop->GetNameID() == nameId);
				TEST_ASSERT(prop->GetAsciiIDValue() == strRef);

				testGet = mpHeader->GetString(prop->GetAsciiIDValue());
				TEST_ASSERT(0 == strcmp(testStr, testGet));

				// find by name ID
				const SharedPropVal * getProp = sess->GetReadablePropertyWithID(mpHeader, nameId);

				TEST_ASSERT(getProp->GetType() == SharedPropVal::ASCII_PROPERTY);
				TEST_ASSERT(getProp->GetNameID() == nameId);
				TEST_ASSERT(getProp->GetAsciiIDValue() == strRef);

				testGet = mpHeader->GetString(prop->GetAsciiIDValue());
				TEST_ASSERT(0 == strcmp(testStr, testGet));

				// iterate through all props
				int hashBucket;
				const SharedPropVal * currentProp = NULL;
				sess->GetProps(mpHeader, &currentProp, &hashBucket);
				TEST_ASSERT(currentProp);						// must be at least one
				int propCount = 0;
				while (currentProp)
				{
					propCount++;

					TEST_ASSERT(currentProp->GetType() == SharedPropVal::ASCII_PROPERTY);
					TEST_ASSERT(currentProp->GetNameID() >= realId
								 && currentProp->GetNameID() <= realId + j);

					testGet = mpHeader->GetString(currentProp->GetAsciiIDValue());
					TEST_ASSERT(0 == strcmp(smallTestStr, testGet)
						|| 0 == strcmp(medTestStr, testGet)
						|| 0 == strcmp(largeTestStr, testGet));

					sess->GetNextProp(mpHeader, &currentProp, &hashBucket);
				}
				// should be j + 1 properties at this point
				TEST_ASSERT(propCount == j + 1);
			}

			// now remove the props
			sess->DeleteProps(mpHeader);

			// make sure they're gone
			int hashBucket;
			const SharedPropVal * currentProp = NULL;
			sess->GetProps(mpHeader, &currentProp, &hashBucket);
			TEST_ASSERT(!currentProp);
		}
	}
	else if (aLevel == 5)
	{
		/*
		 * Level 5 test - set allocation/deallocation test
		 */
		// new set
		long setId;
		SharedSet * set = SharedSet::Create(mpHeader, setId);

		unsigned char setuid[16];
		memset(setuid, 0x69, sizeof(setuid));

		// this will trash the "next free" value
		set->SetUID(setuid);

		// release it again
		int count = set->Release(mpHeader);
		::Sleep(0);
	}
	else if (aLevel == 6)
	{
		/*
		 * Level 6 test - session allocation/deallocation test
		 */



		MSIXUidGenerator::Generate(uidString);
		MSIXUidGenerator::Decode(uid, uidString);

		long id;
		SharedSession * sess = SharedSession::Create(mpHeader, id,
																								 uid, -1);
		TEST_ASSERT(sess);

		// release it again
		int count = sess->Release(mpHeader);
		::Sleep(0);
	}
#if 0
	else if (aLevel == 7)
	{
		/*
		 * Level 7 test - multi-thread access to a single object
		 */

		// get the first session
		// TODO: to get this test to work, id must be set to the ID of a session
		// that's known to exist
//		long id = ids(0);
		long id = 0;

		SharedSession * sess = mpHeader->GetSession(id);

		for (int i = 0; i < 500000; i++)
		{
			long count = sess->AddRef();
			TEST_ASSERT(count == 2);
			sess->Release(mpHeader);
		}
	}
#endif

	// remove all sessions in a random order
	LongVector indeces;
	for (i = 0; i < SESSIONS; i++)
		indeces.push_back(i);

	for (i = 0; i < SESSIONS; i++)
	{
		// randomly choose which one to remove
		int indexChoice = rand() % indeces.size();
		int index = indeces[indexChoice];
		indeces.erase(indeces.begin() + indexChoice);

		long id = ids[index];
		long realId = realIds[index];

		SharedSession * sess = mpHeader->GetSession(id);

		TEST_ASSERT(sess);
		TEST_ASSERT(realId == sess->GetRealID());

		int count = sess->Release(mpHeader);

		// no one else should have access to this session
///		TEST_ASSERT(count == 0);
	}

#if 0
	// make sure they're really gone
	for (i = 0; i < SESSIONS; i++)
	{
		long id = ids(i);
		long realId = realIds(i);

		long foundId;
		SharedSession * sess = SharedSession::FindWithRealID(mpHeader, foundId, realId);

		if (sess)
		{
			TEST_ASSERT(0);
			sess = SharedSession::FindWithRealID(mpHeader, foundId, realId);
		}
	}
#endif
	return TRUE;
}



int main (int argc, char * argv[])
{
	if (argc > 1 && 0 == strcmp(argv[1], "-auto"))
	{
		int level;
		if (argc > 3)
			level = strtol(argv[3], NULL, 10);
		else
			level = 0;

		SharedSessThreadTest test(level, 2, 100, 500000000);
//		SharedSessThreadTest test(level, 5, 100, 500000);
		if (test.RunTest(argc, argv))
			cout << "Test passed" << endl;
		else
			cout << "Test failed" << endl;
		return 0;
	}


	return 0;
}
