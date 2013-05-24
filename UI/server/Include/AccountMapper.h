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
 * 	AccountMapper.h : 
 *	-------------
 *	This is the header file of the AccountMapper class.
 *
 ***************************************************************************/

#ifndef _ACCOUNTMAPPER_H_
#define _ACCOUNTMAPPER_H_

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
#include <NTLogger.h>
#include <NTLogMacros.h>
#include <MTUtil.h>
#include <mtparamnames.h>
#include <mtprogids.h>
#include <NTThreadLock.h>
#include <KioskLogging.h>
#include <autologger.h>

#define ACTION_TYPE_MISMATCH	"ActionType indicates that both NewLoginName and NewNamespace params should be set, however at least one of them is missing!"

#import <Rowset.tlb> rename ("EOF", "RowsetEOF")

// forward declaration
struct IMTQueryAdapter;

// Need to change this to _declspec every member rather than the whole
// class
class CAccountMapper :
  public virtual ObjectWithError,
  public DBAccess
{
	public:
		// Constructors
		// @cmember Constructor
		DLL_EXPORT CAccountMapper();

		// @cmember Destructor
		DLL_EXPORT virtual ~CAccountMapper();

        // @cmember Initialize the CKioskGate object
		DLL_EXPORT BOOL Initialize ();

		// Copy Constructor
		DLL_EXPORT CAccountMapper (const CAccountMapper& C);	

		// Assignment operator
		DLL_EXPORT const CAccountMapper& CAccountMapper::operator=(const CAccountMapper& rhs);

		// @cmember Add to account mapper table
		DLL_EXPORT BOOL Add(const wstring &arLoginName,
							const wstring &arName_Space,
						 	long arAcctID, LPDISPATCH pRowset,
							long& arReturnCode);
		DLL_EXPORT BOOL Modify(long& arReturnCode,
											const int ActionType, /*0 add, 1 update,2 delete*/
											BSTR LoginName,
											BSTR NameSpace,
											BSTR NewLoginName = L"",
											BSTR NewNameSpace = L"", 
											LPDISPATCH pRowset = NULL);
		// @cmember Retrieve an account identifier given a namespace and identifier
		DLL_EXPORT BOOL MapAccountIdentifier(
							const wstring &arSourceName_Space,
							const wstring &arSourceIdentifier,
							const wstring &arDestinationName_Space,
							wstring &arDestinationIdentifier,
							long& arReturnCode);
	protected:

  private:
	  HRESULT DoesMappingExist(const wstring &arLoginName, const wstring &arNameSpace, ROWSETLib::IMTSQLRowsetPtr &aRowset);
	  HRESULT IsNameSpaceValid(const wstring &arNameSpace, ROWSETLib::IMTSQLRowsetPtr &aRowset);
    
    void TearDown() ;

    BOOL CreateAndExecuteQueryToAddAccountMapper (const wstring &arLoginName, 
      const wstring &arNameSpace, const long &arAccountID, BOOL isModify, ROWSETLib::IMTSQLRowsetPtr &arRowset) ;
      
    BOOL CreateAndExecuteQueryToUpdateAccountMapping (const wstring &arLoginName, 
      const wstring &arNameSpace, const wstring &arNewLoginName, 
      const wstring &arNewNameSpace, ROWSETLib::IMTSQLRowsetPtr &arRowset);

    BOOL CreateAndExecuteQueryToDeleteAccountMapping (const wstring &arLoginName, 
      const wstring &arNameSpace, ROWSETLib::IMTSQLRowsetPtr &arRowset);

		MTAutoInstance<MTAutoLoggerImpl<szKioskAccountMapper,szKioskLoggingDir> >	mLogger;
    
    IMTQueryAdapter* mpQueryAdapter;
    BOOL mInitialized ;
    NTThreadLock mLock ;

};

#endif //_ACCOUNTMAPPER_H_

