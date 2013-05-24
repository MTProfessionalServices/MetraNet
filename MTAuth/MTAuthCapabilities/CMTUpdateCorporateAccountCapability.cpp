// CMTUpdateCorporateAccountCapability.cpp : Implementation of CCMTUpdateCorporateAccountCapability
#include "StdAfx.h"
#include "MTAuthCapabilities.h"
#include "CMTUpdateCorporateAccountCapability.h"

/////////////////////////////////////////////////////////////////////////////
// CCMTUpdateCorporateAccountCapability

STDMETHODIMP CCMTUpdateCorporateAccountCapability::InterfaceSupportsErrorInfo(REFIID riid)
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
