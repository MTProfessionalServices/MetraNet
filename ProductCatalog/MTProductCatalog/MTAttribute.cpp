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
#include "MTAttribute.h"

/////////////////////////////////////////////////////////////////////////////
// CMTAttribute

STDMETHODIMP CMTAttribute::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTAttribute
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

/********************************** construction/destruction ***/
CMTAttribute::CMTAttribute()
{
	mUnkMarshalerPtr = NULL;
	mMetaDataPtr = NULL;
}

HRESULT CMTAttribute::FinalConstruct()
{
	return CoCreateFreeThreadedMarshaler(GetControllingUnknown(), &mUnkMarshalerPtr.p);
}

void CMTAttribute::FinalRelease()
{
	mUnkMarshalerPtr.Release();
}

/********************************** IMTAttribute***/

STDMETHODIMP CMTAttribute::get_Value(VARIANT *pVal)
{
	if (!pVal)
		return E_POINTER;

	::VariantInit(pVal);
	::VariantCopy(pVal, &mValue);

	return S_OK;
}

STDMETHODIMP CMTAttribute::put_Value(VARIANT newVal)
{
	mValue = newVal;

	return S_OK;
}

STDMETHODIMP CMTAttribute::GetMetaData(/*[out, retval]*/ IMTAttributeMetaData** apMetaData)
{
	if (!apMetaData)
		return E_POINTER;
	
	mMetaDataPtr.CopyTo(apMetaData);

	return S_OK;
}

STDMETHODIMP CMTAttribute::SetMetaData(/*[in]*/ IMTAttributeMetaData* apMetaData)
{
	mMetaDataPtr = apMetaData;

	return S_OK;
}

STDMETHODIMP CMTAttribute::get_Name(BSTR *pVal)
{
	return mMetaDataPtr->get_Name( pVal);
}

