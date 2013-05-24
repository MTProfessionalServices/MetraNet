/**************************************************************************
 * @doc
 * 
 * Copyright 200 by MetraTech
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
 * REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
 * WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
 * OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
 * INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
 * RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech, and USER
 * agrees to preserve the same.
 *
 * Created by: Carl Shimer
 * $Header$
 *
 * 
 *
 ***************************************************************************/

#ifndef __HEAPWATCH_H__
#define __HEAPWATCH_H__
#pragma once

class MTHeapDetector {

public:
	MTHeapDetector() {}
	~MTHeapDetector() {}
	bool CheckHeap();

};

class AutoHeapLock {
	
	AutoHeapLock(HANDLE aHandle) : mHandle(aHandle)
	{
		::HeapLock(mHandle);
	}
	~AutoHeapLock()
	{
		::HeapUnlock(mHandle);
	}


protected:
	HANDLE mHandle;
};

#define MAX_HEAPS 256

bool MTHeapDetector::CheckHeap() 
{
	const char* pFuncName = "MTHeapDetector::CheckHeap";

	HANDLE hProcessHeap = ::GetProcessHeap();


	HANDLE aHeapArray[MAX_HEAPS];
	long aNumHeaps = GetProcessHeaps(MAX_HEAPS,aHeapArray);

	if(aNumHeaps > MAX_HEAPS) {
		// stop for lack of something better to do
		::DebugBreak();
	}

	for(int i=0;i<aNumHeaps;i++) {
		if(!HeapValidate(aHeapArray[i],0,NULL) != 0) {
			::DebugBreak();
			return false;
		}
	}
	return true;

	/*
	// step 1: lock the heap
	AutoHeapLock aHeapLock;
	PROCESS_HEAP_ENTRY aHeapEntry;
	aHeapEntry.lpData = NULL;

	// step 2: enumerate through the heap
	while(HeapWalk(hProcessHeap,&aHeapEntry) != 0) {

		// step 3: validate the heap pointer


	}

	long aError = ::GetLastError();
	if(aError == ERROR_NO_MORE_ITEMS) {
		return true;
	}
	else {
		SetError(aError,ERROR_MODULE, ERROR_LINE, pFuncName,"failure during heap enumerations");	
		return false;
	}
	*/
}



#endif //__HEAPWATCH_H__