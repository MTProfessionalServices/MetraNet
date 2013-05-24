/**************************************************************************
* Copyright 1997-2000 by MetraTech
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
* $Header$
* 
***************************************************************************/


#include <mtcom.h>
#include <metra.h>
#include <dirwatch.h>
#include <iostream>
#include <stdutils.h>

using std::cout;
using std::endl;

#define INITIAL_START_SIZE 10

using namespace std;

// statics
//OVERLAPPED MTDirWatch::mOverlapped;
NTThreadLock MTDirWatch::mLock;
//FILE_NOTIFY_INFORMATION* MTDirWatch::pNotificationArray = NULL;

// ----------------------------------------------------------------
// Name:     	MTDirWatch constructor
// Arguments:     <aString> - Directory to watch
// ----------------------------------------------------------------

MTDirWatch::MTDirWatch() : 	mWatchDir(""),
	bWatchSubdir(false),
	mFilters(FILE_NOTIFY_CHANGE_FILE_NAME | FILE_NOTIFY_CHANGE_DIR_NAME | 
	FILE_NOTIFY_CHANGE_SIZE | FILE_NOTIFY_CHANGE_LAST_WRITE),
	mhDirectory(0),
	pNotificationArray(NULL),
	mSig('RDTM'),
	mpOverlapped(NULL)
{

}


// ----------------------------------------------------------------
// Name:     	MTDirWatch dtor
// ----------------------------------------------------------------

MTDirWatch::~MTDirWatch()
{
	{
		AutoCriticalSection aLock(&mLock);

		::CloseHandle(mhDirectory);
		delete[] pNotificationArray;
		pNotificationArray = NULL;
	}

	MTWatchIterator it = mMap.begin();
	while(it != mMap.end()) {
		delete (*it).second;
		it++;
	}
	delete mpOverlapped;

}

// ----------------------------------------------------------------
// Name:     	ApcRoutine
// Arguments:     <dwErrorCode> - Error code
//                <dwNumberOfBytesTransfered> - bytes transfered
//								<lpOverlapped>	- Overlapped structure necessary for Async IO
// Description:   ApcRoutine is a callback specified by ReadDirectoryChangesW.  It is called by
// the system whenever the system notices a change in a directory
// ----------------------------------------------------------------

void CALLBACK MTDirWatch::ApcRoutine(
	DWORD dwErrorCode,                // completion code
  DWORD dwNumberOfBytesTransfered,  // number of bytes transferred
  LPOVERLAPPED lpOverlapped)         // I/O information buffer
{
	// return if nothing was read
	MTDirWatch* pThis = reinterpret_cast<MTDirWatch*>(lpOverlapped->hEvent);

	if(dwNumberOfBytesTransfered != 0) {

		unsigned int offset = 0;
		FILE_NOTIFY_INFORMATION* fpInfo;
		// step 1: get the list of files 
		void* pBegin = pThis->pNotificationArray;
		if(pThis && pThis->CheckSig()) {

			AutoCriticalSection aLock(&MTDirWatch::mLock);

			for(int i=0;;i++) {
				fpInfo = (FILE_NOTIFY_INFORMATION*)((unsigned long)pBegin + offset);

				long aLength = fpInfo->FileNameLength;
				mtwstring aWideStr;
				aWideStr.assign(fpInfo->FileName,aLength >> 1);
				mtstring aTemp = aWideStr;

				// evaluate call backs
				vector<mtstring> aDirList;

				pThis->Tokenize(aDirList,aTemp);
				
				// this will call find() n number of times for each path to see if there
				// is a match.
				pThis->ExecuteAllByVector(aDirList,aTemp,fpInfo->Action);
				
				if(fpInfo->NextEntryOffset == 0) {
					break;
				}
				else {
					offset += fpInfo->NextEntryOffset;
				}
			}
		}
	}
	delete lpOverlapped;
	pThis->mpOverlapped = NULL;
}

// ----------------------------------------------------------------
// Name:     	Tokenize
// Arguments:     <aTokenizedList> - The target vector for the tokenized string
//                <aStr> - <the string to tokenize>
// Description:   Populates aToeknizedList with the contents of aStr
// seperated by the WIN32 directory seperator character ("\\")
// ----------------------------------------------------------------

void MTDirWatch::Tokenize(vector<mtstring>& aTokenizedList,mtstring& aStr)
{
	vector<mtstring>::size_type aCurrentPos = 0;
	vector<mtstring>::size_type aLoc;
	while((aLoc = aStr.find("\\",aCurrentPos)) != string::npos) {
		string& aSubStr = aStr.substr(aCurrentPos,aLoc-aCurrentPos);
		aTokenizedList.push_back(aSubStr);
		aCurrentPos = aLoc + 1;
	}
	string& aSubStr = aStr.substr(aCurrentPos,aStr.length()-aCurrentPos);
	aTokenizedList.push_back(aSubStr);
}

// ----------------------------------------------------------------
// Name:     	ExecuteAllByVector
// Arguments:     <aaTokenizedList> - list of a files
//                <aArg> - file that changed
//								<aAction> -  action that occured on the file
// Description:   Exeute all the actions in the vector
// ----------------------------------------------------------------

void MTDirWatch::ExecuteAllByVector(vector<mtstring>& aTokenizedList,mtstring& aArg,long aAction)
{
	string aStr("");

	for(unsigned int i=0;i<aTokenizedList.size();i++) {
		aStr += aTokenizedList[i];
	
		ProcessMapIter(mMap.find(aStr),aArg,aAction);

		aStr += "\\";
	}

}

// ----------------------------------------------------------------
// Name:     	ProcessMapIter
// Arguments:     <aIter> - The watch iterator
//                <aArg> - the file that has changed
//								<aAction> - The action that occured on the file (rename, new, etc)
// Description:   Calls the callback function give the current location of the iterator
// ----------------------------------------------------------------

void MTDirWatch::ProcessMapIter(MTWatchIterator& aIter,mtstring& aArg,long aAction)
{
	if(aIter != mMap.end()) {
		(*aIter).second->CallBackFunc(aArg,aAction);
	}
}




// ----------------------------------------------------------------
// Name:     	Init
// Return Value:  true on successfull initialization, false on not
// Description:   Constructs the directory handle and sets up the directory watch
// ----------------------------------------------------------------


bool MTDirWatch::Init()
{
	static const char* pFucName = " MTDirWatch::Init()";

	// Create directory file handle
	mhDirectory = CreateFile(mWatchDir.c_str(),
    FILE_LIST_DIRECTORY,
    FILE_SHARE_READ |
    FILE_SHARE_WRITE |
    FILE_SHARE_DELETE,
    NULL,
    OPEN_EXISTING,
    FILE_FLAG_BACKUP_SEMANTICS |
    FILE_FLAG_OVERLAPPED,
    NULL);

	if(mhDirectory != INVALID_HANDLE_VALUE) {
		return true;
	}

	SetError(::GetLastError(),ERROR_MODULE,ERROR_LINE,pFucName);
	return false;
}

// ----------------------------------------------------------------
// Name:     	RegisterNotification
// Return Value:  true if the ReadDirectoryChangesW API call was successful
// Description:   Constructs a wait handle on the specified directory.  This method
// must be called every time an event occurs.
// ----------------------------------------------------------------


bool MTDirWatch::RegisterNotification()
{
	static const char* pFucName = " MTDirWatch::RegisterNotification()";
	delete[] pNotificationArray;
	pNotificationArray = new FILE_NOTIFY_INFORMATION[INITIAL_START_SIZE];
	DWORD nBufferSize = sizeof(FILE_NOTIFY_INFORMATION) * INITIAL_START_SIZE;
	DWORD nBytesReturned;

	mpOverlapped = new OVERLAPPED;
	memset(mpOverlapped,0,sizeof(OVERLAPPED));
	mpOverlapped->hEvent = this;

	BOOL bRetVal = ReadDirectoryChangesW(
		mhDirectory,                                  // handle to directory
		pNotificationArray,                 // read results buffer
		nBufferSize,                                 // length of buffer
		bWatchSubdir,                                // monitoring option
		mFilters,                                    // filter conditions
		&nBytesReturned,                             // bytes returned
		mpOverlapped,							                   // overlapped buffer
		&ApcRoutine);																 // completion routine

	if(bRetVal) {
		return true;
	}
	SetError(::GetLastError(),ERROR_MODULE,ERROR_LINE,pFucName);
	return false;
}

// ----------------------------------------------------------------
// Name:     	AddCallBack
// Arguments:     <pCallBack> - the callback to fire
// Description:  Adds pCallback to the callback map
// ----------------------------------------------------------------


void MTDirWatch::AddCallBack(MTWatchCallBack* pCallBack)
{
	AutoCriticalSection aLock(&MTDirWatch::mLock);
	MTWatchPair aValue(pCallBack->GetString(),pCallBack);
	mMap.insert(aValue);
}
