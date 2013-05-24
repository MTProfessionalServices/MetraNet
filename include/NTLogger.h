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
 * $Header$
 *
 * @index | NTLOGGER
 ***************************************************************************/

#ifndef __NTLOGGER_H
#define __NTLOGGER_H

#include <comdef.h>
#include <LoggerEnums.h>
#include <errobj.h>
#include <NTEventLogger.h>
#include <MTUtil.h>
#include <loggerinfo.h>

#define MTGLOBAL_MSG_FILE_D     L"mtglobal_msgd.dll"
#define MTGLOBAL_MSG_FILE       L"mtglobal_msg.dll"

// #defines for application tags ...
#define DBACCESS_TAG			"[DBAccess]"
#define DBOBJECTS_TAG			"[DBObjects]"
#define PIPELINE_TAG			"[Pipeline]"
#define LISTENER_TAG			"[Listener]"
#define KIOSK_TAG				"[Kiosk]"
#define CORE_TAG				"[Core]"
#define DBSVCS_TAG				"[DBSvcs]"
#define DBINSTALL_TAG			"[DBInstall]"
#define CONFIGLOADER_TAG		"[ConfigLoader]"
#define DB_SMOKE_TEST_TAG		"[DBSmokeTest]"
#define CODE_LOOKUP_TAG			"[CodeLookup]"
#define SERVICES_TAG			"[Services]"
#define PRODUCT_VIEW_TAG		"[ProductView]"
#define RULESETCONFIG_TAG       "[RuleSet]"
#define CALENDARLOGGER_TAG      "[Calendar]"
#define MODULEREADER_TAG        "[ModuleReader]"
#define INSTALL_TAG             "[Install]"
#define MTLDAP_TAG              "[MTLDAP]"
#define CREDITCARDACCOUNT_TAG   "[CreditCardAccount]"
#define MTACCOUNT_TAG           "[MTAccount]"

// forward declarations
class NTLogServer ;

// disable warning ...
#pragma warning( disable : 4251 4275 )

// @class NTLogger 
class NTLogger : public virtual ObjectWithError
{
// @access Public:
public:
  DLL_EXPORT void FlushAllMessages();
  // @cmember Constructor
  DLL_EXPORT NTLogger() ;
  // @cmember Copy constructor
  DLL_EXPORT NTLogger(const NTLogger & arLogger) ;
  // @cmember Destructor
  DLL_EXPORT ~NTLogger() ;

	DLL_EXPORT NTLogger & operator =(const NTLogger & arLogger);

  // @cmember Initialize the NTLogger.
  DLL_EXPORT BOOL Init(LoggerInfo *apLoggerInfo, const char *apAppTag) ;
  DLL_EXPORT void SetApplicationTag(const char *apAppTag) ;
  DLL_EXPORT const char * GetApplicationTag();

  // @cmember force a rollover of the log files in this object
  DLL_EXPORT BOOL Rollover() ;
  // @cmember Log the data to the log at the log level specified.
  DLL_EXPORT BOOL LogThis (const MTLogLevel aLogLevel, const char *apData) ;
  // @cmember Log the data to the log at the log level specified.
  DLL_EXPORT BOOL LogThis (const MTLogLevel aLogLevel, const wchar_t *apData) ;
  // @cmember Log the variable argument data to tje log file
  DLL_EXPORT BOOL LogVarArgs (const MTLogLevel aLogLevel, const char *pFormat, ...) ;
  // @cmember Log the variable argument data to tje log file
  DLL_EXPORT BOOL LogVarArgs (const MTLogLevel aLogLevel, const wchar_t *pFormat, ...) ;
  // @cmember Log the error object 
  DLL_EXPORT BOOL LogErrorObject (const MTLogLevel aLogLevel, const ErrorObject *apError) ;

  // @cmember Log the event id to the NT event log. Log the raw data also if any was specified.
  DLL_EXPORT BOOL LogEvent (const DWORD aEventID, const DWORD aRawDataSize=0, void *apRawData=NULL) ;
  // @cmember Log the event string to the NT event log.
  DLL_EXPORT BOOL LogEvent (const NTEventMsg::EventType logLevel, const char *apData) ;

#if 0
  // @cmember Log the event id to the log at the log level specified.
  BOOL LogThis (const DWORD aEventID, const MTLogLevel aLogLevel, 
    const MTLoggingLocation aLoggingLocation) ;
  // @cmember Log the event id with the specified arguments to the log at the log level
  //  specified
  BOOL LogThis (const DWORD aEventID, const NTEventArgs &aArgs, const MTLogLevel aLogLevel, 
    const MTLoggingLocation aLoggingLocation) ;
  // @cmember Log the event id with the specified arguments to the NT event log. Log the
  // raw data also if any was specified.
  BOOL LogEvent (const DWORD aEventID, const NTEventArgs &aArgs, const DWORD aRawDataSize=0, 
    void *apRawData=NULL) ;
#endif
  // @cmember check to see if its ok to log data
  DLL_EXPORT BOOL IsOkToLog (const MTLogLevel aLogLevel) ;
// @access Private:
private:
  // @cmember The initialization flag
  BOOL          mIsInitialized ;
  // @cmember The pointer to the LogServer
  NTLogServer * mpLogServer ;
  // @cmember The log level
  MTLogLevel    mLogLevel ;
  // @cmember The application tag 
  char        * mpAppTag ;
  // @cmember The file id 
  int           mFileID ;
  // @cmember The Event Logger
  NTEventLogger mEvtLogger ;
} ;

// reenable the warning
#pragma warning( default : 4251 4275)
#endif // __NTLOGGER_H
