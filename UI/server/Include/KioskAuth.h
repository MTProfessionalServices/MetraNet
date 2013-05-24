/**************************************************************************
* Copyright 1997-2000 by MetraTech
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
***************************************************************************/

#ifndef _KIOSKAUTH_H_
#define _KIOSKAUTH_H_

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
#include <mtparamnames.h>
#include <mtprogids.h>

#import <Rowset.tlb> rename ("EOF", "RowsetEOF")

// forward declaration
struct IMTQueryAdapter;

// Need to change this to _declspec every member rather than the whole
// class
class CKioskAuth :
	public virtual ObjectWithError
{
	public:

		// Friend functions  
		//friend ostream& operator<<(ostream& os, const CKioskAuth& C);
	
		// Constructors

		// Copy Constructor
		DLL_EXPORT CKioskAuth (const CKioskAuth& C);	

		// Assignment operator
		DLL_EXPORT const CKioskAuth& CKioskAuth::operator=(const CKioskAuth& rhs);

		// @cmember Get a pointer to the object
		DLL_EXPORT long IsAuthentic (const wchar_t* pLoginName,
							  			   const wchar_t* pPwd,
									       const wchar_t* pName_Space);

		// @cmember Add a user
		DLL_EXPORT BOOL AddUser (const wchar_t* pLoginName,
								   	   const wchar_t* pPwd,
							       	   const wchar_t* pName_Space, LPDISPATCH pRowset);

   // method to determine if account exists
    DLL_EXPORT BOOL AccountExists(const wchar_t* pLoginName, 
				 	  	         const wchar_t* pName_Space);

		// @cmember Initialize the CKioskAuth object
		DLL_EXPORT BOOL Initialize ();

		// @cmember Constructor
		DLL_EXPORT  CKioskAuth();

		// @cmember Destructor
		DLL_EXPORT virtual ~CKioskAuth();

  private:
		// method to create query for init with provider id
		void CreateQuery(const wchar_t* pLoginName,
						 const wchar_t* pPwd,
						 const wchar_t* pName_Space,
						 wstring& langRequest);

		// query to validate pwd
		void CreateQueryToSetPwd(const wchar_t* pLoginName,
									  const wchar_t* pName_Space,
									  const wchar_t* pPwd,
									  wstring& langRequest);

		// query to add user
		void CreateQueryToAddUser(const wchar_t* pLoginName,
								  const wchar_t* pPwd,
								  const wchar_t* pName_Space,
								  wstring& langRequest);

    BOOL CreateAndExecuteQueryToAddUser(const wchar_t* pLoginName,
								  const wchar_t* pPwd,
								  const wchar_t* pName_Space,
								  ROWSETLib::IMTSQLRowsetPtr &arRowset);

		MTAutoInstance<MTAutoLoggerImpl<szKioskAuth,szKioskLoggingDir> >	mLogger;
    
    IMTQueryAdapter* mpQueryAdapter;
    NTThreadLock mLock ;
    BOOL mInitialized ;
};

#endif //_KIOSKAUTH_H_

