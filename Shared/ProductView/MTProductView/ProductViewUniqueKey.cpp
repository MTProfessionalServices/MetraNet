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
#include "MTProductView.h"
#include "ProductViewUniqueKey.h"

#include <comdef.h>
#include <mtcomerr.h>
#include <errutils.h>
#include <DBConstants.h>
#include <mtprogids.h>
#include <ProductViewCollection.h>
#include <stdutils.h>
#include <string>

#import <NameID.tlb>
#import <MTProductViewExec.tlb> rename ("EOF", "EOFX")

//////////////////////////////////////////////////////////////////////////////
// CProductViewUniqueKey

CProductViewUniqueKey::CProductViewUniqueKey()
{
	//m_pUnkMarshaler = NULL;
	mID = -1;
}

STDMETHODIMP CProductViewUniqueKey::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IProductView
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}



STDMETHODIMP CProductViewUniqueKey::get_Name(BSTR *pVal)
{
	if (!pVal)
		return E_POINTER;

	*pVal = mName.copy();
	return S_OK;
}

STDMETHODIMP CProductViewUniqueKey::put_Name(BSTR newVal)
{
	mName = newVal;
	return S_OK;
}

STDMETHODIMP CProductViewUniqueKey::get_TableName(BSTR *pVal)
{
	if (!pVal)
		return E_POINTER;

	*pVal = mTableName.copy();
	return S_OK;
}

STDMETHODIMP CProductViewUniqueKey::put_TableName(BSTR newVal)
{
	mTableName = newVal;
	return S_OK;
}

STDMETHODIMP CProductViewUniqueKey::get_ID(long *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = mID;

	return S_OK;
}

STDMETHODIMP CProductViewUniqueKey::put_ID(long newVal)
{
	mID = newVal;
	return S_OK;
}
STDMETHODIMP CProductViewUniqueKey::putref_ProductView(IProductView* newVal)
{
	mProductView = newVal;
	return S_OK;
}

STDMETHODIMP CProductViewUniqueKey::get_ProductView(IProductView* *pVal)
{
	if (!pVal)
		return E_POINTER;
	else
	{
		MTPRODUCTVIEWLib::IProductViewPtr ptr = mProductView;
		*pVal = reinterpret_cast<IProductView*> (ptr.Detach());
	}
	return S_OK;
}

STDMETHODIMP CProductViewUniqueKey::GetProperties(IMTCollection **pProperties)
{
	return mProperties.CopyTo(pProperties);
}
STDMETHODIMP CProductViewUniqueKey::AddProperty(IProductViewProperty *pProperty)
{
	mProperties.Add(pProperty);
	return S_OK;
}

