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
#include "MTAttributes.h"

using namespace MTAttributesNamespace;


/////////////////////////////////////////////////////////////////////////////
// CMTAttributes

STDMETHODIMP CMTAttributes::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTAttributes
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

/********************************** construction/destruction ***/
CMTAttributes::CMTAttributes()
{
	mUnkMarshalerPtr = NULL;
}

HRESULT CMTAttributes::FinalConstruct()
{
	return CoCreateFreeThreadedMarshaler(
		GetControllingUnknown(), &mUnkMarshalerPtr.p);
}

void CMTAttributes::FinalRelease()
{
	mUnkMarshalerPtr.Release();
}

/********************************** IMTAttributes***/
STDMETHODIMP CMTAttributes::get_Item(VARIANT aKey, VARIANT *pVal)
{
	if (pVal == NULL)
		return E_POINTER;

	try
	{
		HRESULT hr = S_OK;
		CComVariant varKey;

		if (aKey.vt != VT_BSTR)
		{
			// If the index isn't a string, but can be converted to a long value interpret as string

			hr = varKey.ChangeType(VT_I4, &aKey);
			if (SUCCEEDED(hr))
			{
				unsigned long idx = varKey.lVal;
				//COM collections are 1-based collection
				if (idx < 1 || idx > m_coll.size())
					MT_THROW_COM_ERROR( MTPC_INDEX_OUT_OF_RANGE, idx);
				
				return CollImpl::get_Item(idx, pVal);
			}
		}

		// Otherwise, we assume index is a string key into the map
		hr = varKey.ChangeType(VT_BSTR, &aKey);

		// If we can't convert to a string, just return
		if (FAILED(hr))
			return hr;

		mtwstring wName(varKey.bstrVal);
		wName.toupper();

		AttrMap::iterator it = m_coll.find(CComBSTR(wName));

		// item not found
		if (it == m_coll.end())
		{ _bstr_t name = varKey.bstrVal;
			MT_THROW_COM_ERROR( "Attribute named '%s' not found", (const char*)name);
		}
			
		// If item was found, copy the variant to the out param
		return (CComVariant(it->second).Detach(pVal));
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	return S_OK;
}

// returns true if the specified item exists in the collection
STDMETHODIMP CMTAttributes::Exists(/*[in]*/ VARIANT aKey, /*[out, retval]*/ VARIANT_BOOL *pVal)
{
	try
	{
		HRESULT hr = S_OK;
		CComVariant varKey;

		if (aKey.vt != VT_BSTR)
		{
			// If the index isn't a string, but can be converted to a long value interpret as string

			hr = varKey.ChangeType(VT_I4, &aKey);
			if (SUCCEEDED(hr))
			{
				unsigned long idx = varKey.lVal;
				//COM collections are 1-based collection
				if (idx < 1 || idx > m_coll.size())
					*pVal = VARIANT_FALSE;
				else
					*pVal = VARIANT_TRUE;

				return S_OK;
			}
		}

		// Otherwise, we assume index is a string key into the map
		hr = varKey.ChangeType(VT_BSTR, &aKey);

		// If we can't convert to a string, just return
		if (FAILED(hr))
			return hr;

		mtwstring wName(varKey.bstrVal);
		wName.toupper();

		AttrMap::iterator it = m_coll.find(CComBSTR(wName));

		// item not found
		if (it == m_coll.end())
			*pVal = VARIANT_FALSE;
		else
			*pVal = VARIANT_TRUE;
			
		return S_OK;
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	return S_OK;
}


STDMETHODIMP CMTAttributes::Add(/*[in]*/ IMTAttributeMetaData* apMetaData,
																/*[out, retval]*/ IMTAttribute** apAttr)
{
	HRESULT hr = S_OK;

	if (apMetaData == NULL)
		return E_POINTER;

	if (apAttr == NULL)
		return E_POINTER;
	else
		*apAttr = NULL;

	try
	{
		//create a new MTAttribute based on this meta data
		CComPtr<IMTAttribute> attrPtr;
		attrPtr.CoCreateInstance(__uuidof(MTAttribute));
		HRESULT hr = attrPtr->SetMetaData(apMetaData);
		if (FAILED(hr))
			return hr;

		//set value of Attribute to default value of meta data
		VARIANT var;
		VariantInit(&var);
		hr = apMetaData->get_DefaultValue(&var);
		if (FAILED(hr))
			return hr;
		
		_variant_t defValue(var, false); //make sure we variant gets cleared 

		hr = attrPtr->put_Value(defValue);
		if (FAILED(hr))
			return hr;
		
		// add MTAttribute to collection
		BSTR bstrName;
		apMetaData->get_Name(&bstrName);
		_bstr_t strName(bstrName, false); //make sure we release it

		// make name uppercase, so case won't matter
		mtwstring wName(strName);
		wName.toupper();

		m_coll[CComBSTR(wName)] = attrPtr;

		*apAttr = attrPtr.Detach();

	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}		

	return S_OK;
}

