/**************************************************************************
* Copyright 1997-2001 by MetraTech
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
* $Header$
* 
***************************************************************************/

#include "StdAfx.h"

#include <metra.h>
#include <comdef.h>
#include <mtcomerr.h>
#include <stdutils.h>

#include "MTProductCatalog.h"
#include "MTAttributeMetaDataSet.h"

using namespace MTAttributeMetaDataSetNamespace;

/////////////////////////////////////////////////////////////////////////////
// CMTAttributeMetaDataSet

STDMETHODIMP CMTAttributeMetaDataSet::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTAttributeMetaDataSet
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

/********************************** construction/destruction ***/
CMTAttributeMetaDataSet::CMTAttributeMetaDataSet()
{
	mUnkMarshalerPtr = NULL;
}

HRESULT CMTAttributeMetaDataSet::FinalConstruct()
{
	return CoCreateFreeThreadedMarshaler(
		GetControllingUnknown(), &mUnkMarshalerPtr.p);
}

void CMTAttributeMetaDataSet::FinalRelease()
{
	mUnkMarshalerPtr.Release();
}

/********************************** IMTAttributeMetaDataSet***/
STDMETHODIMP CMTAttributeMetaDataSet::get_Item(VARIANT aKey, VARIANT *pVal)
{
	if (pVal == NULL)
		return E_POINTER;

	try
	{
		switch(aKey.vt)
		{
		case VT_I4:
			return CollImpl::get_Item(aKey.lVal, pVal);

		case VT_I2:
			return CollImpl::get_Item((long)aKey.iVal, pVal);

		case VT_BSTR:
			{
				// make name uppercase, so case won't matter
				mtwstring wName(aKey.bstrVal);
				wName.toupper();

				//indexed by name
				AttrMap::iterator it;
				it = m_coll.find(wName.c_str());
				
				if(it == m_coll.end())
				{ _bstr_t name = aKey.bstrVal;
					MT_THROW_COM_ERROR( MTPC_ATTRIBUTE_NOT_FOUND, (const char*)name);
				}

				pVal->vt = VT_DISPATCH;
				IMTAttributeMetaData * pAttr = (*it).second;

				//copy the item's IDispatch into pItem (also implicit AddRef))
				return pAttr->QueryInterface(IID_IDispatch, (void**) & (pVal->pdispVal));
			}

		default:	
			//unrecognized index type
			return E_INVALIDARG;
		}
	}	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	return S_OK;
}

STDMETHODIMP CMTAttributeMetaDataSet::CreateMetaData(/*[in]*/ BSTR aAttributeName, /*[out, retval]*/ IMTAttributeMetaData** apMetaData)
{
	if (!apMetaData)
		return E_POINTER;
	
	//create a metaData instance
	CComPtr<IMTAttributeMetaData> metaData;
	HRESULT hr = metaData.CoCreateInstance(__uuidof(MTAttributeMetaData));
	if (!SUCCEEDED(hr))
	{	Error("Cannot create instance of MTAttributeMetaData");
		return hr;
	}

	// set its name
	metaData->put_Name(aAttributeName);

	//add it to collection
	
	// make name uppercase, so case won't matter
	mtwstring wName(aAttributeName); 
	wName.toupper();
	m_coll[CComBSTR(wName)] = metaData;
	
	*apMetaData = metaData.Detach();

	return S_OK;
}
