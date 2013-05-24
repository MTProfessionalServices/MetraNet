// MTLanguage.cpp : Implementation of CMTLanguage
#include "StdAfx.h"
#include "MTSiteConfig.h"
#include "MTLanguage.h"

/////////////////////////////////////////////////////////////////////////////
// CMTLanguage

STDMETHODIMP CMTLanguage::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTLanguage,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}


STDMETHODIMP CMTLanguage::Initialize(BSTR aName, BSTR aDescription)
{
	// copy the parameters to data members ...
  mName = aName ;
  mDescription = aDescription ;

	return S_OK;
}

STDMETHODIMP CMTLanguage::get_Name(BSTR * pVal)
{
  if (!pVal)
  {
    return E_POINTER;
  }

  // copy the data member ...
  *pVal = mName.copy() ;

	return S_OK;
}

STDMETHODIMP CMTLanguage::put_Name(BSTR newVal)
{
  // set the data member ...
  mName = newVal ;

	return S_OK;
}

STDMETHODIMP CMTLanguage::get_Description(BSTR * pVal)
{
  if (!pVal)
  {
    return E_POINTER;
  }

  // copy the data member ...
  *pVal = mDescription.copy() ;

	return S_OK;
}

STDMETHODIMP CMTLanguage::put_Description(BSTR newVal)
{
  // set the date member ...
  mDescription = newVal ;

	return S_OK;
}

