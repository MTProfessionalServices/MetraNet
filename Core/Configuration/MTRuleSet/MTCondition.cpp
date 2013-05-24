// MTCondition.cpp : Implementation of CMTCondition
#include "StdAfx.h"
#include "MTRuleSet.h"
#include "MTCondition.h"

/////////////////////////////////////////////////////////////////////////////
// CMTCondition

STDMETHODIMP CMTCondition::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTCondition,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}
