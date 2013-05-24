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


// MTEnumTypeCollection.cpp : Implementation of CMTEnumTypeCollection
#include "StdAfx.h"
#include "MTEnumConfig.h"
#include "MTEnumTypeCollection.h"

/////////////////////////////////////////////////////////////////////////////
// CMTEnumTypeCollection

// ----------------------------------------------------------------
// Arguments:     
// Return Value:  
// Raised Errors:
// Description:  INTERNAL USE ONLY
// ----------------------------------------------------------------

HRESULT CMTEnumTypeCollection::FinalConstruct()
{
	return CoCreateFreeThreadedMarshaler(
		GetControllingUnknown(), &m_pUnkMarshaler.p);
}


STDMETHODIMP CMTEnumTypeCollection::get__NewEnum(LPUNKNOWN * pVal)
{
    HRESULT hr = S_OK;

	typedef CComObject<CComEnum<IEnumVARIANT, 
	  &IID_IEnumVARIANT, VARIANT, _Copy<VARIANT> > > enumvar;

	enumvar* pEnumVar = new enumvar;
	ASSERT (pEnumVar);
	int size = mEnumTypeVector.size();

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
		hr = pEnumVar->Init(&mEnumTypeVector[0], 
							&mEnumTypeVector[size - 1] + 1, 
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
// Name:     			Add
// Arguments:     
// Return Value:  
// Raised Errors:
// Description:  INTERNAL USE ONLY
// ----------------------------------------------------------------

STDMETHODIMP CMTEnumTypeCollection::Add(::IMTEnumType * pEnum)
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
	mEnumTypeVector.push_back(var);
	
	return hr;

}

// ----------------------------------------------------------------
// Name:     			get_Size
// Arguments:     
// Return Value:  long* val - collection size
// Raised Errors:
// Description:  Returns number of enum types in the collection
// ----------------------------------------------------------------

STDMETHODIMP CMTEnumTypeCollection::get_Size(long * pSize)
{
	*pSize = (long)mEnumTypeVector.size();
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     			get_Count
// Arguments:     
// Return Value:  long* val - collection size
// Raised Errors:
// Description:  Same as get_Size
// ----------------------------------------------------------------

STDMETHODIMP CMTEnumTypeCollection::get_Count(long * pVal)
{
	if (!pVal)
		return E_POINTER;

	*pVal = (long)mEnumTypeVector.size();

	return S_OK;
}

// ----------------------------------------------------------------
// Name:     			get_Item
// Arguments:     long aIndex			-		index
// Return Value:  VARIANT* pVal		-		MTEnumType
// Raised Errors:
// Description:  returns MTEnumType object at a specified index
// ----------------------------------------------------------------

STDMETHODIMP CMTEnumTypeCollection::get_Item(long aIndex, VARIANT * pVal)
{
	ASSERT(pVal);
	if (!pVal)
		return E_POINTER;

	//VariantInit(pVal);
	pVal->vt = VT_UNKNOWN;
	pVal->punkVal = NULL;

	if ((aIndex < 1) || (aIndex > (long) mEnumTypeVector.size()))
		return E_INVALIDARG;

	::VariantClear(pVal);
	::VariantCopy(pVal, &mEnumTypeVector.at(aIndex - 1));
	//	pVal->punkVal->Release();
	
	
	return S_OK;
}
