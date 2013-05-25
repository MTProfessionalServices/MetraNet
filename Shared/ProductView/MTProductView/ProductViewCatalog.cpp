// ProductViewCatalog.cpp : Implementation of CProductViewCatalog
#include "StdAfx.h"
#include "MTProductView.h"
#include "ProductViewCatalog.h"

#import <MTProductViewExec.tlb> rename ("EOF", "EOFX")

/////////////////////////////////////////////////////////////////////////////
// CProductViewCatalog

STDMETHODIMP CProductViewCatalog::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IProductViewCatalog
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CProductViewCatalog::CreateProductViewFromConfig(BSTR aProductViewName, VARIANT_BOOL aHasChildren, IProductView **apPV)
{
	if (!apPV)
		return E_POINTER;
	else
		*apPV = NULL;

	try
	{
		MTPRODUCTVIEWLib::IProductViewPtr PV(__uuidof(MTPRODUCTVIEWLib::ProductView));

		PV->SessionContext = mSessionContext;
		PV->Init(_bstr_t(aProductViewName), aHasChildren);

		*apPV = reinterpret_cast<IProductView*>(PV.Detach());
	}
	catch(_com_error & err)
	{
		return returnProductViewError(err);
	}

	return S_OK;
}

STDMETHODIMP CProductViewCatalog::GetProductViewByName(BSTR aName, IProductView **apPV)
{
	if(!apPV)
		return E_POINTER;
	else
		*apPV = NULL;

	try
	{
		MTPRODUCTVIEWEXECLib::IMTProductViewReaderPtr reader (__uuidof(MTPRODUCTVIEWEXECLib::MTProductViewReader));

		*apPV = reinterpret_cast<IProductView *> (reader->FindByName(mSessionContextExec, _bstr_t(aName)).Detach());
	}
	catch(_com_error &  err)
	{
		return returnProductViewError(err);
	}

	return S_OK;
}

STDMETHODIMP CProductViewCatalog::GetProductView(long aID, IProductView **apPV)
{
	if(!apPV)
		return E_POINTER;
	else
		*apPV = NULL;

	try
	{
		MTPRODUCTVIEWEXECLib::IMTProductViewReaderPtr reader (__uuidof(MTPRODUCTVIEWEXECLib::MTProductViewReader));

		*apPV = reinterpret_cast<IProductView *> (reader->Find(mSessionContextExec, aID).Detach());
	}
	catch(_com_error &  err)
	{
		return returnProductViewError(err);
	}

	return S_OK;
}

STDMETHODIMP CProductViewCatalog::RemoveProductView(long aID)
{
	try
	{
		MTPRODUCTVIEWEXECLib::IMTProductViewWriterPtr writer (__uuidof(MTPRODUCTVIEWEXECLib::MTProductViewWriter));

		// This remove the product view and all of its properties.
		writer->Remove(mSessionContextExec, aID);
	}
	catch(_com_error &  err)
	{
		return returnProductViewError(err);
	}

	return S_OK;
}

STDMETHODIMP CProductViewCatalog::putref_SessionContext(IMTSessionContext* newVal)
{
	try
	{
		mSessionContext = newVal;
		mSessionContextExec = newVal;
	}
	catch(_com_error & err)
	{
		return returnProductViewError(err);
	}
	return S_OK;
}

STDMETHODIMP CProductViewCatalog::get_SessionContext(IMTSessionContext* *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = NULL;
	try
	{
    MTPRODUCTVIEWLib::IMTSessionContextPtr ptr = mSessionContext;

    *pVal = reinterpret_cast<IMTSessionContext*> (ptr.Detach());
	}
	catch(_com_error & err)
	{
		return returnProductViewError(err);
	}
	return S_OK;
}

STDMETHODIMP CProductViewCatalog::GetProductViewProperty(long aID, IProductViewProperty **apPVProp)
{
	if(!apPVProp)
		return E_POINTER;
	else
		*apPVProp = NULL;

	try
	{
		MTPRODUCTVIEWEXECLib::IMTProductViewPropertyReaderPtr reader (__uuidof(MTPRODUCTVIEWEXECLib::MTProductViewPropertyReader));

		*apPVProp = reinterpret_cast<IProductViewProperty *> (reader->Find(mSessionContextExec, aID).Detach());
	}
	catch(_com_error &  err)
	{
		return returnProductViewError(err);
	}

	return S_OK;
}

