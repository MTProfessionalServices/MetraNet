/**************************************************************************
 * @doc 
 * 
 * @module |
 *
 * This class 
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
 * @index | 
 ***************************************************************************/

#ifndef __MTNOTIFICATION_H
#define __MTNOTIFICATION_H

#include <comdef.h>
#include <errobj.h>

#define NOTIFICATION_FILE        "notification.xml"

// disable warning ...
#pragma warning( disable : 4251 4275 )

// defines for exporting dll ...
#undef DLL_EXPORT
#define DLL_EXPORT		__declspec (dllexport)

// @class MTNotification 
class MTNotification : public virtual ObjectWithError
{
// @access Public:
public:
  // @cmember Constructor
  DLL_EXPORT MTNotification() ;
  // @cmember Destructor
  DLL_EXPORT ~MTNotification() ;

  // @cmember Initialize the MTNotification.
  DLL_EXPORT BOOL Init() ;
  // @cmember 
  DLL_EXPORT BOOL SendEmail(const char *apSubject, const char *apData) ;
  // @cmember 
  DLL_EXPORT BOOL SendEmail(const wchar_t *apSubject, const wchar_t *apData) ;

// @access Private:
private:
  // @cmember The initialization flag
  BOOL          mIsInitialized ;
  // @cmember the source account for the email
  _bstr_t       mSource ;
  // @cmember the destination account(s) for the email 
  _bstr_t       mDest ;
  // @cmember the notification state
  BOOL          mState ;
} ;

// reenable the warning
#pragma warning( default : 4251 4275)
#endif // __NTLOGGER_H
