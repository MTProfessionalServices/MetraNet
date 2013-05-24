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
* $Header$
* 
***************************************************************************/

#include "StdAfx.h"
#include "RCD.h"
#include <dirwatch.h>
#include <stdutils.h>
#include "MTRcdFileList.h"
#include <stlenum.h>

using namespace std;

/////////////////////////////////////////////////////////////////////////////
// CMTRcdFileList

STDMETHODIMP CMTRcdFileList::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTRcdFileList
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

// ----------------------------------------------------------------
// Name:     	CMTRcdFileList destructor
// Description:   Empties the mFilelist vector
// ----------------------------------------------------------------

CMTRcdFileList::~CMTRcdFileList()
{
	mFileList.erase(mFileList.begin(),mFileList.end());
}

// ----------------------------------------------------------------
// Name:     	get_Count
// Arguments:     <pVal> -  the value to store the count
// Return values: E_POINTER, S_OK
// Description:   returns the count of the number of files
// ----------------------------------------------------------------

STDMETHODIMP CMTRcdFileList::get_Count(long *pVal)
{
	ASSERT(pVal);
	if(!pVal) return E_POINTER;
	*pVal = mFileList.size();
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	get_Item
// Arguments:     <aIndex> - The index that specifies the item to retrieve
//                <pVal> - the result
// Return Value:  E_POINTER, S_OK 
// Description:   returns the specified item in the variant
// ----------------------------------------------------------------

STDMETHODIMP CMTRcdFileList::get_Item(long aIndex, VARIANT *pVal)
{
	ASSERT(pVal);
	if(!pVal) return E_POINTER;

	mtstring aStr = mFileList.at(aIndex);
	
	// should use the char* constructor
	_variant_t aVariant(aStr);
	
	::VariantClear(pVal);
	::VariantCopy(pVal,&aVariant);
	return S_OK;
}


// ----------------------------------------------------------------
// Name:     	AddFile
// Arguments:     <newVal> - a new file to add to the collection
// Return Value:  E_POINTER, S_OK
// Description:   Adds a file to the collection
// ----------------------------------------------------------------

STDMETHODIMP CMTRcdFileList::AddFile(BSTR newVal)
{
	ASSERT(newVal);
	if(!newVal) return E_POINTER;

	string aTemp = mtwstring(newVal);
	AddItem(aTemp);
	return S_OK;
}


// ----------------------------------------------------------------
// Name:     	get__NewEnum
// Arguments:     <LPUNKNOWN> - returns an IUNknown pointer to the collection interface pointer
// Return Value:  E_POINTER,S_OK   
// Description:   Constructs the enumerator interface pointer using the STL helpers
// ----------------------------------------------------------------

STDMETHODIMP CMTRcdFileList::get__NewEnum(LPUNKNOWN *pVal)
{
	ASSERT(pVal);
	if(!pVal) return E_POINTER;

	IUnknown* pUnk;

	QueryInterface(IID_IUnknown,(void**)&pUnk);
	HRESULT hr = CreateSTLEnumerator<stringcoll::EnumeratorType>(pVal,pUnk,mFileList);
	pUnk->Release();
	return hr;
}
