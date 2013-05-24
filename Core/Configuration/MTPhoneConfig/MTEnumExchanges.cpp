// MTEnumExchanges.cpp : Implementation of CMTEnumExchanges
#include "StdAfx.h"
#import	<MTConfigLib.tlb> 
using namespace MTConfigLib;
#include "PhoneLookup.h"
#include "MTEnumExchanges.h"
#include "MTExchange.h"

/////////////////////////////////////////////////////////////////////////////
// CMTEnumExchanges

STDMETHODIMP CMTEnumExchanges::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTEnumExchanges,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CMTEnumExchanges::get__NewEnum(LPUNKNOWN * pVal)
{
    HRESULT hr = S_OK;

	return E_NOTIMPL;
}

STDMETHODIMP CMTEnumExchanges::Add(IMTExchange * pItem)
{
    HRESULT hr = S_OK;
	LPDISPATCH lpDisp = NULL;


	CComPtr<IMTExchange> p = pItem;

	// append data
	mExchangeList.push_back(p);
	mCount++;

	return S_OK;
}

STDMETHODIMP CMTEnumExchanges::get_Count(long * pVal)
{
	if (!pVal)
		return E_POINTER;

	*pVal = mCount;

	return S_OK;
}

STDMETHODIMP CMTEnumExchanges::get_Item(long aIndex, LPDISPATCH * pVal)
{
	if (pVal == NULL)
		return E_POINTER;

	if ((aIndex < 1) || (aIndex > mCount))
		return E_INVALIDARG;

	*pVal = mExchangeList[aIndex-1];
	(*pVal)->AddRef();
	return S_OK;
}

STDMETHODIMP CMTEnumExchanges::Read(BSTR bstrHostName, BSTR bstrFileName)
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

STDMETHODIMP CMTEnumExchanges::InitFromPropSet(IDispatch * pSet)
{
	IMTConfigPropSetPtr pPropSet(pSet);
	CComObject<CMTExchange>* pExchange;

	IMTConfigPropSetPtr device = pPropSet->NextSetWithName(OLESTR("exchange"));
	while ((bool) device)
		{
			HRESULT hRes = CComObject<CMTExchange>::CreateInstance(&pExchange);
			if (FAILED(hRes))
				return hRes;

			_bstr_t aString = device->NextStringWithName("code");
			pExchange->put_Code (aString);
			aString = device->NextStringWithName("description");
			pExchange->put_Description (aString);
			Add (pExchange);
			device = pPropSet->NextSetWithName(OLESTR("exchange"));
		}

	return S_OK;
}

