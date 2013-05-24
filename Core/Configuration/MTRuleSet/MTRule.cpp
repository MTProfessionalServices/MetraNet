// MTRule.cpp : Implementation of CMTRule
#include "StdAfx.h"
#include "MTRuleSet.h"
#include "MTRule.h"

/////////////////////////////////////////////////////////////////////////////
// CMTRule

STDMETHODIMP CMTRule::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTRule,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTRule::FinalConstruct()
{
	return CoCreateFreeThreadedMarshaler(
		GetControllingUnknown(), &m_pUnkMarshaler.p);
}

void CMTRule::FinalRelease()
{
}

// ----------------------------------------------------------------
// Description:  Actions to apply if all conditions of this rule match
// Return Value: set of actions that will be applied when the rule matches
// ----------------------------------------------------------------
STDMETHODIMP CMTRule::get_Actions(IMTActionSet * * pVal)
{
	if (!pVal)
		return E_POINTER;

	*pVal = (IMTActionSet *) mActionSet.GetInterfacePtr();
	if (*pVal == NULL)
		return Error("Actions not set on rule");

	(*pVal)->AddRef();

	return S_OK;
}

// ----------------------------------------------------------------
// Description:  Actions to apply if all conditions of this rule match
// Return Value: actions - set of actions to apply if the rule matches
// ----------------------------------------------------------------
STDMETHODIMP CMTRule::put_Actions(IMTActionSet * newVal)
{
	if (!newVal)
		return E_POINTER;

	mActionSet = newVal;
	return S_OK;
}

// ----------------------------------------------------------------
// Description: A set of conditions that must apply for this rule to match.
//              All actions must apply (AND is used)
// Return Value: set of conditions that must apply
// ----------------------------------------------------------------
STDMETHODIMP CMTRule::get_Conditions(IMTConditionSet * * pVal)
{
	if (!pVal)
		return E_POINTER;

	*pVal = (IMTConditionSet *) mConditionSet.GetInterfacePtr();
	if (*pVal == NULL)
		return Error("Conditions not set on rule");

	(*pVal)->AddRef();

	return S_OK;
}

// ----------------------------------------------------------------
// Description: A set of conditions that must apply for this rule to match.
//              All actions must apply (AND is used)
// Arguments:   set of conditions that must apply
// ----------------------------------------------------------------
STDMETHODIMP CMTRule::put_Conditions(IMTConditionSet * newVal)
{
	if (!newVal)
		return E_POINTER;

	mConditionSet = newVal;
	return S_OK;
}
