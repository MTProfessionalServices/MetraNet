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
#include "MTPriceListMapping.h"

#include <mtcomerr.h>
#include <mtprogids.h>

using MTPRODUCTCATALOGLib::IMTProductCatalogPtr;
using MTPRODUCTCATALOGLib::IMTRateSchedulePtr;
using MTPRODUCTCATALOGEXECLib::IMTRateScheduleReaderPtr;
using MTPRODUCTCATALOGEXECLib::MTRateScheduleReader;

/////////////////////////////////////////////////////////////////////////////
// CMTPriceListMapping

STDMETHODIMP CMTPriceListMapping::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
    &IID_IMTPriceListMapping,
    &IID_IMTPCBase
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTPriceListMapping::FinalConstruct()
{
	try
	{
		LoadPropertiesMetaData(PCENTITY_TYPE_PRICE_LIST_MAP);
    HRESULT hr = PutPropertyValue("MappingType", (long)MTPRODUCTCATALOGLib::MAPPING_NORMAL);
    if(FAILED(hr)) {
      return hr;
    }

		return CoCreateFreeThreadedMarshaler(
			GetControllingUnknown(), &m_pUnkMarshaler.p);
	}
	catch (_com_error & err)
	{ return LogAndReturnComError(PCCache::GetLogger(),err); }
}


STDMETHODIMP CMTPriceListMapping::get_PriceableItemID(long *pVal)
{
	return GetPropertyValue("PriceableItemID", pVal);
}

STDMETHODIMP CMTPriceListMapping::put_PriceableItemID(long newVal)
{
	return PutPropertyValue("PriceableItemID", newVal);
}

STDMETHODIMP CMTPriceListMapping::get_ParamTableDefinitionID(long *pVal)
{
	return GetPropertyValue("ParamTableDefinitionID", pVal);
}

STDMETHODIMP CMTPriceListMapping::put_ParamTableDefinitionID(long newVal)
{
	return PutPropertyValue("ParamTableDefinitionID", newVal);
}

STDMETHODIMP CMTPriceListMapping::get_PriceListID(long *pVal)
{
	return GetPropertyValue("PriceListID", pVal);
}

STDMETHODIMP CMTPriceListMapping::put_PriceListID(long newVal)
{
	return PutPropertyValue("PriceListID", newVal);
}

STDMETHODIMP CMTPriceListMapping::get_CanICB(VARIANT_BOOL *pVal)
{
	return GetPropertyValue("CanICB", pVal);
}

STDMETHODIMP CMTPriceListMapping::put_CanICB(VARIANT_BOOL newVal)
{
	return PutPropertyValue("CanICB", newVal);
}

STDMETHODIMP CMTPriceListMapping::GetPriceableItem(IMTPriceableItem **pVal)
{
	if (!pVal)
		return E_POINTER;

	try
	{
		// create reader instance
		IMTProductCatalogPtr catalog(__uuidof(MTProductCatalog));
		//TODO: use the appropriate reader to find the PI!!

		long id = -1;
		HRESULT hr = get_PriceableItemID(&id);
		if (FAILED(hr))
			return Error(L"Error getting priceable item ID", IID_IMTPriceListMapping, hr);

		*pVal = reinterpret_cast<IMTPriceableItem*> (catalog->GetPriceableItem(id).Detach());
	}
	catch (_com_error & err)
	{ return LogAndReturnComError(PCCache::GetLogger(),err); }

	return S_OK;
}

STDMETHODIMP CMTPriceListMapping::GetParameterTable(IMTParamTableDefinition **pVal)
{
	if (!pVal)
		return E_POINTER;

	try
	{
		// create reader instance
		IMTProductCatalogPtr catalog(__uuidof(MTProductCatalog));
		//TODO: use the appropriate reader to find the PI!!

		long id = -1;
		HRESULT hr = get_ParamTableDefinitionID(&id);
		if (FAILED(hr))
			return Error(L"Error getting parameter table ID", IID_IMTPriceListMapping, hr);

		*pVal = reinterpret_cast<IMTParamTableDefinition*>
			(catalog->GetParamTableDefinition(id).Detach());
	}
	catch (_com_error & err)
	{ return LogAndReturnComError(PCCache::GetLogger(),err); }

	return S_OK;
}

STDMETHODIMP CMTPriceListMapping::GetPriceList(IMTPriceList **pVal)
{
	if (!pVal)
		return E_POINTER;

	try
	{
		// create reader instance
		IMTProductCatalogPtr catalog(__uuidof(MTProductCatalog));
		//TODO: use the appropriate reader to find the PI!!

		long id = -1;
		HRESULT hr = get_PriceListID(&id);
		if (FAILED(hr))
			return Error(L"Error getting pricelist ID", IID_IMTPriceListMapping, hr);

		*pVal = reinterpret_cast<IMTPriceList*>
			(catalog->GetPriceList(id).Detach());
	}
	catch (_com_error & err)
	{ return LogAndReturnComError(PCCache::GetLogger(),err); }

	return S_OK;
}


STDMETHODIMP CMTPriceListMapping::FindRateSchedulesAsRowset(VARIANT aFilter, IMTRowSet **apRowset)
{
	if (!apRowset)
		return E_POINTER;

  try
	{
		// create reader instance and pass through
		IMTRateScheduleReaderPtr rsReader(__uuidof(MTRateScheduleReader));

		MTPRODUCTCATALOGEXECLib::IMTPriceListMapping* mapping =
			reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTPriceListMapping *>(this);

		MTPRODUCTCATALOGEXECLib::IMTRowSetPtr aRowset = rsReader->FindForPriceListMappingAsRowset(GetSessionContextPtr(), mapping, aFilter);
		*apRowset	= reinterpret_cast<IMTRowSet*>(aRowset.Detach());
	}
	catch (_com_error & err)
	{ return LogAndReturnComError(PCCache::GetLogger(),err); }

	return S_OK;
}

STDMETHODIMP CMTPriceListMapping::CreateRateSchedule(IMTRateSchedule **apSchedule)
{
	if (!apSchedule)
		return E_POINTER;

	try
	{
		IMTRateSchedulePtr schedule(__uuidof(MTRateSchedule));
		
		//pass the session context on to objects created from this one
		MTPRODUCTCATALOGLib::IMTPriceListMappingPtr thisPtr = this;
		MTPRODUCTCATALOGLib::IMTSessionContextPtr ctxt = thisPtr->GetSessionContext();
		schedule->SetSessionContext(ctxt);

		long plID = -1;
		HRESULT hr = get_PriceListID(&plID);
		if (FAILED(hr))
			return Error(L"Error getting pricelist ID", IID_IMTPriceListMapping, hr);

		// TODO: verify ID isn't -1

		schedule->PutPriceListID(plID);


		long ptID = -1;
		hr = get_ParamTableDefinitionID(&ptID);
		if (FAILED(hr))
			return Error(L"Error getting param table ID", IID_IMTPriceListMapping, hr);

		// TODO: verify ID isn't -1
		schedule->PutParameterTableID(ptID);


		//get ID of prc item template for this plm's pricable item instance
		MTPRODUCTCATALOGLib::IMTPriceListMappingPtr mapping = this;
    MTPRODUCTCATALOGEXECLib::IMTPriceableItemReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTPriceableItemReader));
    MTPRODUCTCATALOGEXECLib::IMTSQLRowsetPtr rowset = reader->FindTemplateByInstanceAsRowset(GetSessionContextPtr(), mapping->PriceableItemID);
    _variant_t val;
    val = rowset->GetValue("id_prop");
    long prcItemTmplID = val.lVal;

		// TODO: verify ID isn't -1
		schedule->PutTemplateID(prcItemTmplID);

    MTPriceListMappingType tempType;
    get_MappingType(&tempType);
    schedule->PutScheduleType((MTPRODUCTCATALOGLib::MTPriceListMappingType)tempType);


		*apSchedule = (IMTRateSchedule *) schedule.Detach();
	}
	catch (_com_error & err)
	{ return LogAndReturnComError(PCCache::GetLogger(),err); }

	return S_OK;
}

STDMETHODIMP CMTPriceListMapping::Save()
{
  try
	{
		// only support update
		// creation of price list mappings is done be owning prc item instance

		// create writer
		MTPRODUCTCATALOGEXECLib::IMTPriceListMappingWriterPtr writer(__uuidof(MTPRODUCTCATALOGEXECLib::MTPriceListMappingWriter));

		MTPRODUCTCATALOGEXECLib::IMTPriceListMapping* mapping =
			reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTPriceListMapping *>(this);

		writer->Update(GetSessionContextPtr(), mapping);
	}
	catch (_com_error & err)
	{ return LogAndReturnComError(PCCache::GetLogger(), (err)); }

	return S_OK;
}

STDMETHODIMP CMTPriceListMapping::get_MappingType(MTPriceListMappingType *pVal)
{
	return GetPropertyValue("MappingType", (long*)pVal);
}

STDMETHODIMP CMTPriceListMapping::put_MappingType(MTPriceListMappingType newVal)
{
	return PutPropertyValue("MappingType", (long)newVal);
}
