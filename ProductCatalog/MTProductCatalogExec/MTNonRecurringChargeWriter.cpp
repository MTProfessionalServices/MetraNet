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
// MTNonRecurringChargeWriter.cpp : Implementation of CMTNonRecurringChargeWriter
#include "StdAfx.h"
#include "MTProductCatalogExec.h"
#include "MTNonRecurringChargeWriter.h"

#include <pcexecincludes.h>
#include <mtcomerr.h>

#import <MTProductCatalog.tlb> rename ("EOF", "RowsetEOF") 

/////////////////////////////////////////////////////////////////////////////
// CMTNonRecurringChargeWriter

/******************************************* error interface ***/
STDMETHODIMP CMTNonRecurringChargeWriter::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTNonRecurringChargeWriter
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTNonRecurringChargeWriter::Activate()
{
	HRESULT hr = GetObjectContext(&m_spObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTNonRecurringChargeWriter::CanBePooled()
{
	return FALSE;
} 

void CMTNonRecurringChargeWriter::Deactivate()
{
	m_spObjectContext.Release();
} 


STDMETHODIMP CMTNonRecurringChargeWriter::CreateProperties(IMTSessionContext* apCtxt, IMTNonRecurringCharge *apNRC)
{
	return RunDBInsertOrUpdateQuery(apNRC, "__INSERT_NRC_PROPERTIES_BY_ID__");
}

STDMETHODIMP CMTNonRecurringChargeWriter::UpdateProperties(IMTSessionContext* apCtxt, IMTNonRecurringCharge *apNRC)
{
	MTAutoContext context(m_spObjectContext);

	try 
	{
		MTPRODUCTCATALOGLib::IMTNonRecurringChargePtr pNRC(apNRC);

		if(pNRC == NULL)
			return E_POINTER;

		long ID = pNRC->ID;

		if(ID == 0)
			MT_THROW_COM_ERROR( MTPC_OBJECT_NO_STATE );

		MTPRODUCTCATALOGLib::IMTProductCatalogPtr productCatalog(__uuidof(MTProductCatalog));
		MTPRODUCTCATALOGLib::IMTPropertyMetaDataSetPtr metaData = productCatalog->GetMetaData(pNRC->Kind);

		if (pNRC->IsTemplate() == VARIANT_TRUE)
		{
			// Update all properties in the template
			metaData->UpdateProperties(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(apCtxt), 
										 pNRC->Properties,
									   VARIANT_FALSE, // VARIANT_BOOL aOverrideableOnly,
									   "t_nonrecur",
									   ""
									   );

			// propagate properties to the instances
			metaData->PropagateProperties(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(apCtxt), pNRC->Properties, "t_nonrecur", "");
		}
		else
		{
			// update only overridable properties in the instance
			metaData->UpdateProperties(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(apCtxt), 
									   pNRC->Properties,
									   VARIANT_TRUE, // VARIANT_BOOL aOverrideableOnly,
									   "t_nonrecur",
									   ""
									   );
		}
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();

	return S_OK;
}

STDMETHODIMP CMTNonRecurringChargeWriter::RemoveProperties(IMTSessionContext* apCtxt, long lDBID)
{
	MTAutoContext context(m_spObjectContext);

	try
	{
		long ID = lDBID;

		if(ID == 0)
			MT_THROW_COM_ERROR( MTPC_OBJECT_NO_STATE );


		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		rowset->SetQueryTag("__DELETE_NRC_PROPERTIES_BY_ID__");
		rowset->AddParam("%%ID_PROP%%", ID);

		rowset->Execute();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();

	return S_OK;
}

HRESULT CMTNonRecurringChargeWriter::RunDBInsertOrUpdateQuery(IMTNonRecurringCharge  *apNRC, LPCSTR lpQueryName)
{
	MTAutoContext context(m_spObjectContext);

	try
	{
		MTPRODUCTCATALOGLib::IMTNonRecurringChargePtr pNRC(apNRC);

		if(pNRC == NULL)
			return E_POINTER;

		long ID = pNRC->ID;

		if(ID == 0)
			MT_THROW_COM_ERROR( MTPC_OBJECT_NO_STATE );


		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		rowset->SetQueryTag(lpQueryName);
		rowset->AddParam("%%ID_PROP%%", ID);

		// get value type
		long lEvent = pNRC->NonRecurringChargeEvent;

		// check value type for validity
		if((lEvent < NREVENT_TYPE_MIN) || (lEvent > NREVENT_TYPE_MAX))
			MT_THROW_COM_ERROR( MTPC_INVALID_PROPERTY );

		rowset->AddParam("%%N_EVENT_TYPE%%", lEvent);

		rowset->Execute();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();

	return S_OK;
}
