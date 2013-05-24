// MTManageRatesCapability.cpp : Implementation of CMTManageRatesCapability
// NOTE: At first, this capability will only be used to prevent Rate Schedule and Price List deletion.
//			 Later on, we can leverage it to be parametrized to include READ/WRITE/DELETE options.

#include "StdAfx.h"
#include "MTManageRatesCapability.h"


// CMTManageRatesCapability

STDMETHODIMP CMTManageRatesCapability::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTCompositeCapability
	};

	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}
