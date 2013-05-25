/**************************************************************************
 * @doc MTCONFIGFILE
 *
 * Copyright 1999 by MetraTech Corporation
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
 * NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech Corporation MAKES NO
 * REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
 * PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
 * DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
 * COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech Corporation,
 * and USER agrees to preserve the same.
 *
 * Created by: Chen He
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

// MTConfigFile.cpp : Implementation of CMTConfigFile
#include "StdAfx.h"
#include "ConfigLoader.h"
#include "MTConfigFileImpl.h"
#include "MTConfig_i.c"
#include <metra.h>
#include <iostream>
#include <MTUtil.h>

using std::cout;
using std::endl;

/////////////////////////////////////////////////////////////////////////////
// CMTConfigFile

STDMETHODIMP CMTConfigFile::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTConfigFile,
	};
	for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

CMTConfigFile::CMTConfigFile()
{

	mMainConfigData = NULL;

	mConfigData = NULL;

	// dismiss date
	mDismissDate = 0;

	// expiration date
	mExpireDate = 0;

	// effective date
	mEffectDate = 0;
}

CMTConfigFile::~CMTConfigFile()
{
#if MTDEBUG
	cout << "CMTConfigFile::~CMTConfigFile() called" << endl;
#endif

}

STDMETHODIMP CMTConfigFile::get_ConfigData(::IMTConfigPropSet* * apVal)
{
	if (apVal == NULL)
		return E_POINTER;

//	int ref;

//	ref = mConfigData->AddRef();
//	cout << "ref1(CMTConfigFile::get_ConfigData): " << ref << endl;

	mConfigData->QueryInterface(IID_IMTConfigPropSet, (void**)apVal);

//	ref = mConfigData->AddRef();
//	cout << "ref2(CMTConfigFile::get_ConfigData): " << ref << endl;

	return S_OK;
}

STDMETHODIMP CMTConfigFile::put_ConfigData(::IMTConfigPropSet* aNewVal)
{

	MTConfigLib::IMTConfigPropSetPtr smPtr(aNewVal);

	mConfigData = smPtr;

//	aNewVal->Release();

	return S_OK;
}

STDMETHODIMP CMTConfigFile::get_EffectDate(long * apVal)
{
	if (apVal == NULL)
		return E_POINTER;

	*apVal = mEffectDate;

	return S_OK;
}

STDMETHODIMP CMTConfigFile::put_EffectDate(long aNewVal)
{
	mEffectDate = aNewVal;

	return S_OK;
}

STDMETHODIMP CMTConfigFile::get_ExpireDate(long * apVal)
{
	if (apVal == NULL)
		return E_POINTER;

	*apVal = mExpireDate;

	return S_OK;
}

STDMETHODIMP CMTConfigFile::put_ExpireDate(long aNewVal)
{
	mExpireDate = aNewVal;

	return S_OK;
}

STDMETHODIMP CMTConfigFile::get_DismissDate(long * apVal)
{
	if (apVal == NULL)
		return E_POINTER;

	*apVal = mDismissDate;

	return S_OK;
}

STDMETHODIMP CMTConfigFile::put_DismissDate(long aNewVal)
{
	mDismissDate = aNewVal;

	return S_OK;
}

STDMETHODIMP CMTConfigFile::get_LingerDate(long * apVal)
{
	if (apVal == NULL)
		return E_POINTER;

	*apVal = mLingerDate;

	return S_OK;
}

STDMETHODIMP CMTConfigFile::put_LingerDate(long aNewVal)
{
	mLingerDate = aNewVal;

	return S_OK;
}

STDMETHODIMP CMTConfigFile::get_MainConfigData(::IMTConfigPropSet* * apVal)
{
	if (apVal == NULL)
		return E_POINTER;

	mMainConfigData->QueryInterface(IID_IMTConfigPropSet, (void**)apVal);

	return S_OK;
}

STDMETHODIMP CMTConfigFile::put_MainConfigData(::IMTConfigPropSet* aNewVal)
{
	MTConfigLib::IMTConfigPropSetPtr smPtr(aNewVal);

	mMainConfigData = smPtr;

	//aNewVal->Release();

	return S_OK;
}


STDMETHODIMP CMTConfigFile::get_ConfigFilename(BSTR* apFilename)
{
	if (apFilename == NULL)
	{
		return E_POINTER;
	}

	*apFilename = mFilename.copy();

	return S_OK;
}


STDMETHODIMP CMTConfigFile::put_ConfigFilename(BSTR aFilename)
{
	mFilename = aFilename;

	return S_OK;
}

// local function
HRESULT HandleVariantRequest(long aTime,VARIANT* vtDate)
{
	ASSERT(vtDate);
	if(!vtDate) return E_POINTER;
	
	DATE aDate;
	OleDateFromTimet(&aDate,aTime);
	_variant_t aVariant(aDate, VT_DATE);
	::VariantClear(vtDate);
	::VariantCopy(vtDate,&aVariant);
	return S_OK;
}


STDMETHODIMP CMTConfigFile::get_EffectDateAsVbDate(/*[out, retval]*/ VARIANT* vtDate)
{
	return HandleVariantRequest(mEffectDate,vtDate);
}


STDMETHODIMP CMTConfigFile::get_ExpireDateAsVbDate(/*[out, retval]*/ VARIANT* vtDate)
{
		return HandleVariantRequest(mExpireDate,vtDate);
}

STDMETHODIMP CMTConfigFile::get_DismissDateAsVbDate(/*[out, retval]*/ VARIANT* vtDate)
{
	return HandleVariantRequest(mDismissDate,vtDate);
}

STDMETHODIMP CMTConfigFile::get_LingerDateAsVbDate(/*[out, retval]*/ VARIANT* vtDate)
{
	return HandleVariantRequest(mLingerDate,vtDate);
}

