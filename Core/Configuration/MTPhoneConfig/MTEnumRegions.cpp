// MTEnumRegions.cpp : Implementation of CMTEnumRegions
#include "StdAfx.h"

#import	<MTConfigLib.tlb> 
#import <Rowset.tlb> rename ("EOF", "RowsetEOF") 

using namespace MTConfigLib;

#include "PhoneLookup.h"
#include "MTEnumRegions.h"
#include "MTRegion.h"

/////////////////////////////////////////////////////////////////////////////
// CMTEnumRegions

STDMETHODIMP CMTEnumRegions::get__NewEnum(LPUNKNOWN * pVal)
{
    HRESULT hr = S_OK;

	return E_NOTIMPL;
}

STDMETHODIMP CMTEnumRegions::Add(IMTRegion * pItem)
{
    HRESULT hr = S_OK;
	LPDISPATCH lpDisp = NULL;


	CComPtr<IMTRegion> p = pItem;

	// append data
	mRegionList.push_back(p);
	mCount++;

	return S_OK;
}

STDMETHODIMP CMTEnumRegions::get_Count(long * pVal)
{
	if (!pVal)
		return E_POINTER;

	*pVal = mCount;

	return S_OK;
}

STDMETHODIMP CMTEnumRegions::get_Item(long aIndex, LPDISPATCH * pVal)
{
	if (pVal == NULL)
		return E_POINTER;

	if ((aIndex < 1) || (aIndex > mCount))
		return E_INVALIDARG;

	*pVal = mRegionList[aIndex-1];
	(*pVal)->AddRef();
	return S_OK;
}

STDMETHODIMP CMTEnumRegions::ReadFromDatabase(BSTR bstrCountry)
{
	CComObject<CMTRegion>* pRegion;

  ROWSETLib::IMTSQLRowsetPtr rowset(__uuidof(ROWSETLib::MTSQLRowset));
	rowset->Init("queries\\PhoneCrack");
	rowset->SetQueryTag("__READ_REGIONS__");
	rowset->AddParam("%%COUNTRY%%", bstrCountry);
  rowset->Execute();


	for(int i=0;i<rowset->GetRecordCount();i++)
  {

			HRESULT hRes = CComObject<CMTRegion>::CreateInstance(&pRegion);
			_bstr_t aString = rowset->GetValue("code");
 			pRegion->put_DestinationCode (aString);
			aString = rowset->GetValue("countryname");
			pRegion->put_CountryName (aString);
			aString = rowset->GetValue("description");
			pRegion->put_Description (aString);

      aString = rowset->GetValue("international");
      if (aString==_bstr_t("TRUE"))
      {
        pRegion->put_International(true);
      }
      else
      {
        pRegion->put_International(false);
      }

      aString = rowset->GetValue("tollfree");
      if (aString==_bstr_t("TRUE"))
      {
        pRegion->put_TollFree(true);
      }
      else
      {
        pRegion->put_TollFree(false);
      }

  	  aString = rowset->GetValue("localcodetable");
		  pRegion->put_LocalCodeTable (aString);
  	
      Add (pRegion);
		  rowset->MoveNext();
	}
	
  return S_OK;
}

STDMETHODIMP CMTEnumRegions::Read(BSTR bstrHostName, BSTR bstrFileName)
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

STDMETHODIMP CMTEnumRegions::InitFromPropSet(IDispatch * pSet)
{
	IMTConfigPropSetPtr pPropSet(pSet);
	CComObject<CMTRegion>* pRegion;

	IMTConfigPropSetPtr device = pPropSet->NextSetWithName(OLESTR("region"));
	while ((bool) device)
		{
			HRESULT hRes = CComObject<CMTRegion>::CreateInstance(&pRegion);
			if (FAILED(hRes))
				return hRes;

			_bstr_t aString = device->NextStringWithName("code");
			pRegion->put_DestinationCode (aString);
			aString = device->NextStringWithName("countryname");
			pRegion->put_CountryName (aString);
			aString = device->NextStringWithName("description");
			pRegion->put_Description (aString);
			BOOL bVal;
			try
			{
				bVal = device->NextBoolWithName("international");
			}
			catch (_com_error)
			{
				device->Reset();
				bVal = false;
			}

			pRegion->put_International (bVal);
			
			try
			{
				bVal = device->NextBoolWithName("tollfree");
			}
			catch (_com_error)
			{
				device->Reset();
				bVal = false;
			}

			pRegion->put_TollFree (bVal);
			
			aString = device->NextStringWithName("localcodetable");
			pRegion->put_LocalCodeTable (aString);
			Add (pRegion);
			device = pPropSet->NextSetWithName(OLESTR("region"));
		}

	return S_OK;
}
