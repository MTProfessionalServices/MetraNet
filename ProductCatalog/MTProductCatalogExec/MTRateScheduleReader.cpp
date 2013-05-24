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
#include <mtprogids.h>
#include <comdef.h>
#include <mtcomerr.h>

#include "MTProductCatalogExec.h"
#include "MTRateScheduleReader.h"

#include <mtautocontext.h>
#include <ParamTable.h>

using MTPRODUCTCATALOGLib::IMTRateSchedulePtr;
using MTPRODUCTCATALOGLib::IMTPriceListMappingPtr;
using MTPRODUCTCATALOGLib::IMTPCTimeSpanPtr;

#define MTPROGID_RATE_SCHEDULE L"MetraTech.MTRateSchedule.1"

/////////////////////////////////////////////////////////////////////////////
// CMTRateScheduleReader

/******************************************* error interface ***/
STDMETHODIMP CMTRateScheduleReader::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTRateScheduleReader
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTRateScheduleReader::Activate()
{
	HRESULT hr = GetObjectContext(&mpObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTRateScheduleReader::CanBePooled()
{
	return FALSE;
} 

void CMTRateScheduleReader::Deactivate()
{
	mpObjectContext.Release();
} 


STDMETHODIMP CMTRateScheduleReader::FindAsRowset(IMTSessionContext* apCtxt, VARIANT aFilter, IMTSQLRowset **apRowset)
{
	return E_NOTIMPL;
#if 0
	if (!apRowset)
		return E_POINTER;

	try
	{
		MTPRODUCTCATALOGLib::IMTPropertyMetaDataSetPtr aMetaData(__uuidof(MTPropertyMetaDataSet));
		MTPRODUCTCATALOGLib::IMTDataFilterPtr aDataFilter = 
			aMetaData->TranslateFilter(aFilter,PCENTITY_TYPE_RATE_SCHEDULE);

		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		rowset->SetQueryTag("GET_FILTERED_PO");
		rowset->AddParam("%%COLUMNS%%", ""); //todo!!
		rowset->AddParam("%%JOINS%%", ""); //todo!!
		rowset->AddParam("%%FILTERS%%", ""); //todo!!
		rowset->Execute();

		// apply filter... XXX replace ADO filter with customized SQL
		// for better performance
		if(aDataFilter != NULL) {
			rowset->PutRefFilter(reinterpret_cast<ROWSETLib::IMTDataFilter*>(aDataFilter.GetInterfacePtr()));
		}

		*apRowset = reinterpret_cast<IMTSQLRowset*>(rowset.Detach());

		if (mpObjectContext)
			mpObjectContext->SetComplete();
	}
	catch (_com_error & err)
	{
		if (mpObjectContext)
			mpObjectContext->SetAbort();

		return ReturnComError(err);
	}


	return S_OK;
#endif
}


#define FIND_RATE_SCHEDULE_BY_ID L"__FIND_RATE_SCHEDULE_BY_ID__"

STDMETHODIMP CMTRateScheduleReader::Find(IMTSessionContext* apCtxt, long id, IMTRateSchedule **apSchedule)
{
	MTAutoContext context(mpObjectContext);
	try
	{
		if (!apCtxt)
			return E_POINTER;

		long languageID;
		HRESULT hr = apCtxt->get_LanguageID(&languageID);
		if (FAILED(hr))
			return hr;

		ROWSETLib::IMTSQLRowsetPtr rs;
		hr = rs.CreateInstance(MTPROGID_SQLROWSET);
		if (FAILED(hr))
			return hr;

		rs->Init(CONFIG_DIR);
		rs->SetQueryTag(FIND_RATE_SCHEDULE_BY_ID);
		rs->AddParam("%%ID%%", id);
		rs->AddParam(L"%%ID_LANG%%", languageID);
		rs->Execute();

		if (rs->GetRowsetEOF().boolVal == VARIANT_TRUE)
		{
			// TODO:
			ASSERT(0);
			return Error("Parameter table not found");
		}

		long returnedId = rs->GetValue("id_sched");
		ASSERT(returnedId == id);
		if (returnedId != id)
			return Error("rate schedule ID returned from the database is invalid");

		_variant_t val;
		// TODO: not localized
		val = rs->GetValue("nm_desc");
		_bstr_t desc = MTMiscUtil::GetString(val);

		IMTRateSchedulePtr schedule(MTPROGID_RATE_SCHEDULE);
		schedule->SetSessionContext(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(apCtxt));


		schedule->PutID(id);
		schedule->PutParameterTableID(rs->GetValue("id_pt"));
		schedule->PutPriceListID(rs->GetValue("id_pricelist"));
		schedule->PutTemplateID(rs->GetValue("id_pi_template"));
    // cast the integer value to MTPriceListMappingType
    schedule->PutScheduleType((MTPRODUCTCATALOGLib::MTPriceListMappingType)(long)rs->GetValue("type"));

		// populate the description
		schedule->PutDescription(desc);

		//
		// populate the contained effective date object
		IMTPCTimeSpanPtr timespan = schedule->GetEffectiveDate();

		val = rs->GetValue(L"id_eff_date");
		timespan->PutID(val);

		val = rs->GetValue(L"n_begintype");
		timespan->PutStartDateType(static_cast<MTPRODUCTCATALOGLib::MTPCDateType>(val.lVal));

		val = rs->GetValue(L"dt_start");
		if (V_VT(&val) == VT_NULL)
			timespan->PutStartDate(0.0);
		else
			timespan->PutStartDate(val);

		val = rs->GetValue(L"n_beginoffset");
		timespan->PutStartOffset(val);

		val = rs->GetValue(L"n_endtype");
		timespan->PutEndDateType(static_cast<MTPRODUCTCATALOGLib::MTPCDateType>(val.lVal));

		val = rs->GetValue(L"dt_end");
		if (V_VT(&val) == VT_NULL)
			timespan->PutEndDate(0.0);
		else
			timespan->PutEndDate(val);

		val = rs->GetValue(L"n_endoffset");
		timespan->PutEndOffset(val);

		*apSchedule = (IMTRateSchedule *) schedule.Detach();
	}
	catch(_com_error& e)
	{ return ReturnComError(e); }

	context.Complete();
	return S_OK;
}

STDMETHODIMP CMTRateScheduleReader::FindForPriceListMappingAsRowset(IMTSessionContext* apCtxt, IMTPriceListMapping *apMapping, VARIANT aFilter, IMTSQLRowset **apRowset)
{
	MTAutoContext context(mpObjectContext);

	if (!apMapping || !apRowset)
		return E_POINTER;

	try
	{
		if (!apCtxt)
			return E_POINTER;

		long languageID;
		HRESULT hr = apCtxt->get_LanguageID(&languageID);
		if (FAILED(hr))
			return hr;

		//TODO: implement Filter

		IMTPriceListMappingPtr mapping = apMapping;

		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		rowset->SetQueryTag(L"__FIND_RATE_SCHEDULES_FOR_PL_MAPPING__");
		rowset->AddParam(L"%%PRICELIST%%", mapping->PriceListID);
		rowset->AddParam(L"%%PT%%", mapping->ParamTableDefinitionID);
		rowset->AddParam(L"%%PI_INSTANCE%%", mapping->PriceableItemID);
		rowset->AddParam(L"%%ID_LANG%%", languageID);
		rowset->Execute();

		*apRowset = reinterpret_cast<IMTSQLRowset*>(rowset.Detach());
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	context.Complete();
	return S_OK;
}

STDMETHODIMP CMTRateScheduleReader::FindForParamTableAsRowset(IMTSessionContext* apCtxt, long aParamTblDefID, VARIANT_BOOL aIncludeICB, VARIANT_BOOL aShowHidden, VARIANT aFilter, IMTSQLRowset **apRowset)
{
	MTAutoContext context(mpObjectContext);

	if (!apRowset)
		return E_POINTER;

	try
	{
		if (!apCtxt)
			return E_POINTER;

		long languageID;
		HRESULT hr = apCtxt->get_LanguageID(&languageID);
		if (FAILED(hr))
			return hr;

		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);

		if (aIncludeICB == VARIANT_TRUE)
				rowset->SetQueryTag(L"__FIND_RATE_SCHEDULES_FOR_PARAM_TBL__");
		else
				rowset->SetQueryTag(L"__FIND_NON_ICB_RATE_SCHEDULES_FOR_PARAM_TBL__");

		// Check if we are supposed to return rate schedules that belong to Product Offerings that are currently marked as hidden.
		// If not, then create a extra clause to filter them out in the query
		_bstr_t extra_filters = "";
		if (!aShowHidden)
		{
			extra_filters = " and (b_hidden = 'N' or b_hidden is NULL)";
		}

		MTPRODUCTCATALOGLib::IMTProductCatalogPtr pc(__uuidof(MTProductCatalog));

		rowset->AddParam(L"%%PT%%", aParamTblDefID);
		rowset->AddParam("%%ID_LANG%%", languageID);
		rowset->AddParam("%%EXTRA_FILTERS%%", extra_filters, true);
		rowset->Execute();

		// Check the filter and apply changes
		MTPRODUCTCATALOGLib::IMTPropertyMetaDataSetPtr metaData = pc->GetMetaData(MTPRODUCTCATALOGLib::PCENTITY_TYPE_PRICE_LIST);
		MTPRODUCTCATALOGLib::IMTDataFilterPtr aDataFilter = metaData->TranslateFilter(aFilter);
		if(aDataFilter != NULL) {
			rowset->PutRefFilter(reinterpret_cast<ROWSETLib::IMTDataFilter*>(aDataFilter.GetInterfacePtr()));
		}

		*apRowset = reinterpret_cast<IMTSQLRowset*>(rowset.Detach());
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	context.Complete();
	return S_OK;
}

STDMETHODIMP CMTRateScheduleReader::FindForParamTablePriceableItemTypeAsRowset(IMTSessionContext* apCtxt, long aParamTblDefID, long aPriceableItemTypeID, VARIANT_BOOL aIncludeICB, IMTSQLRowset **apRowset)
{
	MTAutoContext context(mpObjectContext);

	if (!apRowset)
		return E_POINTER;

	try
	{
		if (!apCtxt)
			return E_POINTER;

		long languageID;
		HRESULT hr = apCtxt->get_LanguageID(&languageID);
		if (FAILED(hr))
			return hr;

		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);

		if (aIncludeICB == VARIANT_TRUE)
				rowset->SetQueryTag(L"__FIND_RATE_SCHEDULES_FOR_PARAM_TBL_PI_TYPE__");
		else
				rowset->SetQueryTag(L"__FIND_NON_ICB_RATE_SCHEDULES_FOR_PARAM_TBL_PI_TYPE__");

		rowset->AddParam(L"%%PI%%", aPriceableItemTypeID);
		rowset->AddParam(L"%%PT%%", aParamTblDefID);
		rowset->AddParam("%%ID_LANG%%", languageID);
		rowset->Execute();

		*apRowset = reinterpret_cast<IMTSQLRowset*>(rowset.Detach());
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	context.Complete();
	return S_OK;
}



STDMETHODIMP CMTRateScheduleReader::FindForParamTablePriceListAsRowset(IMTSessionContext* apCtxt, long aParamTblDefID, long aPrcListID, long aPITemplate, IMTSQLRowset **apRowset)
{
	MTAutoContext context(mpObjectContext);

	if (!apRowset)
		return E_POINTER;

	try
	{
		if (!apCtxt)
			return E_POINTER;

		long languageID;
		HRESULT hr = apCtxt->get_LanguageID(&languageID);
		if (FAILED(hr))
			return hr;

		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		rowset->SetQueryTag(L"__FIND_RATE_SCHEDULES_FOR_PARAM_TBL_PL__");
		rowset->AddParam(L"%%PRICELIST%%", aPrcListID);
		rowset->AddParam(L"%%PT%%", aParamTblDefID);
		rowset->AddParam(L"%%PI_TEMPLATE%%", aPITemplate);
		rowset->AddParam(L"%%ID_LANG%%", languageID);
		rowset->Execute();

		*apRowset = reinterpret_cast<IMTSQLRowset*>(rowset.Detach());
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	context.Complete();
	return S_OK;
}

STDMETHODIMP CMTRateScheduleReader::GetCountByPriceList(IMTSessionContext* apCtxt, long aPriceListID, long *pCount)
{
	MTAutoContext context(mpObjectContext);

	if (!pCount)
		return E_POINTER;

	try
	{
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		rowset->SetQueryTag(L"__GET_RSCHED_COUNT_BY_PL__");
		rowset->AddParam(L"%%ID_PL%%", aPriceListID);
		rowset->Execute();
	
		*pCount = rowset->GetValue(0L);
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	context.Complete();
	return S_OK;
}
