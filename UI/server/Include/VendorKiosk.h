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
 * 	VendorKiosk.h : 
 *	---------------
 *	This is the header file of the Vendor Kiosk class.
 *
 ***************************************************************************/

#ifndef _VENDORKIOSK_H_
#define _VENDORKIOSK_H_

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
#include <DBInMemRowset.h>
#include <DBConstants.h>
#include <mtprogids.h>

// import the query adapter tlb ...
#import <Rowset.tlb> rename( "EOF", "RowsetEOF" )

// Need to change this to _declspec every member rather than the whole
// class
class CVendorKiosk :
public virtual ObjectWithError
{
public:
		// @cmember Constructor
		DLL_EXPORT CVendorKiosk();
    
    // @cmember Destructor
    DLL_EXPORT virtual ~CVendorKiosk();
    
    // Copy Constructor
    DLL_EXPORT  CVendorKiosk (const CVendorKiosk& C);	
    
    // Assignment operator
    DLL_EXPORT const CVendorKiosk& CVendorKiosk::operator=(const CVendorKiosk& rhs);
    
    // @cmember Initialize the CVendorKiosk object
    DLL_EXPORT BOOL Initialize (const wstring &arProvider);
    
    //	Accessors
		DLL_EXPORT const wstring& GetAuthMethod() const { return mAuthMethod; }
		DLL_EXPORT const wstring& GetAuthNamespace() const { return mAuthNamespace; }
    DLL_EXPORT const wstring& GetAccMapper() const { return mAccMapper; }
    DLL_EXPORT const wstring& GetProviderName() const { return mProviderName; }
    
    // Record set to get colors back
#if 0
    DLL_EXPORT ROWSETLib::IMTInMemRowsetPtr GetColors();
#endif
    DLL_EXPORT ROWSETLib::IMTSQLRowsetPtr GetLanguageCollection(const wstring &arLangCode);
    
    // Record set to get timezone back
    DLL_EXPORT ROWSETLib::IMTInMemRowsetPtr GetTimezone(const wstring &arLangCode);
protected:
  
private:
    wstring mProviderName ;
		MTAutoInstance<MTAutoLoggerImpl<szKioskVendorKiosk,szKioskLoggingDir> >	mLogger;
    wstring mAuthMethod;
    wstring mAuthNamespace;
    wstring mAccMapper;
};

#endif //_VENDORKIOSK_H_

