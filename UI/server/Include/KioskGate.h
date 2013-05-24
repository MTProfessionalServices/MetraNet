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
 * 	KioskGate.h : 
 *	------------------
 *	This is the header file of the KioskGate class.
 *
 ***************************************************************************/

#ifndef _KIOSKGATE_H_
#define _KIOSKGATE_H_

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
#include <errobj.h>
#include <KioskLogging.h>
#include <autologger.h>
#include <MTUtil.h>
#include <mtprogids.h>

// Need to change this to _declspec every member rather than the whole
// class
class CKioskGate : 
public virtual ObjectWithError
{
public:

  // @cmember Constructor
		DLL_EXPORT CKioskGate();

		// @cmember Destructor
		DLL_EXPORT virtual ~CKioskGate();

		// Copy Constructor
		DLL_EXPORT  CKioskGate (const CKioskGate& C);	

		// Assignment operator
		DLL_EXPORT const CKioskGate& CKioskGate::operator=(const CKioskGate& rhs);

		//	Accessors
		const wstring& GetWebURL() const { return mWebURL; } 

		// @cmember Initialize the CKioskGate object
		DLL_EXPORT BOOL Initialize(const wstring &arProvider);

	protected:

  private:

		wstring mWebURL;
		MTAutoInstance<MTAutoLoggerImpl<szKioskGate,szKioskLoggingDir> >	mLogger;
};

#endif //_KIOSKGATE_H_

