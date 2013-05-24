// MTUpdateFailedTransactions.cpp : Implementation of CMTUpdateFailedTransactions
#include "StdAfx.h"
#include "MTAuthCapabilities.h"
#include "MTUpdateFailedTransactions.h"

/////////////////////////////////////////////////////////////////////////////
// CMTUpdateFailedTransactions

STDMETHODIMP CMTUpdateFailedTransactions::InterfaceSupportsErrorInfo(REFIID riid)
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
