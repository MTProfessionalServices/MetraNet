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
* 
***************************************************************************/
// ---------------------------------------------------------------------------
// MTSiteCollection.cpp : Implementation of CMTSiteCollection
// ---------------------------------------------------------------------------
#include "StdAfx.h"
#include "COMKiosk.h"
#include "MTSiteCollection.h"

/////////////////////////////////////////////////////////////////////////////
// CMTSiteCollection

// ----------------------------------------------------------------
// Object: MTSiteCollection
// Prog ID: COMKiosk.MTSiteCollection.1
// Description: An object holding the collection of all Product Collection
//              objects.
// Enumeration Element Type: MTProductCollection
// ----------------------------------------------------------------
STDMETHODIMP CMTSiteCollection::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTSiteCollection
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

// ---------------------------------------------------------------------------
// Description:   Gets the site name property (MT)
// ---------------------------------------------------------------------------
STDMETHODIMP CMTSiteCollection::get_Name(BSTR *pVal)
{
    *pVal = mName.copy();
	return S_OK;
}

// ---------------------------------------------------------------------------
// Description:   Sets the site name property (MT)
// ---------------------------------------------------------------------------
STDMETHODIMP CMTSiteCollection::put_Name(BSTR newVal)
{
    mName = newVal;
	return S_OK;
}

// ---------------------------------------------------------------------------
// Description:   Gets the default product property
//                (metratech.com/audioconfcall)
// ---------------------------------------------------------------------------
STDMETHODIMP CMTSiteCollection::get_DefaultProduct(BSTR *pVal)
{
    *pVal = mDefaultProduct.copy();
	return S_OK;
}

// ---------------------------------------------------------------------------
// Description:   Sets the default product property
//                (metratech.com/audioconfcall)
// ---------------------------------------------------------------------------
STDMETHODIMP CMTSiteCollection::put_DefaultProduct(BSTR newVal)
{
    mDefaultProduct = newVal;
	return S_OK;
}

STDMETHODIMP CMTSiteCollection::Add(IMTProductCollection *pMTProductCollection)
{
    HRESULT hr = S_OK;
	LPDISPATCH lpDisp = NULL;

	hr = pMTProductCollection->QueryInterface(IID_IDispatch, (void**)&lpDisp);
	if (FAILED(hr))
	{
		return hr;
	}
	
	// create a variant
	CComVariant var;
	var.vt = VT_DISPATCH;
	var.pdispVal = lpDisp;

	// append data
	mProductCollectionList.push_back(var);
	mSize++;

	return S_OK;
}

STDMETHODIMP CMTSiteCollection::get_Item(long aIndex, VARIANT *pVal)
{
    ASSERT(pVal);
	if (!pVal)
		return E_POINTER;

	VariantInit(pVal);
	pVal->vt = VT_UNKNOWN;
	pVal->punkVal = NULL;

	if ((aIndex < 1) || (aIndex > mSize))
		return E_INVALIDARG;

	VariantCopy(pVal, &mProductCollectionList[aIndex-1]);

	return S_OK;
}

STDMETHODIMP CMTSiteCollection::get_Count(long *pVal)
{
    if (!pVal)
		return E_POINTER;

	*pVal = mSize;
	return S_OK;
}

STDMETHODIMP CMTSiteCollection::get__NewEnum(LPUNKNOWN *pVal)
{
    HRESULT hr = S_OK;

	typedef CComObject<CComEnum<IEnumVARIANT, 
	  &IID_IEnumVARIANT, VARIANT, _Copy<VARIANT> > > enumvar;

	enumvar* pEnumVar = new enumvar;
	ASSERT (pEnumVar);

	// Note: end pointer has to be one past the end of the list
	if (mSize == 0)
	{
		hr = pEnumVar->Init(NULL,
							NULL, 
							NULL, 
							AtlFlagCopy);
	}
	else
	{
	    hr = pEnumVar->Init(&mProductCollectionList[0], 
							&mProductCollectionList[mSize - 1] + 1, 
							NULL, 
							AtlFlagCopy);
	}

	if (SUCCEEDED(hr))
		hr = pEnumVar->QueryInterface(IID_IEnumVARIANT, reinterpret_cast<void**>(pVal));

	if (FAILED(hr))
		delete pEnumVar;

	return hr;
}
