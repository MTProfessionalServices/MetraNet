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

#ifndef __NTREGISTRYNOTIFY_H
#define __NTREGISTRYNOTIFY_H

// #include files ...
#include "MTSL_DLL.h"
#include "NTRegistryIO.h"

// @class NTRegistryNotify
class MTSL_DLL_EXPORT NTRegistryNotify
{
// @access Public:
public:
  // @cmember Constructor
  NTRegistryNotify() ;
  // @cmember Destructor
  virtual ~NTRegistryNotify() ;

  // @cmember Initialize the change notification for the specified registry key
  BOOL InitChangeNotification (const NTRegistryIO::NTRegTree aRootKey, const _TCHAR *apKey) ;
  // @cmember Check for the change notification
  BOOL CheckForChange(BOOL &arRegChanged) ;
  // @cmember Close the registry and free the change notification event
  void CloseRegistry() ;
  // @cmember Get the last error 
  DWORD GetLastError() const ;
// @access Private:
private:
  // @cmember handle to the key to setup notification on
  HKEY        mNotifyKey ;
  // @cmember handle to the notification event
  HANDLE        mNotifyEvent ;
  // @cmember the last error
  DWORD         mLastError ;
} ;

//
//	@mfunc
//	Get the last error
//  @rdesc 
//  Returns the mLastError data member
// 
inline DWORD NTRegistryNotify::GetLastError() const
{
  return mLastError ;
}
#endif // __NTREGISTRYNOTIFY_H

