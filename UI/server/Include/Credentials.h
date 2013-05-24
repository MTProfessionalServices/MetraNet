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
 * Created by: Raju Matta
 * $Header: c:\development35\UI\server\Include\Credentials.h, 9, 7/25/2002 4:06:46 PM, Derek Young$
 * 
 * 	Credentials.h : 
 *	-------------
 *	This is the header file of the Credentials class.
 *
 ***************************************************************************/

#ifndef _CREDENTIALS_H_
#define _CREDENTIALS_H_

#ifdef WIN32
// NOTE: this is necessary for the MS compiler because
// using templates that expand to huge strings makes their
// names > 255 characters.
#pragma warning( disable : 4786 )
// NOTE: compiler complains because even though the class is
// dll exported, the map cannot be dll exported.  hence the 
// warning
#pragma warning( disable : 4251 )
#endif //  WIN32

//	All the includes
#include <KioskDefs.h>
#include <SharedDefs.h>
#include <NTThreadLock.h>
#include <errobj.h>
#include <DBAccess.h>
#include <KioskLogging.h>
#include <autologger.h>
#include <MTUtil.h>

// Need to change this to _declspec every member rather than the whole
// class
class CCredentials :
	public virtual ObjectWithError,
	public DBAccess
{
	public:

		enum CredentialsType { LP = LOGIN_PWD_TYPE, CE = CERTIFICATE_TYPE };

		// Copy Constructor
		DLL_EXPORT  CCredentials (const CCredentials& C);	

		// Assignment operator
		DLL_EXPORT const CCredentials& CCredentials::operator=(const CCredentials& rhs);

		//	Accessors
		const wstring& GetLoginName() const { return mLoginName; } 
		const wstring& GetPwd() const { return mPwd; } 
		const wstring& GetName_Space() const { return mName_Space; } 
		const wstring& GetTicket() const { return mTicket; }

		//	Mutators
		DLL_EXPORT void SetLoginName (const wchar_t* LoginName); 
		DLL_EXPORT void SetPwd (const wchar_t* pwd);
		DLL_EXPORT void SetName_Space (const wchar_t* name_space);
		DLL_EXPORT void SetTicket (const wchar_t* ticket);

		// @cmember Initialize the CKioskGate object
		DLL_EXPORT BOOL Initialize ();

		// @cmember Constructor
		DLL_EXPORT  CCredentials();

		// @cmember Destructor
		DLL_EXPORT virtual ~CCredentials();

	protected:

	private:

		wstring mLoginName;
		wstring mPwd;
		wstring mName_Space;
		wstring mTicket;

		MTAutoInstance<MTAutoLoggerImpl<szKioskCred,szKioskLoggingDir> >	mLogger;
};

#endif //_CREDENTIALS_H_

