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
#include "MTActionMetaData.h"

/////////////////////////////////////////////////////////////////////////////
// CMTActionMetaData

STDMETHODIMP CMTActionMetaData::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
    &IID_IMTActionMetaData,
    &IID_IMTPCBase
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTActionMetaData::FinalConstruct()
{
	try
	{
		LoadPropertiesMetaData(PCENTITY_TYPE_ACTION_META_DATA);

		return CoCreateFreeThreadedMarshaler(
			GetControllingUnknown(), &m_pUnkMarshaler.p);
	}
	catch (_com_error & err)
	{ return LogAndReturnComError(PCCache::GetLogger(),err); }
}

STDMETHODIMP CMTActionMetaData::get_PropertyName(BSTR *pVal)
{
	return GetPropertyValue("PropertyName", pVal);
}

STDMETHODIMP CMTActionMetaData::put_PropertyName(BSTR newVal)
{
	return PutPropertyValue("PropertyName", newVal);
}

STDMETHODIMP CMTActionMetaData::get_ColumnName(BSTR *pVal)
{
	return GetPropertyValue("ColumnName", pVal);
}

STDMETHODIMP CMTActionMetaData::put_ColumnName(BSTR newVal)
{
	return PutPropertyValue("ColumnName", newVal);
}

STDMETHODIMP CMTActionMetaData::get_Kind(long *pVal)
{
	return GetPropertyValue("Kind", pVal);
}

STDMETHODIMP CMTActionMetaData::put_Kind(long newVal)
{
	return PutPropertyValue("Kind", newVal);
}

STDMETHODIMP CMTActionMetaData::get_DataType(PropValType *pVal)
{
	return GetPropertyValue("DataType", reinterpret_cast<long*>(pVal));
}

STDMETHODIMP CMTActionMetaData::put_DataType(PropValType newVal)
{
	return PutPropertyValue("DataType", static_cast<long>(newVal));
}

STDMETHODIMP CMTActionMetaData::get_DefaultValue(VARIANT *pVal)
{
	return GetPropertyValue("DefaultValue", pVal);
}

STDMETHODIMP CMTActionMetaData::put_DefaultValue(VARIANT newVal)
{
	return PutPropertyValue("DefaultValue", newVal);
}

STDMETHODIMP CMTActionMetaData::get_EnumSpace(BSTR *pVal)
{
	return GetPropertyValue("EnumSpace", pVal);
}

STDMETHODIMP CMTActionMetaData::put_EnumSpace(BSTR newVal)
{
	return PutPropertyValue("EnumSpace", newVal);
}

STDMETHODIMP CMTActionMetaData::get_EnumType(BSTR *pVal)
{
	return GetPropertyValue("EnumType", pVal);
}

STDMETHODIMP CMTActionMetaData::put_EnumType(BSTR newVal)
{
	return PutPropertyValue("EnumType", newVal);
}

STDMETHODIMP CMTActionMetaData::get_DisplayName(BSTR *pVal)
{
	return GetPropertyValue("DisplayName", pVal);
}

STDMETHODIMP CMTActionMetaData::put_DisplayName(BSTR newVal)
{
	return PutPropertyValue("DisplayName", newVal);
}

STDMETHODIMP CMTActionMetaData::get_Editable(VARIANT_BOOL *pVal)
{
	return GetPropertyValue("Editable", pVal);
}

STDMETHODIMP CMTActionMetaData::put_Editable(VARIANT_BOOL newVal)
{
	return PutPropertyValue("Editable", newVal);
}

STDMETHODIMP CMTActionMetaData::get_Required(VARIANT_BOOL *pVal)
{
	return GetPropertyValue("Required", pVal);
}

STDMETHODIMP CMTActionMetaData::put_Required(VARIANT_BOOL newVal)
{
	return PutPropertyValue("Required", newVal);
}

STDMETHODIMP CMTActionMetaData::get_Length(/*[out, retval]*/ long *pVal)
{
	return GetPropertyValue("Length", pVal);
}

STDMETHODIMP CMTActionMetaData::put_Length(/*[in]*/ long newVal)
{
	return PutPropertyValue("Length", newVal);
}
