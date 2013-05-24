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
#include "MTConditionMetaData.h"

/////////////////////////////////////////////////////////////////////////////
// CMTConditionMetaData

STDMETHODIMP CMTConditionMetaData::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
    &IID_IMTConditionMetaData,
    &IID_IMTPCBase
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTConditionMetaData::FinalConstruct()
{
	try
	{
		LoadPropertiesMetaData(PCENTITY_TYPE_CONDITION_META_DATA);

		return CoCreateFreeThreadedMarshaler(
			GetControllingUnknown(), &m_pUnkMarshaler.p);
	}
	catch (_com_error & err)
	{ return LogAndReturnComError(PCCache::GetLogger(),err); }
}

STDMETHODIMP CMTConditionMetaData::get_ColumnName(BSTR *pVal)
{
	return GetPropertyValue("ColumnName", pVal);
}

STDMETHODIMP CMTConditionMetaData::put_ColumnName(BSTR newVal)
{
	return PutPropertyValue("ColumnName", newVal);
}

STDMETHODIMP CMTConditionMetaData::get_PropertyName(BSTR *pVal)
{
	return GetPropertyValue("PropertyName", pVal);
}

STDMETHODIMP CMTConditionMetaData::put_PropertyName(BSTR newVal)
{
	return PutPropertyValue("PropertyName", newVal);
}

STDMETHODIMP CMTConditionMetaData::get_DataType(PropValType *pVal)
{
	return GetPropertyValue("DataType", reinterpret_cast<long*>(pVal));
}

STDMETHODIMP CMTConditionMetaData::put_DataType(PropValType newVal)
{
	return PutPropertyValue("DataType", static_cast<long>(newVal));
}

STDMETHODIMP CMTConditionMetaData::get_Operator(MTOperatorType *pVal)
{
	return GetPropertyValue("Operator", reinterpret_cast<long*>(pVal));
}

STDMETHODIMP CMTConditionMetaData::put_Operator(MTOperatorType newVal)
{
	return PutPropertyValue("Operator", static_cast<long>(newVal));
}

STDMETHODIMP CMTConditionMetaData::get_OperatorPerRule(VARIANT_BOOL *pVal)
{
	return GetPropertyValue("OperatorPerRule", pVal);
}

STDMETHODIMP CMTConditionMetaData::put_OperatorPerRule(VARIANT_BOOL newVal)
{
	return PutPropertyValue("OperatorPerRule", newVal);
}

STDMETHODIMP CMTConditionMetaData::get_DisplayOperator(VARIANT_BOOL *pVal)
{
	return GetPropertyValue("DisplayOperator", pVal);
}

STDMETHODIMP CMTConditionMetaData::put_DisplayOperator(VARIANT_BOOL newVal)
{
	return PutPropertyValue("DisplayOperator", newVal);
}

STDMETHODIMP CMTConditionMetaData::get_EnumSpace(BSTR *pVal)
{
	return GetPropertyValue("EnumSpace", pVal);
}

STDMETHODIMP CMTConditionMetaData::put_EnumSpace(BSTR newVal)
{
	return PutPropertyValue("EnumSpace", newVal);
}

STDMETHODIMP CMTConditionMetaData::get_EnumType(BSTR *pVal)
{
	return GetPropertyValue("EnumType", pVal);
}

STDMETHODIMP CMTConditionMetaData::put_EnumType(BSTR newVal)
{
	return PutPropertyValue("EnumType", newVal);
}

STDMETHODIMP CMTConditionMetaData::get_Filterable(VARIANT_BOOL *pVal)
{
	return GetPropertyValue("Filterable", pVal);
}

STDMETHODIMP CMTConditionMetaData::put_Filterable(VARIANT_BOOL newVal)
{
	return PutPropertyValue("Filterable", newVal);
}

STDMETHODIMP CMTConditionMetaData::get_Required(VARIANT_BOOL *pVal)
{
	return GetPropertyValue("Required", pVal);
}

STDMETHODIMP CMTConditionMetaData::put_Required(VARIANT_BOOL newVal)
{
	return PutPropertyValue("Required", newVal);
}

STDMETHODIMP CMTConditionMetaData::get_DisplayName(BSTR *pVal)
{
	return GetPropertyValue("DisplayName", pVal);
}

STDMETHODIMP CMTConditionMetaData::put_DisplayName(BSTR newVal)
{
	return PutPropertyValue("DisplayName", newVal);
}

STDMETHODIMP CMTConditionMetaData::get_Length(/*[out, retval]*/ long *pVal)
{
	return GetPropertyValue("Length", pVal);
}

STDMETHODIMP CMTConditionMetaData::put_Length(/*[in]*/ long newVal)
{
	return PutPropertyValue("Length", newVal);
}

STDMETHODIMP CMTConditionMetaData::get_DefaultValue(VARIANT *pVal)
{
	return GetPropertyValue("DefaultValue", pVal);
}

STDMETHODIMP CMTConditionMetaData::put_DefaultValue(VARIANT newVal)
{
	return PutPropertyValue("DefaultValue", newVal);
}
