// MTManageProductOfferingsCapability.cpp : Implementation of CMTManageProductOfferingsCapability
// NOTE: At first, this capability will only be used to prevent Product Offering deletion.
//			 Later on, we can leverage it to be parametrized to include READ/WRITE/DELETE options.

#include "StdAfx.h"
#include "MTManageProductOfferingsCapability.h"


// CMTManageProductOfferingsCapability

STDMETHODIMP CMTManageProductOfferingsCapability::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTManageProductOfferingsCapability
	};

	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}
