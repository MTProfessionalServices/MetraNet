/**************************************************************************
* Copyright 1997-2002 by MetraTech
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
***************************************************************************/

#include "StdAfx.h"
#include "MTAccountStates.h"
#include "MTState.h"

/////////////////////////////////////////////////////////////////////////////
// CMTState

STDMETHODIMP CMTState::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTState
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

//
//
//
STDMETHODIMP CMTState::get_Name(BSTR *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = NULL;

	*pVal = mName.copy();
	return S_OK;
}

//
//
//
STDMETHODIMP CMTState::put_Name(BSTR newVal)
{
	mName = newVal;
	return S_OK;
}

//
//
//
STDMETHODIMP CMTState::get_LongName(BSTR *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = NULL;

	*pVal = mLongName.copy();
	return S_OK;
}

//
//
//
STDMETHODIMP CMTState::put_LongName(BSTR newVal)
{
	mLongName = newVal;
	return S_OK;
}

//
//
//
STDMETHODIMP CMTState::get_ProgID(BSTR *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = NULL;

	*pVal = mProgID.copy();
	return S_OK;
}

//
//
//
STDMETHODIMP CMTState::put_ProgID(BSTR newVal)
{
	mProgID = newVal;
	return S_OK;
}

//
//
//
STDMETHODIMP CMTState::AddConfiguredBusinessRules(BSTR rule, VARIANT_BOOL boolVal)
{
	_bstr_t bstrRule (rule);
	mBizRulesMap[bstrRule] = boolVal;

	return S_OK;
}

//
//
//
STDMETHODIMP CMTState::GetBusinessRuleValue(BSTR rule, VARIANT_BOOL* boolVal)
{
	_bstr_t buffer;
	_bstr_t bstrRule (rule);
	_bstr_t bstrLowerCaseRule = _strlwr((char*)bstrRule);

	BusinessRulesMap::iterator it = mBizRulesMap.find(bstrLowerCaseRule);
	if(it == mBizRulesMap.end())
	{
		buffer = "Business Rule <";
		buffer += bstrRule;
		buffer += "> not found in the account states configuration file";
		mLogger->LogThis(LOG_ERROR, (const char*)buffer);
		return Error((const char*)buffer);
	}
	else
		*boolVal = (*it).second;

	return S_OK;
}

//
//
//
STDMETHODIMP CMTState::get_ArchiveAge(long *pVal)
{
	*pVal = mArchiveAge;
	return S_OK;
}

//
//
//
STDMETHODIMP CMTState::put_ArchiveAge(long newVal)
{
	mArchiveAge = newVal;
	return S_OK;
}
