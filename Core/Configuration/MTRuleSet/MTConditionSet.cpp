// MTConditionSet.cpp : Implementation of CMTConditionSet
#include "StdAfx.h"
#include "MTRuleSet.h"
#include "MTConditionSet.h"

#import <MTRuleSet.tlb>

#include "MTSimpleCondition.h"

#include <rwcom.h>


#include <stdutils.h>

/////////////////////////////////////////////////////////////////////////////
// CMTConditionSet

STDMETHODIMP CMTConditionSet::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTConditionSet,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTConditionSet::FinalConstruct()
{
	return CoCreateFreeThreadedMarshaler(
		GetControllingUnknown(), &m_pUnkMarshaler.p);
}

void CMTConditionSet::FinalRelease()
{ }

// ----------------------------------------------------------------
// Description:  Automation method, used for enumerating conditions
//               within this condition set
// Return Value:  enumeration object
// ----------------------------------------------------------------
STDMETHODIMP CMTConditionSet::get__NewEnum(/*[out, retval]*/ IUnknown * * pVal)
{
	GENERICCOLLECTIONLib::IMTCollection * set = NULL;
	HRESULT hr = mConditions.CopyTo((::IMTCollection **) &set);
	if (FAILED(hr))
		return hr;

	hr = set->get__NewEnum(pVal);
	set->Release();
	return hr;
}

// ----------------------------------------------------------------
// Description:  Either the n-th condition in the set or the condition
//               with the given property name, depending on the type of the argument.
// Return Value: Condition requested
// ----------------------------------------------------------------
STDMETHODIMP CMTConditionSet::get_Item(/*[in]*/ VARIANT varIndex, /*[out,retval]*/ LPVARIANT pItem)
{
	_variant_t var(varIndex);
	// "dereference" the variant if necessary
	if (V_VT(&var) == (VT_VARIANT | VT_BYREF))
		var = var.pvarVal;

	long index = -1;
	VARIANT * object = NULL;
	if (V_VT(&var) == VT_BSTR || V_VT(&var) == (VT_BSTR | VT_BYREF))
	{
		std::wstring name = (const wchar_t *) (_bstr_t) var;
		StrToLower(name);

		NameIndexMap::const_iterator findit = mIndexMap.find(name);
		if (findit == mIndexMap.end())
			return E_INVALIDARG;

		index = findit->second + 1;
	}
	else
		index = var;

	IMTSimpleCondition * condition = NULL;
	// mConditions is 1 based, not zero based.
	HRESULT hr = mConditions.Item(index, &condition);

	// TODO: this should be false?
	_variant_t objectvar(condition, true);
	*pItem = objectvar;
	return hr;
}

// ----------------------------------------------------------------
// Description:  return the Nth item with the given name.  For example,
//               if there are two conditions that hold the property name
//               "ABC", NthItem can be used to return either the
//               first or second.
// Arguments: index - name of condition
//            N - which condition with the given name
// Return Value: condition requested
// ----------------------------------------------------------------
STDMETHODIMP CMTConditionSet::get_NthItem(/*[in]*/ VARIANT varIndex, long aN,
																					/*[out,retval]*/ LPVARIANT pItem)
{
	return E_NOTIMPL;
}

// ----------------------------------------------------------------
// Description:  Add a condition to the condition set
// Argument: condition - condition to add to the set
// ----------------------------------------------------------------
STDMETHODIMP CMTConditionSet::Add(/*[in]*/ IMTSimpleCondition * pMyObj )
{
	MTRULESETLib::IMTSimpleConditionPtr condition(pMyObj);

	// keep a map of where which index this name maps to
	long count;
	HRESULT hr = get_Count(&count);
	if (FAILED(hr))
		return hr;

	std::wstring name = (const wchar_t *) condition->GetPropertyName();
	StrToLower(name);
	mIndexMap[name] = count;

	// update map
	return mConditions.Add(pMyObj);
}

// ----------------------------------------------------------------
// Description:  The number of conditions in the set
// Return Value: number of conditions in this set
// ----------------------------------------------------------------
STDMETHODIMP CMTConditionSet::get_Count(/*[out, retval]*/ long *pVal )
{
	if (!pVal)
		return E_POINTER;

	return mConditions.Count(pVal);
}
