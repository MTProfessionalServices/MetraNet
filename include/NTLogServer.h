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

#ifndef __NTLOGSERVER_H
#define __NTLOGSERVER_H

#include <comdef.h>
#include <NTThreader.h>
#include <NTThreadLock.h>
#include <MTUtil.h>
#include <LoggerEnums.h>
#include <errobj.h>
#include <loggerinfo.h>
#include <ConfigChange.h>

#import <MetraTime.tlb>

using METRATIMELib::IMetraTimeClientPtr;
using METRATIMELib::MetraTimeClient;

// disable warning ...
#pragma warning( disable : 4251 4275 )

// forward declarations ...
class NTLogRequest;
class NTLogFile;
class CEasySocket;

// typedefs ...
#include <deque>
#include <map>
using namespace std;
typedef deque<NTLogRequest * > NTLogRequestColl;
typedef deque<string>	CacheMissList;
typedef NTLogRequestColl::iterator NTLogRequestCollIter;
typedef map<int, NTLogFile *> MTLogFileColl;
typedef MTLogFileColl::iterator MTLogFileCollIter;

// @class NTLogServer
class NTLogServer : 
public NTThreader,
  public ConfigChangeObserver,
  public ObjectWithError
{
// @access Public:
public: 
  // @cmember Destructor
  DLL_EXPORT ~NTLogServer() ;
  // @cmember Initialize the LogServer
  DLL_EXPORT BOOL Init() ;
  // @cmember Log this data to the MetraTech log file.
  DLL_EXPORT BOOL LogThis(const char *apData, const int &arFileID, const char *apAppTag, 
    const MTLogLevel aLogLevel) ;
  // @cmember check to see if its ok to log data for a given file
  DLL_EXPORT BOOL IsOkToLog (MTLogLevel aLogLevel, int aFileID) ;
  // @cmember Log this data to the MetraTech log file.
  DLL_EXPORT BOOL LogThis(const wchar_t *apData, const int &arFileID, const char *apAppTag, 
    const MTLogLevel aLogLevel) ;
  // @cmember Add the config information to the log server 
  DLL_EXPORT BOOL AddConfigInfo(const LoggerInfo *apLoggerInfo, int &arFileID) ;
  // @cmember Find the config info 
  DLL_EXPORT BOOL FindConfigInfo(const char *apConfigPath, LoggerInfo ** arppLoggerInfo) ;
  // @cmember Get a reference to the LogServer.
  DLL_EXPORT static NTLogServer * GetInstance() ;
  // @cmember Release the reference to the LogServer
  DLL_EXPORT static void ReleaseInstance() ;

  DLL_EXPORT virtual void ConfigurationHasChanged() ;
  // @cmember rollover the file if it is time
  DLL_EXPORT BOOL Rollover(BOOL bForceRolloverNow);

  // Flush any pending logs
  DLL_EXPORT void FlushAll();
  
	

	// public only to allow access by LoggerConfigReader
  DLL_EXPORT LoggerInfo * ReadConfiguration (const char *apConfigPath) ;


// @access Protected:
protected:
  // inheritted from NTThreader ...
  // @cmember The main loop of the LogServer.
  virtual int ThreadMain() ; 

  // @cmember Constructor.
  NTLogServer() ;

// @access Private:
private:

	// flushes all outstanding requests to disk (serialized)
	DWORD Flush();

  // write requests in queues to log files
	DWORD EmptyQueue();

	// flushes all log files disk buffers
	void FlushFileBuffers();

  // @cmember Close the file logs
  void CloseLogFiles() ;
  
	// return metratime
	time_t MTTime();
	// return true if the current time is adjusted
	BOOL TimeIsAdjusted();

	// add a request to the queue and signal the listening thread
	// if necessary.
	BOOL AddRequest(NTLogRequest * request);

  // @cmember The pointer to the LogServer object.
  static NTLogServer *  mpsLogServer ;
  // @cmember The reference counter 
  static DWORD          msNumRefs ;
  // @cmember The critical section lock 
  static NTThreadLock   msLock ;


  // @cmember The lock for insertion/removal of LogRequests on the queue.
  NTThreadLock          mQLock ;
  // @cmember The list of files to log data to
  MTLogFileColl         mFileList ;
  // @cmember The lock for access to the log file list
  NTThreadLock          mFileListLock ;
  // @cmember The counter for file numbers
  int                   mFileListNum ;
  // @cmember The event that signals the insertion of a LogRequest on the queue.
  HANDLE                mQEvent ;
  // @cmember The event that signals file rollover for all log files
  HANDLE                mRolloverEvent ;
  // @cmember The queue to hold the LogRequests.
  NTLogRequestColl      mQueue ;
	CacheMissList					mCacheMissList;
  // @cmember The flag to indicate whether it's ok to log data
  BOOL                  mOkToLogData ;
  ConfigChangeObservable mObservable;
  BOOL            mObserverInitialized ;
	
	LoggerInfo* mpCachedInfo;

	IMetraTimeClientPtr mTimeClient;

  BOOL                  mLogProcessName; 
  string                mProcessName; //Holds the name of the process (cmdstage.exe, inetinfo.exe,  etc.) to be written to the log

	// critical section that guards flushing messages to disk
  NTThreadLock  mFlushLock;

} ;

//
// definition of the NTLogFile class ...
//
// @class NTLogFile
class NTLogFile : public ObjectWithError
{
// @access Public:
public:
  // @cmember Constructor
  NTLogFile() ;
  // @cmember Destructor
  ~NTLogFile() ;

  // @cmember Initialize the LogFile object.
  BOOL Init(const LoggerInfo *apLoggerInfo) ;
  // @cmember add and entry to the log request queue
  BOOL ProcessLogRequest( NTLogRequest *apNTLogRequest) ;
  // @cmember add and entry to the log request queue
  BOOL WriteLogRequest(const NTLogRequest *apNTLogRequest) ;
  // @cmember Get the log file pointer
  FILE *GetLogFilePtr() const 
  { return mpFile ; }
  // @cmember Get the config path
  _bstr_t GetConfigPath() const 
  { return mConfigPath ; }
  // @cmember Get the filename
  _bstr_t GetFilename() const 
  { return mFilename ; }
  // @cmember Get the log level 
  MTLogLevel GetLogLevel() const
  { return mLogLevel ; }
  // @cmember get the port number for remote logging
  MTLogLevel GetLogSocketLevel() const 
    {return mLogSocketLevel; }
  // @cmember used to get the lowest level of message that should be logged (either to the file or to remote logging)
  MTLogLevel GetMinimumLogLevel() const
  { return max(mLogLevel,mLogSocketLevel);  }

  DWORD GetLogSocketPort() const 
  { return mLogSocketPort ; }
  _bstr_t GetLogSocketServer() const 
  { return mLogSocketServerName ; }
  _bstr_t GetLogSocketTag() const 
  { return mLogSocketTag ; }
  DWORD GetLogSocketFacility() const 
  { return mLogSocketFacility ; }
  BOOL GetLogSocketUseTcp() const 
  { return mLogSocketUseTcp ; }

  DWORD GetSyslogSeverityFromLogLevel(MTLogLevel aLogLevel);

    // @cmember get the number of days between rollovers
  DWORD GetLogRolloverAge() const 
    {return mLogRolloverAge ; }

  // @cmember get the number of messages in the circular buffer
  DWORD GetLogCircularBufferSize() const 
    {return mLogCircularBufferSize;}

  // @cmember get the trigger log level for filtered messages
  MTLogLevel GetLogFilterLevel() const 
    {return mLogFilterLevel ; }
  // @cmember get the trigger application tag for filtered messages
  _bstr_t GetLogFilterTag() const
    {return mLogFilterTag ;   }

  // @cmember is trigger disabled
  BOOL IsNotTriggerable()
  { return (mLogFilterLevel==0  &&  (!mLogFilterTag || mLogFilterTag.length()==0)) ? TRUE : FALSE; }
  // @cmember is triggered by this message
  BOOL IsTriggered(const NTLogRequest *apNTLogRequest);
  // @cmember is time to rollover log file now
  BOOL IsRolloverRequired();
  // @cmember rollover log file now
  BOOL Rollover(BOOL bForceRolloverNow);

// @access Private:
private:
  // @cmember The config path 
  _bstr_t mConfigPath ;
  // @cmember The filename
  _bstr_t mFilename ;
  // @cmember The log level
  MTLogLevel mLogLevel ;
  // @cmember The file pointer for the log file
  FILE      *mpFile ;
  MTLogLevel mLogSocketLevel ;
  // @cmember port number for remote logging
  DWORD mLogSocketPort;
  _bstr_t mLogSocketServerName;
  BOOL mLogSocketUseTcp;
  DWORD mLogSocketFacility;
  _bstr_t mLogSocketTag;
  _bstr_t mLogSocketMachineTagBuffer;  // A buffer to hold the "MachineName TagName" for syslog.

  // @cmember number of days between rollovers
  DWORD mLogRolloverAge;

  // @cmember number of messages in the circular buffer
  DWORD mLogCircularBufferSize;

  // @cmember trigger log level for filtered messages
  MTLogLevel mLogFilterLevel;
  // @cmember trigger application tag for filtered messages
  _bstr_t mLogFilterTag;
  // @cmember The queue to hold the LogRequests.
  NTLogRequestColl      mQueueForThisLog ;
  // @cmember The event that signals file rollover for all log files
  HANDLE                mRolloverEvent ;
  // @cmember log file is ripe for rollover
  BOOL mbRolloverRequired;
  CEasySocket * mSocket;
} ;

//
// definition of the NTLogRequest class ...
//
// @class LogRequest
class NTLogRequest : public ObjectWithError
{
// @access Public:
public:
  // @cmember Constructor
  NTLogRequest() ;
  // @cmember Destructor
  ~NTLogRequest() ;

  // @cmember Initialize the LogRequest object.
  BOOL Init(const char *apData, const int &arFileID, const char *apAppTag, 
    const MTLogLevel aLogLevel, time_t aMTTime) ;
  // @cmember Initialize the LogRequest object.
  BOOL Init(const wchar_t *apData, const int &arFileID, const char *apAppTag, 
    const MTLogLevel aLogLevel, time_t aMTTime) ;
  // @cmember Get a pointer to the data to be logged.
  char *GetData() const ;
  // @cmember Get the file id 
  int GetFileID() const ;
  // @cmember Get the log level 
  MTLogLevel GetLogLevel() const
  { return mLogLevel ; }
  struct tm *GetTimestamp() const 
  { return (tm *)&mlTime; }
  // @cmember get the application tag 
  _bstr_t GetTag() const
    {return mAppTag ;   }
// @access Private:
private:
  // @cmember Get the log level string
  void GetLogLevelString ( MTLogLevel aLogLevel, _bstr_t &arLogLevelString) ;

  // @cmember A pointer to the data to be logged.
  char    *mpData ;
  // A time structure for when the message was generated
  struct tm mlTime ;
  // @cmember The file id 
  int     mFileID ;
  _bstr_t mAppTag ;
  MTLogLevel mLogLevel ;
} ;

//
//	@mfunc
//	
//  @rdesc 
//  
// 
inline void NTLogRequest::GetLogLevelString ( MTLogLevel aLogLevel, 
                                            _bstr_t &arLogLevelString)
{
  switch (aLogLevel)
  {
  case LOG_FATAL:
    arLogLevelString = "FATAL" ;
    break ;
  case LOG_ERROR:
    arLogLevelString = "ERROR" ;
    break ;
  case LOG_WARNING:
    arLogLevelString = "WARNING" ;
    break ;
  case LOG_INFO:
    arLogLevelString = "INFO" ;
    break ;
  case LOG_DEBUG:
    arLogLevelString = "DEBUG" ;
    break ;
  case LOG_TRACE:
    arLogLevelString = "TRACE" ;
    break ;
  default:
    arLogLevelString = "Unknown" ;
    break ;
  }
}

//
//	@mfunc
//	Get the data to be logged.
//  @rdesc 
//  Returns the data to be logged.
// 
inline char *NTLogRequest::GetData() const 
{
  return mpData ;
}

//
//	@mfunc
//	Get the field id to log the data to
//  @rdesc 
//  Returns the file id
// 
inline int NTLogRequest::GetFileID() const 
{
  return mFileID ;
}



// reenable the warning
#pragma warning( default : 4251 4275)
#endif // __NTLOGSERVER_H
