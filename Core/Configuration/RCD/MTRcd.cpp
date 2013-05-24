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

#include "StdAfx.h"
#include <metra.h>
#include "RCD.h"
#include "MTRcd.h"
#include <ConfigDir.h>
#include <autocritical.h>
#include <errobj.h>
#include <mttime.h>

// MTWatchThread object

// disable silly bool conversion warning
#pragma warning(disable : 4800)

using namespace std;


// ----------------------------------------------------------------
// Name:     	MTWatchThread constructor
// Description:   creates a couple of events for thread notification
// ----------------------------------------------------------------

MTWatchThread::MTWatchThread() : mBaseWatchDir("")
{

	mhEvent = CreateEvent(NULL,FALSE,FALSE,NULL);
	if(mhEvent == NULL) {
		throw ErrorObject(::GetLastError(),__FILE__,__LINE__,"MTWatchThread::MTWatchThread");
	}
	mStartEvent = CreateEvent(NULL,FALSE,FALSE,NULL);
	if(mStartEvent == NULL) {
		throw ErrorObject(::GetLastError(),__FILE__,__LINE__,"MTWatchThread::MTWatchThread");
		
	}
}

void MTWatchThread::WaitForThreadStartup()
{
	if(::WaitForSingleObject(mStartEvent,INFINITE) != WAIT_OBJECT_0) {
		throw ErrorObject(::GetLastError(),__FILE__,__LINE__,"MTWatchThread::WaitForThreadStartup");
	}
}


// ----------------------------------------------------------------
// Name:     	TerminateThread
// Description:   sets an event which should terminate that watch thread
// ----------------------------------------------------------------

void MTWatchThread::TerminateThread()
{
	::SetEvent(mhEvent);
	WaitForThread(INFINITE);
}

// ----------------------------------------------------------------
// Name:     	TerminateThread
// arguments:		<aWatch> add a callback to the watch list
// Description:   Adds a callback to the watch list.  This callback will
// be fired by theh dirwatch thread if a file changes that matches the query
// ----------------------------------------------------------------

void  MTWatchThread::AddWatchCallBack(MTWatchCallBack* aWatch)
{
	mDirWatch.AddCallBack(aWatch);
}



// ----------------------------------------------------------------
// Name:     	MTWatchThread destructor
// Description:   Terminates the thread and closes the NT event handles
// ----------------------------------------------------------------

MTWatchThread::~MTWatchThread()
{
	TerminateThread();
	::CloseHandle(mhEvent);
	::CloseHandle(mStartEvent);
}

// ----------------------------------------------------------------
// Name:     	ThreadMain
// Errors Raised: <error number> - <error description>
// Description:   This is the thread main function that watches the extension
// directory structure.  Notice that it does not look like anything happens in
// this thread besides queuing directory watch notifications with RegisterNotification() 
// and waiting for the results with ::WaitForSingleObject.  This is because NT queues a 
// APC on this thread that calls the dirwatch callback.  If a file changes in the
// directory we are watching the stack would look like this:
//
// NTDLL:CreateThread (or whatever it really is)
// MTWatchThread::ThreadMain
// MTDirWatch::ApcRoutine
// ----------------------------------------------------------------

int MTWatchThread::ThreadMain()
{
	bool bDone = false;
	long aRetVal;
	bool bFirstTimeThrough = true;

	mDirWatch.WatchSubDirectories(true);
	mDirWatch.Init();
	
	while(!bDone) {
		if(!mDirWatch.RegisterNotification()) {
			// XXX log error
			bDone = false;
		}
		if(bFirstTimeThrough) {
			::SetEvent(mStartEvent);
			bFirstTimeThrough = false;
		}

		aRetVal = ::WaitForSingleObject(mhEvent,INFINITE);
		
		// if the return value is anything else than a message
		// that a file was changed, exit the thread
		if(aRetVal != WAIT_IO_COMPLETION) {
			// log message
			bDone = true;
		}
	}

	return bDone;
}



/////////////////////////////////////////////////////////////////////////////
// CMTRcd

STDMETHODIMP CMTRcd::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTRcd
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

// ----------------------------------------------------------------
// Name:     	CMTRcd destructor
// Description:   Destroys the CMTRcd object.  It terminates the watch thread and empties 
// mExtensionList vector
// ----------------------------------------------------------------

CMTRcd::~CMTRcd()
{
	mExtensionList.erase(mExtensionList.begin(),mExtensionList.end());
	mExtensionListFullPath.erase(mExtensionListFullPath.begin(),mExtensionListFullPath.end());
}	


// ----------------------------------------------------------------
// Name:     	get_ExtensionDir
// Arguments:     <pVal> - The returned extension directory
// Return Value:  E_POINTER,S_OK  
// Description:   Returns the extension directory
// ----------------------------------------------------------------


STDMETHODIMP CMTRcd::get_ExtensionDir(BSTR *pVal)
{
	ASSERT(pVal);
	if(!pVal) return E_POINTER;
	*pVal = mExtensionDir.copy();
	return S_OK;
}


// ----------------------------------------------------------------
// Name:     	put_ExtensionDir
// Arguments:     <newVal> - extension dir
// Return Value:  E_POINTER,S_OK    
// Description:   Sets the extension directory
// ----------------------------------------------------------------


STDMETHODIMP CMTRcd::put_ExtensionDir(BSTR newVal)
{
	ASSERT(newVal);
	if(!newVal) return E_POINTER;
	mExtensionDir = newVal;
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	FinalConstruct
// Return Value:  S_OK  
// Description:   Initializes the RCD object.  This includes finding
// all the extension folders and spinning up the directory watch thread.
// ----------------------------------------------------------------


STDMETHODIMP CMTRcd::FinalConstruct()
{
	// if init has allready been called simply return
	if(mbInit) return S_OK;

	static const char* FunctionName = "CMTRcd::FinalConstruct";

	// default the extensions directory to installdir + "extensions
	if(mExtensionDir.length() == 0) {
		std::string aExtensionDir;

		if(GetExtensionsDir(aExtensionDir)) {
			mExtensionDir = (const char*)	aExtensionDir.c_str();
		}
		else {
			return Error("CMTRcd::Init: failed to find extensions directory");
		}
	}

	// step 2: spin up the directory watch thread
	string aStr((const char*)mExtensionDir);

	// init is successfull
	mbInit = true;
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	Init
// Return Value:  S_OK  
// Description:   This method is deprecated for FinalConstruct
// ----------------------------------------------------------------


STDMETHODIMP CMTRcd::Init()
{
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	RunQuery
// Arguments:     <query> - what files (or kind of files) to return.  can be an absolute
//													file or a wildcard
//                <bRecurse> - to recurse through the directory hierarchy or not
//								<ppFileList> - the returned file list
// Return Value:  E_POINTER,S_OK
// Description:  Iterates through the extension folder looking for matches.  Matches
// are stored in the ppFileList interface pointer.
// ----------------------------------------------------------------

STDMETHODIMP CMTRcd::RunQuery(BSTR query, VARIANT_BOOL bRecurse, IMTRcdFileList **ppFileList)
{
	ASSERT(query && ppFileList);
	if(!(query && ppFileList)) return E_POINTER;

	// step 1: create a MTRcdFileList object
	CComObject<CMTRcdFileList>* pFileList;
	HRESULT hr = CComObject<CMTRcdFileList>::CreateInstance(&pFileList);
	ASSERT (SUCCEEDED(hr));

  mtstring strQuery = (const char *)_bstr_t(query);

  //Replace foreslashes with backslashes
  static const basic_string <char>::size_type npos = -1;
  basic_string <char>::size_type index;

  index = strQuery.find("/");

  while(index != npos) {
    strQuery.replace(index, 1, "\\");
    index = strQuery.find("/");
  }
  

	bool bRecurseInternal = bRecurse == VARIANT_TRUE ? true : false;

	// step 2: populate it
	FindExtensionFolders(mExtensionList);
	GetFilesByQuery(mtstring((const char*)mExtensionDir),
		strQuery,
		bRecurseInternal,
		pFileList->GetFileList());

	// step 3: return the object

	hr = pFileList->QueryInterface(IID_IMTRcdFileList,(void**)ppFileList);
	return hr;
}

// ----------------------------------------------------------------
// Name:     	RegisterCallBack
// Arguments:     <query> - The query to watch for
//                <pHook> - The hook to execute
//								<vHookArg> - an argument to the hook
// Return Value:  S_OK
// Description:   Constructs the directory handle and sets up the directory watch
// ----------------------------------------------------------------

STDMETHODIMP CMTRcd::RegisterCallBack(BSTR query, IUnknown *pHook, VARIANT vHookArg)
{
  return E_NOTIMPL;
}

// ----------------------------------------------------------------
// Name:     	get_ExtensionList
// Arguments:     <pVal> - The pointer to the File list
// Return Value:  S_OK, E_POINTER
// Description:   Constructs the directory handle and sets up the directory watch
// ----------------------------------------------------------------

STDMETHODIMP CMTRcd::get_ExtensionList(IMTRcdFileList **pVal)
{
	AutoCriticalSection aAutoLock(&mExtensionListLock);

	FindExtensionFolders(mExtensionList);
	return GetExtensionListInternal(mExtensionList,pVal);
}


// ----------------------------------------------------------------
// Name:     	RunQueryInAlternateFolder
// Arguments:     <query> - The query to run in the alternate folder
//								<bRecurse> - Recurse through the folders
//								<AlternateFolder> - The alternate folder we are using.  This is an absolute path
//								<pPFileList> - The File list we are returning
// Return Value:  S_OK, E_POINTER
// Description:   The same as RunQuery except we use an alternate folder
// ----------------------------------------------------------------


STDMETHODIMP CMTRcd::RunQueryInAlternateFolder(BSTR query, VARIANT_BOOL bRecurse, BSTR AlternateFolder, IMTRcdFileList **ppFileList)
{
	bool bTest = query && AlternateFolder && ppFileList;
	ASSERT(bTest);
	if(!bTest) return E_POINTER;
	// TODO: Add your implementation code here

		// step 1: create a MTRcdFileList object
	CComObject<CMTRcdFileList>* pFileList;
	HRESULT hr = CComObject<CMTRcdFileList>::CreateInstance(&pFileList);
	ASSERT (SUCCEEDED(hr));

	mtstring aAlternate = (const char*)_bstr_t(AlternateFolder);
  
  //Replace foreslashes with backslashes
  mtstring strQuery = (const char *)_bstr_t(query);

  //Replace foreslashes with backslashes
  static const basic_string <char>::size_type npos = -1;
  basic_string <char>::size_type index;

  index = strQuery.find("/");

  while(index != npos) {
    strQuery.replace(index, 1, "\\");
    index = strQuery.find("/");
  }

	// tokenize the query
	vector<mtstring> aVector;
	mtstring aExtensionQuery;
	Tokenize<vector<mtstring> >(aVector,strQuery);

	if(aVector.size() != 0) {
		vector<mtstring>::iterator it = aVector.begin();
		while(it != aVector.end()-1) {
			aAlternate += DIR_SEP;
			aAlternate += *it;
			it++;
		}
		aExtensionQuery = *it;
	}
	else {
		aExtensionQuery = strQuery;
	}

	bool bRecurseInternal = bRecurse == VARIANT_TRUE ? true : false;

	GetFilesbyQueryInExtension(aAlternate,aExtensionQuery,bRecurseInternal,pFileList->GetFileList());

	hr = pFileList->QueryInterface(IID_IMTRcdFileList,(void**)ppFileList);
	return hr;

	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	get_ExtensionListWithPath
// Arguments:     <ppFileList> - the returned list of extensions with full path name
// Return Value:  S_OK, E_POINTER, E_FAIL
// Description:   The same as get_ExtensionList but return each argument with the full path
// ----------------------------------------------------------------

STDMETHODIMP CMTRcd::get_ExtensionListWithPath(IMTRcdFileList** ppFileList)
{
	AutoCriticalSection aAutoLock(&mExtensionListLock);

	FindExtensionFolders(mExtensionListFullPath,true);
	return GetExtensionListInternal(mExtensionListFullPath,ppFileList);
}

// ----------------------------------------------------------------
// Name:     	get_InstallDir
// Arguments:     <query> - The query to run in the alternate folder
//								<bRecurse> - Recurse through the folders
//								<AlternateFolder> - The alternate folder we are using.  This is an absolute path
//								<pPFileList> - The File list we are returning
// Return Value:  S_OK, E_POINTER
// Description:   The same as RunQuery except we use an alternate folder
// ----------------------------------------------------------------

STDMETHODIMP CMTRcd::get_InstallDir(BSTR* pVal)
{
	ASSERT(pVal);
	if(!pVal) return E_POINTER;

	std::string aInstallDir;
	if(GetMTInstallDir(aInstallDir)) {
		_bstr_t aTemp((const char*)aInstallDir.c_str());
		*pVal = aTemp.copy();
		return S_OK;
	}
	else {
		*pVal = NULL;
		return E_FAIL;
	}
}


STDMETHODIMP CMTRcd::get_ConfigDir(BSTR *pVal)
{
	ASSERT(pVal);
	if(!pVal) return E_POINTER;
	std::string aConfigDir;
	if(GetMTConfigDir(aConfigDir)) {
		_bstr_t aTemp((const char*)aConfigDir.c_str());
		*pVal = aTemp.copy();
		return S_OK;
	}
	else {
		*pVal = NULL;
		return E_FAIL;
	}
}


///////////////////////////////////////////////////////////////////////////////
// Non COM methods
//
///////////////////////////////////////////////////////////////////////////////

// ----------------------------------------------------------------
// Name:     	FindExtensionFolders
// Description:   Builds a list of the top level extension folders
// in mExtensionDir
// ----------------------------------------------------------------

void CMTRcd::FindExtensionFolders(std::vector<string>& aVec,bool bFullPath)
{
	AutoCriticalSection aAutoLock(&mExtensionListLock);
	aVec.clear();

	WIN32_FIND_DATAA aFindData;
	mtstring adirQuery = mExtensionDir + "\\*.*";
	HANDLE hFind = ::FindFirstFileA(adirQuery,&aFindData);

	if(hFind != INVALID_HANDLE_VALUE) {
		do {

			if(strcmp(aFindData.cFileName,".") != 0 && 
				strcmp(aFindData.cFileName,"..") != 0 && 
				(aFindData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) > 0) {

				if(bFullPath) {
					string szTemp = mExtensionDir;
					szTemp += DIR_SEP;
					szTemp += aFindData.cFileName;
					aVec.push_back(szTemp);
				}
				else {

					aVec.push_back(string(aFindData.cFileName));
				}
			}
		}while(::FindNextFileA(hFind,&aFindData));
	}
	::FindClose(hFind);

}

// ----------------------------------------------------------------
// Name:     	GetFilesByQuery
// Arguments:     <seed> - The starting directory
//                <aQuery> - The query of the files to find
//								<bRecurse> - Whether recursing or not
//								<aFileList> - The list of found files
// Description:   GetFilesByQuery is a recursive function which searches a directory
// hierarchy for a files that match the query string.  Results are stored in aFileList
// ----------------------------------------------------------------

void CMTRcd::GetFilesByQuery(const mtstring& seed,
														 const mtstring& aQuery,
														 BOOL bRecurse,
														 RcdFileList& aFileList)
{
	AutoCriticalSection aAutoLock(&mExtensionListLock);

	vector<string>::iterator aExtensionIter = mExtensionList.begin();
	mtstring aExtensionQuery;

	// iterate through all the extensions
	while(aExtensionIter != mExtensionList.end()) {
		mtstring szExtensionPath = seed;
		szExtensionPath += DIR_SEP;
		szExtensionPath += *aExtensionIter;

		// if aQuery contains a path, we must decompose this path and append it
		// to szExtensionPath
		vector<mtstring> aVector;
		Tokenize<vector<mtstring> >(aVector,aQuery);

		if(aVector.size() != 0) {
			vector<mtstring>::iterator it = aVector.begin();
			while(it != aVector.end()-1) {
				szExtensionPath += DIR_SEP;
				szExtensionPath += *it;
				it++;
			}
			aExtensionQuery = *it;
		}
		else {
			aExtensionQuery = aQuery;
		}

		GetFilesbyQueryInExtension(szExtensionPath,aExtensionQuery,bRecurse,aFileList);
		// increment our extension list iterator
		aExtensionIter++;
	}

}

// ----------------------------------------------------------------
// Name:     	GetFilesbyQueryInExtension
// Arguments:     <seed> - The starting directory
//                <aQuery> - The query of the files to find
//								<bRecurse> - Whether recursing or not
//								<aFileList> - The list of found files
// Description:   GetFilesbyQueryInExtension is a recursive function which searches a particular extensions
// for a files that match the query string.  Results are stored in aFileList
// ----------------------------------------------------------------

void CMTRcd::GetFilesbyQueryInExtension(const mtstring& seed,const mtstring& aQuery,bool bRecurse,RcdFileList& aFileList)
{
	WIN32_FIND_DATAA aFindData;
	static const mtstring gAllFiles("*.*");
	mtstring szFullPath = seed + DIR_SEP;

	// step 1: construct the full path
	if(bRecurse) {
		GetFilesbyQueryInExtension(seed,aQuery,false,aFileList);
		szFullPath += gAllFiles; 
	}
	else {
		szFullPath += aQuery;
	}


	HANDLE hFind = ::FindFirstFileA(szFullPath,&aFindData);

	if(hFind != INVALID_HANDLE_VALUE) {
		do {
			if(strcmp(aFindData.cFileName,".") != 0 && 
			strcmp(aFindData.cFileName,"..") != 0) {
				if(bRecurse) {
					if((aFindData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) > 0) {
						mtstring aFullPath = seed + DIR_SEP;
						aFullPath += aFindData.cFileName;
						GetFilesbyQueryInExtension(aFullPath,aQuery,true,aFileList);
					}
				}
				else {
					string aFullFileName = seed;
					aFullFileName += DIR_SEP;
					aFullFileName += aFindData.cFileName;
					aFileList.push_back(aFullFileName);
				}
			}
		}while(::FindNextFileA(hFind,&aFindData));

		::FindClose(hFind);
	}
}

// ----------------------------------------------------------------
// Name:     	GetExtensionListInternal
// Arguments:     <aExtensionList> - the list to use
//                <pVal> - the interface pointer to use
// Description:   creates and populates a IMTRcdFileList object based on the list
// ----------------------------------------------------------------

HRESULT  CMTRcd::GetExtensionListInternal(vector<string>& aExtensionList,IMTRcdFileList **pVal)
{

	ASSERT(pVal);
	if(!pVal) return E_POINTER;

	AutoCriticalSection aAutoLock(&mExtensionListLock);

	// step 1: construct a IMTRcdFileList object
	CComObject<CMTRcdFileList>* pFileList;
	HRESULT hr = CComObject<CMTRcdFileList>::CreateInstance(&pFileList);

	// step 2: populate with the contents of mExtensionList vector
	pFileList->SetFileList(aExtensionList);

	// step 3: addref and return
	hr = pFileList->QueryInterface(IID_IMTRcdFileList,(void**)pVal);
	return hr;
}

HRESULT CMTRcd::get_ErrorMessage(VARIANT aErrorCode,BSTR *pVal)
{
	ASSERT(pVal);
	if(!pVal) return E_POINTER;

	long errorCode;
	try {
		errorCode = ErrorCodeFromVariant(_variant_t(aErrorCode));
	}
	catch(_com_error&) {
		// hmm.... probably a bad type conversion
		return Error("Error converting variant type");

	}

	
	wstring astr_message;
	Message aMessage(errorCode);
	aMessage.GetErrorMessage(astr_message);
	_bstr_t aReturnErrorStr = astr_message.c_str();
	*pVal = aReturnErrorStr.copy();
	return S_OK;
}

HRESULT CMTRcd::get_ErrorAsLong(VARIANT aErrorCode,long* pVal)
{
	try {
		*pVal = ErrorCodeFromVariant(_variant_t(aErrorCode));
		return S_OK;
	}
	catch(_com_error&) {
		// hmm.... probably a bad type conversion
		return Error("Error converting variant type");

	}
}

long CMTRcd::ErrorCodeFromVariant(_variant_t& vtVal)
{
	long errorCode;

	switch(vtVal.vt) {
		case VT_I2:
		case VT_I4:
		case VT_UI4:
		case VT_I8:
		case VT_UI8:
			errorCode = vtVal; break;
		case VT_DECIMAL:
			errorCode = vtVal; break;
		case VT_BSTR:
			{
		  char* pStopStr;
			unsigned long val = strtoul((const char*)_bstr_t(vtVal),&pStopStr,16);
			errorCode = (long)val;
			}
			break;
		default:
			_com_issue_errorex(E_FAIL, (IMTRcd*)this, __uuidof((IMTRcd*)this));
	}
	return errorCode;
}

HRESULT CMTRcd::AddErrorResourceLibrary(BSTR filename)
{
	ASSERT(filename);
	if(!filename) return E_POINTER;

	// add resource dll
	if(!Message::AddModule(_bstr_t(filename))) {
		long aErrorCode = ::GetLastError();
		char buff[100];
		sprintf(buff,"Error adding resource library: %d",aErrorCode);
		return Error(buff);
	}
	return S_OK;
}	



STDMETHODIMP CMTRcd::GetUTCDate(DATE *pRetVal)
{
  ASSERT(pRetVal);
  if(!pRetVal) return E_POINTER;

  *pRetVal= GetMTOLETime();
	return S_OK;
}

STDMETHODIMP CMTRcd::GetMinDate(DATE *pRetVal)
{
  ASSERT(pRetVal);
  if(!pRetVal) return E_POINTER;

  *pRetVal = getMinMTOLETime();
	return S_OK;
}

STDMETHODIMP CMTRcd::GetMaxDate(DATE *pRetVal)
{
  ASSERT(pRetVal);
  if(!pRetVal) return E_POINTER;

  *pRetVal = GetMaxMTOLETime();
	return S_OK;
}

STDMETHODIMP CMTRcd::GetExtensionFromPath(BSTR aPath, BSTR *pExtension)
{
	ASSERT(aPath && pExtension);
	if(!aPath || !pExtension)
		return E_POINTER;

  string extensionDir = (char *) mExtensionDir;
	string path = (char *) _bstr_t(aPath); 
	
	if (path.find(extensionDir) == string::npos)
	{
		*pExtension = NULL;
		return Error("Path must lead to the extension directory");
	}

	size_t start = extensionDir.length() + 1;
	size_t end = path.find_first_of('\\', start);
	if (end == string::npos)
		end = 0;

	string extension = path.substr(start, end - start);
	
	_bstr_t aTemp((const char*) extension.c_str());
	*pExtension = aTemp.copy();
	return S_OK;
}
