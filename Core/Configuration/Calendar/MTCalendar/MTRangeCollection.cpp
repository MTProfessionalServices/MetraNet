// MTRangeCollection.cpp : Implementation of CMTRangeCollection
#include "StdAfx.h"
#include "MTCalendar.h"
#include "MTRange.h"
#include "MTRangeCollection.h"

/////////////////////////////////////////////////////////////////////////////
// CMTRangeCollection

STDMETHODIMP CMTRangeCollection::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTRangeCollection,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CMTRangeCollection::get__NewEnum(LPUNKNOWN * pVal)
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
		hr = pEnumVar->Init(&mRangeList[0], 
							&mRangeList[mSize - 1] + 1, 
							NULL, 
							AtlFlagCopy);
	}

	if (SUCCEEDED(hr))
		hr = pEnumVar->QueryInterface(IID_IEnumVARIANT, (void**)pVal);

	if (FAILED(hr))
		delete pEnumVar;

	return hr;
}

STDMETHODIMP CMTRangeCollection::get_Code(BSTR * pVal)
{
	// TODO: Add your implementation code here
    *pVal = mCode.copy();
	return S_OK;
}

STDMETHODIMP CMTRangeCollection::put_Code(BSTR newVal)
{
	// TODO: Add your implementation code here
    mCode = newVal;
	return S_OK;
}

STDMETHODIMP CMTRangeCollection::get_Count(long * pVal)
{
	if (!pVal)
		return E_POINTER;

	*pVal = mSize;

	return S_OK;
}

STDMETHODIMP CMTRangeCollection::get_Item(long aIndex, VARIANT * pVal)
{
	if (pVal == NULL)
		return E_POINTER;

	VariantInit(pVal);
	pVal->vt = VT_UNKNOWN;
	pVal->punkVal = NULL;

	if ((aIndex < 1) || (aIndex > mSize))
		return E_INVALIDARG;

	VariantCopy(pVal, &mRangeList[aIndex-1]);

	return S_OK;
}

STDMETHODIMP CMTRangeCollection::Add(IMTRange* pRange)
{
  // TODO: DY
    HRESULT hr = S_OK;
	LPDISPATCH lpDisp = NULL;

	hr = pRange->QueryInterface(IID_IDispatch, (void**)&lpDisp);
	if (FAILED(hr))
	{
		return hr;
	}
	
	// create a variant
	CComVariant var;
	var.vt = VT_DISPATCH;
	var.pdispVal = lpDisp;

	// append data
	mRangeList.push_back(var);
	mSize++;

	return S_OK;
}

STDMETHODIMP CMTRangeCollection::WriteSet(::IMTConfigPropSet* apPropSet)
{
    HRESULT hr = S_OK;
    const char* procName = "CMTRangeCollection::WriteSet";

	if (apPropSet == NULL)
		return E_POINTER;

	MTConfigLib::IMTConfigPropSetPtr pSet(apPropSet);

    // enumerate through the ranges
	if (mSize > 0)
	{
		int index;
		IMTRange* pIMTRange;
		LPDISPATCH lpDisp = NULL;

		::IMTConfigPropSet* pRangePropSet;
		for (index = 0; index < mSize; index++) 
		{
		    lpDisp = NULL;
			lpDisp = mRangeList[index].pdispVal;
			hr = lpDisp->QueryInterface(IID_IMTRange, (void**)&pIMTRange);

			if (FAILED(hr))
			    return hr;
			ASSERT (pIMTRange);

			pSet->QueryInterface(IID_IMTConfigPropSet,
								 (void**)&pRangePropSet);

			pIMTRange->WriteSet(pRangePropSet);

			int ref = lpDisp->Release();
		}
	} 

	

	return S_OK;
}
