/**************************************************************************
 * @doc NTREGISTRYNOTIFY
 * 
 * @module Registry notification encapsulation |
 * 
 * This is class that encapsulates the setting up and checking of a 
 * notification event for the specified registry key hierarchy.
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
 * @index | NTREGISTRYNOTIFY
 ***************************************************************************/

#include "MTSL_PCH.h"
#include <NTRegistryNotify.h>

//
//	@mfunc
//	Initialize the data members to invalid values.
//  @rdesc 
//  No return value
// 
NTRegistryNotify::NTRegistryNotify()
: mNotifyKey(0), mNotifyEvent(INVALID_HANDLE_VALUE), mLastError(NO_ERROR)
{
}

//
//	@mfunc
//	Call the CloseRegistry() function to close the registry key and free
//  the event notification handle
//  @rdesc 
//  No return value
// 
NTRegistryNotify::~NTRegistryNotify()
{
  // call CloseRegistry()
  CloseRegistry() ;
}

//
//	@mfunc
//	Close the registry key and free the event notification handle.
//  @rdesc 
//  No return value
// 
void NTRegistryNotify::CloseRegistry()
{
  // local variables ...
  LONG nRetVal=ERROR_SUCCESS ;

  if (mNotifyKey != 0)
  {
    nRetVal = ::RegCloseKey (mNotifyKey) ;
    mNotifyKey = 0 ;
  }
  if (mNotifyEvent != INVALID_HANDLE_VALUE)
  {
    ::CloseHandle (mNotifyEvent) ;
    mNotifyEvent = INVALID_HANDLE_VALUE ;
  }
  return  ;
}

//
//	@mfunc
//	Initialize the change notification. Open the specified registry key with the
//  correct access (KEY_QUERY_VALUE | KEY_NOTIFY). Create an event and set up change
//  notification on the specified registry key.
//	@parm The Windows NT root registry. 
//  @parm The registry key to setup change notification for.
//  @rdesc 
//  Returns TRUE if change notification setup succeeded. Otherwise, FALSE is returned and 
//  the error is stored in the mLastError data member.
//  @devnote
//  This function should be used to initialize the change notification and must be called
//  before CheckForChange(). A call to CheckForChange() without first initializing the
//  change notification will fail with ERROR_INVALID_FUNCTION as the error.
// 
BOOL NTRegistryNotify::InitChangeNotification(const NTRegistryIO::NTRegTree aRootKey, const _TCHAR *apKey)
{
  // local variables ...
  BOOL bRetCode=TRUE ;  
  REGSAM regAccessType ;
  DWORD nRetVal=NO_ERROR ;

  // make sure the registry is closed before we try to open it ...
  CloseRegistry() ;

  // start the try ...
  try
  {
    // open the appropriate key ...
    regAccessType = KEY_QUERY_VALUE | KEY_NOTIFY ;
    switch (aRootKey)
    {
    case NTRegistryIO::CLASSES_ROOT:
      nRetVal = ::RegOpenKeyEx (HKEY_CLASSES_ROOT, apKey, 0, regAccessType, &mNotifyKey) ;
      break ;

    case NTRegistryIO::CURRENT_CONFIG:
      nRetVal = ::RegOpenKeyEx (HKEY_CURRENT_CONFIG, apKey, 0, regAccessType, &mNotifyKey) ;
      break ;

    case NTRegistryIO::CURRENT_USER:
      nRetVal = ::RegOpenKeyEx (HKEY_CURRENT_USER, apKey, 0, regAccessType, &mNotifyKey) ;
      break ;

    case NTRegistryIO::LOCAL_MACHINE:
      nRetVal = ::RegOpenKeyEx (HKEY_LOCAL_MACHINE, apKey, 0, regAccessType, &mNotifyKey) ;
      break ;
    
    case NTRegistryIO::USERS:
      nRetVal = ::RegOpenKeyEx (HKEY_USERS, apKey, 0, regAccessType, &mNotifyKey) ;
      break ;

    case NTRegistryIO::PERF_DATA:
      nRetVal = ::RegOpenKeyEx (HKEY_PERFORMANCE_DATA, apKey, 0, regAccessType, &mNotifyKey) ;
      break ;

    default:
      nRetVal = ERROR_INVALID_PARAMETER ;
      break ;
    }
    if (nRetVal != ERROR_SUCCESS)
    {
      mNotifyKey = 0 ;
      throw nRetVal ;
    }
    // create a manual reset event that will be used to check for registry changes ...
    mNotifyEvent = ::CreateEvent (NULL, TRUE, FALSE, NULL) ;
    if (mNotifyEvent == NULL)
    {
      mNotifyEvent = INVALID_HANDLE_VALUE ;
      nRetVal = ::GetLastError() ;
      throw nRetVal ;
    }
    // setup the registry change notification ... the mNotifyEvent is signalled whenever a key or value 
    // changes under the specified registry ... 
    nRetVal = ::RegNotifyChangeKeyValue (mNotifyKey, TRUE, REG_NOTIFY_CHANGE_LAST_SET, 
      mNotifyEvent, TRUE) ;
    if (nRetVal != NO_ERROR)
    {
      throw nRetVal ;
    }
  }
  catch (DWORD nStatus)
  {
    mLastError = nStatus ;
    bRetCode = FALSE ;
    CloseRegistry() ;
  }

  return bRetCode ;
}

//
//	@mfunc
//	Check to see if the change notification event was signalled. 
//	@parm The change notification boolen value. If TRUE, a change in the
//  registry occurred. If FALSE, a change did not occur.
//  @rdesc 
//  Returns TRUE if the routine functioned properly. Otherwise, FALSE is returned
//  and the error code is saved in the mLastError data member.
//  @devnote
//  InitChangeNotification() must be called in before calling this routine.
// 
BOOL NTRegistryNotify::CheckForChange(BOOL &arRegChanged) 
{
  // local variables ...
  BOOL bRetCode=TRUE ;
  DWORD nRetVal ;
  DWORD nError=NO_ERROR ;

  // if the mNotifyEvent isnt valid ...
  if (mNotifyEvent == INVALID_HANDLE_VALUE)
  {
    mLastError = ERROR_INVALID_FUNCTION ;
    return FALSE ;
  }

  // test to see if the change notification event has been signalled ...
  nRetVal = ::WaitForSingleObject (mNotifyEvent, 0) ;
  
  // switch on the result ...
  switch (nRetVal)
  {
  case WAIT_OBJECT_0:
    // there was a change ... 
    arRegChanged = TRUE ; 
    
    // setup the registry change notification ... the mNotifyEvent is signalled whenever a key or value 
    // changes under the specified registry ... 
    nError = ::RegNotifyChangeKeyValue (mNotifyKey, TRUE, REG_NOTIFY_CHANGE_LAST_SET, 
      mNotifyEvent, TRUE) ;
    if (nError != ERROR_SUCCESS)
    {
      CloseRegistry() ;
      mLastError = nError ;
    }
    break ;

  case WAIT_TIMEOUT:
    // no change ...
    arRegChanged = FALSE ;
    break ;

  case WAIT_ABANDONED:
  case WAIT_FAILED:
  default:
    bRetCode = FALSE ;
    arRegChanged = FALSE ;
    break ;
  }

  return bRetCode ;
}

