/**************************************************************************
* Copyright 1997-2002 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
***************************************************************************/

#include "StdAfx.h"
#include "MTYAAC.h"
#include "MTAccountTemplateProperty.h"

/////////////////////////////////////////////////////////////////////////////
// CMTAccountTemplateProperty

STDMETHODIMP CMTAccountTemplateProperty::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTAccountTemplateProperty
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CMTAccountTemplateProperty::Initialize(BSTR aClass,BSTR aName,BSTR aValue)
{
	// TODO: Add your implementation code here

	return S_OK;
}


STDMETHODIMP CMTAccountTemplateProperty::get_ToString(BSTR *pVal)
{
	// TODO: Add your implementation code here

	return S_OK;
}



STDMETHODIMP CMTAccountTemplateProperty::get_Name(BSTR *pVal)
{
	*pVal = mName.copy();
	return S_OK;
}

STDMETHODIMP CMTAccountTemplateProperty::put_Name(BSTR newVal)
{
	mName = newVal;
	return S_OK;
}

STDMETHODIMP CMTAccountTemplateProperty::get_Value(BSTR *pVal)
{
	*pVal = mValue.copy();
	return S_OK;
}

STDMETHODIMP CMTAccountTemplateProperty::put_Value(BSTR newVal)
{
	mValue = newVal;
	return S_OK;
}

STDMETHODIMP CMTAccountTemplateProperty::get_Class(BSTR *pVal)
{
	*pVal = mClass.copy();
	return S_OK;
}

STDMETHODIMP CMTAccountTemplateProperty::put_Class(BSTR newVal)
{
	mClass = newVal;
	return S_OK;
}

STDMETHODIMP CMTAccountTemplateProperty::get_Type(PropValType *pVal)
{
	*pVal = mType;
	return S_OK;
}

STDMETHODIMP CMTAccountTemplateProperty::put_Type(PropValType newVal)
{
	mType = newVal;
	return S_OK;
}

STDMETHODIMP CMTAccountTemplateProperty::get_InternalValue(BSTR *pVal)
{
	*pVal = mInternalValue.copy();
	return S_OK;
}

STDMETHODIMP CMTAccountTemplateProperty::put_InternalValue(BSTR newVal)
{
	mInternalValue = newVal;
	return S_OK;
}