// MTCollectionEx.cpp : Implementation of CMTCollectionEx
#include "StdAfx.h"
#include "GenericCollection.h"
#include "MTCollectionEx.h"

/////////////////////////////////////////////////////////////////////////////
// CMTCollectionEx

STDMETHODIMP CMTCollectionEx::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTCollectionEx,
    &IID_IMTCollection,
    &IID_IMTCollectionReadOnly
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}
