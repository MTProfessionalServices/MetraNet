// MTActionSet.cpp : Implementation of CMTActionSet
#include "StdAfx.h"
#include "MTRuleSet.h"
#include "MTActionSet.h"

#import <MTRuleSet.tlb>

//using namespace MTRULESETLib;

#include <metra.h>

#include <stdutils.h>


/////////////////////////////////////////////////////////////////////////////
// CMTActionSet

STDMETHODIMP CMTActionSet::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTActionSet,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTActionSet::FinalConstruct()
{
	return CoCreateFreeThreadedMarshaler(
		GetControllingUnknown(), &m_pUnkMarshaler.p);
}

void CMTActionSet::FinalRelease()
{
}


// ----------------------------------------------------------------
// Description:  Automation method, used for enumerating actions within this action set
// Return Value:  enumeration object
// ----------------------------------------------------------------
STDMETHODIMP CMTActionSet::get__NewEnum(/*[out, retval]*/ LPUNKNOWN *pVal)
{
	GENERICCOLLECTIONLib::IMTCollection * set = NULL;
	HRESULT hr = mActions.CopyTo((::IMTCollection **) &set);
	if (FAILED(hr))
		return hr;

	hr = set->get__NewEnum(pVal);
	set->Release();
	return hr;
}

// ----------------------------------------------------------------
// Description:  Either the n-th action in the set or the action with the
//               given property name, depending on the type of the argument.
// Return Value: action requested
// ----------------------------------------------------------------
STDMETHODIMP CMTActionSet::get_Item(/*[in]*/ VARIANT varIndex, /*[out,retval]*/ LPVARIANT pItem)
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

		// our indexes are zero based.  the collection index is 1 based
		index = findit->second + 1;
	}
	else
		index = var;

	IMTAssignmentAction * action = NULL;
	// mActions is 1 based, not zero based.
	HRESULT hr = mActions.Item(index, &action);

//	_variant_t objectvar(action, true);
	// TODO: this should be false?
	_variant_t objectvar(action, true);
	*pItem = objectvar;
	return hr;
}

// ----------------------------------------------------------------
// Description: return the Nth item with the given name.  For example, if there
//              are two actions that hold the property name "ABC", NthItem
//              can be used to return either the first or second.
// Arguments: index - name of action
//            N - which action with the given name
// Return Value: action requested
// ----------------------------------------------------------------
STDMETHODIMP CMTActionSet::get_NthItem(/*[in]*/ VARIANT varIndex, long aN,
																			 /*[out,retval]*/ LPVARIANT pItem)
{
	return E_NOTIMPL;
}

// ----------------------------------------------------------------
// Description:  Add an action to the set
// Argument: action - action to add to the set
// ----------------------------------------------------------------
STDMETHODIMP CMTActionSet::Add(/*[in]*/ IMTAssignmentAction * pMyObj )
{
	MTRULESETLib::IMTAssignmentActionPtr action(pMyObj);

	// keep a map of where which index this name maps to
	long count;
	HRESULT hr = get_Count(&count);
	if (FAILED(hr))
		return hr;

	std::wstring name = (const wchar_t *) action->GetPropertyName();
	StrToLower(name);
	mIndexMap[name] = count;

	return mActions.Add(pMyObj);
}

// ----------------------------------------------------------------
// Description:  number of actions in this set
// Return Value: number of actions in this set
// ----------------------------------------------------------------
STDMETHODIMP CMTActionSet::get_Count(/*[out, retval]*/ long *pVal )
{
	if (!pVal)
		return E_POINTER;

	return mActions.Count(pVal);
}
