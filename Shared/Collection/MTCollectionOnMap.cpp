// MTCollectionOnMap.cpp : Implementation of CMTCollectionOnMap
#include "StdAfx.h"
#include "GenericCollection.h"
#include "MTCollectionOnMap.h"

/////////////////////////////////////////////////////////////////////////////
// CMTCollectionOnMap


/////////////////////////////////////////////////////////////////////////////
// CMTCollectionOnMap

STDMETHODIMP CMTCollectionOnMap::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTCollectionOnMap
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}
