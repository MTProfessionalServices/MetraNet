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
#include "MTPCTimeSpanWriter.h"

#include <MTUtil.h>
#include <mtautocontext.h>


/////////////////////////////////////////////////////////////////////////////
// CMTPCTimeSpanWriter

/******************************************* error interface ***/
STDMETHODIMP CMTPCTimeSpanWriter::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTPCTimeSpanWriter
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

CMTPCTimeSpanWriter::CMTPCTimeSpanWriter()
{
	mpObjectContext = NULL;
}


HRESULT CMTPCTimeSpanWriter::Activate()
{
	HRESULT hr = GetObjectContext(&mpObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTPCTimeSpanWriter::CanBePooled()
{
	return FALSE;
} 

void CMTPCTimeSpanWriter::Deactivate()
{
	mpObjectContext.Release();
} 


//helper to convert a DATE to the correct database format
_variant_t CMTPCTimeSpanWriter::DateToDBParam(DATE aDate)
{
	_bstr_t dbParam;

	if (aDate == 0.0)
		dbParam = "NULL";
	else
	{	struct tm tmDest;
		wchar_t buffer[256];
		StructTmFromOleDate(&tmDest, aDate);
		
		// NOTE: use the ODBC escape sequence to work with Oracle and SQL Server
		// {ts 'yyyy-mm-dd hh:mm:ss'}
		wcsftime(buffer, 255, L"{ts \'%Y-%m-%d %H:%M:%S\'}", &tmDest);
		dbParam = buffer;
	}

	return dbParam;
}


STDMETHODIMP CMTPCTimeSpanWriter::Create(IMTSessionContext* apCtxt, IMTPCTimeSpan *apTimeSpan, long* apID)
{
	MTAutoContext context(mpObjectContext);

	if (!apTimeSpan)
		return E_POINTER;

	try
	{
		//use comptr for convenience
		MTPRODUCTCATALOGLib::IMTPCTimeSpanPtr timeSpan = apTimeSpan;

		//check for errors and normalize data
		timeSpan->Validate();

		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);

		//insert into base prop
		MTPRODUCTCATALOGEXECLib::IMTBasePropsWriterPtr baseWriter(__uuidof(MTBasePropsWriter));
		long idProp = baseWriter->Create( reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), (long)PCENTITY_TYPE_TIME_SPAN, "", "");

		// add to eff date
		rowset->SetQueryTag("_ADD_EFF_DATE__");

		rowset->AddParam("%%ID_EFFDATE%%", idProp);

		rowset->AddParam("%%STARTTYPE%%", static_cast<long>(timeSpan->StartDateType));
		
		_variant_t param;
		param = DateToDBParam( timeSpan->StartDate );
		rowset->AddParam("%%DTSTART%%", param, true); //do not validate string (needed quotes are already included)

		rowset->AddParam("%%BOFFSET%%", timeSpan->StartOffset);
		rowset->AddParam("%%ENDTYPE%%", static_cast<long>(timeSpan->EndDateType));

		param = DateToDBParam( timeSpan->EndDate );
		rowset->AddParam("%%DTEND%%", param, true); //do not validate string (needed quotes are already included)
		
		rowset->AddParam("%%ENDOFFSET%%", timeSpan->EndOffset);
		
		rowset->Execute();

		*apID = idProp;
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}

STDMETHODIMP CMTPCTimeSpanWriter::Update(IMTSessionContext* apCtxt, IMTPCTimeSpan *apTimeSpan)
{
	MTAutoContext context(mpObjectContext);

	if (!apTimeSpan)
		return E_POINTER;

	try
	{
		//use comptr for convenience
		MTPRODUCTCATALOGLib::IMTPCTimeSpanPtr timeSpan = apTimeSpan;

		//check for errors and normalize data
		timeSpan->Validate();

		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);

		rowset->SetQueryTag("__UPDATE_EFF_DATE__");

		rowset->AddParam("%%ID_EFF_DATE%%", timeSpan->ID);
		rowset->AddParam("%%BEGIN_TYPE%%", static_cast<long>(timeSpan->StartDateType));
		
		_variant_t param;
		param = DateToDBParam( timeSpan->StartDate );
		rowset->AddParam("%%START_DATE%%", param, true); //do not validate string (needed quotes are already included)
		
		rowset->AddParam("%%BEGIN_OFFSET%%", timeSpan->StartOffset);
		rowset->AddParam("%%END_TYPE%%", static_cast<long>(timeSpan->EndDateType));
		
		param = DateToDBParam( timeSpan->EndDate );
		rowset->AddParam("%%END_DATE%%", param, true); //do not validate string (needed quotes are already included)
		
		rowset->AddParam("%%END_OFFSET%%", timeSpan->EndOffset);
		rowset->Execute();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}


STDMETHODIMP CMTPCTimeSpanWriter::PropagateEndDateChange(IMTSessionContext* apCtxt, 
																												 long aProdOffID, 
																												 IMTPCTimeSpan *apTimeSpan)
{
	MTAutoContext context(mpObjectContext);

	if (!apTimeSpan)
		return E_POINTER;

	try
	{
		//use comptr for convenience
		MTPRODUCTCATALOGLib::IMTPCTimeSpanPtr timeSpan = apTimeSpan;

		// do nothing if the end date is NULL
		if (timeSpan->IsEndDateNull() == VARIANT_TRUE)
		{
			context.Complete();
			return S_OK;
		}

		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);

		rowset->SetQueryTag("__UPDATE_SUB_EFFECTIVEDATE_LIST_THROUGH_PO__");

		_variant_t param;

		param = DateToDBParam( timeSpan->EndDate );
		rowset->AddParam("%%END_DATE%%", param, true); //do not validate string (needed quotes are already included)
		rowset->AddParam("%%ID_PO%%", aProdOffID);

		rowset->Execute();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}


STDMETHODIMP CMTPCTimeSpanWriter::Remove(IMTSessionContext* apCtxt, long aID)
{
	MTAutoContext context(mpObjectContext);

	try
	{
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);

		rowset->SetQueryTag("DELETE_EFF_DATE");
		rowset->AddParam("%%ID_EFF_DATE%%", aID);
		rowset->Execute();

		MTPRODUCTCATALOGEXECLib::IMTBasePropsWriterPtr baseWriter(__uuidof(MTBasePropsWriter));
		baseWriter->Delete(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt),
											 aID);
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}
