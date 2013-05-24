// MTManageCSRAuthCapability.cpp : Implementation of CMTManageCSRAuthCapability
#include "StdAfx.h"
#include "MTAuthCapabilities.h"
#include "MTManageCSRAuthCapability.h"

/////////////////////////////////////////////////////////////////////////////
// CMTManageCSRAuthCapability

STDMETHODIMP CMTManageCSRAuthCapability::InterfaceSupportsErrorInfo(REFIID riid)
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
