// MTManageSubscriberAuthCapability.cpp : Implementation of CMTManageSubscriberAuthCapability
#include "StdAfx.h"
#include "MTAuthCapabilities.h"
#include "MTManageSubscriberAuthCapability.h"

/////////////////////////////////////////////////////////////////////////////
// CMTManageSubscriberAuthCapability

STDMETHODIMP CMTManageSubscriberAuthCapability::InterfaceSupportsErrorInfo(REFIID riid)
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
