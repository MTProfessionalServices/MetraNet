/**************************************************************************
 * @doc NTEVENTLOGGER
 * 
 * @module Windows NT Event Log encapsulation |
 * 
 * This class encapsulates the Win32 calls used to log events to the 
 * Windows NT event log.
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
 * @index | NTEVENTLOGGER
 ***************************************************************************/

#include <metra.h>
#include <NTEventLogger.h>
#include <LoggerEnums.h>

//
//	@mfunc
//	Constructor. Initialize the data members
//  @rdesc 
//  No return value
// 
NTEventLogger::NTEventLogger() 
: mpSid(NULL), mEvtMsgFile(NULL), mpData(NULL), mIsInitialized(FALSE),
mpAppName(NULL), mEvtLog(INVALID_HANDLE_VALUE)
{
}

//
//	@mfunc
//	Destructor. Free handles and allocated memory.
//  @rdesc 
//  No return value.
// 

NTEventLogger::~NTEventLogger() 
{
  // local variables ...
  BOOL bRetCode=TRUE ;

  // delete allocated data ...
  if (mpAppName != NULL)
  {
    delete [] mpAppName ;
    mpAppName = NULL ;
  }
  if (mpSid != NULL)
  {
    delete [] mpSid ;
    mpSid = NULL ;
  }
  if (mpData != NULL)
  {
    ::LocalFree (mpData) ;
  }
 
  // free the library ...
  if (mEvtMsgFile != NULL)
  {
    ::FreeLibrary (mEvtMsgFile) ;
  }
  // deregister the event source ...
  if (mEvtLog != INVALID_HANDLE_VALUE)
  {
    bRetCode = ::DeregisterEventSource (mEvtLog) ;
    if (bRetCode == FALSE)
    {
      SetError (::GetLastError(), ERROR_MODULE, ERROR_LINE, "NTEventLogger::~NTEventLogger") ;
    }
  }
}

//
//	@mfunc
//	Initialize the NTEventLogger class. Copy the application name, register the event source,
//  get the user Sid, and open the message file.
//	@parm The application name
//  @rdesc 
//  Returns TRUE on success. Otherwise, FALSE is returned and the error code gets saved in the
//  mLastError data member
//  @devnote
//  This routine should be called before calling any of the other routines.
// 
#if 1
BOOL NTEventLogger::Init(const wchar_t *apModuleName)
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  
  // load the library specified ...
  ASSERT (apModuleName) ;
  mEvtMsgFile = ::LoadLibraryW(apModuleName) ;
  if (mEvtMsgFile == NULL)
  {
    SetError (::GetLastError(), ERROR_MODULE, ERROR_LINE, "NTEventLogger::Init") ;
    bRetCode = FALSE ;
  }
  else
  {
    // get the user sid ...
    bRetCode = GetUserSid() ;
    if (bRetCode == TRUE)
    {
      // register the event source ...
      mEvtLog = ::RegisterEventSourceW (NULL, L"NetMeter") ;
      if (mEvtLog == INVALID_HANDLE_VALUE)
      {
        SetError (::GetLastError(), ERROR_MODULE, ERROR_LINE, "NTEventLogger::Init") ;
        bRetCode = FALSE ;
      }
      else
      {
        mIsInitialized = TRUE ;
      }
    }
  }

  return bRetCode ;
}

#else
BOOL NTEventLogger::Init(const _TCHAR *apAppName)  
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  DWORD nError=NO_ERROR ;

  // start the try ...
  try
  { 
    // if the app name is not valid ...
    if (apAppName == NULL)
    {
      nError = ERROR_INVALID_PARAMETER ;
      throw nError ;
    }
    // copy the application name ...
    mpAppName = new _TCHAR [(_tcslen (apAppName) + 1) * sizeof (_TCHAR)] ;
    if (mpAppName == NULL)
    {
      nError = ::GetLastError() ;
      throw nError ;
    }
    _tcscpy (mpAppName, apAppName) ;
 
    // register the event source ...
    mEvtLog = ::RegisterEventSource (NULL, mpAppName) ;
    if (mEvtLog == INVALID_HANDLE_VALUE)
    {
      nError = ::GetLastError() ;
      throw nError ;
    }
    // get the user sid ...
    nError = GetUserSid() ;
    if (nError != NO_ERROR)
    {
      throw nError ;
    }
    // open the message file ...
    nError = OpenMessageFile() ;
    if (nError != NO_ERROR)
    {
      throw nError ;
    }
  }
  catch (DWORD nStatus) 
  {
    mLastError = nStatus ;
    bRetCode = FALSE ;
  }

  return bRetCode ;
}
#endif
//
//	@mfunc
//	Write the event to the Windows NT event log.
//	@parm The event message to write to the event log.
//  @rdesc 
//  Returns TRUE on success. Otherwise, FALSE is returned and the error code is saved in
//  the mLastError data member.
//  @devnote
//  The Init() routine should be called before calling this routine.
// 
BOOL NTEventLogger::Submit(NTEventMsg &arEvtMsg) 
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  WORD wEvtType=0 ;

  // transform the severity into the appropriate type ...
  switch (arEvtMsg.GetSeverity())
  {
  case NTEventMsg::EVENT_INFO:
    wEvtType = EVENTLOG_INFORMATION_TYPE;
    break;

  case NTEventMsg::EVENT_WARNING:
    wEvtType = EVENTLOG_WARNING_TYPE;
    break;

  case NTEventMsg::EVENT_ERROR:
    wEvtType = EVENTLOG_ERROR_TYPE;
    break;

  default:
    bRetCode = FALSE ;
    return bRetCode ;
    break;
  }

  // call ::ReportEvent to log the message to the Windows NT event log ...
  bRetCode = ::ReportEventA(mEvtLog, wEvtType, 0, arEvtMsg.GetEventId(), mpSid, arEvtMsg.GetNumArgs(),
    arEvtMsg.GetRawDataSize(), (const char **) arEvtMsg.GetArgs(), arEvtMsg.GetRawData()) ;
  if (bRetCode == FALSE)
  {
    SetError (::GetLastError(), ERROR_MODULE, ERROR_LINE, "NTEventLogger::Submit") ;
    bRetCode = FALSE ;
  }

  return bRetCode ;
}

//
//	@mfunc
//	Get the message string associated with the event id.
//	@parm The event id to get the message for
//  @rdesc 
//  Returns a pointer to the message string. 
// 
char *NTEventLogger::GetMessageString (const DWORD aEventID)
{
  // local variables ...
	DWORD	flags;
  DWORD nError=NO_ERROR ;

  // delete the data from a previous GetMessageString ...
  if (mpData != NULL)
  {
    ::LocalFree (mpData) ;
    mpData = NULL ;
  }
  // setup the flags for the ::FormatMessage call ...
	flags = FORMAT_MESSAGE_FROM_HMODULE | FORMAT_MESSAGE_FROM_SYSTEM | 
    FORMAT_MESSAGE_ALLOCATE_BUFFER	| FORMAT_MESSAGE_ARGUMENT_ARRAY	|	FORMAT_MESSAGE_MAX_WIDTH_MASK;

  // call ::FormatMessage to get the string associated with the aEventID ...
  nError = ::FormatMessageA (flags, mEvtMsgFile, aEventID, 0, (char *) &mpData, 0, NULL) ;
  if (nError == 0)
  {
    SetError (::GetLastError (), ERROR_MODULE, ERROR_LINE, "NTEventLogger::GetMessageString") ;
    mpData = NULL ;
  }

  return mpData ;
}

//
//	@mfunc
//	Get the message string associated with the event id.
//	@parm The event id to get the message for
//  @parm The substitution string(s)
//  @rdesc 
//  Returns a pointer to the message string. 
// 
char *NTEventLogger::GetMessageString (const DWORD aEventID, NTEventArgs aArgs)
{
  // local variables ...
  wchar_t *pData=NULL ;
	DWORD	flags;
  DWORD nError=NO_ERROR ;

  // delete the data from a previous GetMessageString ...
  if (mpData != NULL)
  {
    ::LocalFree (mpData) ;
    mpData = NULL ;
  }
  // setup the flags for the ::FormatMessage call ...
	flags = FORMAT_MESSAGE_FROM_HMODULE | FORMAT_MESSAGE_FROM_SYSTEM | 
    FORMAT_MESSAGE_ALLOCATE_BUFFER	| FORMAT_MESSAGE_ARGUMENT_ARRAY	|	FORMAT_MESSAGE_MAX_WIDTH_MASK;

  // call ::FormatMessage to get the string associated with the aEventID ...
  nError = ::FormatMessage (flags, mEvtMsgFile, aEventID, 0, (LPTSTR) &mpData, 0, 
    (char **) aArgs.GetArgList()) ;
  if (nError == 0)
  {
    SetError (::GetLastError (), ERROR_MODULE, ERROR_LINE, "NTEventLogger::GetMessageString") ;
    mpData = NULL ;
  }

  return mpData ;
}
//
//	@mfunc
//	Get the user's Sid
//  @rdesc 
//  Returns the error code. On success, the errorcode will be NO_ERROR.  
// 
BOOL NTEventLogger::GetUserSid()
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  HANDLE hPseudo=INVALID_HANDLE_VALUE ;
  HANDLE hProcessToken=INVALID_HANDLE_VALUE ;
  DWORD actualLength = 0;
  const DWORD bufferSize = 128 ; // big enough for the TokenUser information
  char buffer[bufferSize];
  TOKEN_USER *pProcUserToken=NULL ;
  DWORD nSidLen=0 ;

  // get the pseudo handle to the current process ... always returns pseudo handle ...
  hPseudo = ::GetCurrentProcess() ;
  
  // open the access token for the current process with TOKEN_READ access ...
  memset(buffer,0,bufferSize);  
  bRetCode = ::OpenProcessToken (hPseudo, TOKEN_READ, &hProcessToken );
  if (bRetCode == FALSE )
  {
    SetError (::GetLastError(), ERROR_MODULE, ERROR_LINE, "NTEventLogger::GetUserSid") ;
    return bRetCode ;
  }
  // get the process security token for the use (TokenUser) ...
  bRetCode = ::GetTokenInformation (hProcessToken, TokenUser, buffer, bufferSize, &actualLength );
  if (bRetCode == FALSE)
  {
    SetError (::GetLastError(), ERROR_MODULE, ERROR_LINE, "NTEventLogger::GetUserSid") ;
    return bRetCode ;
  }
  // get a pointer to the TOKEN_USER information ...
  pProcUserToken = (TOKEN_USER *)buffer;
  
  // get the length of the sid ...
  nSidLen = ::GetLengthSid( pProcUserToken->User.Sid );
  
  // allocate the appropriate size for the SID ...
  mpSid = (PSID) new BYTE [nSidLen + 1] ;
  if (mpSid == NULL)
  {
    bRetCode = FALSE ;
    SetError (::GetLastError(), ERROR_MODULE, ERROR_LINE, "NTEventLogger::GetUserSid") ;
    return bRetCode ;
  }
  
  // copy the Sid to our local copy ...
  bRetCode = ::CopySid(nSidLen, mpSid, pProcUserToken->User.Sid ) ;
  if (bRetCode == FALSE)
  {
    SetError (::GetLastError(), ERROR_MODULE, ERROR_LINE, "NTEventLogger::GetUserSid") ;
    return bRetCode ;
  }
  
  // close the process handle ... 
  if (hProcessToken != INVALID_HANDLE_VALUE)
  {
    ::CloseHandle (hProcessToken);
  }
  // we do NOT need to close the pseudo handle ... pseudo handle's do not need
  // to be closed explicitly via CloseHandle ... 

  return bRetCode ;
}

#if 0
//
//	@mfunc
//	Open the message file
//  @rdesc 
//  Returns the error code. On success, the errorcode will be NO_ERROR.  
// 
DWORD NTEventLogger::OpenMessageFile()
{
  // local variables ...
  DWORD nError=NO_ERROR ;
  const DWORD nSize=512 ; // no max ... allocated a large amount 
  BYTE *pBuffer=NULL ;
  _TCHAR regKey[nSize] ;
  _TCHAR *pString ;
  DWORD nRetSize ;
  BOOL bRetCode=TRUE ;
  NTRegistryIO RegIO ;

  // start the try ...
  try
  {
    // allocate memory for the string ...
    pBuffer = new BYTE[nSize] ;
    if (pBuffer == NULL)
    {
      nError = ::GetLastError() ;
      throw nError ;
    }
    // create the registry path we want to read from ...
    memset (regKey, 0, nSize) ;
    _tcscpy(regKey, _T("SYSTEM\\CurrentControlSet\\Services\\EventLog\\Application\\")) ;
    _tcscat(regKey, mpAppName );

    // open the registry with the registry writer ...
    bRetCode = RegIO.OpenRegistryRaw (NTRegistryIO::NTRegTree::LOCAL_MACHINE, regKey, 
      RegistryIO::AccessType::READ_ACCESS);
    if (bRetCode == FALSE)
    {
      nError = ERROR_INVALID_FUNCTION ; // RegWrite.GetLastError() ;
      throw nError ;
    }
    // read in the EventMessageFile registry value ...
    nRetSize = nSize ;
    bRetCode = RegIO.ReadRegistryValue (_T("EventMessageFile"), RegistryIO::ValueType::STRING,
      pBuffer, nRetSize) ;
    if (bRetCode == FALSE)
    {
      nError = ERROR_INVALID_FUNCTION ; // RegWrite.GetLastError() ;
      throw nError ;
    }
    pString = (_TCHAR *) pBuffer ;

    // load the event message library DLL ...
    mEvtMsgFile = ::LoadLibrary(pString) ;
    if (mEvtMsgFile == NULL)
    {
      nError = ::GetLastError() ;
      throw nError ;
    }
  }
  catch (DWORD nStatus)
  {
    nError = nStatus ;
  }
  // close the registry writer ...
  RegIO.CloseRegistry() ;

  return nError ;
}
#endif
