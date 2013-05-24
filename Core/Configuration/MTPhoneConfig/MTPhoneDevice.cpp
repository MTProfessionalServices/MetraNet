// MTPhoneDevice.cpp : Implementation of CMTPhoneDevice
#include "StdAfx.h"
#include "PhoneLookup.h"
#include "MTPhoneDevice.h"

/////////////////////////////////////////////////////////////////////////////
// CMTPhoneDevice


STDMETHODIMP CMTPhoneDevice::get_Name(BSTR * pVal)
{
	*pVal = mName.copy();
	return S_OK;
}

STDMETHODIMP CMTPhoneDevice::put_Name(BSTR newVal)
{
	mName = newVal;
	return S_OK;
}

STDMETHODIMP CMTPhoneDevice::get_Description(BSTR * pVal)
{
	*pVal = mDescription.copy();
	return S_OK;
}

STDMETHODIMP CMTPhoneDevice::put_Description(BSTR newVal)
{
	mDescription = newVal;
	return S_OK;
}

STDMETHODIMP CMTPhoneDevice::get_LineAccessCode(BSTR * pVal)
{
	*pVal = mLineAccessCode.copy();
	return S_OK;
}

STDMETHODIMP CMTPhoneDevice::put_LineAccessCode(BSTR newVal)
{
	mLineAccessCode = newVal;
	return S_OK;
}

STDMETHODIMP CMTPhoneDevice::get_CountryName(BSTR * pVal)
{
	*pVal = mCountryName.copy();
	return S_OK;
}

STDMETHODIMP CMTPhoneDevice::put_CountryName(BSTR newVal)
{
	mCountryName = newVal;
	return S_OK;
}

STDMETHODIMP CMTPhoneDevice::get_NationalDestinationCode(BSTR * pVal)
{
	*pVal = mNationalDestinationCode.copy();
	return S_OK;
}

STDMETHODIMP CMTPhoneDevice::put_NationalDestinationCode(BSTR newVal)
{
	mNationalDestinationCode = newVal;
	return S_OK;
}

