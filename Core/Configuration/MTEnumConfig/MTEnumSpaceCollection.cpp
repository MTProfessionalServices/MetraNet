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
* Created by: Boris Partensky
* $Header$
* 
***************************************************************************/


// MTEnumSpaceCollection.cpp : Implementation of CMTEnumSpaceCollection
#include "StdAfx.h"
#include "MTEnumConfig.h"
#include "MTEnumSpaceCollection.h"

/////////////////////////////////////////////////////////////////////////////
// CMTEnumSpaceCollection

// ----------------------------------------------------------------
// Arguments:     
// Return Value:  
// Raised Errors:
// Description:  AUTO GENERATED
// ----------------------------------------------------------------

HRESULT CMTEnumSpaceCollection::FinalConstruct()
{
	return CoCreateFreeThreadedMarshaler(
		GetControllingUnknown(), &m_pUnkMarshaler.p);
}


STDMETHODIMP CMTEnumSpaceCollection::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTEnumSpaceCollection
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

// ----------------------------------------------------------------
// Arguments:     
// Return Value:  
// Raised Errors:
// Description:  INTERNAL USE ONLY
// ----------------------------------------------------------------

STDMETHODIMP CMTEnumSpaceCollection::get__NewEnum(LPUNKNOWN * pVal)
{
    HRESULT hr = S_OK;

	typedef CComObject<CComEnum<IEnumVARIANT, 
	  &IID_IEnumVARIANT, VARIANT, _Copy<VARIANT> > > enumvar;

	enumvar* pEnumVar = new enumvar;
	ASSERT (pEnumVar);
	int size = mEnumSpaceColl.size();

	// Note: end pointer has to be one past the end of the list
	if (size == 0)
	{
		hr = pEnumVar->Init(NULL,
							NULL, 
							NULL, 
							AtlFlagCopy);
	}
	else
	{
		hr = pEnumVar->Init(&mEnumSpaceColl[0], 
							&mEnumSpaceColl[size - 1] + 1, 
							NULL, 
							AtlFlagCopy);
	}

	if (SUCCEEDED(hr))
		hr = pEnumVar->QueryInterface(IID_IEnumVARIANT, (void**)pVal);

	if (FAILED(hr))
		delete pEnumVar;

	return hr;
}

// ----------------------------------------------------------------
// Name:     			get_Size
// Arguments:     
// Return Value:  long* val - collection size
// Raised Errors:
// Description:  Returns number of enum spaces in the collection
// ----------------------------------------------------------------

STDMETHODIMP CMTEnumSpaceCollection::get_Size(long * pSize)
{
	if (!pSize)
		return E_POINTER;
	*pSize = (long)mEnumSpaceColl.size();
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     			get_Count
// Arguments:     
// Return Value:  long* val - collection size
// Raised Errors:
// Description:		Same as get_Size
// ----------------------------------------------------------------

STDMETHODIMP CMTEnumSpaceCollection::get_Count(long * pVal)
{
	if (!pVal)
		return E_POINTER;

	*pVal = (long)mEnumSpaceColl.size();

	return S_OK;
}

// ----------------------------------------------------------------
// Name:     			get_Item
// Arguments:     long aIndex			-		index
// Return Value:  VARIANT* pVal		-		MTEnumSpace
// Raised Errors:
// Description:  returns MTEnumSpace object at a specified index
// ----------------------------------------------------------------

STDMETHODIMP CMTEnumSpaceCollection::get_Item(long aIndex, VARIANT * pVal)
{
	if (pVal == NULL)
		return E_POINTER;

	//VariantInit(pVal);
	pVal->vt = VT_UNKNOWN;
	pVal->punkVal = NULL;

	if ((aIndex < 1) || (aIndex > (long) mEnumSpaceColl.size()))
		return E_INVALIDARG;

	::VariantClear(pVal);
	::VariantCopy(pVal, &mEnumSpaceColl.at(aIndex - 1));
	//pVal->punkVal->Release();

	return S_OK;
}


// ----------------------------------------------------------------
// Name:     			Add
// Arguments:     
// Return Value:  
// Raised Errors:
// Description:		CURRENTLY NOT USED
// ----------------------------------------------------------------

STDMETHODIMP CMTEnumSpaceCollection::Add(::IMTEnumSpace * pEnum)
{
	HRESULT hr = S_OK;
	LPDISPATCH lpDisp = NULL;

	
	hr = pEnum->QueryInterface(IID_IDispatch, (void**)&lpDisp);
	
	if (FAILED(hr))
	{
		return hr;
	}
	
	// create a variant
	CComVariant var;
	var.vt = VT_DISPATCH;
	var.pdispVal = lpDisp;
	
	mEnumSpaceColl.push_back(var);
	return hr;

}
