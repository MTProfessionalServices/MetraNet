/**************************************************************************
 * @doc NTLOGGER
 * 
 * @module Logger class |
 *
 * This class is used to log data to the MetraTech file log or the Windows
 * NT based event log. 
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
 * $Header: NTLogger.cpp, 34, 8/26/2002 14:15:59, Ralf Boeck$
 *
 * @index | NTLOGGER
 ***************************************************************************/

#include <metra.h>
#include <NTLogger.h>
#include <NTLogServer.h>
#include <NTRegistryIO.h>
#include <stdio.h>
#include <stdarg.h>
#include <mtglobal_msg.h>
#if 0
#include <MTNotification.h>
#endif
#include <loggerinfo.h>

//
//	@mfunc
//	Constructor. Initialize the data members.
//  @rdesc 
//  No return value.
// 
NTLogger::NTLogger()
: mIsInitialized (FALSE), mpLogServer(NULL), mLogLevel (LOG_OFF), 
mpAppTag(NULL)
{
}

//
//	@mfunc
//	Copy constructor. Initialize the data members from another logger object.
//  @rdesc 
//  No return value.
// 

NTLogger::NTLogger(const NTLogger & arLogger)
: mIsInitialized (FALSE), mpLogServer(NULL), mLogLevel (LOG_OFF), 
mpAppTag(NULL)
{
	*this = arLogger;
}

NTLogger & NTLogger::operator =(const NTLogger & arLogger)
{
	mIsInitialized = arLogger.mIsInitialized;

  if (mpLogServer != NULL) mpLogServer->ReleaseInstance();
	if (arLogger.mpLogServer)
  {
		mpLogServer = NTLogServer::GetInstance() ;
  }
	else
  {
		mpLogServer = NULL;
  }

	mLogLevel = arLogger.mLogLevel;
  // copy the app tag ...
	// NOTE: the other logger might not yet have been initialized.
	//       we need to support this
  delete [] mpAppTag;
	if (arLogger.mpAppTag)
	{
		int nSize = strlen (arLogger.mpAppTag) ;
		mpAppTag = new char[nSize+1] ;
		ASSERT (mpAppTag) ;
		strcpy (mpAppTag, arLogger.mpAppTag) ;
	}
	else
  {
		mpAppTag = NULL;
  }

	mFileID = arLogger.mFileID;
	mEvtLogger = arLogger.mEvtLogger;
	return *this;
}


//
//	@mfunc
//	Destructor.
//  @rdesc 
//  No return value.
//  @devnote
//  Do NOT delete the mpLogServer. There is only one per process.                              
// 
NTLogger::~NTLogger()
{
  // release the instance of the log server
  if (mpLogServer != NULL)
  {
    mpLogServer->ReleaseInstance() ;
  }
  if (mpAppTag != NULL)
  {
    delete [] mpAppTag;
    mpAppTag = NULL ;
  }
}

//
// This method clears the buffers to ensure all logs messages are written to the MTLogs
// before an exception terminates execution
//
DLL_EXPORT void NTLogger::FlushAllMessages()
{
 if(mpLogServer != NULL)
{
 mpLogServer->FlushAll();
}
}

//
//	@mfunc
//	Initialize the NTLogger class. Initialize the NTEventLogger class and get a 
//  pointer to the LogServer.
//	@parm The application name 
//  @rdesc 
//  Returns TRUE on succesful initialization. Otherwise, FALSE is returned.
//  @devnote
//  This routine should be called before logging data to the MetraTech file log or the 
//  Windows NT event log.
// 
BOOL NTLogger::Init(LoggerInfo *apLoggerInfo, const char *apAppTag)
{
	// if it's already initialized, return immediately
	if (mIsInitialized)
	{
		delete apLoggerInfo;
		return TRUE;
	}

  // local variables ...
  BOOL bRetCode=TRUE ;
  DWORD nError=NO_ERROR ;
  DWORD nSize ;
  
  // check to see if we have config info ...
  //ASSERT (apLoggerInfo) ;
  if (apLoggerInfo == NULL)
  {
    bRetCode = FALSE ;
    SetError (CORE_ERR_NO_CONFIG_INFO, ERROR_MODULE, ERROR_LINE, 
		"NTLogger::Init",
	  "logging.xml file error: Either a property is missing or the log file could not be opened (nonexistent directory)");
    return bRetCode ;
  }
  // copy the app tag ...
  ASSERT (apAppTag) ;
  nSize = strlen (apAppTag) ;
  ASSERT (NULL == mpAppTag) ;
  mpAppTag = new char[nSize+1] ;
  ASSERT (mpAppTag) ;
  strcpy (mpAppTag, apAppTag) ;

  // get a ptr to the LogServer ...
  ASSERT(NULL == mpLogServer);
  mpLogServer = NTLogServer::GetInstance() ;
  if (mpLogServer == NULL)
  {
    bRetCode = FALSE ;
    SetError (CORE_ERR_NO_INSTANCE, ERROR_MODULE, ERROR_LINE, 
      "NTLogger::Init", "Unable to get an instance of the LogServer");
  }
  // otherwise ... add the log file to the log server ...
  else
  {
    // add the config dir to the log server ...
    bRetCode = mpLogServer->AddConfigInfo (apLoggerInfo, mFileID) ;
    if (bRetCode == FALSE)
    {
	  //DWORD err = mpLogServer->GetLastError();
	  DWORD err = ::GetLastError();
	  if (err == ERROR_ACCESS_DENIED)
		  SetError(CORE_ERR_INCORRECT_PERMISSIONS_ON_LOGFILE, ERROR_MODULE, ERROR_LINE, 
					"The permissions on the log file are incorrect.");
	  else if (err == ERROR_PATH_NOT_FOUND)
			SetError(CORE_ERR_INVALID_LOGFILE_PATH, ERROR_MODULE, ERROR_LINE, "The log file path is incorrect.");
	  else
		SetError (CORE_ERR_UNKNOWN_ERROR, ERROR_MODULE, ERROR_LINE,
			"Unable add the config path to the LogServer") ;
    }
    // otherwise ... we're initialized ...
    else
    {
      mLogLevel = apLoggerInfo->GetLogLevel() ;
      mIsInitialized = TRUE ;
    }
  }

  // delete the loggerinfo ...
  if (apLoggerInfo != NULL)
  {
    delete apLoggerInfo ;
  }

  return bRetCode ;
}

DLL_EXPORT void NTLogger::SetApplicationTag(const char *apAppTag)
{
  //Remove old app tag
  if (mpAppTag != NULL)
  {
    delete [] mpAppTag;
    mpAppTag = NULL ;
  }

  //Set the app tag ...
  ASSERT (apAppTag) ;
  int nSize = strlen (apAppTag) ;
  mpAppTag = new char[nSize+1] ;
  ASSERT (mpAppTag) ;
  strcpy (mpAppTag, apAppTag) ;

  return;
}

DLL_EXPORT const char * NTLogger::GetApplicationTag()
{
  return mpAppTag;
}

//
//	@mfunc
//  force all the log files in this loger to rollover
// 
BOOL NTLogger::Rollover ()
{
  // local variables 
  BOOL bRetCode=TRUE ;

  bRetCode = mpLogServer->Rollover (TRUE) ;
  if (bRetCode == FALSE)
  {
    SetError (CORE_ERR_UNKNOWN_ERROR, ERROR_MODULE, ERROR_LINE,
      "Unable to rollover log file.") ;
  }

  return (bRetCode) ;
}

//
//	@mfunc
//	Log this data at the appropriate log level to the specified log location
//	@parm The data to be logged.
//  @parm The log level
//  @parm The location to log the data
//  @rdesc 
//  Returns TRUE on success. Otherwise, FALSE is returned.
//  @devnote
//  The Init() routine should be called before calling this routine.
// 
BOOL NTLogger::LogThis (const MTLogLevel aLogLevel, const char *apData)
{
  // local variables 
  BOOL bRetCode=TRUE ;

  // check to see if we are ok to log this message ...
  bRetCode = IsOkToLog(aLogLevel) ;
  if (bRetCode == FALSE)
  {
    return TRUE ;
  }
  // log the data ...
  bRetCode = mpLogServer->LogThis (apData, mFileID, mpAppTag, aLogLevel) ;
  if (bRetCode == FALSE)
  {
    SetError (CORE_ERR_UNKNOWN_ERROR, ERROR_MODULE, ERROR_LINE,
      "Unable to log to log file.") ;
  }

  return (bRetCode) ;
}

//
//	@mfunc
//	Log this data at the appropriate log level to the specified log location
//	@parm The data to be logged.
//  @parm The log level
//  @parm The location to log the data
//  @rdesc 
//  Returns TRUE on success. Otherwise, FALSE is returned.
//  @devnote
//  The Init() routine should be called before calling this routine.
// 
BOOL NTLogger::LogThis (const MTLogLevel aLogLevel, const wchar_t *apData)
{
  // local variables 
  BOOL bRetCode=TRUE ;

  // check to see if we are ok to log this message ...
  bRetCode = IsOkToLog(aLogLevel) ;
  if (bRetCode == FALSE)
  {
    return TRUE ;
  }
  // log the data ...
  bRetCode = mpLogServer->LogThis (apData, mFileID, mpAppTag, aLogLevel) ;
  if (bRetCode == FALSE)
  {
    SetError (CORE_ERR_UNKNOWN_ERROR, ERROR_MODULE, ERROR_LINE,
      "Unable to log to log file.") ;
  }
  
  return (bRetCode) ;
}

//
//	@mfunc
//	Check to see if its ok to log at the specified log level.
//	@parm The log level
//  @rdesc 
//  Returns TRUE if it's ok to log at the specified log level. Otherwise, FALSE is returned.
// 
BOOL NTLogger::IsOkToLog (const MTLogLevel aLogLevel)
{
	return mIsInitialized && mpLogServer->IsOkToLog(aLogLevel, mFileID);
}


//
//	@mfunc
//	Log this data at the appropriate log level to the specified log location
//	@parm The data to be logged.
//  @parm The log level
//  @rdesc 
//  Returns TRUE on success. Otherwise, FALSE is returned.
//  @devnote
//  The Init() routine should be called before calling this routine.
// 
#define VAR_ARGS_BUFF_SIZE 2048

BOOL NTLogger::LogVarArgs (const MTLogLevel aLogLevel,
                           const char *pFormat, ...)
{
  // local variables 
  BOOL bRetCode=TRUE ;

  // check to see if we are ok to log this message ...
  bRetCode = IsOkToLog(aLogLevel) ;
  if (bRetCode == FALSE)
  {
    return TRUE ;
  }
  // convert the variable argument list to a character buffer ...
  // allocate big buffer on the heap
  char* bBuf = new char[VAR_ARGS_BUFF_SIZE] ;

  // start the try to catch any error from vsprintf ...
  try
  {
    va_list arglist ;
    va_start (arglist, pFormat) ;
    int charsWritten = _vsnprintf (bBuf,VAR_ARGS_BUFF_SIZE,pFormat, arglist) ;

    //if buffer is exceeded, null terminate with "...\0"
    if( charsWritten < 0 )
      strcpy( bBuf + VAR_ARGS_BUFF_SIZE - 4, "...");

    va_end (arglist) ;
  }
  catch (...)
  {
    // vsprintf failed ... log the formatted string ...
    strcpy (bBuf, "Unable to expand formatted string.") ;
    strcat (bBuf, pFormat) ;
  }

  // log the data ...
  bRetCode = mpLogServer->LogThis (bBuf, mFileID, mpAppTag, aLogLevel) ;
  if (bRetCode == FALSE)
  {
    SetError (CORE_ERR_UNKNOWN_ERROR, ERROR_MODULE, ERROR_LINE,
      "Unable to log to log file.") ;
  }

  delete[] bBuf;

  return (bRetCode) ;
}

//
//	@mfunc
//	Log this data at the appropriate log level to the specified log location
//	@parm The data to be logged.
//  @parm The log level
//  @parm The location to log the data
//  @rdesc 
//  Returns TRUE on success. Otherwise, FALSE is returned.
//  @devnote
//  The Init() routine should be called before calling this routine.
// 
BOOL NTLogger::LogVarArgs (const MTLogLevel aLogLevel,
                           const wchar_t *pFormat, ...)
{
  // local variables 
  BOOL bRetCode=TRUE ;

  // check to see if we are ok to log this message ...
  bRetCode = IsOkToLog(aLogLevel) ;
  if (bRetCode == FALSE)
  {
    return TRUE ;
  }
  // convert the variable argument list to a character buffer ...
  // allocate big buffer on the heap
  wchar_t* bBuf = new wchar_t[VAR_ARGS_BUFF_SIZE] ;
  
  // start the try to catch any error from vswprintf ...
  try
  {
    va_list arglist ;
    va_start (arglist, pFormat) ;
    int charsWritten = _vsnwprintf (bBuf, VAR_ARGS_BUFF_SIZE, pFormat, arglist) ;

    //if buffer is exceeded, null terminate with "...\0"
    if( charsWritten < 0 )
      wcscpy( bBuf + VAR_ARGS_BUFF_SIZE - 4, L"...");

    va_end (arglist) ;
  }
  catch (...)
  {
    // vswprintf failed ... log the formatted string ...
    wcscpy (bBuf, L"Unable to expand formatted string.") ;
    wcscat (bBuf, pFormat) ;
  }


  // log the data ...
  bRetCode = mpLogServer->LogThis (bBuf, mFileID, mpAppTag, aLogLevel) ;
  if (bRetCode == FALSE)
  {
    SetError (CORE_ERR_UNKNOWN_ERROR, ERROR_MODULE, ERROR_LINE,
      "Unable to log to log file.") ;
  }

  delete[] bBuf;

  return (bRetCode) ;
}

//
//	@mfunc
//	Log this data at the appropriate log level to the specified log location
//	@parm The data to be logged.
//  @parm The log level
//  @parm The location to log the data
//  @rdesc 
//  Returns TRUE on success. Otherwise, FALSE is returned.
//  @devnote
//  The Init() routine should be called before calling this routine.
// 
BOOL NTLogger::LogErrorObject (const MTLogLevel aLogLevel, 
                               const ErrorObject *apError)
{
  // local variables 
  BOOL bRetCode=TRUE ;

  // check to see if we are ok to log this message ...
  bRetCode = IsOkToLog(aLogLevel) ;
  if (bRetCode == FALSE)
  {
    return TRUE ;
  }

  //don't crash if apError is NULL
  if (apError == NULL)
  {
    bRetCode = LogThis (aLogLevel, "Error occurred (ErrorObject is NULL)");
    ASSERT(false); //apError should not be NULL
  }
  else
  {
    // get the error object detail ...
    const string & strDetail = apError->GetProgrammerDetail() ;
    if (strDetail.length() != 0)
    {      
      // log the error object ...
      bRetCode = LogVarArgs (aLogLevel, 
        "%s\n          Error 0x%x occurred in module %s in function %s on line %d",
        strDetail.c_str(), apError->GetCode(), apError->GetModuleName(), 
        apError->GetFunctionName(), apError->GetLineNumber()) ;
    }
    else
    {      
      // log the error object ...
      bRetCode = LogVarArgs (aLogLevel,
        "Error 0x%x occurred in module %s in function %s on line %d",
        apError->GetCode(), apError->GetModuleName(), apError->GetFunctionName(), 
        apError->GetLineNumber()) ;
    }
  }
  if (bRetCode == FALSE)
  {
    SetError (CORE_ERR_UNKNOWN_ERROR, ERROR_MODULE, ERROR_LINE,
      "Unable to log to log file.") ;
  }

  return (bRetCode) ;
}


//
//	@mfunc
//	Log the event id to the NT event log. Log the raw data also if any was 
//  specified.
//	@parm The event id to be logged
//  @parmopt The size of the raw data
//  @parmopt The raw data
//  @rdesc 
//  Returns TRUE on success. Otherwise, FALSE is returned.
//  @devnote
//  The Init() routine should be called before calling this routine.
// 
BOOL NTLogger::LogEvent (const DWORD aEventID, const DWORD aRawDataSize, 
                         void *apRawData)
{
  // local variables 
  BOOL bRetCode=TRUE ;

  // if we are not initialized ... return FALSE ...
  if (mIsInitialized == FALSE)
  {
    return FALSE ;
  }
  // if the event logger isnt initialized ... call Init()
  if (mEvtLogger.IsInitialized() == FALSE)
  {
    bRetCode = mEvtLogger.Init(MTGLOBAL_MSG_FILE) ;
    if (bRetCode == FALSE)
    {
      bRetCode = mEvtLogger.Init(MTGLOBAL_MSG_FILE_D) ;
      if (bRetCode == FALSE)
      {
        SetError (mEvtLogger.GetLastError()) ;
        return FALSE ;
      }
    }
  }
  // create the event msg that will be used to send the event log message ...
  NTEventMsg EvtMsg(aEventID, aRawDataSize, apRawData) ;

  // send the EventMsg ...
  bRetCode = mEvtLogger.Submit (EvtMsg) ;

  return bRetCode ;
}


//
//	Logs the event string to the NT event log.
//  Returns TRUE on success. Otherwise, FALSE is returned.
//  The Init() routine should be called before calling this routine.
// 
BOOL NTLogger::LogEvent(const NTEventMsg::EventType logLevel, const char *msg)
{
  if (!mIsInitialized)
    return FALSE;

  // if the event logger isnt initialized call Init()
  if (!mEvtLogger.IsInitialized())
  {
    if (!mEvtLogger.Init(MTGLOBAL_MSG_FILE))
    {
      SetError(mEvtLogger.GetLastError());
      return FALSE;
    }
  }

  // sends the event to the event log
  NTEventMsg event(logLevel, msg);
  return mEvtLogger.Submit(event);
}


#if 0
//
//	@mfunc
//	Log this event id at the appropriate log level to the specified log location
//	@parm The event id to be logged.
//  @parm The log level
//  @parm The location to log the data
//  @rdesc 
//  Returns TRUE on success. Otherwise, FALSE is returned.
//  @devnote
//  The Init() routine should be called before calling this routine.
// 
BOOL NTLogger::LogThis (const DWORD aEventID, const MTLogLevel aLogLevel, 
    const MTLoggingLocation aLoggingLocation)
{
  // local variables 
  BOOL bRetCode1=TRUE ;
  BOOL bRetCode2=TRUE ;
  char *pData=NULL ;

  // check to see if we are ok to log this message ...
  bRetCode1 = IsOkToLog(aLogLevel) ;
  if (bRetCode1 == FALSE)
  {
    return TRUE ;
  }
  // if we are logging to the FILE_LOG or the FILE_AND_EVENT_LOG ...
  if ((aLoggingLocation == FILE_LOG) || (aLoggingLocation == FILE_AND_EVENT_LOG))
  {
    // call GetMessageString to get the string we want to log  ...
    pData = mEvtLogger.GetMessageString (aEventID) ;

    // if we got the message string ...
    if (pData != NULL)
    {
      bRetCode1 = mpLogServer->LogThis (pData, aLogLevel) ;
    }
    // otherwise ... indicate error
    else
    {
      bRetCode1 = FALSE ;
    }
  }
  // if we are logging to the EVENT_LOG or the FILE_AND_EVENT_LOG ...
  if ((aLoggingLocation == EVENT_LOG) || (aLoggingLocation == FILE_AND_EVENT_LOG))
  {
    // log the event ...
    bRetCode2 = LogEvent (aEventID) ;
  }
  // return TRUE only if both succeeded ...
  return (bRetCode1 && bRetCode2) ;
}

//
//	@mfunc
//	Log this event id with the passed arguments at the appropriate log level
//  to the specified log location
//	@parm The event id to be logged.
//  @parm The substitution strings
//  @parm The log level
//  @parm The location to log the data
//  @rdesc 
//  Returns TRUE on success. Otherwise, FALSE is returned.
//  @devnote
//  The Init() routine should be called before calling this routine.
// 
BOOL NTLogger::LogThis (const DWORD aEventID, const NTEventArgs &aArgs, 
    const MTLogLevel aLogLevel, const MTLoggingLocation aLoggingLocation)
{
  // local variables 
  BOOL bRetCode1=TRUE ;
  BOOL bRetCode2=TRUE ;
  char *pData=NULL ;

  // check to see if we are ok to log this message ...
  bRetCode1 = IsOkToLog(aLogLevel) ;
  if (bRetCode1 == FALSE)
  {
    return TRUE ;
  }
  // if we are logging to the FILE_LOG or the FILE_AND_EVENT_LOG ...
  if ((aLoggingLocation == FILE_LOG) || (aLoggingLocation == FILE_AND_EVENT_LOG))
  {
    // call GetMessageString to get the string we want to log  ...
    pData = mEvtLogger.GetMessageString (aEventID, aArgs) ;

    // if we got the message string ...
    if (pData != NULL)
    {
      bRetCode1 = mpLogServer->LogThis (pData, aLogLevel) ;
    }
    // otherwise ... indicate error
    else
    {
      bRetCode1 = FALSE ;
    }
  }
  // if we are logging to the EVENT_LOG or the FILE_AND_EVENT_LOG ...
  if ((aLoggingLocation == EVENT_LOG) || (aLoggingLocation == FILE_AND_EVENT_LOG))
  {
    // log the event ...
    bRetCode2 = LogEvent (aEventID, aArgs) ;
  }
  // return TRUE only if both succeeded ...
  return (bRetCode1 && bRetCode2) ;
}


//
//	@mfunc
//	Log the event id with the passed arguments to the NT event log. Log the raw data also 
//  if any was specified.
//	@parm The event id to be logged
//  @parm The substitution strings
//  @parmopt The size of the raw data
//  @parmopt The raw data
//  @rdesc 
//  Returns TRUE on success. Otherwise, FALSE is returned.
//  @devnote
//  The Init() routine should be called before calling this routine.
// 
BOOL NTLogger::LogEvent (const DWORD aEventID, const NTEventArgs &aArgs, const DWORD aRawDataSize, 
    void *apRawData)
{
  // local variables 
  BOOL bRetCode=TRUE ;

  // if we are not initialized ... return FALSE ...
  if (mIsInitialized == FALSE)
  {
    return FALSE ;
  }
  // create the event msg that will be used to send the event log message ...
  NTEventMsg EvtMsg(aEventID, aArgs, aRawDataSize, apRawData) ;

  // send the EventMsg ...
  bRetCode = mEvtLogger.Submit (EvtMsg) ;

  return bRetCode ;
}

#endif

