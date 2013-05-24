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

#ifndef _ACCOUNT_H_
#define _ACCOUNT_H_

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

// Roguewave includes
#include <KioskLogging.h>
#include <autologger.h>


#import <Rowset.tlb> rename ("EOF", "RowsetEOF")

// forward declaration
struct IMTQueryAdapter;

class CAccount :
  public virtual ObjectWithError
{
public:
	// Constructors
	// @cmember Constructor
	DLL_EXPORT CAccount();
    
    // @cmember Destructor
    DLL_EXPORT virtual ~CAccount();
    
    // @cmember Initialize the CKioskGate object
    DLL_EXPORT BOOL Initialize ();
    
    // Copy Constructor
    DLL_EXPORT CAccount (const CAccount& C);	
    
    // Assignment operator
    DLL_EXPORT const CAccount& CAccount::operator=(const CAccount& rhs);
    
    // Accessors
    DLL_EXPORT const long GetAccountID() const { return mAccountID;}
    DLL_EXPORT const wstring& GetTariffName () const { return mTariffName;}
    DLL_EXPORT const long GetGeoCode() const { return mGeoCode;}
    DLL_EXPORT const long GetTimezoneID() const { return mTimezoneID;}
    DLL_EXPORT const double GetTimezoneOffset() const { return mTimezoneOffset;}
    DLL_EXPORT const wstring& GetTaxExempt () const { return mTaxExempt;}
    DLL_EXPORT const long GetPaymentMethod () const { return mPaymentMethod;}
    DLL_EXPORT const _variant_t& GetStartDate () const { return mStartDate;}
    DLL_EXPORT const _variant_t& GetEndDate () const { return mEndDate;}
    DLL_EXPORT const long GetTariffID() const { return mTariffID;}
    
	DLL_EXPORT const wstring& GetCurrency () const { return mCurrency;}
    DLL_EXPORT const long GetAccountCycleID() const { return mAccountCycleID;}
    DLL_EXPORT BOOL IsActiveAccount();
    // 
    DLL_EXPORT long GetAccountInfo(
      const wstring &arLoginName, 
      const wstring &arName_Space);
    
    // 
    DLL_EXPORT long GetAccountInfo(long arAccountID);
    
    // @cmember Add to account mapper table
    DLL_EXPORT BOOL Add(long arAccountStatus, LPDISPATCH &arpRowset,
      long& acctID );
    
    // @cmember update to account table
    DLL_EXPORT BOOL Update(const wstring& arLogin,
						   const wstring& arNamespace,
						   const wstring& arAccountEndDate,
						   const long& alAccountStatus);
    
protected:
  
private:
    // query to update account 
    void CreateQueryToUpdateAccount(const wstring& arLogin,
									const wstring& arNamespace,
									const wstring& arAccountEndDate,
									const long& alAccountStatus,
									wstring& langRequest);

  BOOL CreateAndExecuteQueryToAddAccount(const long& aAccountStatus,
	  ROWSETLib::IMTSQLRowsetPtr &arRowset);
  
		// method to create query for getting AccountInfo
  void CreateQueryToGetAccountInfo (const wstring &arLoginName,
    const wstring &arName_Space,
    wstring& langRequest);

  // method to create query for getting AccountInfo
  void CreateQueryToGetAccountInfo (long arAccountID,
    wstring& langRequest);
	void SetActiveFlag();
	
	MTAutoInstance<MTAutoLoggerImpl<szKioskAccount,szKioskLoggingDir> >	mLogger;
  
  BOOL mInitialized;
  
  // store the member attributes locally
  long mAccountID;
  wstring mTariffName;
  long mGeoCode;
  wstring mTaxExempt;
  long mTimezoneID;
  double mTimezoneOffset;
  long mPaymentMethod;
  _variant_t mStartDate;
  _variant_t mEndDate;
	long mAccountCycleID;
  long mTariffID;
  
  wstring mCurrency; 

	BOOL mbActiveAccount;

	_bstr_t configPath;
};

#endif //_ACCOUNT_H_

