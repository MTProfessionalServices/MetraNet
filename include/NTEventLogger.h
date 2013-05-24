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

#ifndef __NTEVENTLOGGER_H
#define __NTEVENTLOGGER_H

#include <NTEventMsg.h>
#include <errobj.h>

// @class NTEventLogger
class NTEventLogger : public ObjectWithError
{
// @access Public:
public:
  // @cmember Constructor
  NTEventLogger() ;
  // @cmember Destructor
  virtual ~NTEventLogger() ;

  // @cmember Initialize the NTEventLogger class
  BOOL Init(const wchar_t *apModuleName)  ;
  // @cmember Submit the NTEventMsg to the Windows NT event log.
  BOOL Submit(NTEventMsg &arEvtMsg) ;
  // @cmember Get the message string for the specified event
  char *GetMessageString(const DWORD aEventID) ;
  // @cmember Get the message string for the specified event and arguments
  char *GetMessageString(const DWORD aEventID, NTEventArgs aArgs) ;
  // @cmember Is the class initialized
  BOOL IsInitialized() const ;
private:
  // private routines ...
  // @cmember Get the user Sid 
  BOOL GetUserSid() ;
  // @cmember Open the event message file
//  DWORD OpenMessageFile() ;

  // data members ...
  // @cmember The handle to the event message file
  HMODULE         mEvtMsgFile ;
  // @cmember The initialized flag 
  BOOL            mIsInitialized ;
  // @cmember The handle to the event source
  HANDLE          mEvtLog ;
  // @cmember The user Sid
  PSID            mpSid ;
  // @cmember The name of the application
  char *        mpAppName ;
  // @cmember A pointer to the data returned by the FormatMessage call
  char *        mpData ;

} ;

//
//	@mfunc
//	Check to see if class is initialized
//  @rdesc 
//  Returns the initialized flag
// 
inline BOOL NTEventLogger::IsInitialized() const
{
  return mIsInitialized ;
}
#endif // __NTEVENTLOGGER_H

