/**************************************************************************
 * @doc MTCOM
 *
 * @module |
 *
 *
 * Copyright 1998 by MetraTech Corporation
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
 * NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech Corporation MAKES NO
 * REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
 * PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
 * DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
 * COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech Corporation,
 * and USER agrees to preserve the same.
 *
 * Created by: Derek Young
 *
 * $Date$
 * $Author$
 * $Revision$
 *
 * @index | MTCOM
 ***************************************************************************/

#ifndef _MTCOM_H
#define _MTCOM_H

#ifndef _WIN32_WINNT
#define _WIN32_WINNT 0x0500
#endif

#ifdef WIN32
// only bring this in once
#pragma once
#endif

#include <objbase.h>

class ComInitialize
{
public:
	ComInitialize(DWORD aThreading = COINIT_MULTITHREADED)
	{ 
		mRetVal = ::CoInitializeEx(NULL, aThreading); 
	}

	~ComInitialize()
	{
		if(SUCCEEDED(mRetVal)) {
			::CoUninitialize(); 
		}
	}

protected:
	DWORD mRetVal;
};

class DComInitialize : public ComInitialize
{
public:
  DComInitialize(HRESULT* pRetVal = NULL,DWORD aThreading = COINIT_MULTITHREADED) 
    : ComInitialize(aThreading)
  {
    HRESULT aRetval;

    aRetval = ::CoInitializeSecurity(
      NULL,                       // No ACL checking
      -1,                         // COM will choose which authentication service to register
      0,                          // array of registration services for authentication, kerberos
      NULL,                       // reserved, must be NULL
      RPC_C_AUTHN_LEVEL_CONNECT,     // perform NO authentication
      RPC_C_IMP_LEVEL_IDENTIFY,   // The server can obtain the client's identity
      NULL,                       // authentication list, NULL for NT 4
      EOAC_NONE,                  // authentication capabilities
      NULL);                      // Reserved, Must be NULL

    if(pRetVal)
      *pRetVal = aRetval;
  }
};

#endif /* _MTCOM_H */
