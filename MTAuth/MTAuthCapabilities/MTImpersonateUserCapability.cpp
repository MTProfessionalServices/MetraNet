// MTImpersonateUserCapability.cpp : Implementation of CMTImpersonateUserCapability
#include "StdAfx.h"
#include "MTAuthCapabilities.h"
#include "MTImpersonateUserCapability.h"

/////////////////////////////////////////////////////////////////////////////
// CMTImpersonateUserCapability

STDMETHODIMP CMTImpersonateUserCapability::InterfaceSupportsErrorInfo(REFIID riid)
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
