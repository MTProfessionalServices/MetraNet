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
#include "MTAuth.h"
#include "MTPathParameter.h"

/////////////////////////////////////////////////////////////////////////////
// CMTPathParameter

STDMETHODIMP CMTPathParameter::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTPathParameter
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CMTPathParameter::get_Path(BSTR *pVal)
{
	(*pVal) = mPath.copy();

	return S_OK;
}

STDMETHODIMP CMTPathParameter::get_LeafNode(BSTR *pVal)
{
  wchar_t	*strToken;
  _bstr_t	strPrevToken = "";

  if(mPath.length()	<= 0 ||
    _wcsicmp((wchar_t*)mPath, L"/") ==	0	||
    _wcsicmp((wchar_t*)mPath,	L"/*") ==	0	||
    _wcsicmp((wchar_t*)mPath, L"/-") ==	0)
  {
    (*pVal)	=	_bstr_t("");
    return S_OK;
  }
  strToken = wcstok((wchar_t *)mPath,	L"/");

  while(strToken !=	NULL)
  {
    //Store	the	current	token
    strPrevToken = strToken;

    //Get	the	next token
    strToken = wcstok(NULL,	L"/");

    //If the next	token	is not null, add to	the	id
    if(strToken	== NULL	|| 
      _wcsicmp((wchar_t*)strToken, L"")	== 0 ||
      _wcsicmp((wchar_t*)strToken, L"-") ==	0	||
      _wcsicmp((wchar_t*)strToken, L"*") ==	0)
    {
      (*pVal)	=	strPrevToken.copy();
      return S_OK;
    }
  }

  return S_OK;
}


STDMETHODIMP CMTPathParameter::put_Path(BSTR newVal)
{
	mPath = newVal;

	return S_OK;
}

STDMETHODIMP CMTPathParameter::get_WildCard(MTHierarchyPathWildCard *pVal)
{
	(*pVal) = mWildCard;

	return S_OK;
}

STDMETHODIMP CMTPathParameter::put_WildCard(MTHierarchyPathWildCard newVal)
{
	mWildCard = newVal;

	return S_OK;
}
