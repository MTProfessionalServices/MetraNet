// MTRegion.cpp : Implementation of CMTRegion
#include "StdAfx.h"
#include "PhoneLookup.h"
#include "MTRegion.h"

/////////////////////////////////////////////////////////////////////////////
// CMTRegion


STDMETHODIMP CMTRegion::get_DestinationCode(BSTR * pVal)
{
	*pVal = mDestinationCode.Copy();	
	return S_OK;
}

STDMETHODIMP CMTRegion::put_DestinationCode(BSTR newVal)
{
	mDestinationCode = newVal;
	return S_OK;
}

STDMETHODIMP CMTRegion::get_CountryName(BSTR * pVal)
{
	*pVal = mCountryName.Copy();
	return S_OK;
}

STDMETHODIMP CMTRegion::put_CountryName(BSTR newVal)
{
	mCountryName = newVal;
	return S_OK;
}

STDMETHODIMP CMTRegion::get_Description(BSTR * pVal)
{
	*pVal = mDescription.Copy();
	return S_OK;
}

STDMETHODIMP CMTRegion::put_Description(BSTR newVal)
{
	mDescription = newVal;
	return S_OK;
}

STDMETHODIMP CMTRegion::get_LocalCodeTable(BSTR * pVal)
{
	*pVal = mLocalCodeTable.Copy();
	return S_OK;
}

STDMETHODIMP CMTRegion::put_LocalCodeTable(BSTR newVal)
{
	mLocalCodeTable = newVal;
	return S_OK;
}

STDMETHODIMP CMTRegion::get_International(BOOL * pVal)
{

	*pVal = mInternational;
	return S_OK;
}

STDMETHODIMP CMTRegion::put_International(BOOL newVal)
{
	mInternational = newVal;
	return S_OK;
}

STDMETHODIMP CMTRegion::get_TollFree(BOOL * pVal)
{
	*pVal = mTollFree;
	return S_OK;
}

STDMETHODIMP CMTRegion::put_TollFree(BOOL newVal)
{
	mTollFree = newVal;
	return S_OK;
}
