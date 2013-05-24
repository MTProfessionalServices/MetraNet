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
 * $Header$
 * 
 * 	CertCredentials.h : 
 *	-----------------
 *	This is the header file of the CertCredentials class.
 *
 ***************************************************************************/

#ifndef _CERTCREDENTIALS_H_
#define _CERTCREDENTIALS_H_

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
#include <KioskLogging.h>
#include <autologger.h>
#include <MTUtil.h>

// Need to change this to _declspec every member rather than the whole
// class
class CCertCredentials : public Credentials
{
	public:

		// Friend functions  
		friend ostream& operator<<(ostream& os, const CCertCredentials& C);
	
		// Constructors

		// Copy Constructor
		DLL_EXPORT CCertCredentials (const CCertCredentials& C);	

		// Assignment operator
		DLL_EXPORT const CCertCredentials& CCertCredentials::operator=(const CCertCredentials& rhs);

		//	Accessors
		const wstring& GetCertificate() const { return mCertificate; } 
		
		//	Mutators
		void SetCertificate (const wchar_t* certificate) 
			{ mCertificate = certificate; }

	protected:

		// @cmember Constructor
		DLL_EXPORT CCertCredentials();

		// @cmember Destructor
		DLL_EXPORT virtual ~CCertCredentials();

	private:
		
		wstring mCertificate;
		MTAutoInstance<MTAutoLoggerImpl<szKioskCred,szKioskLoggingDir> >	mLogger;
		
};

#endif //_CERTCREDENTIALS_H_

