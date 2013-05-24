// MTAccountProperty.cpp : Implementation of CMTAccountProperty
#include "StdAfx.h"
#include "MTAccount.h"
#include "MTAccountProperty.h"
#include "stdutils.h"

/////////////////////////////////////////////////////////////////////////////
// CMTAccountProperty

STDMETHODIMP CMTAccountProperty::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTAccountProperty
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CMTAccountProperty::get_Name(BSTR *pVal)
{
    *pVal = mName.copy();
	return S_OK;
}

STDMETHODIMP CMTAccountProperty::put_Name(BSTR newVal)
{
	mtwstring wName(newVal);
	wName.toupper();

    mName = wName;
	return S_OK;
}

STDMETHODIMP CMTAccountProperty::get_Value(VARIANT *pVal)
{
	_variant_t var;
	var = mValue;

    *pVal = var.Detach();
	return S_OK;
}

STDMETHODIMP CMTAccountProperty::put_Value(VARIANT newVal)
{
    mValue = newVal;
	return S_OK;
}

STDMETHODIMP CMTAccountProperty::Add(BSTR Name, VARIANT Value)
{
	mtwstring wName(Name);
	wName.toupper();

    mName = wName;
    mValue = Value;

	return S_OK;
}
