// MTConfigAttribSet.cpp : Implementation of CMTConfigAttribSet
#include "StdAfx.h"
#include "PropSet.h"
#include "MTConfigProp.h"
#include "MTConfigAttribSet.h"
#include <comutil.h>


/////////////////////////////////////////////////////////////////////////////
// CMTConfigAttribSet

STDMETHODIMP CMTConfigAttribSet::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTConfigAttribSet
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}


// ----------------------------------------------------------------
// Arguments:     N/A
// Return Value:  long *pVal - the count
// Errors Raised: N/A
// Description:   Gets the count of attribute name/value pairs in
//				  the set
// ----------------------------------------------------------------
STDMETHODIMP CMTConfigAttribSet::get_Count(long *pVal)
{
	ASSERT(pVal && (&mpAttributes));
	if(!pVal) return E_POINTER;
	if(mpAttributes.GetObject() == NULL) {
		*pVal = 0;
	}
	else {
		*pVal = mpAttributes->size();
	}
	return S_OK;
}



// ----------------------------------------------------------------
// Arguments:     BSTR bstrKey - the name of the attribute
// Return Value:  BSTR *pVal - the value of the attribute
// Errors Raised: N/A
// Description:   Gets an attribute's value given its key
// ----------------------------------------------------------------
STDMETHODIMP CMTConfigAttribSet::get_AttrValue(BSTR bstrKey, BSTR *pVal)
{
	ASSERT(bstrKey && pVal && (&mpAttributes));
	if(!bstrKey && pVal) return E_POINTER;

	XMLString aKey(bstrKey);
	XMLString aValue;
	HRESULT hr;
	
	XMLNameValueMapDictionary::iterator it = mpAttributes->find(aKey);
	if (it == mpAttributes->end())
		hr = E_FAIL;
	else
	{
		_bstr_t aRetVal(it->second.c_str());
		*pVal = aRetVal.copy();
		hr = S_OK;
	}

	return hr;
}



// ----------------------------------------------------------------
// Arguments:     BSTR bstrKey - the key
//				  BSTR pVal - the value
// Return Value:  N/A
// Errors Raised: N/A
// Description:   Adds a key/value pair into the set
// ----------------------------------------------------------------
STDMETHODIMP CMTConfigAttribSet::AddPair(/*[in]*/ BSTR bstrKey, /*[in]*/ BSTR pVal)
{
	XMLString aKey(bstrKey);
	XMLString aValue(pVal);
	HRESULT hr = E_FAIL;

	// look up the name value pair... don't add it if it already exists

	XMLNameValueMapDictionary::iterator it = mpAttributes->find(aKey);
	if (it == mpAttributes->end())
	{
		(*mpAttributes)[aKey] = aValue;
		hr = S_OK;
	}

	return hr;
}

// ----------------------------------------------------------------
// Arguments:     N/A
// Return Value:  N/A
// Errors Raised: N/A
// Description:   Initializes the object
// ----------------------------------------------------------------
STDMETHODIMP CMTConfigAttribSet::Initialize()
{
	mpAttributes = new XMLNameValueMapDictionary();
	return S_OK;
}


// ----------------------------------------------------------------
// Arguments:     BSTR key - the key
// Return Value:  N/A
// Errors Raised: N/A
// Description:   Removes an attribute given its key
// ----------------------------------------------------------------
STDMETHODIMP CMTConfigAttribSet::RemoveAttr(BSTR key)
{
	ASSERT(key && (&mpAttributes));
	if(!(key && (&mpAttributes))) {
		return E_POINTER;
	} 
	XMLString aStr(key);
	// we don't really care if the user attempts to remove a non existant key so
	// we ignore the return value
	mpAttributes->erase(aStr);

	return S_OK;
}


// ----------------------------------------------------------------
// Arguments:     long aIndex - the index of the attribute to get
// Return Value:  BSTR* pKey - the key
//                BSTR* pValue - the value
// Errors Raised: N/A
// Description:   Gets a key and its associated value given an index
//                into the set.
// ----------------------------------------------------------------
STDMETHODIMP CMTConfigAttribSet::GetAttrItem(long aIndex,BSTR* pKey,BSTR* pValue)
{
	ASSERT(pKey && pValue);
	if(!(pKey && pValue)) return E_POINTER;

	ASSERT(aIndex < (long)mpAttributes->size());
	if(aIndex >= (long)mpAttributes->size()) return E_FAIL;


	XMLNameValueMapDictionary::iterator it = mpAttributes->begin();
	for (int i = 0; i < aIndex && it != mpAttributes->end(); i++, it++)
		;
	
	_bstr_t aKey = it->first.c_str();
	_bstr_t aValue = it->second.c_str();

	*pKey = aKey.copy();
	*pValue = aValue.copy();
	return S_OK;
}

