// MTSite.cpp : Implementation of CMTSite
#include "StdAfx.h"
#include "MTSiteConfig.h"
#include "MTSite.h"

/////////////////////////////////////////////////////////////////////////////
// CMTSite

STDMETHODIMP CMTSite::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTSite,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CMTSite::Initialize(BSTR aName, BSTR aProviderName, 
                                 BSTR aRelativeURL, VARIANT_BOOL aNewSiteFlag)
{
	// copy the parameters to data members ...
  mName = aName ;
  mProviderName = aProviderName ;
  mRelativeURL = aRelativeURL ;
  mNewSiteFlag = aNewSiteFlag ;

	return S_OK;
}

STDMETHODIMP CMTSite::get_Name(BSTR * pVal)
{
  if (!pVal)
  {
    return E_POINTER;
  }

  // copy the data member ...
  *pVal = mName.copy() ;

	return S_OK;
}

STDMETHODIMP CMTSite::put_Name(BSTR newVal)
{
  // set the data member ...
  mName = newVal ;

	return S_OK;
}

STDMETHODIMP CMTSite::get_ProviderName(BSTR * pVal)
{
  if (!pVal)
  {
    return E_POINTER;
  }

  // copy the data member ...
  *pVal = mProviderName.copy() ;

	return S_OK;
}

STDMETHODIMP CMTSite::put_ProviderName(BSTR newVal)
{
  // set the date member ...
  mProviderName = newVal ;

	return S_OK;
}

STDMETHODIMP CMTSite::get_RelativeURL(BSTR * pVal)
{
  if (!pVal)
  {
    return E_POINTER;
  }

  // copy the data member ...
  *pVal = mRelativeURL.copy() ;

	return S_OK;
}

STDMETHODIMP CMTSite::put_RelativeURL(BSTR newVal)
{
  // set the data member ...
  mRelativeURL = newVal ;

	return S_OK;
}

STDMETHODIMP CMTSite::get_NewSite(VARIANT_BOOL * pVal)
{
	if (!pVal)
  {
    return E_POINTER;
  }

  // copy the data member ...
  *pVal = mNewSiteFlag ;

	return S_OK;
}
