// MTDB2Adapter.cpp : Implementation of CMTDB2Adapter
#include "StdAfx.h"
#include "MTAccount.h"
#include "MTDB2Adapter.h"

/////////////////////////////////////////////////////////////////////////////
// CMTDB2Adapter

STDMETHODIMP CMTDB2Adapter::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTAccountAdapter,
		&IID_IMTAccountAdapter2
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CMTDB2Adapter::Initialize(BSTR AdapterName)
{
	return S_OK;
}

STDMETHODIMP CMTDB2Adapter::Install()
{
	return S_OK;
}

STDMETHODIMP CMTDB2Adapter::Uninstall()
{
	return S_OK;
}

STDMETHODIMP CMTDB2Adapter::AddData(BSTR AdapterName,
								    IMTAccountPropertyCollection* mtptr, VARIANT apRowset)
{
	return E_NOTIMPL;
}

STDMETHODIMP CMTDB2Adapter::UpdateData(BSTR AdapterName,
								       IMTAccountPropertyCollection* mtptr, VARIANT apRowset)
{
	return E_NOTIMPL;
}

STDMETHODIMP CMTDB2Adapter::GetData(BSTR AdapterName,
								    long AccountID,
									VARIANT apRowset,
								    IMTAccountPropertyCollection** mtptr)
{
	return E_NOTIMPL;
}

STDMETHODIMP CMTDB2Adapter::SearchData(BSTR AdapeterName,
									   ::IMTAccountPropertyCollection* mtptr,
									   VARIANT apRowset,
									   ::IMTSearchResultCollection** mtp)
{

	return E_NOTIMPL;
}

STDMETHODIMP CMTDB2Adapter::SearchDataWithUpdLock(BSTR AdapeterName,
									   ::IMTAccountPropertyCollection* mtptr,
									   BOOL wUpdLock,
									   VARIANT apRowset,									   
									   ::IMTSearchResultCollection** mtp)
{

	return E_NOTIMPL;
}
STDMETHODIMP CMTDB2Adapter::GetPropertyMetaData(BSTR aPropertyName,
												::IMTPropertyMetaData** apMetaData)
{
	return E_NOTIMPL;
}
