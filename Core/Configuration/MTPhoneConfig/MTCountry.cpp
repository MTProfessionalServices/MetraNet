// MTCountry.cpp : Implementation of CMTCountry
#include "StdAfx.h"
#include "PhoneLookup.h"
#include "MTCountry.h"

/////////////////////////////////////////////////////////////////////////////
// CMTCountry


STDMETHODIMP CMTCountry::get_CountryCode(BSTR * pVal)
{
	*pVal = mCountryCode.Copy();
	return S_OK;
}

STDMETHODIMP CMTCountry::put_CountryCode(BSTR newVal)
{
	mCountryCode = newVal;
	return S_OK;
}

STDMETHODIMP CMTCountry::get_Name(BSTR * pVal)
{
	*pVal = mName.Copy();
	return S_OK;
}

STDMETHODIMP CMTCountry::put_Name(BSTR newVal)
{
	mName = newVal;
	return S_OK;
}

STDMETHODIMP CMTCountry::get_InternationalAccessCode(BSTR * pVal)
{
	*pVal = mInternationalAccessCode.Copy();
	return S_OK;
}

STDMETHODIMP CMTCountry::put_InternationalAccessCode(BSTR newVal)
{
	mInternationalAccessCode = newVal;
	return S_OK;
}

STDMETHODIMP CMTCountry::get_NationalAccessCode(BSTR * pVal)
{
	*pVal = mNationalAccessCode.Copy();
	return S_OK;
}

STDMETHODIMP CMTCountry::put_NationalAccessCode(BSTR newVal)
{
	mNationalAccessCode = newVal;
	return S_OK;
}

STDMETHODIMP CMTCountry::get_Description(BSTR * pVal)
{
	*pVal = mDescription.Copy();
	return S_OK;
}

STDMETHODIMP CMTCountry::put_Description(BSTR newVal)
{
	mDescription = newVal;
	return S_OK;
}

STDMETHODIMP CMTCountry::get_NationalCodeTable(BSTR * pVal)
{
	*pVal = mNationalCodeTable.Copy();
	return S_OK;
}

STDMETHODIMP CMTCountry::put_NationalCodeTable(BSTR newVal)
{
	mNationalCodeTable = newVal;
	return S_OK;
}


STDMETHODIMP CMTCountry::get_Primary(BOOL * pVal)
{
	*pVal = mPrimary;
	return S_OK;
}

STDMETHODIMP CMTCountry::put_Primary(BOOL newVal)
{
	mPrimary = newVal;
	return S_OK;
}
