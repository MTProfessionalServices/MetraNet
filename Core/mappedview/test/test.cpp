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
#include <mappedview.h>
#include <iostream>

#include <conio.h>

using std::cout;
using std::endl;
using std::hex;
using std::dec;

void DynamicTest()
{
#if 0

	DynamicMappedViewHandle view;
	DWORD err = view.Open("c:\\scratch\\dynamic.bin",
												"testview", 5000, FALSE); //1024 * 1024);

	if (err == NO_ERROR)
	{
		cout << "view opened" << endl;
	}
	else
	{
		cout << "open failed " << hex << err << dec << endl;
		return;
	}

	cout << "initial" << endl;
	cout.flush();
	view.HeapWalk();

	const char * mystr = "12345";
	char * str1 = (char *) view.Allocate(strlen(mystr) + 1);
	strcpy(str1, mystr);

	cout << "after allocate" << endl;
	cout.flush();
	view.HeapWalk();

	mystr = "abc";
	char * str2 = (char *) view.Allocate(strlen(mystr) + 1);
	strcpy(str2, mystr);

	cout << "after allocate" << endl;
	cout.flush();
	view.HeapWalk();

	view.Free(str1);

	cout << "after free" << endl;
	cout.flush();
	view.HeapWalk();

	view.Free(str2);

	cout << "after free" << endl;
	cout.flush();
	view.HeapWalk();
#endif
}


/*
 * Auto Test of MappedViewHandle class
 */

#include <winbase.h>
void AutoTest()
{
	//if (IsDebuggerPresent())
	SET_ASSERT_MODE(_CRTDBG_MODE_WNDW);
	//else
	//SET_ASSERT_MODE(_CRTDBG_MODE_DEBUG);

	/*
	 * make sure the file will open correctly
	 */
	MappedViewHandle mapped;
	DWORD size = 1024 * 1024;
	DWORD err = mapped.Open("c:\\temp\\autotest.bin", "autotestmapping",
													size, TRUE);
	ASSERT(err == NO_ERROR);

	int pageSize = mapped.GetPageSize();
	cout << "page size: " << pageSize << endl;

	int total = mapped.GetTotalSpace();
	cout << "total space: " << total << endl;

	int avail = mapped.GetAvailableSpace();
	cout << "available: " << avail << endl;

	void * start = mapped.GetMemoryStart();

	/*
	 * allocate all space in 1k chunks, verifying the starting
	 * address and remaining free space after every allocation
	 */
	const DWORD chunkSize = 1024;
	for (int i = 0; i < (int) (avail / chunkSize); i++)
	{
		void * allocated = mapped.AllocateSpace(chunkSize);
		ASSERT_VALID_POINTER(allocated, chunkSize);

		int newAvail = mapped.GetAvailableSpace();
		// there shouldn't be any lost space between allocations
		ASSERT(newAvail == (int) (avail - chunkSize));
		ASSERT(allocated == start);

		start = OffsetPointer<void, void>(allocated, chunkSize);
		avail = newAvail;
	}

	/*
	 * dump memory info and leak info
	 */
	//cout << "****** memory state ******" << endl;
#ifdef _DEBUG
	_CrtMemState state;
	_CrtMemCheckpoint(&state);
	_CrtMemDumpStatistics(&state);

	//cout << "****** memory leaks ******" << endl;
	if (_CrtDumpMemoryLeaks())
		cout << "Memory leak(s) found" << endl;
	else
		cout << "No memory leak(s) found" << endl;
#endif // _DEBUG
}



int main (int argc, char * argv[])
{
	if (argc > 1 && 0 == strcmp(argv[1], "-auto"))
	{
		AutoTest();
		return 0;
	}

	DynamicTest();

#if 0
	MappedViewHandle view;
	DWORD err = view.Open("d:\\scratch\\testview.bin", "testview",
												1024 * 1024);
	if (err == NO_ERROR)
	{
		cout << "view opened" << endl;
	}
	else
	{
		cout << "open failed " << hex << err << dec << endl;
	}
#endif

	return 0;
}
