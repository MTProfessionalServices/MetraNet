// MTLDAPAdapter.cpp : Implementation of CMTLDAPAdapter
#include "StdAfx.h"
#include "MTAccount.h"
#include "MTLDAPAdapter.h"
#include "MTSearchResultCollection.h"
#include "MTAccountPropertyCollection.h"
#include "MTAccountProperty.h"

#include <mtprogids.h>
#include <mtglobal_msg.h>
#include <loggerconfig.h>
#include <mtcomerr.h>
#include <SetIterate.h>

#import <MTLDAPLib.tlb>

/////////////////////////////////////////////////////////////////////////////
// CMTLDAPAdapter

STDMETHODIMP CMTLDAPAdapter::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTAccountAdapter,
	    &IID_IMTAccountAdapter2
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}


// ----------------------------------------------------------------------
// Final Construct
HRESULT 
CMTLDAPAdapter::FinalConstruct()
{
	return mEnumConfig.CreateInstance(MTPROGID_ENUM_CONFIG);
}

// ----------------------------------------------------------------------
// Final Release
void
CMTLDAPAdapter::FinalRelease()
{
}

// ----------------------------------------------------------------------
STDMETHODIMP CMTLDAPAdapter::Initialize(BSTR AdapterName)
{
	return S_OK;
}

// ----------------------------------------------------------------------
STDMETHODIMP CMTLDAPAdapter::Install()
{
	return E_NOTIMPL;
}

// ----------------------------------------------------------------------
STDMETHODIMP CMTLDAPAdapter::Uninstall()
{
	return E_NOTIMPL;
}

// ----------------------------------------------------------------------
/*
apRowset is a dead argument, we needed to have it the interface. In fact
the only adapter using it will ever be MTSQLAdapter
*/
STDMETHODIMP CMTLDAPAdapter::AddData(BSTR AdapterName,
								     ::IMTAccountPropertyCollection* mtptr, VARIANT apRowset)
{
    HRESULT hr = S_OK;
	string buffer;
    const char* procName = "CMTLDAPAdapter::AddData";

	try
	{
	    // create the MTLDAPImpl object
	    MTLDAPLib::IMTLDAPImplPtr ldapptr;
		hr = ldapptr.CreateInstance("MTLDAP.MTLDAPImpl.1");
    	if (!SUCCEEDED(hr))
		{
    		buffer = "ERROR: unable to create instance of MTLDAPImpl object";
			mLogger->LogThis(LOG_ERROR, buffer.c_str());
			return Error(buffer.c_str(), IID_IMTAccountAdapter, hr);
		}

		hr = ldapptr->Initialize();
    	if (!SUCCEEDED(hr))
    	{
    		buffer = "ERROR: unable to initialize";
			mLogger->LogThis(LOG_ERROR, buffer.c_str());
			return Error(buffer.c_str(), IID_IMTAccountAdapter, hr);
		}

		hr = ldapptr->AddData((MTLDAPLib::IMTAccountPropertyCollection*)mtptr);
    	if (!SUCCEEDED(hr))
    	{
    		buffer = "ERROR: unable to add data";
			mLogger->LogThis(LOG_ERROR, buffer.c_str());
			return Error(buffer.c_str(), IID_IMTAccountAdapter, hr);
		}
	}
	catch (_com_error& e)
	{
		return ReturnComError(e);
	}

	return S_OK;
}

STDMETHODIMP CMTLDAPAdapter::UpdateData(BSTR AdapterName,
									    ::IMTAccountPropertyCollection* mtptr,VARIANT apRowset)
{
    HRESULT hr = S_OK;
	string buffer;
    const char* procName = "CMTLDAPAdapter::UpdateData";

	try
	{
	    // create the MTLDAPImpl object
	    MTLDAPLib::IMTLDAPImplPtr ldapptr;
		hr = ldapptr.CreateInstance("MTLDAP.MTLDAPImpl.1");
    	if (!SUCCEEDED(hr))
		{
    		buffer = "ERROR: unable to create instance of MTLDAPImpl object";
			mLogger->LogThis(LOG_ERROR, buffer.c_str());
			return Error(buffer.c_str(), IID_IMTAccountAdapter, hr);
		}

		hr = ldapptr->Initialize();
    	if (!SUCCEEDED(hr))
    	{
    		buffer = "ERROR: unable to initialize";
			mLogger->LogThis(LOG_ERROR, buffer.c_str());
			return Error(buffer.c_str(), IID_IMTAccountAdapter, hr);
		}

		hr = ldapptr->UpdateData((MTLDAPLib::IMTAccountPropertyCollection*)mtptr);
    	if (!SUCCEEDED(hr))
    	{
    		buffer = "ERROR: unable to add data";
			mLogger->LogThis(LOG_ERROR, buffer.c_str());
			return Error(buffer.c_str(), IID_IMTAccountAdapter, hr);
		}
	}
	catch (_com_error& e)
	{
		return ReturnComError(e);
	}

	return S_OK;
}

STDMETHODIMP CMTLDAPAdapter::GetData(BSTR AdapterName,
								     long AccountID,
									 VARIANT apRowset,
								     ::IMTAccountPropertyCollection** mtptr)
{
	return E_NOTIMPL;
}


STDMETHODIMP CMTLDAPAdapter::SearchData(BSTR AdapeterName,
										::IMTAccountPropertyCollection* apAPC,
										VARIANT apRowset,
										::IMTSearchResultCollection** apSRC)
{
	HRESULT hr = S_OK;
	string buffer;
    const char* procName = "CMTLDAPAdapter::SearchData";	

	ROWSETLib::IMTSQLRowsetPtr rowset;
	_variant_t vRowset;
	if (apRowset.vt != VT_NULL && OptionalVariantConversion(apRowset,VT_DISPATCH,vRowset))
		mLogger->LogThis(LOG_WARNING, L"Rowset is passed in, but not not used");

	//try
	//{
	    // create the MTLDAPImpl object
	    MTLDAPLib::IMTLDAPImplPtr ldapptr;
		hr = ldapptr.CreateInstance("MTLDAP.MTLDAPImpl.1");
    	if (!SUCCEEDED(hr))
		{
    		buffer = "ERROR: unable to create instance of MTLDAPImpl object";
			mLogger->LogThis(LOG_ERROR, buffer.c_str());
			return Error(buffer.c_str(), IID_IMTAccountAdapter, hr);
		}

		hr = ldapptr->Initialize();
    	if (!SUCCEEDED(hr))
    	{
    		buffer = "ERROR: unable to initialize";
			mLogger->LogThis(LOG_ERROR, buffer.c_str());
			return Error(buffer.c_str(), IID_IMTAccountAdapter, hr);
		}
		
		
		MTACCOUNTLib::IMTAccountPropertyCollectionPtr pAPC = apAPC;	
		MTACCOUNTLib::IMTAccountPropertyPtr pAP;
		
		try
		{
			pAP = pAPC->GetItem(L"_accountid");
			_variant_t vtValue = pAP->GetValue();
			switch (vtValue.vt) {
				case VT_BSTR:
					{
						_bstr_t bstrVal = pAP->GetValue().bstrVal;
						if (0 == _wcsicmp(L"*", bstrVal))
							mAccID = 0;
						else
						{
							mLogger->LogThis(LOG_ERROR, "Expecting account ID in long format");
							return Error ("Expecting account ID in long format");
						}
						
						break;
					}

				case VT_I2:
				case VT_I4:
					mAccID = pAP->GetValue().lVal;
					break;

				default:
					mLogger->LogThis(LOG_ERROR, "Unknown Variant Type");
					break;
			}
		}
		catch (_com_error& e)
		{
			if(e.Error() == E_INVALIDARG)
				mAccID = 0;
		}
			
		// if Account ID is the only search criteria, then invoke RetrieveContact, else Search
		if(0 != mAccID)
			hr = ldapptr->RetrieveContact(mAccID);
		else
			hr = ldapptr->Search((MTLDAPLib::IMTAccountPropertyCollection*)apAPC);
		
    	if(!SUCCEEDED(hr))
    	{
    		buffer = "ERROR: unable to retrieve/search contact";
			mLogger->LogThis(LOG_ERROR, buffer.c_str());
			return Error(buffer.c_str(), IID_IMTAccountAdapter, hr);
		}

		CComObject<CMTSearchResultCollection>* pSRC;
		hr = CComObject<CMTSearchResultCollection>::CreateInstance(&pSRC);
		if (FAILED(hr)) return hr;

		SetIterator<MTLDAPLib::IMTLDAPImplPtr, MTLDAPLib::IMTLDAPDataSetPtr> it;
	    hr = it.Init(ldapptr);
	    if (FAILED(hr)) return hr;
	
		while (TRUE)
		{
			MTLDAPLib::IMTLDAPDataSetPtr dataset = it.GetNext();
		    if (dataset == NULL) break;

			CComObject<CMTAccountPropertyCollection>* pAPC;		
			hr = CComObject<CMTAccountPropertyCollection>::CreateInstance(&pAPC);
			if (FAILED(hr)) return hr;

			SetIterator<MTLDAPLib::IMTLDAPDataSetPtr, MTLDAPLib::IMTLDAPDataPtr> it1;
			hr = it1.Init(dataset);
			if (FAILED(hr)) return hr;
		
			while (TRUE)
			{
				MTLDAPLib::IMTLDAPDataPtr data = it1.GetNext();
		    	if (data == NULL) break;

				CComPtr<::IMTAccountProperty> pAP;
								
				_bstr_t name;
				_variant_t vtValue;

				name = data->GetAttribute();
				wstring wstrName(name);
				vtValue = data->GetValue();
				

				if(0 == _wcsicmp(wstrName.c_str(), L"sn"))
					name = L"lastname";
				else if(0 == _wcsicmp(wstrName.c_str(), L"givenname"))
					name = L"firstname";
				else if(0 == _wcsicmp(wstrName.c_str(), L"contactid"))
					name = L"_accountid";
				else if(0 == _wcsicmp(wstrName.c_str(), L"c"))
				{
					name = L"country";
					
					long lValue = _wtol(vtValue.bstrVal);
					
					try
					{
						vtValue = mEnumConfig->GetEnumeratorValueByID(lValue);
					}
					catch(_com_error & e)
					{
						return ReturnComError(e);
					}
				}
				else if(0 == _wcsicmp(wstrName.c_str(), L"accounttype"))
				{
					long lValue = _wtol(vtValue.bstrVal);
					
					try
					{
						vtValue = mEnumConfig->GetEnumeratorValueByID(lValue);
					}
					catch(_com_error & e)
					{
						return ReturnComError(e);
					}
				}
						
				pAPC->Add(name, vtValue, &pAP);
			}
					
			pSRC->Add(pAPC);
		}

		pSRC->QueryInterface(apSRC);
	//}
	//catch (_com_error& e)
	//{
	//	return ReturnComError(e);
	//}

	return S_OK;
}

STDMETHODIMP CMTLDAPAdapter::SearchDataWithUpdLock(BSTR AdapeterName,
										::IMTAccountPropertyCollection* apAPC,
										BOOL wUpdLock,
										VARIANT apRowset,										
										::IMTSearchResultCollection** apSRC)
{
	HRESULT hr = S_OK;
	string buffer;
    const char* procName = "CMTLDAPAdapter::SearchDataWithUpdLock";	

	ROWSETLib::IMTSQLRowsetPtr rowset;
	_variant_t vRowset;
	if (apRowset.vt != VT_NULL && OptionalVariantConversion(apRowset,VT_DISPATCH,vRowset))
		mLogger->LogThis(LOG_WARNING, L"Rowset is passed in, but not not used");

	//try
	//{
	    // create the MTLDAPImpl object
	    MTLDAPLib::IMTLDAPImplPtr ldapptr;
		hr = ldapptr.CreateInstance("MTLDAP.MTLDAPImpl.1");
    	if (!SUCCEEDED(hr))
		{
    		buffer = "ERROR: unable to create instance of MTLDAPImpl object";
			mLogger->LogThis(LOG_ERROR, buffer.c_str());
			return Error(buffer.c_str(), IID_IMTAccountAdapter, hr);
		}

		hr = ldapptr->Initialize();
    	if (!SUCCEEDED(hr))
    	{
    		buffer = "ERROR: unable to initialize";
			mLogger->LogThis(LOG_ERROR, buffer.c_str());
			return Error(buffer.c_str(), IID_IMTAccountAdapter, hr);
		}
		
		
		MTACCOUNTLib::IMTAccountPropertyCollectionPtr pAPC = apAPC;	
		MTACCOUNTLib::IMTAccountPropertyPtr pAP;
		
		try
		{
			pAP = pAPC->GetItem(L"_accountid");
			_variant_t vtValue = pAP->GetValue();
			switch (vtValue.vt) {
				case VT_BSTR:
					{
						_bstr_t bstrVal = pAP->GetValue().bstrVal;
						if (0 == _wcsicmp(L"*", bstrVal))
							mAccID = 0;
						else
						{
							mLogger->LogThis(LOG_ERROR, "Expecting account ID in long format");
							return Error ("Expecting account ID in long format");
						}
						
						break;
					}

				case VT_I2:
				case VT_I4:
					mAccID = pAP->GetValue().lVal;
					break;

				default:
					mLogger->LogThis(LOG_ERROR, "Unknown Variant Type");
					break;
			}
		}
		catch (_com_error& e)
		{
			if(e.Error() == E_INVALIDARG)
				mAccID = 0;
		}
			
		// if Account ID is the only search criteria, then invoke RetrieveContact, else Search
		if(0 != mAccID)
			hr = ldapptr->RetrieveContact(mAccID);
		else
			hr = ldapptr->Search((MTLDAPLib::IMTAccountPropertyCollection*)apAPC);
		
    	if(!SUCCEEDED(hr))
    	{
    		buffer = "ERROR: unable to retrieve/search contact";
			mLogger->LogThis(LOG_ERROR, buffer.c_str());
			return Error(buffer.c_str(), IID_IMTAccountAdapter, hr);
		}

		CComObject<CMTSearchResultCollection>* pSRC;
		hr = CComObject<CMTSearchResultCollection>::CreateInstance(&pSRC);
		if (FAILED(hr)) return hr;

		SetIterator<MTLDAPLib::IMTLDAPImplPtr, MTLDAPLib::IMTLDAPDataSetPtr> it;
	    hr = it.Init(ldapptr);
	    if (FAILED(hr)) return hr;
	
		while (TRUE)
		{
			MTLDAPLib::IMTLDAPDataSetPtr dataset = it.GetNext();
		    if (dataset == NULL) break;

			CComObject<CMTAccountPropertyCollection>* pAPC;		
			hr = CComObject<CMTAccountPropertyCollection>::CreateInstance(&pAPC);
			if (FAILED(hr)) return hr;

			SetIterator<MTLDAPLib::IMTLDAPDataSetPtr, MTLDAPLib::IMTLDAPDataPtr> it1;
			hr = it1.Init(dataset);
			if (FAILED(hr)) return hr;
		
			while (TRUE)
			{
				MTLDAPLib::IMTLDAPDataPtr data = it1.GetNext();
		    	if (data == NULL) break;

				CComPtr<::IMTAccountProperty> pAP;
								
				_bstr_t name;
				_variant_t vtValue;

				name = data->GetAttribute();
				wstring wstrName(name);
				vtValue = data->GetValue();
				

				if(0 == _wcsicmp(wstrName.c_str(), L"sn"))
					name = L"lastname";
				else if(0 == _wcsicmp(wstrName.c_str(), L"givenname"))
					name = L"firstname";
				else if(0 == _wcsicmp(wstrName.c_str(), L"contactid"))
					name = L"_accountid";
				else if(0 == _wcsicmp(wstrName.c_str(), L"c"))
				{
					name = L"country";
					
					long lValue = _wtol(vtValue.bstrVal);
					
					try
					{
						vtValue = mEnumConfig->GetEnumeratorValueByID(lValue);
					}
					catch(_com_error & e)
					{
						return ReturnComError(e);
					}
				}
				else if(0 == _wcsicmp(wstrName.c_str(), L"accounttype"))
				{
					long lValue = _wtol(vtValue.bstrVal);
					
					try
					{
						vtValue = mEnumConfig->GetEnumeratorValueByID(lValue);
					}
					catch(_com_error & e)
					{
						return ReturnComError(e);
					}
				}
						
				pAPC->Add(name, vtValue, &pAP);
			}
					
			pSRC->Add(pAPC);
		}

		pSRC->QueryInterface(apSRC);
	//}
	//catch (_com_error& e)
	//{
	//	return ReturnComError(e);
	//}

	return S_OK;
}

STDMETHODIMP CMTLDAPAdapter::GetPropertyMetaData(BSTR aPropertyName,
																								::IMTPropertyMetaData** apMetaData)
{
	return E_NOTIMPL;
}

