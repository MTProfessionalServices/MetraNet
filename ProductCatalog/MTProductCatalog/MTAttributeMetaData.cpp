/**************************************************************************
* Copyright 1997-2001 by MetraTech
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
* $Header$
* 
***************************************************************************/

#include "StdAfx.h"
#include <metra.h>
#include <comdef.h>
#include <mtcomerr.h>

#include "MTProductCatalog.h"
#include "MTAttributeMetaData.h"

/////////////////////////////////////////////////////////////////////////////
// CMTAttributeMetaData

/******************************************* error interface ***/
STDMETHODIMP CMTAttributeMetaData::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTAttributeMetaData
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

/********************************** construction/destruction ***/

CMTAttributeMetaData::CMTAttributeMetaData()
{
	mUnkMarshalerPtr = NULL;
	mName = "";
	mDefaultValue = vtMissing;
}

HRESULT CMTAttributeMetaData::FinalConstruct()
{
	return CoCreateFreeThreadedMarshaler(
		GetControllingUnknown(), &mUnkMarshalerPtr.p);
}

void CMTAttributeMetaData::FinalRelease()
{
	mUnkMarshalerPtr.Release();
}

/********************************** IMTAttributeMetaData***/
STDMETHODIMP CMTAttributeMetaData::get_Name(BSTR *pVal)
{
	if (pVal == NULL)
		return E_POINTER;

	*pVal = mName.copy();
	return S_OK;
}

STDMETHODIMP CMTAttributeMetaData::put_Name(BSTR newVal)
{
	mName = newVal;
	return S_OK;
}


STDMETHODIMP CMTAttributeMetaData::get_DefaultValue(VARIANT *pVal)
{
	if (pVal == NULL)
		return E_POINTER;
	
	::VariantInit(pVal);
	::VariantCopy(pVal, &mDefaultValue);

	return S_OK;
}

STDMETHODIMP CMTAttributeMetaData::put_DefaultValue(VARIANT newVal)
{
	mDefaultValue = newVal;
	return S_OK;
}

