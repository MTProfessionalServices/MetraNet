// MTRequiredAttrs.cpp : Implementation of CMTRequiredAttrs
#include "StdAfx.h"
#include <metra.h>
#include "SchemaReader.h"
#include "MTRequiredAttrs.h"

/////////////////////////////////////////////////////////////////////////////
// CMTRequiredAttrs


/////////////////////////////////////////////////////////////////////////////
// Function name	: CMTRequiredAttrs::InterfaceSupportsErrorInfo
// Description	    : 
// Return type		: STDMETHODIMP 
// Argument         : REFIID riid
/////////////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTRequiredAttrs::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTRequiredAttrs
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}


/////////////////////////////////////////////////////////////////////////////
// Function name	: CMTRequiredAttrs::get_Count
// Description	    : 
// Return type		: STDMETHODIMP 
// Argument         : long *pVal
/////////////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTRequiredAttrs::get_Count(long *pVal)
{
	ASSERT(&mAttrList && pVal);
	if(!(&mAttrList && pVal)) return E_POINTER;

	*pVal = mAttrList->size();
	return S_OK;
}


/////////////////////////////////////////////////////////////////////////////
// Function name	: CMTRequiredAttrs::get__NewEnum
// Description	    : 
// Return type		: STDMETHODIMP 
// Argument         : LPUNKNOWN *pVal
/////////////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTRequiredAttrs::get__NewEnum(LPUNKNOWN *pVal)
{
	return E_NOTIMPL;
}




/////////////////////////////////////////////////////////////////////////////
// Function name	: CMTRequiredAttrs::get_AttrValue
// Description	    : 
// Return type		: STDMETHODIMP 
// Argument         : long aIndex
// Argument         : BSTR *pVal
/////////////////////////////////////////////////////////////////////////////

STDMETHODIMP CMTRequiredAttrs::get_AttrValue(long aIndex, BSTR *pVal)
{
	ASSERT(&mAttrList && pVal);
	if(!(&mAttrList && pVal)) return E_POINTER;

	ASSERT((long)mAttrList->size() > aIndex);
	if(!((long)mAttrList->size() > aIndex)) return E_INVALIDARG;

	_bstr_t aValue = (*mAttrList.GetObject())[aIndex]->GetName().c_str();
	*pVal = aValue.copy();
	return S_OK;
}



/////////////////////////////////////////////////////////////////////////////
// Function name	: CMTRequiredAttrs::get_AttrType
// Description	    : 
// Return type		: STDMETHODIMP 
// Argument         : long aIndex
// Argument         : BSTR *pVal

/////////////////////////////////////////////////////////////////////////////


STDMETHODIMP CMTRequiredAttrs::get_AttrType(long aIndex, BSTR *pVal)
{
	ASSERT(&mAttrList && pVal);
	if(!(&mAttrList && pVal)) return E_POINTER;

	ASSERT((long)mAttrList->size() > aIndex);
	if(!((long)mAttrList->size() > aIndex)) return E_INVALIDARG;

	_bstr_t aValue = (*mAttrList.GetObject())[aIndex]->GetType().c_str();
	*pVal = aValue.copy();
	
	return S_OK;
}
