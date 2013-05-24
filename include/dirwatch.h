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

#ifndef __DIRWATCH_H__
#define __DIRWATCH_H__


#include <errobj.h>
#include <string>
#include <map>
#include <vector>
#include <autocritical.h>
#include <stdutils.h>

//using namespace std;


// ----------------------------------------------------------------
//
// ----------------------------------------------------------------
class MTWatchCallBack {
public:
	
	MTWatchCallBack(mtstring& aFileWatch) : mString(aFileWatch) {}
	virtual ~MTWatchCallBack() {}
	mtstring& GetString() { return mString; }

public: // abstract methods
	virtual void CallBackFunc(mtstring& aFullFile,long aActionType) = 0;


protected:
	mtstring mString;
};


typedef std::map<string,MTWatchCallBack*> MTWatchMap;
typedef std::pair<string,MTWatchCallBack*> MTWatchPair;
typedef MTWatchMap::iterator MTWatchIterator;

// ----------------------------------------------------------------
//
// ----------------------------------------------------------------

class MTDirWatch : public ObjectWithError
{
public:
	//MTDirWatch(const char* pString) : MTDirWatch(string(pString)) {}
	MTDirWatch();
	virtual ~MTDirWatch();

public: //properties
	void WatchSubDirectories(bool bArg) { bWatchSubdir = bArg; }
	void Filters(DWORD arg) { mFilters = arg; }
	void SetWatchDir(const string& aString) { mWatchDir = aString; };

public: // callbacks
	static void CALLBACK ApcRoutine(
	DWORD dwErrorCode,                // completion code
  DWORD dwNumberOfBytesTransfered,  // number of bytes transferred
  LPOVERLAPPED lpOverlapped);         // I/O information buffer

public: //methods

	bool Init();
	bool RegisterNotification();
	void AddCallBack(MTWatchCallBack*);

protected: //methods
	
	void Tokenize(std::vector<mtstring>&,mtstring&);
	void ExecuteAllByVector(std::vector<mtstring>&,mtstring&,long);
	void ProcessMapIter(MTWatchIterator&,mtstring&,long);
			

protected:
	// data
	string mWatchDir;
	bool bWatchSubdir;
	DWORD mFilters;
	HANDLE mhDirectory;

private: // methods
	bool CheckSig() { return mSig == 'RDTM'; }
	
private:
	long mSig;
	FILE_NOTIFY_INFORMATION* pNotificationArray;
	OVERLAPPED* mpOverlapped;
	static NTThreadLock mLock;
	MTWatchMap mMap;

};



#endif //__DIRWATCH_H__