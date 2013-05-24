/**************************************************************************
 * @doc NTLOGSERVER
 * 
 * @module LogServer class |
 *
 * This class is writes data out to the MetraTech file log.
 * 
 * Copyright 1998 by MetraTech
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
 * REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
 * WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
 * OR THAT THE USE OF THE LICENSED SOFTWARE OR DOCUMENTATION WILL NOT
 * INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
 * RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech, and USER
 * agrees to preserve the same.
 *
 * Created by: Kevin Fitzgerald
 * $Header$
 *
 * @index | NTLOGSERVER
 ***************************************************************************/

#include <metra.h>
#include <mtcom.h>
#include <time.h>
#include <io.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <NTLogServer.h>
#include <mtglobal_msg.h>
#include <loggerconfig.h>
#include <mtprogids.h>
#include <EasySocket.h>
#include <ConfigDir.h>
#include <autocritical.h>
#include <MTMSIXUnicodeConversion.h>
#include <mttime.h>
#include <tchar.h>
#include <iostream>
#include <perf.h>
#include <hostname.h>
#include <vector>
#include <direct.h>

using namespace std;

// TODO Add backwards capability to config file
// TODO Add inheritence for config file settings
// TODO Add dateformat for logging to config file settings

// static definition ...
NTLogServer * NTLogServer::mpsLogServer = 0;
DWORD NTLogServer::msNumRefs = 0 ;
NTThreadLock NTLogServer::msLock ;
unsigned int MAX_LOG_SIZE_BYTES = 52428800; // 50MBytes

#define DEFAULT_LOG_FILE_DATE_FORMAT "%m/%d/%y %H:%M:%S "
#define REMOTE_LOGGING_DATE_FORMAT "%b %#d %H:%M:%S " //Syslog format is "Aug 2 13:49:02"

//Use this define to display log performance information to stdout per 1000 requests
//#define LOG_PERFORMANCE
#define ENABLE_SOCKETS

#define ROLLOVER_EVENT_NAME L"MTLogFileRollOverInProgress"

// import the propset library ...
#import <MTConfigLib.tlb>
using namespace MTConfigLib;

unsigned int IntHash (const int &arID)
{
  int nHashID ;

  nHashID = arID ;

  return nHashID ;
}



//
//	@mfunc
//	Constructor. Initialize the data members.
//  @rdesc 
//  No return value.
// 
NTLogServer::NTLogServer()
: mQEvent(NULL), mRolloverEvent(NULL), mFileListNum(1), 
mOkToLogData(TRUE), mObserverInitialized(FALSE), mpCachedInfo(NULL), mLogProcessName(TRUE)
{
}

//
//	@mfunc
//	Destructor.
//  @rdesc 
//  No return value
// 
NTLogServer::~NTLogServer()
{
  // The rollover event might be blocking threads
  // while rollover is happening.
  // We cannot reset the event since that would screw
  // up the process that is performing the rolover.
  // Just be patient and wait for the rollover to complete.

  // Stop listening for config change events
  if (mObserverInitialized)
    mObservable.StopThread(INFINITE);

  // stop the thread ...
  BOOL threadStopped = StopThread(0) ;

  // lock the mQLock ...
  mQLock.Lock() ;

	// delete our cached copy
	delete mpCachedInfo;

  // set the mOkToLogData ...
  mOkToLogData = FALSE ;
    
  // set the mQEvent ...
  BOOL bRetCode = ::SetEvent (mQEvent) ;
  if (bRetCode == FALSE)
  {
    bRetCode = FALSE ;
  }
  
  // unlock the mQLock ...
  mQLock.Unlock() ;

  // wait for the thread to stop ... before destructing the rest of objects 
  if (!threadStopped)
    WaitForThread(INFINITE) ;

  // close all the log files ...
  CloseLogFiles() ;

  // release the event ...
  if (mQEvent != NULL)
  {
    ::CloseHandle (mQEvent) ;
    mQEvent = NULL;
  }
  // release the event ...
  if (mRolloverEvent != NULL)
  {
    ::CloseHandle (mRolloverEvent) ;
    mRolloverEvent = NULL;
  }

  // clear the queue ...
  NTLogRequestCollIter iter;
  for(iter = mQueue.begin(); iter != mQueue.end(); iter++)
  {
    delete *iter;    
  }
  mQueue.clear() ;

}

//
//	@mfunc
//	Initialize the LogServer. Create an event for the signalling of 
//  insertions to the LogRequest queue. Read the logging configuration. 
//  Create the log file.
//	@parm The process tag that will be prepended to the log file.
//  @rdesc 
//  Returns TRUE on successful initialization. Otherwise, FALSE is returned.
// 
BOOL NTLogServer::Init()
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  DWORD nError=NO_ERROR ;
	SECURITY_DESCRIPTOR securityDescriptor;
	if (!InitializeSecurityDescriptor(&securityDescriptor, SECURITY_DESCRIPTOR_REVISION)
		|| !SetSecurityDescriptorDacl(&securityDescriptor, TRUE, (PACL)NULL, FALSE))
	{
		HRESULT err = HRESULT_FROM_WIN32(::GetLastError());
		return FALSE;
	}

	SECURITY_ATTRIBUTES securityAttributes;
	securityAttributes.nLength = sizeof(securityAttributes);
	securityAttributes.lpSecurityDescriptor = &securityDescriptor;
	securityAttributes.bInheritHandle = TRUE; 

  // create the rollover event (a manual reset event) ...
  mRolloverEvent = ::CreateEvent(&securityAttributes/* security*/, 
                                TRUE /* manual reset */, 
                                TRUE /* initial signalled state */, 
                                ROLLOVER_EVENT_NAME) ;
  if (mRolloverEvent == NULL)
  {
    nError = ::GetLastError() ;
    bRetCode = FALSE ;
  }

  // create the mQEvent (a manual reset event) ...
  if ( bRetCode )
  {
    mQEvent = ::CreateEvent(&securityAttributes, TRUE, FALSE, NULL) ;
    if (mQEvent == NULL)
    {
      nError = ::GetLastError() ;
      bRetCode = FALSE ;
    }
  }

  if ( bRetCode )
  {
    // start the Queue Drainer thread ...
    StartThread() ;
  }

  // if we havent initialized the observer yet ...
  if (bRetCode && mObserverInitialized == FALSE)
  {
    if (!mObservable.Init())
    {
      //mLogger.LogVarArgs (LOG_ERROR, "Init() failed. Unable to initialize Observer.") ;
      bRetCode = FALSE ;
    }
    else
    {    
      mObservable.AddObserver(*this);
      
      if (!mObservable.StartThread())
      {
        //mLogger.LogVarArgs (LOG_ERROR, "Init() failed. Unable to start Observer Thread.") ;
        bRetCode = FALSE ;
      }
      else
      {
        mObserverInitialized = TRUE ;
      }
    }
  }
	// make sure our cached copy is NULL!
	mpCachedInfo = NULL;

  // Get the process name
  TCHAR buffer[MAX_PATH];
  if (GetModuleFileName(NULL,buffer,MAX_PATH))
  {
    wstring FullPath(buffer);
    wstring ModuleName;
    
    //Strip out the path to get only the .exe name
    string::size_type pos=FullPath.find_last_of(_T("\\/"));
    if (pos==string::npos)
    {
      ModuleName=FullPath;
    }
    else
    {
      ModuleName = FullPath.substr(pos+1,FullPath.length()-pos);
    }
    
    //Strip out the .exe at the end
    pos=ModuleName.find_last_of(_T("."));
    if (pos!=string::npos)
    {
      ModuleName = ModuleName.substr(0,pos);
    }


   	char asciiBuffer[MAX_PATH];

    BOOL usedDefault;
	  char def = '?';
	  int ret = WideCharToMultiByte(
		  CP_ACP,            // code page
      0,            // performance and mapping flags
      ModuleName.c_str(),    // wide-character string
      ModuleName.length(),          // number of chars in string
      asciiBuffer,     // buffer for new string
      sizeof(asciiBuffer),          // size of buffer
      &def,     // default for unmappable chars
		  &usedDefault);  // set when default char used

    asciiBuffer[ret] = '\0';

    mProcessName ="[";
    mProcessName+=asciiBuffer;
    mProcessName+="]";
  }

  mLogProcessName = TRUE;

	try
	{
		IMetraTimeClientPtr timeClient(__uuidof(MetraTimeClient));
		mTimeClient = timeClient;
	}
	catch (_com_error &)
	{
		// if we can't initialize the time client, don't use it.
		mTimeClient = NULL;
	}

  return bRetCode ;
}

// add a request to the queue and signal the listening thread
// if necessary.
BOOL NTLogServer::AddRequest(NTLogRequest * pRequest)
{
	const int QUEUE_DEPTH = 15;

	BOOL signal = FALSE;
	BOOL bRetCode = TRUE;
	DWORD nError;
  ///////////////////////////////////////////////////
  // Entering Critical Section Code ... 
  ///////////////////////////////////////////////////
  // lock the mQLock ...
  mQLock.Lock() ;
  
  // if it's ok to log data ...
  if (mOkToLogData == TRUE)
  {
    // insert the LogRequest object on the end of the queue ...
    mQueue.push_back(pRequest) ;
    
    // set the mQEvent ...
		if (mQueue.size() >= QUEUE_DEPTH)
			signal = TRUE;
  }
  // we're not logging data anymore ... delete the request ...
  else
  {
    delete pRequest ;
    bRetCode = FALSE ;
  }
  
  // unlock the mQLock ...
  mQLock.Unlock() ;

	if (signal)
	{
		bRetCode = ::SetEvent (mQEvent) ;
		if (bRetCode == FALSE)
		{
			nError = ::GetLastError() ; 
			bRetCode = FALSE ;
		}
	}

  ///////////////////////////////////////////////////
  // Leaving Critical Section Code ... 
  ///////////////////////////////////////////////////
	return bRetCode;
}

//
//	@mfunc
//	Log data to the MetraTech log file. Allocate and initialize a new 
//  LogRequest object. Lock access to the LogRequest queue. Insert the new 
//  LogRequest object onto the queue. Set the event to indicate a new object
//  has been added to the queue. Unlock access to the LogRequest queue.
//	@parm The data to be logged.
//  @parm The log level
//  @rdesc 
//  Returns TRUE on success. Otherwise, FALSE is returned.
// 
BOOL NTLogServer::LogThis(const char *apData, const int &arFileID, 
                          const char *apAppTag, const MTLogLevel aLogLevel)
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  DWORD nError=NO_ERROR ;
  NTLogRequest *pRequest=0 ;

  // allocate a new LogRequest object ...
  pRequest = new NTLogRequest ;
  ASSERT (pRequest) ;
  if (pRequest == NULL)
  {
    bRetCode = FALSE ;
    return bRetCode ;
  }
  


  // initialize the new LogRequest object ...
	time_t mttime;
	if (TimeIsAdjusted())
		mttime = MTTime();
	else
		mttime = -1;


  string ApplicationTag(apAppTag);
  if (mLogProcessName)
    ApplicationTag=mProcessName+ApplicationTag;

  bRetCode = pRequest->Init(apData, arFileID, ApplicationTag.c_str(), aLogLevel, mttime) ;
  ASSERT (bRetCode) ;
  if ( !bRetCode )
  {
    delete pRequest;
    return bRetCode ;
  }
  else
		return AddRequest(pRequest);
}

//
//	@mfunc
//	Log data to the MetraTech log file. Allocate and initialize a new LogRequest object. 
//  Lock access to the LogRequest queue. Insert the new LogRequest object onto the queue. Set
//  the event to indicate a new object has been added to the queue. Unlock access to the
//  LogRequest queue.
//	@parm The data to be logged.
//  @parm The log level
//  @rdesc 
//  Returns TRUE on success. Otherwise, FALSE is returned.
// 
BOOL NTLogServer::LogThis(const wchar_t *apData, const int &arFileID, 
                          const char *apAppTag, const MTLogLevel aLogLevel)
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  DWORD nError=NO_ERROR ;
  NTLogRequest *pRequest ;

  // allocate a new LogRequest object ...
  pRequest = new NTLogRequest ;
  ASSERT (pRequest) ;
  if (pRequest == NULL)
  {
    bRetCode = FALSE ;
    return bRetCode ;
  }
  
  // initialize the new LogRequest object ...
	time_t mttime;
	if (TimeIsAdjusted())
		mttime = MTTime();
	else
		mttime = -1;

  string ApplicationTag(apAppTag);
  if (mLogProcessName)
    ApplicationTag=mProcessName+ApplicationTag;

  bRetCode = pRequest->Init(apData, arFileID, ApplicationTag.c_str(), aLogLevel, mttime) ;
  ASSERT (bRetCode) ;
  if ( !bRetCode )
  {
    delete pRequest;
    return bRetCode ;
  }
  else
		return AddRequest(pRequest);
}

//
//	@mfunc
//	Check to see if its ok to log at the specified log level.
//	@parm The log level
//	@parm File ID
//  @rdesc 
//  Returns TRUE if it's ok to log at the specified log level. Otherwise, FALSE is returned.
BOOL NTLogServer::IsOkToLog (const MTLogLevel aLogLevel, int aFileID)
{
	// find the file to log the data to ...
	AutoCriticalSection aLock(&mFileListLock);

	MTLogFileCollIter iter;
	iter = mFileList.find(aFileID);

	if (iter == mFileList.end())
	{
		// unknown file
		ASSERT(0);
		return FALSE;
	}

	NTLogFile * pLogFile = (*iter).second;

  // check to see if should log this message ... if the log level is greater than the 
  // current level do not log this ...
  if (aLogLevel > pLogFile->GetMinimumLogLevel())
  {
    return FALSE;
  }

  return TRUE ;
}


//
//	@mfunc
//	Get a pointer to the LogServer. 
//	@parm The process tag.
//  @rdesc 
//  Returns a pointer to the LogServer on success. Otherwise, NULL is returned.
//  @devnote
//  The first person to call this will initialize the LogServer.

NTLogServer * NTLogServer::GetInstance()
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  // enter the critical section ...
  msLock.Lock() ;

  // if we havent allocated a log server yet ... do it now ...
  if (mpsLogServer == 0)  
  {
    // allocate a log serverinstance ...
    mpsLogServer = new NTLogServer ;

    // call init ...
    bRetCode = mpsLogServer->Init() ;

    // if we werent initialized successfully ...
    if (bRetCode == FALSE)
    {
      delete mpsLogServer ;
      mpsLogServer = NULL ;
    }
  }

  // if we got a valid instance increment reference ...
  if (mpsLogServer != 0)
  {
    msNumRefs++ ;
  }
  // leave the critical section ...
  msLock.Unlock() ;

  // return mpsLogServer ...
  return mpsLogServer ;
}

//
//	@mfunc
//	Release a pointer to the LogServer
//  @rdesc 
//  No return value.
//
void NTLogServer::ReleaseInstance()
{
  // enter the critical section ...
  msLock.Lock() ;

  // decrement the reference counter ...
  if (mpsLogServer != 0)
  {
    msNumRefs-- ;
  }

  // if the number of references is 0 ... delete the collection 
  if (msNumRefs == 0)
  {
    delete mpsLogServer ;
    mpsLogServer = NULL ;
  }
	// a reference can be leaked in some situations w/ managed code (CR11595)
	// to guarentee that all requests are logged we'll flush all requests
	// to disk on each release if we are close to the last instance 
	else if (msNumRefs <= 2)
		mpsLogServer->Flush();

  // leave the critical section ...
  msLock.Unlock() ;
}


//
//	@mfunc
//	Empty the queue.
//  @rdesc 
//  The error code ...
//
BOOL NTLogServer::Rollover( BOOL bForceRolloverNow )
{
  int nError=NO_ERROR ;
  BOOL bRolloverRequired = FALSE;
  NTLogFile *pLogFile ;
  BOOL bOK = TRUE;

  // determine if rollover is required

  if ( bForceRolloverNow )
  {
    // caller is forcing a rollover regardless of file state
    bRolloverRequired = TRUE;
  }
  else
  {
    // check file state and see if any require rollover
	AutoCriticalSection aLock(&mFileListLock);
    MTLogFileCollIter iter ;

    for (iter = mFileList.begin(); iter != mFileList.end(); iter++)
    {
      // get the current element ...
      pLogFile = (*iter).second;
      bRolloverRequired = pLogFile->IsRolloverRequired();
      if ( bRolloverRequired )
        break;
    }
  }

  if ( bRolloverRequired )
  {
    // if rollover,  reset the event to block threads that write to log files
    ResetEvent(mRolloverEvent);

    // rollover log files
		{
			AutoCriticalSection aLock(&mFileListLock);
			MTLogFileCollIter iter ;
			for (iter = mFileList.begin(); iter != mFileList.end(); iter++)
			{
				// get the current element ...
				pLogFile = (*iter).second ;
				bOK = pLogFile->Rollover( bForceRolloverNow );
			}
		}

    // set the event to unblock threads that write to log files
    SetEvent(mRolloverEvent);
  }

  if (nError != NO_ERROR)
  {
    bOK = FALSE;
  }

	return bOK;
}


// flushes all outstanding requests to disk (serialized)
DWORD NTLogServer::Flush()
{
	AutoCriticalSection lock(&mFlushLock);

	DWORD err = EmptyQueue();
	FlushFileBuffers();
	return err;
}

void NTLogServer::FlushAll()
{
  Flush();
}


//
//	@mfunc
//	Empty the queue.
//  @rdesc 
//  The error code ...
//
DWORD NTLogServer::EmptyQueue()
{
  BOOL bMoreLogRequests=FALSE ;
  NTLogRequest *pRequest ;
  DWORD nSize ;
  int nFileID ;
  NTLogFile *pLogFile=NULL ;
  BOOL bRetCode=TRUE ;

	mQLock.Lock() ;
	int initialSize = mQueue.size();
	// unlock the mQLock ...
	mQLock.Unlock() ;

	// if the queue is already empty, we have nothing to do
	if (initialSize == 0)
  {
		return NO_ERROR;
  }

  int nError=NO_ERROR ;

	// the event was signalled ... do some work ...
	do
	{ 
		bMoreLogRequests=FALSE ;
		///////////////////////////////////////////////////
		// Entering Critical Section Code ... 
		///////////////////////////////////////////////////
		// lock the mQLock ... 
		mQLock.Lock() ;
        
		// remove a LogRequest ...
		pRequest = mQueue.front() ;
		mQueue.pop_front() ;
        
		// reset the mQEvent ...
		bRetCode = ::ResetEvent (mQEvent) ;
		if (bRetCode == FALSE)
		{
			nError = ::GetLastError() ;
		}
        
		// unlock the mQLock ...
		mQLock.Unlock() ;
		///////////////////////////////////////////////////
		// Leaving Critical Section Code ... 
		///////////////////////////////////////////////////
      
    nFileID = pRequest->GetFileID() ;

    // find the file to log the data to ...
    MTLogFileCollIter iter ;
		{
			AutoCriticalSection aLock(&mFileListLock);
			iter = mFileList.find(nFileID);
		}
		if (iter == mFileList.end() )
    {
      delete pRequest;
    }
    else
    {
      pLogFile = (*iter).second;
      bRetCode = pLogFile->ProcessLogRequest(pRequest);
      if (bRetCode == FALSE)
      {
//      call seterror in the function the first discovered an error
        nError = ::GetLastError() ;         // error recovery ???
      }
    }

		///////////////////////////////////////////////////
		// Entering Critical Section Code ... 
		///////////////////////////////////////////////////
		// lock the mQLock ... to check the queue ...
		mQLock.Lock() ;

		// check the queue ...
		nSize = mQueue.size() ;
        
		// unlock the mQLock ...
		mQLock.Unlock() ;
		///////////////////////////////////////////////////
		// Leaving Critical Section Code ... 
		///////////////////////////////////////////////////

		// if there are more requests remove another one ...
		if (nSize > 0)
		{
			bMoreLogRequests=TRUE ;
		}
	}
	// while there are more LogRequests on the queue ...
	while (bMoreLogRequests == TRUE) ;

	return nError;
}

time_t NTLogServer::MTTime()
{
	if (mTimeClient != NULL)
	{
		try
		{
			return mTimeClient->GetMTTime();
		}
		catch (_com_error &)
		{ }
	}
	// metratime isn't working or not configured - use the normal time
	return time(0LL);
}

BOOL NTLogServer::TimeIsAdjusted()
{
	if (mTimeClient != NULL)
	{
		try
		{
			return (mTimeClient->GetIsTimeAdjusted() == VARIANT_TRUE);
		}
		catch (_com_error &)
		{ }
	}
	// metratime isn't working or not configured - time is not adjusted
	return FALSE;
}

//
//	@mfunc
//	Process the LogRequest queue. Wait for the mQEvent to be signalled or the 
//  timeout (10 seconds) to be exceeded. If the mQEvent was signalled, process
//  the LogRequest queue. Lock access to the queue, take the request off the 
//  queue, reset the event and unlock access to the queue. Check to see if we 
//  need to rollover the MetraTech file log. Write the LogRequest out to the 
//  MetraTech file log. Check the queue for more LogRequests. If the mQEvent 
//  was not signalled, check to see if the thread was requested to stop and then
//  wait on the event again.
//  @rdesc 
//  Returns the status of the thread.
// 
int NTLogServer::ThreadMain()
{
  int nError=NO_ERROR ;
  BOOL bRetCode=TRUE ;
  HANDLE eventHandles[2];           // Holds events we will monitor
  int nEvents = 1;                  // Number of events we will monitor

  eventHandles[0] = mQEvent;        // We always monitor log queue events

  // Create an event for detecting editing 
  // in the logging config directory.
  
  std::string s;
  if (GetMTConfigDir(s))                                // get config dir
  {
    s = s + "\\Logging";
    std::wstring configDirectory;                       // we need to convert to wide string
    ::ASCIIToWide(configDirectory, s);                  // for upcoming call

    eventHandles[1] = FindFirstChangeNotification( 
                        configDirectory.c_str(),        // directory to watch 
                        TRUE,                           // watch subdirectories
                        FILE_NOTIFY_CHANGE_LAST_WRITE); // watch for edits
 
    if (eventHandles[1] != INVALID_HANDLE_VALUE &&      // if everything went ok,
        eventHandles[1] != NULL)                        // then increase the number of
    {                                                   // events we are going to monitor
      nEvents = 2;
    }
  }
 
	int currentSize;
  // wait for a StopRequested ...
  while (!StopRequested() && mOkToLogData == TRUE)
  {
    // wait for the mQEvent or configuration directory change to be signalled.
    // at most wait a half second so we don't ignore a StopRequested().
    
    nError = ::WaitForMultipleObjects(nEvents, eventHandles, FALSE, 500) ;

    // switch on the wait status ...
    switch (nError)
    {
    case WAIT_OBJECT_0:
      // flushes all requests to disk
			nError = Flush();
      break;

    case WAIT_OBJECT_0 + 1:
      ConfigurationHasChanged();
      FindNextChangeNotification(eventHandles[1]);
      break;

    case WAIT_TIMEOUT:
      // timeout exceeded ... don't do anything ... we're just going to 
      // check to see if someone requested this thread to stop ...
      nError = ::GetLastError() ;

			// only lock when checking the size.  if there's something there
			// at that instance in time then flush the log.
			mQLock.Lock() ;
			currentSize = mQueue.size();
			mQLock.Unlock() ;

			// flushes all requests to disk
			if (currentSize > 0)
				nError = Flush();

      break;

    case WAIT_FAILED:
      // error ... log it ...
      nError = ::GetLastError() ;
      break ;
      
    case WAIT_ABANDONED:
    default:
      // error ... log it ...
      nError = ::GetLastError() ;
      break ;
      
    }    

    if (nError == NO_ERROR)
    {
			bRetCode = Rollover( FALSE /* do not force */ );
    }

  } // end - while ...

	// flushes all requests to disk
	Flush();

  // If we were monitoring configuration file changes,
  // clean up.
  if (nEvents > 1)
  {
      FindCloseChangeNotification(eventHandles[1]);
  }

#ifdef _DEBUG
	// make sure the queue is really empty

	// lock the mQLock ... to check the queue ...
	mQLock.Lock() ;

	// check the queue ...
	int endSize = mQueue.size();
        
	// unlock the mQLock ...
	mQLock.Unlock() ;

	ASSERT(endSize == 0);
#endif // _DEBUG

  return nError ;
}



BOOL NTLogServer::AddConfigInfo (const LoggerInfo *apLoggerInfo, int &arFileID)
{
  BOOL bRetCode=TRUE ;
  NTLogFile *pLogFile ;
  _bstr_t configPath ;
  _bstr_t loggerConfigPath ;
  BOOL bFound=FALSE ;

	AutoCriticalSection aLock(&mFileListLock);

  // does the file exist in the current list of files ...
  arFileID = 0 ;
	{
		AutoCriticalSection aLock(&mFileListLock);
		MTLogFileCollIter iter ;
		loggerConfigPath = apLoggerInfo->GetConfigPath();

		for (iter = mFileList.begin(); (bFound == FALSE) && (iter != mFileList.end()); iter++)
		{
			// get the current element ...
			pLogFile = (*iter).second ;

			// get filename ...
			configPath = pLogFile->GetConfigPath() ;
    
			// if the config path is same ... exit ...
			if (_wcsicmp( (wchar_t *)configPath, (wchar_t *)loggerConfigPath) == 0)
			{
				bFound = TRUE ;
				arFileID = (*iter).first ;
			}
		}
	}

  // if it doesnt exist ...
  if (bFound == FALSE)
  {
    // create new LogFile object ...
    pLogFile = new NTLogFile ;
    ASSERT (pLogFile) ;
    if (pLogFile == NULL)
    {
      bRetCode = FALSE ;
    }
    else
    {
      // init the LogFile object ...
      bRetCode = pLogFile->Init (apLoggerInfo) ;
      if (bRetCode == FALSE)
      {
		DWORD err = ::GetLastError();
		if (err == ERROR_ACCESS_DENIED)
		  SetError(CORE_ERR_INCORRECT_PERMISSIONS_ON_LOGFILE, ERROR_MODULE, ERROR_LINE, 
					"The permissions on the log file are incorrect.");
		else if (err == ERROR_PATH_NOT_FOUND)
		  SetError(CORE_ERR_INVALID_LOGFILE_PATH, ERROR_MODULE, ERROR_LINE, 
					"The log file path is incorrect.");
		else
			SetError (CORE_ERR_UNKNOWN_ERROR, ERROR_MODULE, ERROR_LINE,
			"Unable add the config path to the LogServer") ;
        delete pLogFile;
      }
      // otherwise ... add it to the list ...
      else
      {
				AutoCriticalSection aLock(&mFileListLock);
        mFileListNum++ ;
				mFileList.insert(MTLogFileColl::value_type(mFileListNum, pLogFile));
        arFileID = mFileListNum ;
      }
    }
  }
  
  return bRetCode ;
}


void SetLoggerInfo(LoggerInfo* pLogInfo,const NTLogFile* pLogFile)
{
  pLogInfo->SetLogLevel (pLogFile->GetLogLevel());
  pLogInfo->SetFilename (pLogFile->GetFilename());
  pLogInfo->SetLogSocketLevel (pLogFile->GetLogSocketLevel());
  pLogInfo->SetLogSocketPort (pLogFile->GetLogSocketPort());
  pLogInfo->SetLogSocketServer (pLogFile->GetLogSocketServer());
  pLogInfo->SetLogSocketConnectionType (pLogFile->GetLogSocketUseTcp() ? "tcp" : "udp");
  pLogInfo->SetLogSocketFacility (pLogFile->GetLogSocketFacility());
  pLogInfo->SetLogSocketTag (pLogFile->GetLogSocketTag());
  pLogInfo->SetLogRolloverAge (pLogFile->GetLogRolloverAge());
  pLogInfo->SetLogFilterLevel (pLogFile->GetLogFilterLevel());
  pLogInfo->SetLogFilterTag (pLogFile->GetLogFilterTag());
  pLogInfo->SetLogCircularBufferSize(pLogFile->GetLogCircularBufferSize());
}


//
// Search the current list of log files for the value of the first argument.
// If one of the files matches apConfigPath, then copy that file's LoggerInfo.
//
DLL_EXPORT BOOL NTLogServer::FindConfigInfo(const char *apConfigPath, 
                                            LoggerInfo ** arppLoggerInfo)
{
  BOOL bFound=FALSE ;
  NTLogFile *pLogFile ;
  _bstr_t configPath ;
  MTLogFileCollIter iter ;
  LoggerInfo * pLogInfo = NULL ;
  *arppLoggerInfo = NULL;
	
	// lock the file list
	AutoCriticalSection aLock(&mFileListLock);


	std::string aConfigDir;
	GetMTConfigDir(aConfigDir);
	aConfigDir += apConfigPath;

	for ( iter = mFileList.begin(); 
      (bFound == FALSE)  &&  (iter != mFileList.end()); 
      iter++)
  {
    // get the current element ...
    pLogFile = (*iter).second ;

    // get filename ...
    configPath = pLogFile->GetConfigPath() ;

			
    // if the config path is same ... exit ...
    if (_stricmp( configPath, apConfigPath) == 0) {
      bFound = TRUE ;
      *arppLoggerInfo = new LoggerInfo;
			SetLoggerInfo(*arppLoggerInfo,pLogFile);
      (*arppLoggerInfo)->SetConfigPath(configPath) ;
    }
  }

	if(!bFound && mpCachedInfo != NULL) {
		CacheMissList::iterator aMissIter;
		// look in the cache miss list.
		for(aMissIter = mCacheMissList.begin();bFound == FALSE && aMissIter != mCacheMissList.end() ;aMissIter++) {
			const char* pRef = (*aMissIter).c_str();
			if(_stricmp(pRef,aConfigDir.c_str()) == 0) {
				bFound = TRUE ;
				*arppLoggerInfo = new LoggerInfo(*mpCachedInfo);
			}
		}
	}

  return bFound ;
}

//
//	@mfunc
//	Flush the file buffers
//  @rdesc 
//  No return value.
// 
void NTLogServer::FlushFileBuffers()
{
  NTLogFile *pLogFile=NULL ;
  FILE *pFile=NULL ;

  // iterate through the file list and flush each file ...
	AutoCriticalSection aLock(&mFileListLock);

  MTLogFileCollIter iter ;
  for (iter = mFileList.begin(); iter != mFileList.end(); iter++)
  {
    // get the current element ...
    pLogFile = (*iter).second;

    // get the file pointer ...
    pFile = pLogFile->GetLogFilePtr() ;
    ASSERT (pFile) ;

    fflush(pFile) ;
  }
}

//
//	@mfunc
//	close the file logs
//  @rdesc 
//  No return value.
// 
void NTLogServer::CloseLogFiles()
{
  NTLogFile *pLogFile=NULL ;
  FILE *pFile=NULL ;

  // iterate through the file list and flush each file ...
	AutoCriticalSection aLock(&mFileListLock);

  MTLogFileCollIter iter ;
  for (iter = mFileList.begin(); iter != mFileList.end(); iter++)
  {
    // get the current element ...
    pLogFile = (*iter).second;

    delete pLogFile ; // destructor flushes stream and closes file
  }

  mFileList.clear() ;
}

//
//	@mfunc
//	Update the configuration.
//  @rdesc 
//  No return value
//
void NTLogServer::ConfigurationHasChanged()
{
  // local variables ...
  map<int, string>	localFileConfigColl;
  int nFileID ;
  NTLogFile *pFile=NULL ;
  string configPath ;
  LoggerInfo *pLoggerInfo=NULL ;
  BOOL bRetCode=TRUE ;

  // get the critical section
  mQLock.Lock() ;
	AutoCriticalSection aLock(&mFileListLock);
  MTLogFileCollIter iter ;

  // make a map of the file id to config directory ...
  for (iter = mFileList.begin(); iter != mFileList.end(); iter++)
  {
    // get the key and value ...
    nFileID = (*iter).first ;
    pFile = (*iter).second ;

    // insert the values into the local map ...
    configPath = pFile->GetConfigPath() ;

    localFileConfigColl[nFileID] = configPath;
  }

  // delete the allocated memory ...
  CloseLogFiles() ;

	// get rid of our cached copy of the logging information
	delete mpCachedInfo;
	mpCachedInfo = NULL;

  // iterate through the file config collection ...
	map<int, string>::iterator it;
	for (it = localFileConfigColl.begin(); it != localFileConfigColl.end(); ++it)
	{
		int fileID = it->first;
    // call the config reader to get the logger config info ...
    string configPath = it->second;
    pLoggerInfo = ReadConfiguration(configPath.c_str()) ;

    ASSERT (pLoggerInfo) ;
    if (pLoggerInfo != NULL)
    {
      // create new LogFile object ...
      pFile = new NTLogFile ;
      ASSERT (pFile) ;
      if (pFile == NULL)
      {
        bRetCode = FALSE ;
      }
      else
      {
        // init the LogFile object ...
        bRetCode = pFile->Init (pLoggerInfo) ;
        if (bRetCode == FALSE)
        {
//        call seterror in the function the first discovered an error
//          SetError(pFile->GetLastError(), 
//            "Unable to initialize the log file");
        }
        // otherwise ... add it to the list ...
        else
        {
					mFileList.insert(MTLogFileColl::value_type(fileID, pFile));
        }
      }
      // delete the logger info ...
      delete pLoggerInfo ;
      pLoggerInfo = NULL ;
    }
  }

  // release the critical section
  mQLock.Unlock() ;  

  return ;
}

// ----------------------------------------------------------------
// Name:     	PopulateLoggerInfo
// Arguments:     <pLogInfo> - the loggerinfo object to populate
//                <aPropset> - the XML configuration
//								<apConfigDir>	- the configuration directory
// Description:   Reads the XML and populates the LoggerInfo object.  This is simply a helper function
// ----------------------------------------------------------------

  const _bstr_t versionBstr("version");
  const _bstr_t loggingConfigBstr("logging_config");
  const _bstr_t logFileNameBstr("logfilename");
  const _bstr_t loglevelBstr("loglevel");
  const _bstr_t logsocketlevelBstr("logsocketlevel"); // port number for remote monitoring of messages.
  const _bstr_t logsocketportBstr("logsocketport"); // port number for remote monitoring of messages.
  const _bstr_t logsocketserverBstr("logsocketserver"); // address of server for remote monitoring of messages.
  const _bstr_t logsocketconnectiontypeBstr("logsocketconnectiontype"); 
  const _bstr_t logsocketfacilityBstr("logsocketfacility"); 
  const _bstr_t logsockettagBstr("logsockettag"); 
  const _bstr_t logrolloverageBstr("logrolloverage"); // days that will trigger a log file rollover.
  const _bstr_t logfilterlevelBstr("logfilterlevel"); // trigger log file contents.
  const _bstr_t logfiltertagBstr("logfiltertag");  // trigger log file contents.
  const _bstr_t logcircularbuffersizeBstr("logcircularbuffersize");  // size of the circular buffer

BOOL PopulateLoggerInfo(LoggerInfo* pLogInfo,
												MTConfigLib::IMTConfigPropSetPtr& aMainSet,
												const char* apConfigDir)
{
	BOOL bRetCode = FALSE;

	try {
      
		MTConfigLib::IMTConfigPropSetPtr aPropset = aMainSet->NextSetWithName(loggingConfigBstr);

		// Get the log filename. Support environment variables.
		char ExpandedFilename[MAX_PATH];
		ExpandedFilename[0] = 0;
		ExpandEnvironmentStringsA(aPropset->NextStringWithName(logFileNameBstr), ExpandedFilename, sizeof(ExpandedFilename));

		// set the file name
		pLogInfo->SetFilename (ExpandedFilename);

		// set the log level
		pLogInfo->SetLogLevel ((MTLogLevel)aPropset->NextLongWithName(loglevelBstr));
		// set the config dir
		pLogInfo->SetConfigPath (apConfigDir) ;
		// set the log socket
		pLogInfo->SetLogSocketLevel((MTLogLevel)aPropset->NextLongWithName(logsocketlevelBstr));
		  pLogInfo->SetLogSocketPort(aPropset->NextLongWithName(logsocketportBstr));
		  pLogInfo->SetLogSocketServer(aPropset->NextStringWithName(logsocketserverBstr));
		  pLogInfo->SetLogSocketConnectionType(aPropset->NextStringWithName(logsocketconnectiontypeBstr));
		  pLogInfo->SetLogSocketFacility(aPropset->NextLongWithName(logsocketfacilityBstr));
		  pLogInfo->SetLogSocketTag(aPropset->NextStringWithName(logsockettagBstr));

		pLogInfo->SetLogRolloverAge(aPropset->NextLongWithName(logrolloverageBstr));
		// log filter level
		pLogInfo->SetLogFilterLevel((MTLogLevel)aPropset->NextLongWithName(logfilterlevelBstr));
		// log filter tag
		pLogInfo->SetLogFilterTag((char*)aPropset->NextStringWithName(logfiltertagBstr));
		
		//for backwards compatabillity (logcircularbuffersize is already 25)
		//so if it isn't found we'll use that as a default value
		try {
			pLogInfo->SetLogCircularBufferSize(aPropset->NextLongWithName(logcircularbuffersizeBstr));
		} catch (_com_error &) {}
		bRetCode = TRUE;
	}
	catch (_com_error& ) {
		bRetCode = FALSE ;
	}
	return bRetCode;
}


LoggerInfo * NTLogServer::ReadConfiguration (const char * apConfigDir)
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  char defaultConfigDir[] = "Logging";

  AutoCriticalSection aLock(&mFileListLock);

  // allocate a loggerinfo ...
  LoggerInfo *pLogInfo = new LoggerInfo ;
  ASSERT(pLogInfo) ;
  if (pLogInfo == NULL)
  {
    bRetCode = FALSE ;
    return pLogInfo ;
  }

#if 1
	

	DWORD nError=NO_ERROR ;

	std::string configPath;
	if (!GetMTConfigDir(configPath))
	{
		bRetCode = FALSE ;
	}

	else
	{
		// get the file name ...
		_bstr_t configDir ;
		BOOL bReadConfigFile=TRUE ;
		// wchar_t wstrConfigDir[MAX_PATH] ;
		_bstr_t tempData ;
		tempData = apConfigDir;
		_bstr_t bstrConfigDir ;

		bstrConfigDir = configPath.c_str();
		bstrConfigDir += tempData ;

		MTConfigLib::IMTConfigPtr config(MTPROGID_CONFIG);
		VARIANT_BOOL flag;

		try
		{
			_bstr_t bstrLoggingFile = bstrConfigDir + "\\logging.xml" ;

			// read in the logging configuration
			// only attempt this if the file exists to avoid throwing exceptions all the time
			FILE * fp = fopen(bstrLoggingFile, "r");
			if (fp != NULL)
			{
				fclose(fp);
				MTConfigLib::IMTConfigPropSetPtr propset = config->ReadConfiguration(bstrLoggingFile, &flag);
				bRetCode = PopulateLoggerInfo(pLogInfo,propset, apConfigDir);
			}
			else
			{
				bRetCode = FALSE;
				nError = E_FAIL;				// error's not used
			}
		}
		catch (_com_error e)
		{
			nError = e.Error() ;
			bRetCode = FALSE ;
		}

		// if we didnt read the config file ... read the default ...
		if (bRetCode == FALSE)
		{
			// add the file we failed to read to failure cache list.
			mCacheMissList.push_back((const char*)bstrConfigDir);

			// make sure that a cached copy does not exist
			if(mpCachedInfo) {
				*pLogInfo = *mpCachedInfo;
				bRetCode = TRUE;
			}
			else {
				// we don't have a cached copy.  It must be the first time starting
				// or the configuration was just refreshed
				mpCachedInfo = new LoggerInfo;

				// get the file name ...
				bstrConfigDir = configPath.c_str();
				bstrConfigDir += defaultConfigDir ;

				_bstr_t bstrLoggingFile = bstrConfigDir + "\\logging.xml" ;

				try {
					
					MTConfigLib::IMTConfigPropSetPtr propset = config->ReadConfiguration(bstrLoggingFile, &flag);
					bRetCode = PopulateLoggerInfo(mpCachedInfo,propset, defaultConfigDir);
					if(bRetCode) {
						apConfigDir = defaultConfigDir;  // save where we *really* found the config file
						*pLogInfo = *mpCachedInfo;
					}
				}
				catch (_com_error e)
				{
					nError = e.Error() ;
					bRetCode = FALSE ;
					cout << "ERROR : unable to read configuration file. Error = " << hex << e.Error() << endl ;
					cout << "        File = " << (char *) bstrConfigDir << endl ;
				}
			}
		}
	}

	// if we havent hit an error yet ...
	if(!bRetCode) {
		// we didnt get the log info ... delete the log info structure 
		delete pLogInfo;
		pLogInfo = NULL;
	}

#else
  // for testing purposes ...
  //
  // set the log level and the log filename ...
  pLogInfo->SetLogLevel (LOG_ERROR) ;
  pLogInfo->SetFilename ("c:\\temp\\mtlog.txt") ;
  pLogInfo->SetConfigPath ("Database") ;
  pLogInfo->SetLogSocketLevel(0) ;
  pLogInfo->SetLogRolloverAge(0) ;
  pLogInfo->SetLogFilterLevel(0) ;
  pLogInfo->SetLogFilterTag((char*)logfiltertag) ;
	pLogInfo->SetLogCircularBufferSize(25);
#endif
	
  return pLogInfo;
}


//
//	@mfunc
//	Constructor. Initialize data members.
//  @rdesc 
//  No return value.
// 
NTLogFile::NTLogFile()
: mpFile(NULL), mRolloverEvent(NULL), mLogLevel (LOG_OFF),
 mLogSocketLevel(LOG_OFF), mLogSocketPort(0), mLogSocketUseTcp(0), mLogRolloverAge(0), mLogFilterLevel(LOG_OFF),
 mbRolloverRequired(FALSE), mSocket(NULL), mLogCircularBufferSize(25)
{
}
//
//	@mfunc
//	Destructor. Free allocated data.
//  @rdesc 
//  No return value
// 
NTLogFile::~NTLogFile()
{
  // release the event ...
  if (mRolloverEvent != NULL)
  {
    ::CloseHandle (mRolloverEvent) ;
    mRolloverEvent = NULL;
  }

  if (mpFile != NULL)
  {
     //   Buffers are normally maintained by the operating system, 
     //   which determines the optimal time to write the data 
     //   automatically to disk: 
     //   when a buffer is full, 
     //   when a stream is closed, 
     //   or when a program terminates normally without closing the stream. 
     //   The commit-to-disk feature of the run-time library lets you ensure 
     //   that critical data is written directly to disk rather than to the 
     //   operating-system buffers. 
     //   Without rewriting an existing program, you can enable 
     //   this feature by linking the program’s object files with 
     //   COMMODE.OBJ. In the resulting executable file, calls to 
     //   _flushall write the contents of all buffers to disk. 
     //   Only _flushall and fflush are affected by COMMODE.OBJ.

    fflush (mpFile) ;
    fclose (mpFile) ;
    mpFile = NULL ;
  }

  // clear the queue ...
  NTLogRequestCollIter iter;
  for(iter = mQueueForThisLog.begin(); iter != mQueueForThisLog.end(); iter++)
  {
    delete *iter;    
  }
  mQueueForThisLog.clear() ;

  
  if ( NULL != mSocket)
  {
    delete mSocket;
  }
}


BOOL NTLogFile::WriteLogRequest(const NTLogRequest *apNTLogRequest)
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  char *pData ;
  char bufDateTime[MAX_PATH];
  char *buffer;
  DWORD nSize=0;

  int nError=NO_ERROR ;
  struct tm *pLocalTime ;

  // get the data to log and the file id to log the data to ... 
  pData = apNTLogRequest->GetData() ;
  pLocalTime = apNTLogRequest->GetTimestamp();

  //Should we log this to the file?
  if (apNTLogRequest->GetLogLevel()<=mLogLevel)
  {
    // format the timestamp for the file
    strftime(bufDateTime, MAX_PATH, DEFAULT_LOG_FILE_DATE_FORMAT,pLocalTime);

    // create new buffer to be written to the file
    nSize = ((strlen (bufDateTime)) + (strlen (pData)) + (sizeof (char) * 2)) ;

    buffer=new char[nSize];
    ASSERT (buffer) ;
    if (buffer == NULL)
    {
      bRetCode = FALSE ;
      return bRetCode ;
    }

    sprintf (buffer, "%s%s\n", bufDateTime, pData) ;


    // Wait while a rollover is inprogress
    nError = ::WaitForSingleObject (mRolloverEvent, INFINITE) ;

    // write the logrequest to the file 
    bRetCode = fprintf (mpFile, "%s", buffer) ;
    delete[] buffer;

    if (bRetCode == FALSE)
    {
      nError = ::GetLastError() ;         // error recovery ???
    }
  }

#ifdef ENABLE_SOCKETS
  //Should we log this to the socket?
  if ((mSocket != NULL)&&(apNTLogRequest->GetLogLevel()<=mLogSocketLevel))
  {
    // format the timestamp for syslog
		strftime(bufDateTime, MAX_PATH, REMOTE_LOGGING_DATE_FORMAT, pLocalTime);
    
    // calculate the priority code for syslog
    DWORD dwPriority;
    dwPriority=(mLogSocketFacility*8) + GetSyslogSeverityFromLogLevel(apNTLogRequest->GetLogLevel());

    // create new buffer to be written to the socket
    nSize = (strlen(bufDateTime) + strlen(mLogSocketMachineTagBuffer) + strlen(pData) + (sizeof (char) * (5 + 1 + 2 + 30))) ;
    buffer=new char[nSize];
    ASSERT (buffer) ;
    if (buffer == NULL)
    {
      bRetCode = FALSE ;
      return bRetCode ;
    }

    sprintf (buffer, "<%d>%s %s %s\n", dwPriority, bufDateTime, (const char *)mLogSocketMachineTagBuffer, pData) ;

    bRetCode = mSocket->Send(buffer, strlen(buffer));

    delete[] buffer;

    if (bRetCode == FALSE)
    {
      // Write entry directly to log file
      //time_t uTime ;
      //struct tm *lTime ;
      //lTime =


      //DWORD dwError = mSocket->GetLastError() ; 
      //nSize = (strlen(bufDateTime) + strlen(mLogSocketMachineTagBuffer) + strlen(pData) + (sizeof (char) * (5 + 1 + 2 + 30))) ;
      //buffer=new char[nSize];

      //sprintf(buffer, "<%d>%s %s: %s\n", dwPriority, bufDateTime, (const char *)mLogSocketMachineTagBuffer, pData) ;

      // close the socket - the server probably died
      delete mSocket;
      mSocket = NULL;
    }
  }
#endif // ENABLE_SOCKETS

  delete apNTLogRequest;
  return bRetCode ;
}

//This routine takes the MetraTech log level (ERROR,DEBUG, etc.) and maps
//it to a syslog severity (0-7)
inline DWORD NTLogFile::GetSyslogSeverityFromLogLevel(MTLogLevel aLogLevel)
{
  static DWORD LogLevelToSeverity[7] = {0,1,3,4,6,7,7};
  return LogLevelToSeverity[aLogLevel];
}


BOOL NTLogFile::IsTriggered(const NTLogRequest *apNTLogRequest)
{
  // first check triggered based on log level

  if ( apNTLogRequest->GetLogLevel() > LOG_OFF )
  {
    // logging is enabled,
    // compare the message's log level to the trigger log level

    if ( mLogFilterLevel >= apNTLogRequest->GetLogLevel() )
    {
      // log level triggered

      return TRUE;
    }
  }

  // not triggered on log level, test the application tag values
    
  _bstr_t tag = apNTLogRequest->GetTag();
  char * pTrigger = (char *)mLogFilterTag;

  if ( pTrigger != NULL  && mLogFilterTag.length() > 0)
  {
    // the application trigger is set,
    // compare it to the message's application tag

    if ( 0 == _stricmp((char *)tag, pTrigger))
    {
      // tag trigger

      return TRUE;
    }
  }

    return FALSE;
}

#pragma warning(disable:4018)

#ifdef LOG_PERFORMANCE
  PerformanceTickCount initialTicks;
  PerformanceTickCount finalTicks;
#endif

BOOL NTLogFile::ProcessLogRequest(NTLogRequest *apNTLogRequest)
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  NTLogRequest *pRequest ;
  int nError=NO_ERROR ;
  int qSize;

#ifdef LOG_PERFORMANCE
  //Calculate and display performance information (stdout)
  static long lRequestCount;
  const long lRequestPerformanceGroup=1000;
  
  if (lRequestCount==0)
  {	
	  GetCurrentPerformanceTickCount(&initialTicks);
  }
  else
  {
    if ((lRequestCount%lRequestPerformanceGroup)==0)
    {
      GetCurrentPerformanceTickCount(&finalTicks);
      long ticks = PerformanceCountTicks(&initialTicks, &finalTicks);
      long frequency;
	    GetPerformanceTickCountFrequency(frequency);

      printf("Request %d: \tTicks[%d] \tTime[%f]\n",lRequestCount, ticks, ((double)ticks/(double)frequency));
      GetCurrentPerformanceTickCount(&initialTicks);
    }
  }
  lRequestCount++;
#endif

  // If no filtering, just write the request

  if ( IsNotTriggerable() )
    return WriteLogRequest(apNTLogRequest);

  //  If there is filtering enabled continue processing,
  // check to see if this is a trigger message that
  // causes the queue to be written to the log.

  if ( IsTriggered(apNTLogRequest) )
  {
    // write the queue to the log

	  qSize = mQueueForThisLog.size();

	  // check if the queue is already empty
	  while (bRetCode && qSize > 0)
    {
		  // remove a LogRequest ...
		  pRequest = mQueueForThisLog.front() ;
		  mQueueForThisLog.pop_front() ;
      bRetCode = WriteLogRequest(pRequest);
  	  qSize = mQueueForThisLog.size();
    }

    bRetCode = WriteLogRequest(apNTLogRequest);
  }
  else
  {
    // If this message does not trigger, save it in the queue

    mQueueForThisLog.push_back(apNTLogRequest);

    // remove overflow.  This makes queue look like a circular buffer
	  qSize = mQueueForThisLog.size();

    if ( qSize > mLogCircularBufferSize)
    {
		  pRequest = mQueueForThisLog.front() ;
      delete pRequest;
		  mQueueForThisLog.pop_front() ;
    }
  }

  return bRetCode ;
}

#pragma warning(default:4018)
//
// Test the age of the log file against the rollover age specified
// in the config file.
//
//////////////////////////////////////////////////////////////
//////////////////////

BOOL NTLogFile::IsRolloverRequired()
{
  BOOL bRolloverRequired = FALSE;
  HFILE hFile;
  ULARGE_INTEGER largeInt;
  FILETIME CreationTime; 
  FILETIME SystemFileTime; 
  BOOL bOK;
  LONG compare;
  ULARGE_INTEGER age;
  ULONGLONG agenano;

  // return no reollover required if we are not checking for rollover age

  if ( mLogRolloverAge == 0 )
    return FALSE;

  hFile = _lopen( (char *)mFilename, OF_READWRITE ); 

  if ( HFILE_ERROR != hFile ) 
  { 
    //
    //  get the file age and the current time

    bOK = GetFileTime( (HANDLE)hFile, &CreationTime, 0, 0 );

    GetSystemTimeAsFileTime(  &SystemFileTime  );

    // calculate the rollover interval in the correct units.
    // Number of 100-nanosecond intervals that have elapsed since 12:00 A.M. January 1, 1601 

    age.QuadPart = mLogRolloverAge * 24 /* hrs/day */ * 60 /* min/hr */ * 60 /* sec/min */ ;
    agenano = 10000000;
    age.QuadPart = age.QuadPart * agenano /* 100 nsec */ ;

    // add the age to the file creation time
    // Visual C++® supports the __int64 sized integer type

    largeInt.LowPart = CreationTime.dwLowDateTime;
    largeInt.HighPart = CreationTime.dwHighDateTime;
    largeInt.QuadPart += age.QuadPart;

    CreationTime.dwLowDateTime = largeInt.LowPart;
    CreationTime.dwHighDateTime = largeInt.HighPart;

    if ( bOK )
    {
      // compare = -1  If first file time is less than second file time.

      compare =  CompareFileTime( &CreationTime, &SystemFileTime );

      // Compare the file age to the trigger age.
      // Flag a rollover if the file is older than the trigger age.

      if ( compare < 0 )
      {
        bRolloverRequired = TRUE;
      }

// removed for fix of bug 3079 **TMG**
#if 0
      //
      //  Now check for a file larger than max size.
      //  Note that this code is never reached if the config file specifies
      //  no rollover age checking...
			
      dwSize  = GetFileSize( (HANDLE)hFile, NULL ); // returns -1 if error
      if ( dwSize > MAX_LOG_SIZE_BYTES )
        bRolloverRequired = TRUE;
			
#endif

      // if we are rolling, chage the file creation time

      if ( bRolloverRequired )
      {
        SetFileTime(  (HANDLE)hFile,
                    &SystemFileTime,   // creation time
                    NULL, // last-access time
                    NULL );   // last-write time
      }
    }

  }

  _lclose( hFile ); 

  mbRolloverRequired = bRolloverRequired;

  return bRolloverRequired;
}

//
//  Rollover the log file if we are forced to
//  of if the log file is past the rollover age.
//
//  Rollover is done by creating a new file,
//  moving the log file contents,
//  and truncating the log file.
//  
//////////////////////////////////////////////////////

BOOL NTLogFile::Rollover(BOOL bForceRolloverNow)
{
  // return if no rollover is due
  if ( !mbRolloverRequired  && !bForceRolloverNow )
    return TRUE;

  BOOL bOK = TRUE;
  char archive_fname[_MAX_PATH];   
  char drive[_MAX_DRIVE];   
  char dir[_MAX_DIR];
  char fname[_MAX_FNAME];   
  char ext[_MAX_EXT];
  struct tm  *ptimestruct;
  time_t long_time;
  char newfname[_MAX_FNAME];   
  int archiveHandle(-1);
  int logHandle(-1);
  char read_buffer[512];
  int read_count(0);
  int write_count(0);

  // reset the rolllover flag
  mbRolloverRequired = FALSE;

  // make the archive filename by appending a time stamp
	long_time = GetMTTime();
  ptimestruct = localtime( &long_time );

  _splitpath( (char *)mFilename, drive, dir, fname, ext );

//  strftime (newfname, _MAX_FNAME, "%m/%d/%y %H:%M:%S ", ptimestruct) ;
	sprintf( newfname, "%s%02d%02d%02d%02d", fname, 1+(ptimestruct->tm_mon), 
					 ptimestruct->tm_mday, ptimestruct->tm_hour, ptimestruct->tm_min );

  _makepath( archive_fname, drive, dir, newfname, ext );

  // create archive file for writing.  note that this will fail if executed twice in a
  // minute.
  archiveHandle = _open(archive_fname, _O_CREAT | _O_EXCL | _O_RDWR | _O_BINARY, _S_IREAD | _S_IWRITE);
  if ( -1 == archiveHandle)
  {
    bOK = FALSE;
  }

  // open the log file for reading
  if ( bOK )
  {
    logHandle = _open((char *)mFilename, _O_RDWR | _O_BINARY, _S_IREAD | _S_IWRITE);
    if ( -1 == logHandle )
    {
      bOK = FALSE;
    }
  }

  // copy the log file contents to the archive file
  if (bOK)
  {
    do 
    {
      read_count = _read( logHandle, read_buffer, sizeof(read_buffer) );
      write_count = _write( archiveHandle, read_buffer, read_count );
    }while (read_count > 0  &&  write_count > 0);

    // truncate to log file if we succeeded copying.
    if( _chsize( logHandle, 0 ) != 0 )
      bOK = FALSE;
  }



  if (logHandle != -1)
    _close( logHandle );
  if (archiveHandle != -1)
    _close( archiveHandle );

  return bOK;
}

// DESC: This function takes the fullname and path to a file
//       and will extract only the path portion.
// PARMS: fullname is a wchar_t string
_bstr_t extract_path(_bstr_t fullname)
{
    wstring FullPath(fullname);
    wstring FinalPath;
    
    // Strip find the last slash before the log name
    string::size_type pos = FullPath.find_last_of(_T("\\/"));
    // Check for no find
    if (pos == string::npos)
      FinalPath = FullPath;
    else // Slice off the filename...
      FinalPath = FullPath.substr(0, pos);
    
    _bstr_t retPath(FinalPath.c_str());
    return retPath;
}

// DESC: This function will segment a path into unique components
//       This is useful when one needs to create the entire path
//       to a final directory.
// PARMS: aTokenizedList is a reference to a vector which will be filled with path tokens
//        path is the initialized path wstring reference.
void tokenize(vector<wstring>& aTokenizedList, wstring& path)
{
	vector<wstring>::size_type aCurrentPos = 0;
	vector<wstring>::size_type aLoc;

    while((aLoc = path.find_first_of(_T("\\/"),aCurrentPos)) != string::npos) {
		wstring& aSubStr = path.substr(aCurrentPos,aLoc-aCurrentPos);
        // NOTE: extra slashes turn into "", which is ok when we go to create_dir...
        aTokenizedList.push_back(aSubStr);
		aCurrentPos = aLoc + 1;
	}
	wstring& aSubStr = path.substr(aCurrentPos, path.length() - aCurrentPos);
	aTokenizedList.push_back(aSubStr);
}

// DESC: This function will create a path to and including a final directory.
// PARMS: path is the initialized path wchar_t sting reference.
// NOTE: we tokenize here and use mkdir to make impl cross platform...
BOOL create_path(_bstr_t path)
{
  vector<wstring> pathTokens;
  wstring Path(path);

  // Split the path into tokens
  tokenize(pathTokens, Path);

  if(pathTokens.empty())
    return FALSE;

  // Create the iterator for path tokens
  vector <wstring>::iterator iter = pathTokens.begin( );

  // Make the first part of the path, this may be a drive letter
  // but it is ok...
  wstring temp(*iter);
  _wmkdir(temp.c_str());
  ULONG retval = GetLastError();
  
  if(retval != ERROR_ALREADY_EXISTS && retval != ERROR_SUCCESS)
    return FALSE;

  // Set up the path delimiter
  // Note: mkdir accepts either style of slash! So this also should work on Linux
  wstring slash(L"/");
  for (++iter; iter != pathTokens.end( ) ; iter++ )
  {
    // Add a slash
    temp += slash;

    // Add the next token in the path
    wstring dirpart(*iter);
    temp += dirpart;

    // Make it...
    _wmkdir(temp.c_str());
    retval = GetLastError();

    // Ensure we are still doing fine
    if(retval != ERROR_ALREADY_EXISTS && retval != ERROR_SUCCESS)
      return FALSE;
  }
  return TRUE;
}

// DESC: Test existence, and maybe create directory path
BOOL path_is_ok(_bstr_t fullname)
{
    _bstr_t path = extract_path(fullname);
    // May not have contained a path
    if(fullname != path)
    { // A path was present.... test for it. 
      if (access(path, 0 ) != 0 )
      { // Not there, create the path if possible
        if(!create_path(path)) return FALSE;
      } // Drop though if created
    }
    return TRUE;
}

BOOL NTLogFile::Init(const LoggerInfo *apLoggerInfo)
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  DWORD nError = NO_ERROR;
	SECURITY_DESCRIPTOR securityDescriptor;
	if (!InitializeSecurityDescriptor(&securityDescriptor, SECURITY_DESCRIPTOR_REVISION)
		|| !SetSecurityDescriptorDacl(&securityDescriptor, TRUE, (PACL)NULL, FALSE))
	{
		HRESULT err = HRESULT_FROM_WIN32(::GetLastError());
		return FALSE;
	}

	SECURITY_ATTRIBUTES securityAttributes;
	securityAttributes.nLength = sizeof(securityAttributes);
	securityAttributes.lpSecurityDescriptor = &securityDescriptor;
	securityAttributes.bInheritHandle = TRUE; 


  // create the rollover event (a manual reset event) ...
  mRolloverEvent = ::CreateEvent(&securityAttributes /* security*/, 
																 TRUE /* manual reset */, 
																 TRUE /* initial signalled state */, 
																 ROLLOVER_EVENT_NAME) ;
  if (mRolloverEvent == NULL)
  {
    nError = ::GetLastError() ;
    bRetCode = FALSE ;
  }

  if ( bRetCode )
  {
    // Test & maybe create the directory for the log file
    // as to avoid an exception if the path is missing for file create below
    if (!path_is_ok(apLoggerInfo->GetFilename()))
    {
      string buffer;
      buffer = "LOG ERROR: Log path invalid, and could not be created '";
      buffer += apLoggerInfo->GetFilename();
      buffer += "'";
      printf("%s\n", buffer.c_str());
      //ASSERT(0);
      HRESULT err = HRESULT_FROM_WIN32(::GetLastError());
      bRetCode = FALSE ;
      SetError(CORE_ERR_INVALID_LOGFILE_PATH, ERROR_MODULE, ERROR_LINE, "The log file path is incorrect.");
    }
    if ( bRetCode )
    {
      // create the log file ...

      // The c, n, and t mode options are Microsoft extensions 
      // for fopen and _fdopen and should not be used where 
      // ANSI portability is desired.
      //  mode = 'c' : Enable the commit flag so that the contents 
      // of the file buffer are written directly to disk if 
      // either fflush or _flushall is called.
      mpFile = fopen ((char *) apLoggerInfo->GetFilename(), "a+c") ;
      if (mpFile == NULL)
      {
	    //this is most likely caused if the directory of the log file
	    //specified in a logging.xml does not exist.
	    //for example if C:\temp\mtlog.txt is specified but C:\temp is
	    //not there
	    string buffer;
	    buffer = "LOG ERROR: could not open the log file '";
	    buffer += apLoggerInfo->GetFilename();
	    buffer += "'";
	    buffer += " Either path is invalid or permissions on the file or folder are invalid.";
	    printf("%s\n", buffer.c_str());
	    //ASSERT(0);
	    HRESULT err = HRESULT_FROM_WIN32(::GetLastError());
	    bRetCode = FALSE ;
        SetError(CORE_ERR_INCORRECT_PERMISSIONS_ON_LOGFILE, ERROR_MODULE, ERROR_LINE, "The permissions on the log file are incorrect.");
      }
    }
  }

  if ( bRetCode )
  {
    mConfigPath = apLoggerInfo->GetConfigPath() ;
    mLogLevel = apLoggerInfo->GetLogLevel() ;
    mFilename = apLoggerInfo->GetFilename() ;
    mLogSocketLevel = apLoggerInfo->GetLogSocketLevel() ;
    mLogSocketPort = apLoggerInfo->GetLogSocketPort() ;
    mLogSocketServerName = apLoggerInfo->GetLogSocketServer() ;
    mLogSocketUseTcp = (_stricmp(_bstr_t(_strlwr((char*)apLoggerInfo->GetLogSocketConnectionType())),"tcp")==0) ;
    mLogSocketFacility = apLoggerInfo->GetLogSocketFacility() ;
    mLogSocketTag = apLoggerInfo->GetLogSocketTag() ;
    mLogRolloverAge = apLoggerInfo->GetLogRolloverAge() ;
    mLogFilterLevel = apLoggerInfo->GetLogFilterLevel() ;
    mLogFilterTag = apLoggerInfo->GetLogFilterTag() ;
	  mLogCircularBufferSize = apLoggerInfo->GetLogCircularBufferSize();
  }

#ifdef ENABLE_SOCKETS
  if (mLogSocketLevel!=LOG_OFF)
  {
    // init the socket to broadcast the log messages
    mSocket = new CEasySocket();
    if (mSocket)
    {
      if (mSocket->Open(mLogSocketUseTcp, CLIENT, (USHORT)mLogSocketPort, mLogSocketServerName))
      {
        //char cmd[] = "NTLogFile::Init\r";
        //bRetCode = mSocket->Send(cmd, strlen(cmd));

        //Since we succeeded, lets prepare what we can for the buffer 
        //to be written to syslog
        mLogSocketMachineTagBuffer = GetNTHostName();
        if (mLogSocketTag.length()>0)
        {
          mLogSocketMachineTagBuffer += " ";
          mLogSocketMachineTagBuffer += mLogSocketTag;
          mLogSocketMachineTagBuffer += ":";
        }

      }
      else
      {
        delete mSocket;
        mSocket = NULL;

        // don't return an error message for the socket stuff because
        // it does not affect the file logging
      }
    }
  }
#endif // ENABLE_SOCKETS

  return bRetCode ;
}
//
//	@mfunc
//	Constructor. Initialize data members.
//  @rdesc 
//  No return value.
// 
NTLogRequest::NTLogRequest()
 : mLogLevel(LOG_OFF)
{
  // set mpData to NULL ...
  mpData = NULL ;
}

//
//	@mfunc
//	Destructor. Free allocated data.
//  @rdesc 
//  No return value
// 
NTLogRequest::~NTLogRequest()
{
  // delete the allocated memory ...
  if (mpData != NULL)
  {
    delete [] mpData ;
  }
}

//
//	@mfunc
//	Initialize the LogRequest object. Allocate a buffer to hold the data to be logged and the
//  the date time string.
//	@parm The data to be logged
//  @rdesc 
//  Returns TRUE on succes. Otherwise, FALSE is returned.
// 
BOOL NTLogRequest::Init(const char *apData, const int &arFileID, 
                        const char *apAppTag, const MTLogLevel aLogLevel,
												time_t aMTTime)
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  time_t uTime ;
  struct tm *lTime ;
  char dateTime[MAX_PATH] ;
  dateTime[0]='\0';
  DWORD nSize=0;
  DWORD nError=NO_ERROR ;
  _bstr_t strLogLevel ;
  
  mAppTag = apAppTag;
  mLogLevel = aLogLevel;

  // if we are reusing this NTLogRequest object ...
  if (mpData != NULL)
  {
    delete [] mpData ;
  }
  // copy the file id ...
  mFileID = arFileID ;

  //Save the current system time to be added to the message later
  time(&uTime);
  mlTime=*localtime(&uTime);

  // if we are on MetraTime, add that information to the data being logged...
  // we'll add the system time later.
	if (aMTTime > 0)
	{
    // long mttime first
		lTime = localtime (&aMTTime);
		strftime(dateTime, MAX_PATH, "MetraTime[%m/%d/%y %H:%M:%S=]", lTime) ;
  }

  // allocate a new string for the local data ... add the size of the data to log, the size of the
  // date/time string and 10 to allow for a little extra space ...
  nSize = ((strlen (apData)) + (strlen (dateTime)) + (strlen (apAppTag)) + (sizeof (char) * 20)) ;
  mpData = new char [nSize] ;
  ASSERT (mpData) ;
  if (mpData == NULL)
  {
    bRetCode = FALSE ;
    return bRetCode ;
  }
  // get the log level string ...
  GetLogLevelString (aLogLevel, strLogLevel) ;

  // Get current thread ID
  DWORD threadID = GetCurrentThreadId();

  // copy the date/time string, data to log and a newline character into the space allocated ...
  sprintf (mpData, "%s%u %s [%s] %s", dateTime, threadID, apAppTag, (char *)strLogLevel, apData) ;
  
  return bRetCode ;
}

//
//	@mfunc
//	Initialize the LogRequest object with a wide string. Allocate a buffer to 
//  hold the data to be logged and pass the data to the regular init function
//	@parm The data to be logged
//  @rdesc 
//  Returns TRUE on succes. Otherwise, FALSE is returned.
// 
BOOL NTLogRequest::Init(const wchar_t *apData, const int &arFileID, 
                        const char *apAppTag, const MTLogLevel aLogLevel,
												time_t aMTTime)
{
	MTMSIXUnicodeConversion convertOjb((const char*)apData);
	const char* pLogData = convertOjb.ConvertToASCII();

  return Init(pLogData, arFileID, apAppTag, aLogLevel, aMTTime);
}

