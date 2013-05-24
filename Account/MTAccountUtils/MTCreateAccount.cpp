// MTCreateAccount.cpp : Implementation of CMTCreateAccount
#include "StdAfx.h"
#include <metralite.h>
#include "MTAccountUtils.h"
#include "MTCreateAccount.h"
#include <mtprogids.h>
#include <mtcomerr.h>
#include <mtglobal_msg.h>

#import <Rowset.tlb> rename ("EOF", "RowsetEOF") 

/////////////////////////////////////////////////////////////////////////////
// CMTCreateAccount

STDMETHODIMP CMTCreateAccount::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTCreateAccount
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}


HRESULT CMTCreateAccount::CheckInitStatus()
{
	if(!mbInit) {
		return Error("Initialize was not called or did not complete successfully");

	}
	return S_OK;
}

STDMETHODIMP CMTCreateAccount::Initialize()
{
	HRESULT hr = S_OK;

	try {
		mpAccount = COMKIOSKLib::ICOMAccountPtr(MTPROGID_COMACCOUNT);
		if(mpAccount == NULL) {
			hr = Error("Failed to create ICOMAccount object");
		}
		else {
			mpAccount->Initialize();
		}

		
		mpAccountMapper = COMKIOSKLib::ICOMAccountMapperPtr(MTPROGID_ACCOUNT_MAPPER);
		if(mpAccountMapper == NULL) {
			hr = Error("Failed to create ICOMAccountMapper object");
		}
		else {
			mpAccountMapper->Initialize();
		}

		mpKioskAuth = COMKIOSKLib::ICOMKioskAuthPtr(MTPROGID_KIOSK_AUTH);
		if(mpKioskAuth == NULL) {
			hr = Error("Failed to create ICOMKioskAuth object");
		}
		else {
			mpKioskAuth->Initialize();	
		}
		
		mpUserConfig = COMKIOSKLib::ICOMUserConfigPtr(MTPROGID_KIOSK_USERCONFIG);
		if(mpUserConfig == NULL) {
			hr = Error("Failed to create ICOMUserConfig object");
		}
		else {
			mpUserConfig->Initialize();
		}

		if(SUCCEEDED(hr)) {
			mbInit = true;
		}
	}
	catch(_com_error& err) {
		_bstr_t aErrorBuf = "Failed to create required objects: ";
		aErrorBuf += err.Description();
		mLogger->LogThis(LOG_ERROR,(const char*)aErrorBuf);
		hr = Error((const char*)aErrorBuf);
	}

	return S_OK;
}

STDMETHODIMP CMTCreateAccount::AddUser(LPDISPATCH pCredentials,
										BSTR aLanguage, 
										long TimezoneID, 
										long AccountStatus, 
										LPDISPATCH pRowset, 
										long* AccountID)
{
	// step 1: check arguments
	bool bCondition = (pCredentials && aLanguage && pRowset && AccountID);
	ASSERT(bCondition);
	if(!bCondition) return E_POINTER;

	_bstr_t buffer;

	// step 2: check initialization
	HRESULT hr  = CheckInitStatus();
	if(FAILED(hr)) return hr;

	try {

		// step 3: get the credentials objects.  This is history why it is a LPDISPATCH
		COMKIOSKLib::ICOMCredentialsPtr aComCred(pCredentials);
		if(aComCred == NULL) {
			// if this failed, it is because query interface fails
			_bstr_t buffer = "Unable to get interface for credentials";
			mLogger->LogThis (LOG_ERROR, (const char*)buffer);
			return Error ((const char*)buffer);
		}

		// step 4: get the parameters
		_bstr_t bstrLogin = aComCred->GetLoginID();
		// I think this should be GetPwd (uppercase p... I think this is another ATL bug in generating the tli)
		_bstr_t bstrPwd = aComCred->Getpwd();
		_bstr_t bstrNamespace  = aComCred->GetName_Space();

		// step 5: add the account the the COMAccount interface
		long lAcctID = mpAccount->Add(AccountStatus, pRowset);

		// step 6: add the account mapping
		mpAccountMapper->Add(bstrLogin, bstrNamespace, lAcctID, pRowset);

		// step 7: add the auth stuff
		mpKioskAuth->AddUser(bstrLogin, bstrPwd, bstrNamespace, pRowset);

		// step 8: add through user config
		mpUserConfig->Add(bstrLogin, bstrNamespace, aLanguage, lAcctID, TimezoneID, pRowset);

		// step 9: set the timezone ID
    	// set the timezone value ...
		_bstr_t bstrTimezoneIDValue;
		wchar_t wcharTimezoneIDValue[10];
		bstrTimezoneIDValue = _ltow(TimezoneID, wcharTimezoneIDValue, 10);
    	mpUserConfig->SetValue(L"timeZoneID", bstrTimezoneIDValue);
				
		// step 9: we are done!
		*AccountID = lAcctID;
		hr = S_OK;

	}
	catch(_com_error& err) {
		return ReturnComError (err); 
	}

  return (hr);
}

