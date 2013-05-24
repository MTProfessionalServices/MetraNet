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
#include "MTSessionContext.h"
#include "MTSecurityContext.h"

/////////////////////////////////////////////////////////////////////////////
// CMTSessionContext

STDMETHODIMP CMTSessionContext::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTSessionContext
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CMTSessionContext::get_AccountID(long *pVal)
{
	(*pVal) = mAccountID;
	return S_OK;
}

STDMETHODIMP CMTSessionContext::put_AccountID(long newVal)
{
	mAccountID = newVal;
	return S_OK;
}

STDMETHODIMP CMTSessionContext::get_LanguageID(long *pVal)
{
	(*pVal) = mLanguageID;
	return S_OK;
}

STDMETHODIMP CMTSessionContext::put_LanguageID(long newVal)
{
	mLanguageID = newVal;
	return S_OK;
}

STDMETHODIMP CMTSessionContext::get_SecurityContext(IMTSecurityContext** apVal)
{
	MTAUTHLib::IMTSecurityContextPtr ptr = mSecurityContext;
	(*apVal) = (IMTSecurityContext*)ptr.Detach();
	return S_OK;
}

STDMETHODIMP CMTSessionContext::put_SecurityContext(IMTSecurityContext* newVal)
{
	mSecurityContext = newVal;
	return S_OK;
}


STDMETHODIMP CMTSessionContext::ToXML(BSTR *apXMLString)
{
	(*apXMLString) = mSecurityContext->ToXML().copy();

	return S_OK;
}

STDMETHODIMP CMTSessionContext::FromXML(BSTR aXMLString)
{
  try
  {
    if(mSecurityContext == NULL)
    {
      CComObject<CMTSecurityContext> * directSc;
      CComObject<CMTSecurityContext>::CreateInstance(&directSc);
      HRESULT hr =  directSc->QueryInterface(IID_IMTSecurityContext,
								reinterpret_cast<void**>(&mSecurityContext));
      if (FAILED(hr))
        return hr;
    }
    mSecurityContext->FromXML(aXMLString);
    mAccountID = mSecurityContext->AccountID;
	mLoggedInAs = mSecurityContext->LoggedInAs;
	mApplicationName = mSecurityContext->ApplicationName;
  }
  catch(_com_error& e)
  {
    return LogAndReturnAuthError(e);
  }
  return S_OK;
}

STDMETHODIMP CMTSessionContext::get_LoggedInAs(BSTR *pVal)
{
	*pVal = mLoggedInAs.copy();
	return S_OK;
}

STDMETHODIMP CMTSessionContext::put_LoggedInAs(BSTR newVal)
{
	mLoggedInAs = newVal;
	mSecurityContext->LoggedInAs = mLoggedInAs;
	return S_OK;
}

STDMETHODIMP CMTSessionContext::get_ApplicationName(BSTR *pVal)
{
	*pVal = mApplicationName.copy();
	return S_OK;
}

STDMETHODIMP CMTSessionContext::put_ApplicationName(BSTR newVal)
{
	mApplicationName = newVal;
	mSecurityContext->ApplicationName = mApplicationName;
	return S_OK;
}