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

// MTCalendarWriter.cpp : Implementation of CMTCalendarWriter
#include "StdAfx.h"

#include <metra.h>
#include <mtprogids.h>
#include <comdef.h>
#include <mtcomerr.h>

#include "MTProductCatalogExec.h"
#include "MTCalendarWriter.h"
#include <RowsetDefs.h>

#include <mtautocontext.h>

#include "pcexecincludes.h"


/////////////////////////////////////////////////////////////////////////////
// CMTCalendarWriter

/******************************************* error interface ***/
STDMETHODIMP CMTCalendarWriter::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTCalendarWriter
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTCalendarWriter::Activate()
{
	HRESULT hr = GetObjectContext(&m_spObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTCalendarWriter::CanBePooled()
{
	return TRUE;
} 

void CMTCalendarWriter::Deactivate()
{
	m_spObjectContext.Release();
} 

// ----------------------------------------------------------------
// Name: Save    	
// Arguments:   IMTSessionContext, IMTCalendar
//                
// Return Value: 
// Errors Raised: 
// Description:   First this method will call DeleteCalendarConfiguration to remove this 
//										calendar from the database, if it already exists. Then it
//										will save the calendar again. It needs to delete the calendar
//										first because it is hard to detect which parts of it
//										have changed
// ----------------------------------------------------------------
STDMETHODIMP CMTCalendarWriter::Save(IMTSessionContext* apCtxt, IMTCalendar * apCalendar)
{

	HRESULT hr = S_OK;
	MTAutoContext context(m_spObjectContext);
	MTPRODUCTCATALOGLib::IMTCalendarPtr pCal = apCalendar;

	try
		{
			// The first step is to validate the calendar
			pCal->Validate();

			ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
			rowset->Init(CONFIG_DIR);
		
			MTPRODUCTCATALOGEXECLib::IMTBasePropsWriterPtr baseWriter(__uuidof(MTBasePropsWriter));
			// determine if this is an add or an update
			if (pCal->ID != 0L)
				{
					baseWriter->Update(MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr(apCtxt),
														 pCal->Name, pCal->Description, pCal->ID);
					
					// Let's update the other calendar properties
					rowset->ClearQuery();
					rowset->SetQueryTag("__UPDATE_CALENDAR__");
					rowset->AddParam(L"%%ID_CAL%%", pCal->ID);
					rowset->AddParam(L"%%TZOFFSET%%", pCal->TimezoneOffset);
					_bstr_t c_weekend;
					if (pCal->CombinedWeekend)
						c_weekend = "T";
					else
						c_weekend = "F";
					rowset->AddParam(L"%%BCOMBWEEKEND%%", c_weekend);
					rowset->Execute();
				}
			else
				{
					// insert into t_base_prop
					long idProp = baseWriter->Create(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), PCENTITY_TYPE_CALENDAR, pCal->Name, pCal->Description);
			
					// insert into t_calendar
					rowset->ClearQuery();
					rowset->SetQueryTag("__ADD_CALENDAR__");
					rowset->AddParam("%%ID_CAL%%", idProp);
					rowset->AddParam("%%TZOFFSET%%", pCal->TimezoneOffset);
					rowset->AddParam("%%BCOMBWEEKEND%%", pCal->CombinedWeekend);

					rowset->Execute();

					pCal->PutID(idProp);
				}

			// Delete all information about this calendar
			hr = DeleteCalendarConfiguration(apCalendar);
			if (FAILED(hr))
				return hr;
			// Insert all (holi and week) days, and corresponding time periods
			hr = InsertCalendarConfiguration(apCalendar);
		}
	catch (_com_error & err)
		{
			return ReturnComError(err);
		}
	
	context.Complete();
	PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "Calendar successfully saved with id = %d", pCal->ID);
	return hr;
}

// ----------------------------------------------------------------
// Name: DeleteCalendarConfiguration    	
// Arguments: IMTCalendar
//                
// Return Value: 
// Errors Raised: 
// Description: Deletes a calendar from the database. Mainly as the first
//									step before re-saving it								  
// ----------------------------------------------------------------
STDMETHODIMP CMTCalendarWriter::DeleteCalendarConfiguration(IMTCalendar* apCal)
{
	HRESULT hr = S_OK;
	MTPRODUCTCATALOGLib::IMTCalendarHolidayPtr pHoliday;
	MTPRODUCTCATALOGLib::IMTCalendarWeekdayPtr pWeekday;
	MTPRODUCTCATALOGLib::IMTCalendarPeriodPtr pPeriod;
	MTPRODUCTCATALOGLib::IMTCollectionPtr col;
	
	// Put the calendar into a smart pointer, makes it easier to handle
	MTPRODUCTCATALOGLib::IMTCalendarPtr pCal = apCal;

	// Declare & initialize the rowset
	ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
	ROWSETLib::IMTSQLRowsetPtr rowset2(MTPROGID_SQLROWSET);
	rowset->Init(CONFIG_DIR);
	rowset2->Init(CONFIG_DIR);

	_variant_t dayprop, dayprop2;

	// For each calendar weekday included in this calendar
	//		-delete all calendar periods of it
	//		-if it is a holiday, then delete the t_calendar_holiday row that references it
	// End
	// Delete all calendar (week and holi) days for this calendar id

	try
	{		
		col = pCal->GetWeekdays();
	
		// Retrieve all days linked to this calendar
		rowset->ClearQuery();
		rowset->SetQueryTag(L"__GET_CALENDAR_DAYS__");
		rowset->AddParam(L"%%CALENDAR_ID%%", pCal->GetID());
		rowset->Execute();
		
		// For each calendar day, remove all periods associated with it
		while (rowset->GetRowsetEOF().boolVal == VARIANT_FALSE)
			{
				dayprop = rowset->GetValue("id_day");
				dayprop2 = rowset->GetValue("n_weekday");
				rowset->MoveNext();
				// Call DeletePeriods for each day
				hr = DeleteDayPeriods(dayprop.lVal);
				if (FAILED(hr))
					return hr;

				if (dayprop2.vt == VT_NULL)
					{
						rowset2->ClearQuery();
						rowset2->SetQueryTag(L"__DELETE_CALENDAR_HOLIDAY__");
						rowset2->AddParam(L"%%DAY_ID%%", dayprop.lVal);
						rowset2->Execute();			
					}
			}
		
		// Then remove all days in this calendar
		rowset->ClearQuery();
		rowset->SetQueryTag(L"__DELETE_CALENDAR_DAYS__");
		rowset->AddParam(L"%%CALENDAR_ID%%", pCal->GetID());
		rowset->Execute();

	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}
	
	PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "Calendar successfully deleted", pCal->ID);
	return hr;
}

STDMETHODIMP CMTCalendarWriter::DeleteDayPeriods(long day_id)
{
	HRESULT hr = S_OK;
	ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);

	try
		{
			rowset->Init(CONFIG_DIR);
			rowset->ClearQuery();
			rowset->SetQueryTag(L"__DELETE_CALENDAR_PERIODS__");
			rowset->AddParam(L"%%DAY_ID%%", day_id);
			rowset->Execute();
		}
	catch (_com_error & err)
		{
			return LogAndReturnComError(PCCache::GetLogger(),err);
		}

	return hr;
}

// ----------------------------------------------------------------
// Name: InsertCalendarConfiguration    	
// Arguments: IMTCalendar
//                
// Return Value: 
// Errors Raised: 
// Description: Driver to save the calendar to the database			  
// ----------------------------------------------------------------
STDMETHODIMP CMTCalendarWriter::InsertCalendarConfiguration(IMTCalendar *apCal)
{	
	HRESULT hr = S_OK;
	ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
	
	MTPRODUCTCATALOGLib::IMTCalendarPtr pCal = apCal;
	MTPRODUCTCATALOGLib::IMTCalendarWeekdayPtr pWday;
	MTPRODUCTCATALOGLib::IMTCalendarHolidayPtr pHday;
	MTPRODUCTCATALOGLib::IMTCollectionPtr pCol;

	// For each weekday in this calendar
	//		-insert it
	//		For each period in this weekday
	//			-insert it with the identity return value
	//		End
	// End	
	// For each holiday in this calendar
	//		-insert it
	//		For each period in this holiday
	//			-insert it with the identity return value
	//		End
	// End

	_variant_t dayprop;
	rowset->Init(CONFIG_DIR);

	// Adding Weekdays
	try
		{
			pCol = pCal->GetWeekdays();
			for (long i = 1; i <= pCol->GetCount(); i++)
				{
					pWday = pCol->GetItem(i);
					rowset->ClearQuery();
					rowset->InitializeForStoredProc("AddCalendarWeekday");
					rowset->AddInputParameterToStoredProc (	"id_calendar", MTTYPE_INTEGER, INPUT_PARAM, pCal->GetID());
					rowset->AddInputParameterToStoredProc (	"n_weekday", MTTYPE_INTEGER, INPUT_PARAM, pWday->GetDayofWeek());
					rowset->AddInputParameterToStoredProc (	"n_code", MTTYPE_INTEGER, INPUT_PARAM, pWday->GetCode());			
					rowset->AddOutputParameterToStoredProc ("id_day", MTTYPE_INTEGER, OUTPUT_PARAM);
					rowset->ExecuteStoredProc();

					// The the newly inserted identity value, set it in the weekday object
					dayprop = rowset->GetParameterFromStoredProc("id_day");
					pWday->PutID(dayprop.lVal);
					
					hr = InsertDayPeriods(pWday->GetPeriods(), pWday->GetID());
					if (FAILED(hr))
						return hr;
				}
		}
	catch (_com_error & err)
		{
			return LogAndReturnComError(PCCache::GetLogger(),err);
		}

	// Adding Holidays
	try
		{
			_variant_t vtNULL = "NULL";
			vtNULL.vt = VT_NULL;

			pCol = pCal->GetHolidays();
			for (long i = 1; i <= pCol->GetCount(); i++)
				{
					pHday = pCol->GetItem(i);
					rowset->ClearQuery();
					rowset->InitializeForStoredProc("AddCalendarHoliday");

					rowset->AddInputParameterToStoredProc (	"id_calendar", MTTYPE_INTEGER, INPUT_PARAM, pCal->GetID());
					rowset->AddInputParameterToStoredProc (	"n_code", MTTYPE_INTEGER, INPUT_PARAM, pHday->GetCode());
					rowset->AddInputParameterToStoredProc (	"nm_name", MTTYPE_VARCHAR, INPUT_PARAM, pHday->GetName());
					rowset->AddInputParameterToStoredProc (	"n_day", MTTYPE_INTEGER, INPUT_PARAM, pHday->GetDay());
					// n_weekday in t_calendar_day is null when that particular day is a holiday
					rowset->AddInputParameterToStoredProc (	"n_weekday", MTTYPE_INTEGER, INPUT_PARAM, vtNULL);

					if (pHday->GetWeekofMonth() == NULL)
						{
							rowset->AddInputParameterToStoredProc (	"n_weekofmonth", MTTYPE_INTEGER, INPUT_PARAM, vtNULL);
						}
					else
						{
							rowset->AddInputParameterToStoredProc (	"n_weekofmonth", MTTYPE_INTEGER, INPUT_PARAM, pHday->GetWeekofMonth());
						}
					rowset->AddInputParameterToStoredProc (	"n_month", MTTYPE_INTEGER, INPUT_PARAM, pHday->GetMonth());
					rowset->AddInputParameterToStoredProc (	"n_year", MTTYPE_INTEGER, INPUT_PARAM, pHday->GetYear());
					rowset->AddOutputParameterToStoredProc ("id_day", MTTYPE_INTEGER, OUTPUT_PARAM);
					rowset->ExecuteStoredProc();

					// The the newly inserted identity value, set it in the weekday object
					dayprop = rowset->GetParameterFromStoredProc("id_day");
					pHday->PutID(dayprop.lVal);
					PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "	CMTCalendarWriter::Save | Retrieving output param = (%d)", pHday->GetID());

					hr = InsertDayPeriods(pHday->GetPeriods(), pHday->GetID());
					if (FAILED(hr))
						return hr;
				}
		}
	catch (_com_error & err)
		{
			return LogAndReturnComError(PCCache::GetLogger(),err);
		}

	return hr;	
}

// ----------------------------------------------------------------
// Name: InsertDayPeriods
// Arguments: IMTCollectionPtr, day_id
//                
// Return Value: 
// Errors Raised: 
// Description:  Inserts period collection in the database for a given calendar day
// ----------------------------------------------------------------
STDMETHODIMP CMTCalendarWriter::InsertDayPeriods(MTPRODUCTCATALOGLib::IMTCollectionPtr& apCol, long day_id)
{
	HRESULT hr = S_OK;
	ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
	rowset->Init(CONFIG_DIR);
 
	MTPRODUCTCATALOGLib::IMTCalendarPeriodPtr pPeriod;
	MTPRODUCTCATALOGLib::IMTCalendarPeriodPtr lastPeriod;
	_variant_t periodprop;

	

	try
		{
			long i = 1;
			while (i <= apCol->GetCount())
				{		
					pPeriod = apCol->GetItem(i);
					// Last item to compare
					if (i > 1)
						lastPeriod = apCol->GetItem(i-1);
					else
						lastPeriod = apCol->GetItem(1);

					// First error check: does this period have a positive duration?
					if ((pPeriod->StartTime) > (pPeriod->EndTime))
						{
							PCCache::GetLogger().LogVarArgs(LOG_ERROR, "Calendar period start time must be before end time. Start = %s, End = %s", pPeriod->StartTimeAsString, pPeriod->EndTimeAsString);
							MT_THROW_COM_ERROR(IID_IMTCalendarWriter, MTPCUSER_PERIODSTART_MUSTBE_BEFORE_PERIODEND);
						}
					// Second error check: does this period overlap the previous period? (Note that this collection is sorted!)
					else if (((pPeriod->StartTime) < (lastPeriod->EndTime)) && (pPeriod != lastPeriod))
						{
							// TODO : return custom error
							PCCache::GetLogger().LogVarArgs(LOG_ERROR, "Calendar period with StartTime = %s, EndTime = %s overlaps another with StartTime = %s, EndTime = %s", (const char*) pPeriod->StartTimeAsString, (const char*) pPeriod->EndTimeAsString, (const char*) lastPeriod->StartTimeAsString, (const char*) lastPeriod->EndTimeAsString);
							MT_THROW_COM_ERROR(IID_IMTCalendarWriter, MTPCUSER_PERIODS_OVERLAP);
						}
					rowset->ClearQuery();
					rowset->InitializeForStoredProc("AddCalendarPeriod");
					rowset->AddInputParameterToStoredProc (	"id_day", MTTYPE_INTEGER, INPUT_PARAM, day_id);
					rowset->AddInputParameterToStoredProc (	"n_begin", MTTYPE_INTEGER, INPUT_PARAM, pPeriod->GetStartTime());			
					rowset->AddInputParameterToStoredProc (	"n_end", MTTYPE_INTEGER, INPUT_PARAM, pPeriod->GetEndTime());
					rowset->AddInputParameterToStoredProc (	"n_code", MTTYPE_INTEGER, INPUT_PARAM, pPeriod->GetCode());
					// Output param : period identity
					rowset->AddOutputParameterToStoredProc ("id_period", MTTYPE_INTEGER, OUTPUT_PARAM);
					rowset->ExecuteStoredProc();
					periodprop = rowset->GetParameterFromStoredProc("id_period");
					pPeriod->PutID(periodprop.lVal);
					// Save the last period for overlap check
					i++;
				}
		}
	catch (_com_error & err)
		{
			return LogAndReturnComError(PCCache::GetLogger(),err);
		}

	return hr;
}
