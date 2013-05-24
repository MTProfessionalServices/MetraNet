/**************************************************************************
 * @doc
 * 
 * Copyright 1998 by MetraTech
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
 * REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
 * WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
 * OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
 * INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
 * RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech, and USER
 * agrees to preserve the same.
 *
 * Created by: Rudi Perkins
 * $Header$
 * 
 * 	KioskAuthTicket.h : 
 *	-----------
 *	This is the header file of the AuthenticationTicket class.
 *
 ***************************************************************************/

#ifndef _AUTHTICKET_H_
#define _AUTHTICKET_H_

#include <errobj.h>
#include <NTLogger.h>
#include <NTLogMacros.h>
#include <KioskLogging.h>
#include <autologger.h>


class CAuthenticationTicket  :
public virtual ObjectWithError
{
public:
	DLL_EXPORT CAuthenticationTicket();
	DLL_EXPORT virtual ~CAuthenticationTicket();

  DLL_EXPORT BOOL Initialize();

	//CAuthenticationTicket();
	DLL_EXPORT BOOL Create(string & sDestination,
						const char* pDelimiter,
						const char* pAccountNamespace,
						const char* pAccountId,
						long lTime);
	
	DLL_EXPORT BOOL GetAccountIdentifier(const char* pTicket,
    																		wstring & sTicketAccountID,
																				wstring & sTicketNamespace,
																				wstring & sLoggedInAs,
																				wstring & sApplicationName);

protected:
	
	virtual BOOL Encrypt(const char* szSource, string &sDestination);
	virtual BOOL UnEncrypt(const char* szSource, string &sDestination);
	string mEncryptionKey;

	MTAutoInstance<MTAutoLoggerImpl<szKioskAuthTicket,szKioskLoggingDir> >	mLogger;
	
};



#endif //_AUTHTICKET_H_

