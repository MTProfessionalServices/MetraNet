// MTXmlElement.cpp : Implementation of CMTXmlElement
#include "StdAfx.h"
#include "SchemaReader.h"
#include "MTXmlElement.h"
#include "MTXmlType.h"

/////////////////////////////////////////////////////////////////////////////
// CMTXmlElement

STDMETHODIMP CMTXmlElement::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTXmlElement
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

#define VALIDATE_PARAMS() \
	ASSERT(mpElement && pVal); \
	if(!(mpElement && pVal)) return E_POINTER; \

/////////////////////////////////////////////////////////////////////////////
// Function name	: CMTXmlElement::get_Name
// Description	  : 
/////////////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTXmlElement::get_Name(BSTR *pVal)
{
	VALIDATE_PARAMS();

	_bstr_t aName = mpElement->GetName().c_str();
	*pVal = aName.copy();
	return S_OK;
}


/////////////////////////////////////////////////////////////////////////////
// Function name	: CMTXmlElement::get_Type
// Description	  : 
/////////////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTXmlElement::get_Type(BSTR *pVal)
{
	VALIDATE_PARAMS();
	_bstr_t aType = mpElement->GetType().c_str();
	*pVal = aType.copy();
	return S_OK;
}


/////////////////////////////////////////////////////////////////////////////
// Function name	: CMTXmlElement::get_IsSet
// Description	  : 
/////////////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTXmlElement::get_IsSet(VARIANT_BOOL *pVal)
{
	VALIDATE_PARAMS();
	// we need to make sure that we eventually support user defined primative types
	*pVal = mpElement->IsSet() ? VARIANT_TRUE : VARIANT_FALSE;
	return S_OK;
}


/////////////////////////////////////////////////////////////////////////////
// Function name	: CMTXmlElement::get_MinOccurs
// Description	  : 
/////////////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTXmlElement::get_MinOccurs(long *pVal)
{
	VALIDATE_PARAMS();
	*pVal = mpElement->GetMinOccurences();
	return S_OK;
}


/////////////////////////////////////////////////////////////////////////////
// Function name	: CMTXmlElement::get_MaxOccurs
// Description	  : 
/////////////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTXmlElement::get_MaxOccurs(long *pVal)
{
	VALIDATE_PARAMS();
	*pVal = mpElement->GetMaxOccurrences();
	return S_OK;
}



/////////////////////////////////////////////////////////////////////////////
// Function name	: CMTXmlElement::get_InlineType
// Description	  : 
/////////////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTXmlElement::get_InlineType(IMTXmlType **pVal)
{
	ASSERT(pVal);
	if(!pVal) return E_POINTER;

	if(!mpElement->GetInlineType()) return E_FAIL;

	CComObject<CMTXmlType> * pXmlType;
	CComObject<CMTXmlType>::CreateInstance(&pXmlType);
	if (!pXmlType)
		return E_OUTOFMEMORY;

	HRESULT hr = pXmlType->QueryInterface(IID_IMTXmlType,
												 reinterpret_cast<void**>(pVal));
	if(SUCCEEDED(hr)) {
		pXmlType->SetType(mpElement->GetInlineType());
	}

	return hr;
}

/////////////////////////////////////////////////////////////////////////////
// Function name	: CMTXmlElement::get_Fixed
// Description	    : 
// Return type		: STDMETHODIMP 
// Argument         : VARIANT_BOOL *pVal
/////////////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTXmlElement::get_Fixed(VARIANT_BOOL *pVal)
{
	ASSERT(pVal);
	if(!pVal) return E_POINTER;

	if(mpElement->IsFixedValue()) {
		*pVal = VARIANT_FALSE;
	}
	else {
		*pVal = VARIANT_TRUE;
	}

	return S_OK;
}


/////////////////////////////////////////////////////////////////////////////
// Function name	: CMTXmlElement::get_FixedValue
// Description	    : 
// Return type		: STDMETHODIMP 
// Argument         : BSTR *pVal
/////////////////////////////////////////////////////////////////////////////


STDMETHODIMP CMTXmlElement::get_FixedValue(BSTR *pVal)
{
	ASSERT(pVal);
	if(!pVal) return E_POINTER;
	_bstr_t aStr = mpElement->GetFixedValue().c_str();
	*pVal = aStr.copy();
	return S_OK;
}


