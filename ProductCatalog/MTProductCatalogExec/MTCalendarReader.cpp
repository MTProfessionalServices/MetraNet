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

// MTCalendarReader.cpp : Implementation of CMTCalendarReader
#include "StdAfx.h"
#include "MTProductCatalogExec.h"
#include "MTCalendarReader.h"

#include <pcexecincludes.h>

/////////////////////////////////////////////////////////////////////////////
// CMTCalendarReader

/******************************************* error interface ***/
STDMETHODIMP CMTCalendarReader::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTCalendarReader
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTCalendarReader::Activate()
{
	HRESULT hr = GetObjectContext(&m_spObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTCalendarReader::CanBePooled()
{
	return TRUE;
} 

void CMTCalendarReader::Deactivate()
{
	m_spObjectContext.Release();
} 

// ----------------------------------------------------------------
// Name: GetCalendarsAsRowset    	
// Arguments:   IMTSessionContext  
//                
// Return Value:  IMTSQLRowset
// Errors Raised: 
// Description:   Returns calendars in the system as a rowset
// ----------------------------------------------------------------
STDMETHODIMP CMTCalendarReader::GetCalendarsAsRowset(IMTSessionContext* apCtxt, IMTSQLRowset **apRowset)
{
	ROWSETLib::IMTSQLRowsetPtr rs;
	
	HRESULT hr = rs.CreateInstance(MTPROGID_SQLROWSET);
	_ASSERTE(SUCCEEDED(hr));

	MTAutoContext context(m_spObjectContext);

	try
	{
		if (!apCtxt)
			return E_POINTER;

		long languageID;
		HRESULT hr = apCtxt->get_LanguageID(&languageID);
		if (FAILED(hr))
			return hr;

		rs->Init(CONFIG_DIR);
		rs->SetQueryTag("__GET_CALENDARS__"); 
		rs->AddParam(L"%%ID_LANG%%", languageID);
		rs->Execute();
		
		(*apRowset) = (IMTSQLRowset*)rs.Detach();	

	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}

	context.Complete();
	
	return S_OK;
}

// ----------------------------------------------------------------
// Name: GetCalendarByName    	
// Arguments:   apCtxt , CalendarName
//                
// Return Value:  IMTCalendar
// Errors Raised: 
// Description:   Loads a calendar, with weekdays, holidays and corresponding periods by it's name
// ----------------------------------------------------------------
STDMETHODIMP CMTCalendarReader::GetCalendarByName(IMTSessionContext* apCtxt, BSTR aName, IMTCalendar **apCalendar)
{
	try
	{
		HRESULT hr = S_OK;
		ROWSETLib::IMTSQLRowsetPtr rs;

		if (!apCtxt)
			return E_POINTER;

		long languageID;
		hr = apCtxt->get_LanguageID(&languageID);
		if (FAILED(hr))
			return hr;

		hr = rs.CreateInstance(MTPROGID_SQLROWSET);
		if (FAILED(hr))
			return hr;

		// Execute query to see if a calendar with this Name is already present on the system
		rs->Init(CONFIG_DIR);
		rs->SetQueryTag(L"__GET_CALENDAR_BYNAME__");
		rs->AddParam(_bstr_t("%%CALENDAR_NAME%%"), aName);
		rs->AddParam(L"%%ID_LANG%%", languageID);
		rs->Execute();
	
		// We couldn't find this calendar. Return NULL.
		if (rs->GetRecordCount() == 0)
		{
			(*apCalendar) = NULL;
			return hr;
		}
	
		_variant_t calendarprop = rs->GetValue("id_calendar");
		long calID = calendarprop.lVal;
	
		MTPRODUCTCATALOGEXECLib::IMTCalendarReaderPtr thisPtr = this;
		MTPRODUCTCATALOGLib::IMTCalendarPtr pCalendar = thisPtr->GetCalendar((MTPRODUCTCATALOGEXECLib::IMTSessionContext *) apCtxt, calID);
		(*apCalendar) = (IMTCalendar*) pCalendar.Detach();
		return hr;
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }
}

// ----------------------------------------------------------------
// Name: GetCalendar    	
// Arguments:   apCtxt , CalendarID
//                
// Return Value:  IMTCalendar
// Errors Raised: 
// Description:   Loads a calendar, with weekdays, holidays and corresponding periods
// ----------------------------------------------------------------
STDMETHODIMP CMTCalendarReader::GetCalendar(IMTSessionContext* apCtxt, long aID, IMTCalendar **apCalendar)
{
	HRESULT hr = S_OK;

	ROWSETLib::IMTSQLRowsetPtr rs;
	ROWSETLib::IMTSQLRowsetPtr rs2;
	
	// Core objects to construct the calendar
	MTPRODUCTCATALOGLib::IMTCalendarPtr pCalendar(__uuidof(MTCalendar));
	MTPRODUCTCATALOGLib::IMTCalendarHolidayPtr pHoliday;
	MTPRODUCTCATALOGLib::IMTCalendarWeekdayPtr pWeekday;
	MTPRODUCTCATALOGLib::IMTCalendarPeriodPtr pPeriod;

	_variant_t calendarprop;
	_variant_t dayprop;
	_variant_t periodprop;

	pCalendar->SetSessionContext(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(apCtxt));

	int nCount_rs, nCount_rs2;
	hr = rs.CreateInstance(MTPROGID_SQLROWSET) ;
	hr = rs2.CreateInstance(MTPROGID_SQLROWSET) ;

	MTAutoContext context(m_spObjectContext);
	
	try
	{
		if (!apCtxt)
			return E_POINTER;

		long languageID;
		HRESULT hr = apCtxt->get_LanguageID(&languageID);
		if (FAILED(hr))
			return hr;

		rs->Init(CONFIG_DIR);
		rs2->Init(CONFIG_DIR);

		rs->SetQueryTag(L"__GET_CALENDAR__");
		rs->AddParam(MTPARAM_ID_PROP, aID);
		rs->AddParam(L"%%ID_LANG%%", languageID);
		rs->Execute();
		nCount_rs = rs->GetRecordCount();
		
		if (!nCount_rs)
			MT_THROW_COM_ERROR(MTPC_ITEM_NOT_FOUND_BY_ID, PCENTITY_TYPE_CALENDAR, aID);

		while(rs->GetRowsetEOF().boolVal == VARIANT_FALSE)
		{
			calendarprop = rs->GetValue("id_calendar");
			pCalendar->PutID(calendarprop.lVal);
			
			calendarprop = rs->GetValue("nm_name");
			calendarprop = MTMiscUtil::GetString(calendarprop);
			pCalendar->PutName(calendarprop.bstrVal);

			calendarprop = rs->GetValue("nm_desc");
			calendarprop = MTMiscUtil::GetString(calendarprop);
			pCalendar->PutDescription(calendarprop.bstrVal);

			calendarprop = rs->GetValue("n_timezoneoffset");
			pCalendar->PutTimezoneOffset(calendarprop.lVal);

			calendarprop = rs->GetValue("b_combinedweekend");
			calendarprop = MTMiscUtil::GetString(calendarprop);
			if (_bstr_t(calendarprop.bstrVal) == _bstr_t("T"))
				pCalendar->PutCombinedWeekend(VARIANT_TRUE);
			else
				pCalendar->PutCombinedWeekend(VARIANT_FALSE);

			//Insert ways of getting the timezone offset and the combined weekend flag		

			rs->MoveNext();
		}		
		
		// Populate weekdays of this calendar
		rs->ClearQuery();
		rs->SetQueryTag(L"__GET_CALENDAR_WEEKDAYS__");
		rs->AddParam(_bstr_t("%%CALENDAR_ID%%"), aID);
		rs->Execute();
		nCount_rs = rs->GetRecordCount();
		
		while(rs->GetRowsetEOF().boolVal == VARIANT_FALSE)
		{
			dayprop = rs->GetValue("n_weekday");
			pWeekday = pCalendar->CreateWeekday(dayprop.lVal);

			dayprop = rs->GetValue("id_day");
			pWeekday->PutID(dayprop.lVal);
			
			dayprop = rs->GetValue("n_code");
			pWeekday->PutCode(dayprop.lVal);

			// Get all calendar periods for this weekday
			rs2->ClearQuery();
			rs2->SetQueryTag(L"__GET_CALENDAR_PERIODS__");
			rs2->AddParam(_bstr_t("%%DAY_ID%%"), pWeekday->GetID());
			rs2->Execute();
			nCount_rs2 = rs2->GetRecordCount();
			
			while(rs2->GetRowsetEOF().boolVal == VARIANT_FALSE)
			{
				pPeriod = pWeekday->CreatePeriod();
				
				periodprop = rs2->GetValue("id_period");
				pPeriod->PutID(periodprop.lVal);
				periodprop = rs2->GetValue("n_begin");
				pPeriod->PutStartTime(periodprop.lVal);
				periodprop = rs2->GetValue("n_end");
				pPeriod->PutEndTime(periodprop.lVal);
				periodprop = rs2->GetValue("n_code");
				pPeriod->PutCode(periodprop.lVal);

				rs2->MoveNext();
			}
			
			rs->MoveNext();
		}

		// Populate holidays of this calendar
		rs->ClearQuery();
		rs->SetQueryTag(L"__GET_CALENDAR_HOLIDAYS__");
		rs->AddParam(_bstr_t("%%CALENDAR_ID%%"), aID);
		rs->Execute();
		nCount_rs = rs->GetRecordCount();
		
		while(rs->GetRowsetEOF().boolVal == VARIANT_FALSE)
		{

			dayprop = rs->GetValue("nm_name");
			dayprop = MTMiscUtil::GetString(dayprop);
			pHoliday = pCalendar->CreateHoliday(dayprop.bstrVal);

			dayprop = rs->GetValue("id_day");
			pHoliday->PutID(dayprop.lVal);
						
			dayprop = rs->GetValue("n_code");
			pHoliday->PutCode(dayprop.lVal);
		
			dayprop = rs->GetValue("n_day");
			pHoliday->PutDay(dayprop.lVal);

			dayprop = rs->GetValue("n_weekofmonth");
			pHoliday->PutWeekofMonth(dayprop.lVal);

			dayprop = rs->GetValue("n_month");
			pHoliday->PutMonth(dayprop.lVal);

			dayprop = rs->GetValue("n_year");
			pHoliday->PutYear(dayprop.lVal);

			// Get all calendar periods for this Holiday
			rs2->ClearQuery();
			rs2->SetQueryTag(L"__GET_CALENDAR_PERIODS__");
			rs2->AddParam(_bstr_t("%%DAY_ID%%"), pHoliday->GetID());
			rs2->Execute();
			nCount_rs2 = rs2->GetRecordCount();
			
			while(rs2->GetRowsetEOF().boolVal == VARIANT_FALSE)
			{
				pPeriod = pHoliday->CreatePeriod();
				
				periodprop = rs2->GetValue("id_period");
				pPeriod->PutID(periodprop.lVal);
				periodprop = rs2->GetValue("n_begin");
				pPeriod->PutStartTime(periodprop.lVal);
				periodprop = rs2->GetValue("n_end");
				pPeriod->PutEndTime(periodprop.lVal);
				periodprop = rs2->GetValue("n_code");
				pPeriod->PutCode(periodprop.lVal);

				rs2->MoveNext();
			}
			
			rs->MoveNext();
		}


		(*apCalendar) = (IMTCalendar*) pCalendar.Detach();
		PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "Calendar with id %d successfully loaded", aID);
	}
	catch(_com_error& e)
	{
			return ReturnComError(e);
	}
	
	context.Complete();
	
	return hr;
}
