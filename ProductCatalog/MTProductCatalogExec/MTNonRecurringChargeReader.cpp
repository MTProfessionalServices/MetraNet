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
// MTNonRecurringChargeReader.cpp : Implementation of CMTNonRecurringChargeReader
#include "StdAfx.h"
#include "MTProductCatalogExec.h"
#include "MTNonRecurringChargeReader.h"

#include <pcexecincludes.h>
#include <mtcomerr.h>


/////////////////////////////////////////////////////////////////////////////
// CMTNonRecurringChargeReader

/******************************************* error interface ***/
STDMETHODIMP CMTNonRecurringChargeReader::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTNonRecurringChargeReader
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTNonRecurringChargeReader::Activate()
{
	HRESULT hr = GetObjectContext(&m_spObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTNonRecurringChargeReader::CanBePooled()
{
	return FALSE;
} 

void CMTNonRecurringChargeReader::Deactivate()
{
	m_spObjectContext.Release();
} 


/////////////////////////////////////////////////////////////////////////////////////////
// FUNCTION		: CMTNonRecurringChargeReader::PopulateNRCProperties()
// DESCRIPTION	: this method reads NRC-specific properties from the database. piNRC should
//				: have base properties prepopulated
// RETURN		: STDMETHODIMP
// ARGUMENTS	: IMTNonRecurringCharge *piNRC
// EXCEPTIONS	: 
// COMMENTS		: 
// CREATED		: 4/30/2001, Michael A. Efimov
// MODIFIED		: 
//				: 
/////////////////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CMTNonRecurringChargeReader::PopulateNRCProperties(IMTSessionContext* apCtxt, IMTNonRecurringCharge *piNRC)
{
	MTAutoContext context(m_spObjectContext);

	try
	{
		MTPRODUCTCATALOGLib::IMTNonRecurringChargePtr pNRC(piNRC);

		if(pNRC == NULL)
			return E_POINTER;

		long ID = pNRC->ID;

		if(ID == 0)
			MT_THROW_COM_ERROR( MTPC_OBJECT_NO_STATE );


		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		rowset->SetQueryTag("__GET_NON_RECURRING_CHARGE_PROPERTIES_BY_ID__");
		rowset->AddParam("%%ID_PROP%%", ID);

		rowset->Execute();

		if(0 == rowset->GetRecordCount())
			MT_THROW_COM_ERROR(MTPC_ITEM_NOT_FOUND_BY_ID, PCENTITY_TYPE_NON_RECURRING, ID);

		// get event type
		long lEvent = rowset->GetValue("n_event_type");

		// check event type for validity
		if((lEvent < NREVENT_TYPE_MIN) || (lEvent > NREVENT_TYPE_MAX))
			MT_THROW_COM_ERROR( MTPC_INVALID_PROPERTY );

		pNRC->NonRecurringChargeEvent = static_cast<MTPRODUCTCATALOGLib::MTNonRecurringEventType>(lEvent);
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();

	return S_OK;
}
