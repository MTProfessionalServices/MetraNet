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
* $Header: 
* 
***************************************************************************/

#include "StdAfx.h"
#include "MTProductCatalog.h"
#include "MTCounterPropertyDefinition.h"
#include "MTProductCatalog.h"
#include <mtcomerr.h>
#include <mtprogids.h>

/////////////////////////////////////////////////////////////////////////////
// CMTCounterPropertyDefinition
HRESULT CMTCounterPropertyDefinition::FinalConstruct()
{
	mlPITypeID = -1;
	try
	{
		HRESULT hr = CoCreateFreeThreadedMarshaler(GetControllingUnknown(), &mUnkMarshalerPtr.p);
		if (FAILED(hr))
			throw _com_error(hr);

		LoadPropertiesMetaData( PCENTITY_TYPE_COUNTER_PROPERTY_DEF);
	}	
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return mpPC.CoCreateInstance(__uuidof(MTProductCatalog));
}

STDMETHODIMP CMTCounterPropertyDefinition::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
    &IID_IMTCounterPropertyDefinition,
    &IID_IMTPCBase
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

STDMETHODIMP CMTCounterPropertyDefinition::get_ID(long *pVal)
{
	return GetPropertyValue("ID", pVal);
}

STDMETHODIMP CMTCounterPropertyDefinition::put_ID(long newVal)
{
	return PutPropertyValue("ID", newVal);
}

STDMETHODIMP CMTCounterPropertyDefinition::get_Name(BSTR *pVal)
{
	return GetPropertyValue("Name", pVal);
}

STDMETHODIMP CMTCounterPropertyDefinition::put_Name(BSTR newVal)
{
	return PutPropertyValue("Name", newVal);
}

STDMETHODIMP CMTCounterPropertyDefinition::get_ServiceDefProperty(BSTR *pVal)
{
	return GetPropertyValue("ServiceDefProperty", pVal);
}

STDMETHODIMP CMTCounterPropertyDefinition::put_ServiceDefProperty(BSTR newVal)
{
	return PutPropertyValue("ServiceDefProperty", newVal);
}

STDMETHODIMP CMTCounterPropertyDefinition::get_Order(long *pVal)
{
	return GetPropertyValue("Order", pVal);
}

STDMETHODIMP CMTCounterPropertyDefinition::put_Order(long newVal)
{
	return PutPropertyValue("Order", newVal);
}

STDMETHODIMP CMTCounterPropertyDefinition::get_DisplayName(BSTR *pVal)
{
	return GetPropertyValue("DisplayName", pVal);
}

STDMETHODIMP CMTCounterPropertyDefinition::put_DisplayName(BSTR newVal)
{
	return PutPropertyValue("DisplayName", newVal);
}

STDMETHODIMP CMTCounterPropertyDefinition::get_PreferredCounterTypeName(BSTR *pVal)
{
	return GetPropertyValue("PreferredCounterTypeName", pVal);
}

STDMETHODIMP CMTCounterPropertyDefinition::put_PreferredCounterTypeName(BSTR newVal)
{
 return PutPropertyValue("PreferredCounterTypeName", newVal);
}

STDMETHODIMP CMTCounterPropertyDefinition::get_PITypeID(long *pVal)
{
	return GetPropertyValue("PITypeID", pVal);
}

STDMETHODIMP CMTCounterPropertyDefinition::put_PITypeID(long newVal)
{
	mlPITypeID = newVal;
	return PutPropertyValue("PITypeID", newVal);
}

STDMETHODIMP CMTCounterPropertyDefinition::Save(long *apDBID)
{
	HRESULT hr(S_OK);
	
	
	
	try
	{
		MTPRODUCTCATALOGEXECLib::IMTCounterPropertyDefinitionWriterPtr writer
			( __uuidof(MTPRODUCTCATALOGEXECLib::MTCounterPropertyDefinitionWriter));
		
		if(FAILED(hr))
			return hr;
		
		if(HasID())
		{
			hr = writer->Update(GetSessionContextPtr(), reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTCounterPropertyDefinition*>(this) );
			if (FAILED(hr))
				return hr;
			return GetPropertyValue("ID", apDBID);
		}
		//check for incomplete info
		if(mlPITypeID < 0)
			MT_THROW_COM_ERROR(MTPC_ITEM_CANNOT_BE_SAVED);
		
		//TODO: do I need to check for empty strings
		//
		long lID = writer->Create(GetSessionContextPtr(), reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTCounterPropertyDefinition*>(this) );
		
		(*apDBID) = lID;
		PutPropertyValue("ID", lID);
	 }
	catch(_com_error& e)
	{
		return LogAndReturnComError(PCCache::GetLogger(),e);
		}
	return hr;
}

STDMETHODIMP CMTCounterPropertyDefinition::Load(long aDBID)
{
	//load this state from database
	HRESULT hr(S_OK);
	return hr;
}
