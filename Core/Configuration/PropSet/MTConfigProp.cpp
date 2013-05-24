/**************************************************************************
* Copyright 1997-2000 by MetraTech
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
* Created by: 
* $Header$
* 
***************************************************************************/

/*

MTConfigProp represents a configuration property.
This class provides methods to get/set the name and value of the property
and also to get/set an attribute set (MTConfigAttribSet) associated with
this property. 

*/

// MTConfigProp.cpp : Implementation of CMTConfigProp

// disable identifier was truncated to '255' characters in the debug information
//#pragma warning(disable : 4786)

#include "StdAfx.h"

#include "PropSet.h"
#include "MTConfigProp.h"
#include "MTConfigPropSet.h"
#include "MTConfigAttribSet.h"

#include <MTDec.h>
#include <comdef.h>
#include <mtcom.h>
#include <comutil.h>


STDMETHODIMP CMTConfigProp::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTConfigProp,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}


// ----------------------------------------------------------------
// Arguments:     N/A
// Return Value:  BSTR * pVal - the name
// Errors Raised: N/A
// Description:   Gets the name of the config prop
// ----------------------------------------------------------------
STDMETHODIMP CMTConfigProp::get_Name(BSTR * pVal)
{
	_bstr_t bstr(mpObject->GetName());

	// NOTE: any extra copy is created here.
	// is there a way to detach the BSTR handle from _bstr_t?
	*pVal = bstr.copy();
	return S_OK;
}


// ----------------------------------------------------------------
// Arguments:     BSTR pVal - the name
// Return Value:  N/A
// Errors Raised: N/A
// Description:   Sets the name of the config prop
// ----------------------------------------------------------------
STDMETHODIMP CMTConfigProp::put_Name(BSTR pVal)
{
	mNewXMLObject->SetName(_bstr_t(pVal));
	return S_OK;
}


// ----------------------------------------------------------------
// Arguments:     N/A
// Return Value:  BSTR *pVal - the value as a string
// Errors Raised: N/A
// Description:   Gets the value of the property as a string
// ----------------------------------------------------------------
STDMETHODIMP CMTConfigProp::get_ValueAsString(BSTR *pVal)
{
	if (!pVal)
		return E_POINTER;

	// can't format a property set as a string
	if (!IsNameVal())
	{
		// give them an empty string
		*pVal = ::SysAllocString(L"");
		return S_FALSE;
	}

	string formatted;

	if (!GetNameVal()->FormatValue(formatted))
	{
		// TODO: what else could be returned here?
		return E_FAIL;
	}

	_bstr_t value = formatted.c_str();
	*pVal = value.copy();
	return S_OK;
}


// ----------------------------------------------------------------
// Arguments:     N/A
// Return Value:  VARIANT *pVal - the value as a variant
// Errors Raised: N/A
// Description:   Gets the value of the property as a variant
// ----------------------------------------------------------------
STDMETHODIMP CMTConfigProp::get_PropValue(/*[out, retval]*/ VARIANT *pVal)
{
	if (!pVal)
		return E_POINTER;

	if (IsNameVal())
	{
		XMLConfigNameVal * nameVal = GetNameVal();

		_variant_t var;

		ValType::Type type = nameVal->GetPropType();
		// TODO: use the same enum to avoid remapping
		switch (type)
		{
		case ValType::TYPE_INTEGER:
			var = (long) nameVal->GetInt();
			break;
		case ValType::TYPE_BIGINTEGER:
			var = nameVal->GetBigInt();
			break;
		case ValType::TYPE_DOUBLE:
			var = nameVal->GetDouble();
			break;
		case ValType::TYPE_DECIMAL:
			var = DECIMAL(MTDecimal(nameVal->GetDecimal()));
			break;
		case ValType::TYPE_STRING:
			var = nameVal->GetString().c_str();
			break;
		case ValType::TYPE_DATETIME:
			// NOTE: date times are stored in the variant as time_t, not DATE
			var = (long) nameVal->GetDateTime();
			break;
		case ValType::TYPE_TIME:
			var = (long) nameVal->GetTime();
			break;
		case ValType::TYPE_BOOLEAN:
			var = nameVal->GetBool() ? VARIANT_TRUE : VARIANT_FALSE;
			break;
		case ValType::TYPE_ENUM:
			var = (long) nameVal->GetEnum();
			break;
		default:
		case ValType::TYPE_DEFAULT:
		case ValType::TYPE_UNKNOWN:
			// no good
			return E_FAIL;
		}

		::VariantInit(pVal);
		::VariantCopy(pVal, &var);
	}
	else
	{
		CComObject<CMTConfigPropSet> * setobj;
		CComObject<CMTConfigPropSet>::CreateInstance(&setobj);

		XMLConfigPropSet * propset = GetSet();

		// this set object doesn't own the set
		setobj->SetPropSet(propset, FALSE);

		IMTConfigPropSet * setinterface;

		// have to AddRef or the count will be 0
		HRESULT hr =
			setobj->QueryInterface(IID_IMTConfigPropSet,
														 reinterpret_cast<void**>(&setinterface));
		if (FAILED(hr))
			return E_FAIL;
		_variant_t var(setinterface);
		*pVal = var;
	}

	return S_OK;
}


XMLConfigNameVal* CMTConfigProp::GetNewNameVal()
	{
		ASSERT(mNewXMLObject != NULL);
		return mNewXMLObject;
	}

// ----------------------------------------------------------------
// Arguments:     PropValType aType - the property type
//                VARIANT aVal      - the value as a variant
// Return Value:  N/A
// Errors Raised: N/A
// Description:   Adds a value with the specified type into the property
// ----------------------------------------------------------------
STDMETHODIMP CMTConfigProp::AddProp(PropValType aType,VARIANT aVal)
{
	ASSERT(mNewXMLObject != NULL);
	HRESULT hr = S_OK;

	_variant_t var(aVal);

	switch(aType) {
		case PROP_TYPE_INTEGER:
			mNewXMLObject->InitInt((int)(long)var);
			break;
		case PROP_TYPE_BIGINTEGER:
			mNewXMLObject->InitBigInt((__int64) var);
			break;
		case PROP_TYPE_DOUBLE:
			mNewXMLObject->InitDouble((double) var);
			break;
		case PROP_TYPE_DECIMAL:
		{
			MTDecimalVal val;
			val.SetValue(MTDecimal((DECIMAL) var).Format().c_str());
			mNewXMLObject->InitDecimal(val);
			break;
		}
		case PROP_TYPE_DATETIME:
			mNewXMLObject->InitDateTime((long) var);
			break;
		case PROP_TYPE_TIME:
			mNewXMLObject->InitTime((int) (long) var);
			break;
		case PROP_TYPE_BOOLEAN:
			mNewXMLObject->InitBool((bool) var);
			break;
		case PROP_TYPE_ENUM:
			mNewXMLObject->InitEnum((_bstr_t) var);
			break;
		case PROP_TYPE_STRING:
		default:
			VARIANT aVariant = var.Detach();

			ASSERT(aVariant.vt == VT_BSTR);
			mNewXMLObject->InitString(aVariant.bstrVal);
			::VariantClear(&aVariant);
		}

	return hr;
}



// ----------------------------------------------------------------
// Arguments:     N/A
// Return Value:  PropValType * apType - the property's type
// Errors Raised: N/A
// Description:   Gets the property's type
// ----------------------------------------------------------------
STDMETHODIMP CMTConfigProp::get_PropType(/*[out]*/ PropValType * apType)
{
	if (!apType)
		return E_POINTER;

	if (IsNameVal())
	{
		XMLConfigNameVal * nameVal = GetNameVal();

		ValType::Type type = nameVal->GetPropType();
		// TODO: use the same enum to avoid remapping
		switch (type)
		{
		case ValType::TYPE_INTEGER:
			*apType = PROP_TYPE_INTEGER;
			break;
		case ValType::TYPE_BIGINTEGER:
			*apType = PROP_TYPE_BIGINTEGER;
			break;
		case ValType::TYPE_DOUBLE:
			*apType = PROP_TYPE_DOUBLE;
			break;
		case ValType::TYPE_DECIMAL:
			*apType = PROP_TYPE_DECIMAL;
			break;
		case ValType::TYPE_STRING:
			*apType = PROP_TYPE_STRING;
			break;
		case ValType::TYPE_DATETIME:
			*apType = PROP_TYPE_DATETIME;
			break;
		case ValType::TYPE_TIME:
			*apType = PROP_TYPE_TIME;
			break;
		case ValType::TYPE_BOOLEAN:
			*apType = PROP_TYPE_BOOLEAN;
			break;
		case ValType::TYPE_ENUM:
		case ValType::TYPE_ID:
			*apType = PROP_TYPE_ENUM;
			break;

		case ValType::TYPE_DEFAULT:
		case ValType::TYPE_UNKNOWN:
		default:
			// no good
			return E_FAIL;
		}
	}
	else
	{
		// a subset
		*apType = PROP_TYPE_SET;
	}

	return S_OK;
}


// ----------------------------------------------------------------
// Arguments:     N/A
// Return Value:  PropValType * apType - the property type
//                VARIANT *pVal        - the value as a variant
// Errors Raised: N/A
// Description:   Gets the property type and property value as a
//				  variant
// ----------------------------------------------------------------
STDMETHODIMP CMTConfigProp::get_Value(PropValType * apType, VARIANT *pVal)
{
	// get_PropType doesn't allocate memory, so if it fails we don't have
	// to clean up.
	HRESULT hr = get_PropType(apType);
	if (FAILED(hr))
		return hr;

	hr = get_PropValue(pVal);
	if (FAILED(hr))
		return hr;

	return S_OK;
}


// ----------------------------------------------------------------
// Arguments:     XMLConfigNameVal * apNameVal - ???
// Return Value:  N/A
// Errors Raised: N/A
// Description:   Sets the ???
// ----------------------------------------------------------------
void CMTConfigProp::SetNameValue(XMLConfigNameVal * apNameVal)
{
	mpObject = apNameVal;
}


// ----------------------------------------------------------------
// Arguments:     XMLConfigPropSet * apPropSet - the XML property set
// Return Value:  N/A
// Errors Raised: N/A
// Description:   Sets the XML property set (???)
// ----------------------------------------------------------------
void CMTConfigProp::SetPropSet(XMLConfigPropSet * apPropSet)
{
	mpObject = apPropSet;
}


// ----------------------------------------------------------------
// Arguments:     N/A
// Return Value:  ppAttribSet - map of XML attributes associated with this property.
// Errors Raised: N/A
// Description:   Gets the map of XML attributes associated with this property.
// ----------------------------------------------------------------
STDMETHODIMP CMTConfigProp::get_AttribSet(IMTConfigAttribSet** ppAttribSet)
{
	ASSERT(ppAttribSet);
	if(!ppAttribSet) return E_POINTER;
	HRESULT hr = S_OK;

	*ppAttribSet = NULL;
	XMLConfigNameVal * nameval = NULL;

	if(mNewXMLObject) {
		nameval = ConvertUserObject(mNewXMLObject, nameval);
	}
	else {
		ASSERT(mpObject);
		nameval = ConvertUserObject(mpObject, nameval);
	}
	 
	if(nameval != NULL) {

		XMLNameValueMap aMap = nameval->GetMap();

		if(aMap.GetObject() != NULL) {
			CComObject<CMTConfigAttribSet> * pAttribSet;
			CComObject<CMTConfigAttribSet>::CreateInstance(&pAttribSet);
			if (!pAttribSet)
				return E_OUTOFMEMORY;

			// have to AddRef or the count will be 0
			HRESULT hr =
				pAttribSet->QueryInterface(IID_IMTConfigAttribSet,
														 reinterpret_cast<void**>(ppAttribSet));
			if(SUCCEEDED(hr)) {
				pAttribSet->SetMap(aMap);
			}
		}
	}
	
	return hr;
}


// ----------------------------------------------------------------
// Arguments:     pAttribSet - map of XML attributes associated with this property.
// Return Value:  N/A
// Errors Raised: N/A
// Description:   Sets the map of XML attributes associated with this property.
// ----------------------------------------------------------------
STDMETHODIMP CMTConfigProp::put_AttribSet(/*[in]*/ IMTConfigAttribSet* pAttribSet)
{
	ASSERT(pAttribSet);
	if(!pAttribSet) return E_POINTER;

	CComObject<CMTConfigAttribSet> *pSet = (CComObject<CMTConfigAttribSet>*)pAttribSet;
	if(mNewXMLObject) {
			mNewXMLObject->PutMap(pSet->GetMap());
	}
	else {
		ASSERT(mpObject);
		mpObject->PutMap(pSet->GetMap());
	}
	return S_OK;
}

HRESULT WINAPI _This(void* pv,REFIID iid,void** ppvObject,DWORD)
{
  ATLASSERT(iid == IID_NULL);
  *ppvObject = pv;
  return S_OK;
}





