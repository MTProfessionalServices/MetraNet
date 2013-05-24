// MTExchange.cpp : Implementation of CMTExchange
#include "StdAfx.h"
#include "PhoneLookup.h"
#include "MTExchange.h"

/////////////////////////////////////////////////////////////////////////////
// CMTExchange

STDMETHODIMP CMTExchange::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTExchange,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CMTExchange::get_Code(BSTR * pVal)
{
	*pVal = mCode.copy();	
	return S_OK;
}

STDMETHODIMP CMTExchange::put_Code(BSTR newVal)
{
	mCode = newVal;
	return S_OK;
}


STDMETHODIMP CMTExchange::get_Description(BSTR * pVal)
{
	*pVal = mDescription.copy();
	return S_OK;
}

STDMETHODIMP CMTExchange::put_Description(BSTR newVal)
{
	mDescription = newVal;
	return S_OK;
}
