// MTAccountPropertyCollection.cpp : Implementation of CMTAccountPropertyCollection
#include "StdAfx.h"
#include "MTAccount.h"
#include "MTAccountPropertyCollection.h"
#include "stdutils.h"


/////////////////////////////////////////////////////////////////////////////
// CMTAccountPropertyCollection

STDMETHODIMP CMTAccountPropertyCollection::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTAccountPropertyCollection
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}


STDMETHODIMP CMTAccountPropertyCollection::Add(BSTR aName, VARIANT aValue, IMTAccountProperty ** apAccProp)
{
	HRESULT hr = S_OK;

	// initialize [out] paramter
	if(apAccProp)
		*apAccProp = 0;
	else
		return E_POINTER;

	// make name uppercase, so case won't matter
	mtwstring wName(aName);
	wName.toupper();
	
	CComBSTR bstrName(wName);
	CComObject<CMTAccountProperty> * pAP;

	if(bstrName.Length() == 0)
		return E_INVALIDARG;
	
	hr = CComObject<CMTAccountProperty>::CreateInstance(&pAP);
	ATLASSERT(SUCCEEDED(hr));

	pAP->put_Name(bstrName);
	pAP->put_Value(aValue);

	m_coll[bstrName] = pAP;

	return pAP->QueryInterface(apAccProp);
}


STDMETHODIMP CMTAccountPropertyCollection::get_Item(VARIANT Index, VARIANT * pVal)
{
	VariantInit(pVal);
	std::map<CComBSTR, CComPtr<IMTAccountProperty> >::iterator it;
	
	switch(Index.vt)
	{
	case VT_I4:
		return CollImpl::get_Item(Index.lVal, pVal);
	
	case VT_I2:
		return CollImpl::get_Item((long)Index.iVal, pVal);
	
	case VT_BSTR:
		{
			// make name uppercase, so case won't matter
			mtwstring wName(Index.bstrVal);
			wName.toupper();

			//indexed by name
			it = m_coll.find(wName.c_str());
		}
		
		if(it == m_coll.end())
			return E_INVALIDARG;

		pVal->vt = VT_DISPATCH;
		IMTAccountProperty * pAccProp;

		pAccProp = (*it).second;

		//copy the item's IDispatch into pItem (also implicit AddRef))
		return pAccProp->QueryInterface(IID_IDispatch, (void**) & (pVal->pdispVal));

	default:	
		//unrecognized index type
		return E_INVALIDARG;
	}
}
