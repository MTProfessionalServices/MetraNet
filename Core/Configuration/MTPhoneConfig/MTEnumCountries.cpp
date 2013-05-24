// MTEnumCountries.cpp : Implementation of CMTEnumCountries
#include "StdAfx.h"

#import	<MTConfigLib.tlb> 
#import <Rowset.tlb> rename ("EOF", "RowsetEOF") 

using namespace MTConfigLib;

#include "PhoneLookup.h"
#include "MTEnumCountries.h"
#include "MTCountry.h"


/////////////////////////////////////////////////////////////////////////////
// CMTEnumCountries

STDMETHODIMP CMTEnumCountries::get__NewEnum(LPUNKNOWN * pVal)
{
    HRESULT hr = S_OK;

	return E_NOTIMPL;
}

STDMETHODIMP CMTEnumCountries::Add(IMTCountry * pItem)
{
    HRESULT hr = S_OK;

	CComPtr<IMTCountry> p = pItem;

	// append data
	mCountryList.push_back(p);
	mCount++;

	return S_OK;
}

STDMETHODIMP CMTEnumCountries::get_Count(long * pVal)
{
	if (!pVal)
		return E_POINTER;

	*pVal = mCount;

	return S_OK;
}

STDMETHODIMP CMTEnumCountries::get_Item(long aIndex, LPDISPATCH * pVal)
{
	if (pVal == NULL)
		return E_POINTER;
  (*pVal) = NULL;

	if ((aIndex < 1) || (aIndex > mCount))
		return E_INVALIDARG;

  PHONELOOKUPLib::IMTCountryPtr outPtr =  (IMTCountry *) mCountryList[aIndex - 1];
  (*pVal) = outPtr.Detach();

	return S_OK;
}

STDMETHODIMP CMTEnumCountries::ReadFromDatabase()
{
 	CComObject<CMTCountry>* pCountry;

  ROWSETLib::IMTSQLRowsetPtr rowset(__uuidof(ROWSETLib::MTSQLRowset));
	rowset->Init("queries\\PhoneCrack");
	rowset->SetQueryTag("__READ_COUNTRIES__");

  rowset->Execute();


	for(int i=0;i<rowset->GetRecordCount();i++)
  {
		  rowset->GetValue("name");

			HRESULT hRes = CComObject<CMTCountry>::CreateInstance(&pCountry);
			_bstr_t aString = rowset->GetValue("name");
			pCountry->put_Name (aString);
      
			aString = rowset->GetValue("description");
			pCountry->put_Description (aString);

			aString = rowset->GetValue("internationalaccesscode");
			pCountry->put_InternationalAccessCode (aString);
			aString = rowset->GetValue("countrycode");
			pCountry->put_CountryCode (aString);
			aString = rowset->GetValue("nationalaccesscode");
			pCountry->put_NationalAccessCode (aString);
			aString = rowset->GetValue("nationalcodetable");
			pCountry->put_NationalCodeTable (aString);

      aString = rowset->GetValue("primarycountrycode");
      if (aString==_bstr_t("TRUE"))
      {
        pCountry->put_Primary(true);
      }
      else
      {
        pCountry->put_Primary(false);
      }

      /*
			BOOL bVal;
			try
			{
				bVal = device->NextBoolWithName("primary");
			}
			catch (_com_error)
			{
				device->Reset();
				bVal = true;
			}
			pCountry->put_Primary (bVal);
      */
		Add (pCountry);
		rowset->MoveNext();
	}
	
  return S_OK;
}

STDMETHODIMP CMTEnumCountries::Read(BSTR bstrHostName, BSTR bstrFileName)
{
	IMTConfigPtr pConfig;
	IMTConfigPropSetPtr pProp;
	VARIANT_BOOL bCheckSum = false;
	VARIANT_BOOL bSecure = false;
	HRESULT hr;
	_bstr_t RelativePath;


	RelativePath = bstrFileName;

	pConfig.CreateInstance("MetraTech.MTConfig.1", NULL, CLSCTX_INPROC_SERVER);
	if ((_bstr_t)bstrHostName != (_bstr_t)"")
		pProp = pConfig->ReadConfigurationFromHost (bstrHostName, RelativePath, bSecure, &bCheckSum);
	else
		pProp = pConfig->ReadConfiguration (RelativePath, &bCheckSum);

	IDispatch * pDispatch;
	hr = pProp->QueryInterface(IID_IDispatch, (void**)&pDispatch);
	if (FAILED(hr))
	{
		return hr;
	}

	hr = InitFromPropSet (pDispatch);
	pProp->Release();

	return hr;
}

STDMETHODIMP CMTEnumCountries::InitFromPropSet(IDispatch * pSet)
{
	IMTConfigPropSetPtr pPropSet(pSet);
	CComObject<CMTCountry>* pCountry;

	IMTConfigPropSetPtr device = pPropSet->NextSetWithName(OLESTR("country"));
	while ((bool) device)
		{
			HRESULT hRes = CComObject<CMTCountry>::CreateInstance(&pCountry);
			_bstr_t aString = device->NextStringWithName("name");
			pCountry->put_Name (aString);
			aString = device->NextStringWithName("description");
			pCountry->put_Description (aString);
			aString = device->NextStringWithName("internationalaccesscode");
			pCountry->put_InternationalAccessCode (aString);
			aString = device->NextStringWithName("countrycode");
			pCountry->put_CountryCode (aString);
			aString = device->NextStringWithName("nationalaccesscode");
			pCountry->put_NationalAccessCode (aString);
			aString = device->NextStringWithName("nationalcodetable");
			pCountry->put_NationalCodeTable (aString);
			BOOL bVal;
			try
			{
				bVal = device->NextBoolWithName("primary");
			}
			catch (_com_error)
			{
				device->Reset();
				bVal = true;
			}
			pCountry->put_Primary (bVal);
			Add (pCountry);
			device = pPropSet->NextSetWithName(OLESTR("country"));
		}

	return S_OK;
}

STDMETHODIMP CMTEnumCountries::FindByCountryName(BSTR CountryName, long * Idx)
{
	*Idx = 0; 

	for (int i=1; i <= mCount; i++)
	{
		CComPtr<IMTCountry> pCountry;
		pCountry = mCountryList[i-1];
		BSTR aCountryName;
		HRESULT hr = pCountry->get_Name (&aCountryName);
		_bstr_t b1 = aCountryName;
		_bstr_t b2 = CountryName;
		::SysFreeString(aCountryName);
		char * c1 = b1;
		char * c2 = b2;
		if (b1 == b2)
		{
			*Idx = i;
			break;
		}
	}

	return S_OK;
}


STDMETHODIMP CMTEnumCountries::GetCountryCodeOwner(BSTR bstrCountryCode, IMTCountry **pCountry)
{
	CComPtr<IMTCountry> pTempCountry;

	*pCountry = NULL;
	for (int i=1; i <= mCount; i++)
	{
		pTempCountry = mCountryList[i-1];
		BSTR aCountryCode;
		HRESULT hr = pTempCountry->get_CountryCode (&aCountryCode);
		_bstr_t b1 = aCountryCode;
		_bstr_t b2 = bstrCountryCode;
		::SysFreeString(aCountryCode);
		if (b1 == b2)
		{
			BOOL bPrimary;
			hr = pTempCountry->get_Primary (&bPrimary);
			if (bPrimary)
			{
				hr = pTempCountry->QueryInterface (IID_IMTCountry, (void**)pCountry);		
				break;
			}
		}
	}

	return S_OK;
}
