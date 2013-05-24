

// import the query adapter tlb ...

#include <mtcom.h>
#include <comdef.h>
#include <objbase.h>
#include <AccountTools.h>
#include <stdio.h>
#include <mtprogids.h>
#include <DBConstants.h>
#include <UsageServerConstants.h>
#include <CoreAccountCreation.h>
#include <errobj.h>
#include <iostream>
using std::cout;
using std::endl;


BOOL MTAccountTools::AddDefaultAccount(const string& aPassword,
																			 const string& aNamespace,
																			 const string& aLanguage,
																			 const int aDayOfMonth,
																			 const _bstr_t aUCT,
																			 const long aDayOfWeek,
																			 const long aFirstDayOfMonth,
																			 const long aSecondDayOfMonth,
																			 const long aStartDay,
																			 const long aStartMonth,
																			 const long aStartYear,
																			 const wchar_t* aAccountType,
                                       const wchar_t* aLoginApp)
{ 
	ComInitialize aComInit;
	BOOL bRetVal;

	RowSetInterfacesLib::IMTSQLRowsetPtr aRowset(MTPROGID_SQLROWSET);
	try
	{
		CoreAccountCreationParams params;
		params.bEnforceSameCorp =  PCCache::IsBusinessRuleEnabled(PCCONFIGLib::MTPC_BUSINESS_RULE_Hierarchy_RestrictedOperations) == VARIANT_TRUE;
		params.mAccountState = "AC";
		// don't specify an account start and enddate
		params.mlogin = mAccountName.c_str();
		params.mNameSpace = aNamespace.c_str();
		params.mPassword = aPassword.c_str();
		params.mLangCode = aLanguage.c_str();
		params.mtimezoneID = 18l;
		params.mCycleType = -1l;
		params.mAccountType = aAccountType;
		params.mCurrency = "USD";


		if(_stricmp(aUCT,"Monthly") == 0) {
			params.mCycleType = 1l;
		}
		else if(_stricmp(aUCT,"Daily") == 0) {
			params.mCycleType = 3l;
		}
		else if(_stricmp(aUCT,"Weekly") == 0) {
			params.mCycleType = 4l;
		}
		else if(_stricmp(aUCT,"Bi-weekly") == 0) {
			params.mCycleType = 5l;
		}
		else if(_stricmp(aUCT,"Semi-monthly") == 0) {
			params.mCycleType = 6l;
		}
		else if(_stricmp(aUCT,"Quarterly") == 0) {
			params.mCycleType = 7l;
		}
		else if (_stricmp(aUCT,"Annually") == 0) {
			params.mCycleType = 8l;
		}		
    else if (_stricmp(aUCT,"Semi-annually") == 0) {
			params.mCycleType = 9l;
		}

		if(aDayOfMonth > 0) {
			params.mDayOfMonth = (long)aDayOfMonth;
		}
		
		if(aDayOfWeek > 0) {
			params.mDayOfWeek = aDayOfWeek;
		}

		if(aFirstDayOfMonth > 0) {
			params.mFirstDayOfMonth = aFirstDayOfMonth;
		}
		if(aSecondDayOfMonth > 0) {
			params.mSecondDayOfMonth = aSecondDayOfMonth;
		}
		if(aStartDay > 0) {
			params.mStartDay = aStartDay;
		}
		if(aStartMonth > 0) {
			params.mStartMonth = aStartMonth;
		}
		if(aStartYear > 0) {
			params.mStartYear = aStartYear;
		}
		
		params.mApplyDefaultSecurityPolicy = TRUE;

		params.mBillable = "Y"; // for now

		params.mUseMashedId = false;

		params.mLoginApp = aLoginApp;
    MTCoreAccountMgr manager(params);
		aRowset->Init("queries\\AccountCreation");
		aRowset->BeginTransaction();
		AccountOutputParams outputParams;
		HRESULT hr = manager.CreateAccount(aRowset,outputParams);
		if(SUCCEEDED(hr)) {
			aRowset->CommitTransaction();
			cout << "Account Creation successful, account ID is " << outputParams.mAccountID << endl;
			bRetVal = TRUE;
		}
		else {
			aRowset->RollbackTransaction();
			// XXX add better handling here; use RCD to do error lookups
			Message mesg(hr);
			string astr;
			mesg.GetErrorMessage(astr);

			cout << "Account creation failed; error " << hr << endl;
			cout << astr.c_str() << endl;
			bRetVal = FALSE;
		}
	}
	catch (...)
	{
		bRetVal = FALSE;
		aRowset->RollbackTransaction();
	}
	return bRetVal;
}
