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
#include "MTProductCatalog.h"
#include "MTPriceList.h"

#include <mtcomerr.h>
#include <mtprogids.h>
#include <comdef.h>

using MTPRODUCTCATALOGEXECLib::IMTPriceListWriterPtr;
using MTPRODUCTCATALOGEXECLib::MTPriceListWriter;
using MTPRODUCTCATALOGEXECLib::IMTRateScheduleReaderPtr;
using MTPRODUCTCATALOGEXECLib::MTRateScheduleReader;
using MTPRODUCTCATALOGLib::IMTPriceListPtr;
using MTPRODUCTCATALOGEXECLib::IMTProductOfferingReaderPtr;
using MTPRODUCTCATALOGEXECLib::MTProductOfferingReader;
using MTPRODUCTCATALOGLib::IMTProductOfferingPtr;

/////////////////////////////////////////////////////////////////////////////
// CMTPriceList

STDMETHODIMP CMTPriceList::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
    &IID_IMTPriceList,
    &IID_IMTPCBase
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTPriceList::FinalConstruct()
{
	try
	{
		LoadPropertiesMetaData(PCENTITY_TYPE_PRICE_LIST);

		return CoCreateFreeThreadedMarshaler(
			GetControllingUnknown(), &m_pUnkMarshaler.p);
	}
	catch (_com_error & err)
	{ return LogAndReturnComError(PCCache::GetLogger(),err); }
}

STDMETHODIMP CMTPriceList::get_ID(long *pVal)
{
	return GetPropertyValue("ID", pVal);
}

STDMETHODIMP CMTPriceList::put_ID(long newVal)
{
	return PutPropertyValue("ID", newVal);
}

STDMETHODIMP CMTPriceList::get_Name(BSTR *pVal)
{
	return GetPropertyValue("Name", pVal);
}

STDMETHODIMP CMTPriceList::put_Name(BSTR newVal)
{
	return PutPropertyValue("Name", newVal);
}

STDMETHODIMP CMTPriceList::get_Description(BSTR *pVal)
{
	return GetPropertyValue("Description", pVal);
}

STDMETHODIMP CMTPriceList::put_Description(BSTR newVal)
{
	return PutPropertyValue("Description", newVal);
}

STDMETHODIMP CMTPriceList::get_CurrencyCode(BSTR *pVal)
{
	return GetPropertyValue("CurrencyCode", pVal);
}

STDMETHODIMP CMTPriceList::put_CurrencyCode(BSTR newVal)
{
	return PutPropertyValue("CurrencyCode", newVal);
}

/* Deprecated - DO NOT USE*/
STDMETHODIMP CMTPriceList::get_Shareable(VARIANT_BOOL *pVal)
{
	MTPRODUCTCATALOGLib::IMTPriceListPtr thisPtr = this;
	if (thisPtr->Type != PRICELIST_TYPE_ICB)
		*pVal = VARIANT_TRUE;
	else
		*pVal = VARIANT_FALSE;
	return S_OK;
}
/* Deprecated - DO NOT USE*/
STDMETHODIMP CMTPriceList::put_Shareable(VARIANT_BOOL newVal)
{
	MTPRODUCTCATALOGLib::IMTPriceListPtr thisPtr = this;
	if (newVal == VARIANT_TRUE)
		thisPtr->Type = (MTPRODUCTCATALOGLib::MTPriceListType) PRICELIST_TYPE_REGULAR;
	else
		thisPtr->Type = (MTPRODUCTCATALOGLib::MTPriceListType) PRICELIST_TYPE_ICB;
	return S_OK;
}

STDMETHODIMP CMTPriceList::get_Type(MTPriceListType *pVal)
{
	return GetPropertyValue("Type", (long*) pVal);
}

STDMETHODIMP CMTPriceList::put_Type(MTPriceListType newVal)
{
	return PutPropertyValue("Type", (long) newVal);
}

STDMETHODIMP CMTPriceList::GetOwnerProductOffering(IMTProductOffering ** pVal)
{
	if (!pVal)
		return E_POINTER;

	try
	{
		IMTPriceListPtr thisPtr = this;
		if (thisPtr->Type != PRICELIST_TYPE_PO)
		{
			*pVal = 0L;
		}
		else
		{
			IMTProductOfferingReaderPtr poReader(__uuidof(MTProductOfferingReader));
			IMTProductOfferingPtr poPtr = poReader->FindWithNonSharedPriceList(GetSessionContextPtr(), thisPtr->ID);
			*pVal = reinterpret_cast<IMTProductOffering*>( poPtr.Detach() );
		}
	}
	catch (_com_error & err)
	{ 
		return LogAndReturnComError(PCCache::GetLogger(), err);
	}

	return S_OK;	
}

STDMETHODIMP CMTPriceList::GetRateScheduleCount(long *pVal)
{
	if (!pVal)
		return E_POINTER;

	try
	{
		IMTRateScheduleReaderPtr rsReader(__uuidof(MTRateScheduleReader));
		IMTPriceListPtr thisPtr = this;
		*pVal = rsReader->GetCountByPriceList(GetSessionContextPtr(), thisPtr->ID);
	}
	catch (_com_error & err)
	{ 
		return LogAndReturnComError(PCCache::GetLogger(), err);
	}

	return S_OK;
}

STDMETHODIMP CMTPriceList::Save()
{
  try
	{
		//validate properties based on their meta data (required, length, ...)
		//throws _com_error on failure
		ValidateProperties();
		
		// create instance of COM+ executant
		IMTPriceListWriterPtr plWriter(__uuidof(MTPriceListWriter));

		// just cast "this"
		MTPRODUCTCATALOGEXECLib::IMTPriceList * priceList
			= reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTPriceList *>(this);

		if (HasID())  //created
			plWriter->Update(GetSessionContextPtr(), priceList);
		else					// not yet created
			put_ID(plWriter->Create(GetSessionContextPtr(), priceList));
	}
	catch (_com_error & err)
	{ 
		return LogAndReturnComError(PCCache::GetLogger(), err);
	}

	return S_OK;
}

