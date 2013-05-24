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

// MTAggregateChargeReader.cpp : Implementation of CMTAggregateChargeReader
#include "StdAfx.h"
#include "MTProductCatalogExec.h"
#include "MTAggregateChargeReader.h"
#include "MTDiscountReader.h"

#include <pcexecincludes.h>
#include <mtcomerr.h>

#include "pcexecincludes.h"

/////////////////////////////////////////////////////////////////////////////
// CMTAggregateChargeReader

/******************************************* error interface ***/
STDMETHODIMP CMTAggregateChargeReader::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTAggregateChargeReader
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTAggregateChargeReader::Activate()
{
	HRESULT hr = GetObjectContext(&m_spObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTAggregateChargeReader::CanBePooled()
{
	return FALSE;
} 

void CMTAggregateChargeReader::Deactivate()
{
	m_spObjectContext.Release();
} 

STDMETHODIMP CMTAggregateChargeReader::FindCountersAsRowset(IMTSessionContext* apCtxt, /*[in]*/long aAggregateChargeDBID, /*[out, retval]*/IMTSQLRowset** apRowset)
{
	MTAutoContext context(m_spObjectContext);

	try {
		MTPRODUCTCATALOGLib::IMTProductCatalogPtr catalog( __uuidof(MTPRODUCTCATALOGLib::MTProductCatalog));
		MTPRODUCTCATALOGLib::IMTAggregateChargePtr aggCharge = catalog->GetPriceableItem(aAggregateChargeDBID);

		MTPRODUCTCATALOGEXECLib::IMTCounterMapReaderPtr mapReader( __uuidof(MTPRODUCTCATALOGEXECLib::MTCounterMapReader));
		ROWSETLib::IMTSQLRowsetPtr rowset = mapReader->GetExtendedPIMappingsAsRowset(
				reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), 
				aAggregateChargeDBID,
				aggCharge->PriceableItemType->ID);

		*apRowset = reinterpret_cast<IMTSQLRowset*>(rowset.Detach());
	} 
	catch (_com_error & err) { return ReturnComError(err);}

	context.Complete();

	return S_OK;
}

STDMETHODIMP CMTAggregateChargeReader::Populate(IMTSessionContext* apCtxt, IMTAggregateCharge *pAggCharge)
{
	MTAutoContext context(m_spObjectContext);

	try {
		MTPRODUCTCATALOGLib::IMTAggregateChargePtr aggCharge(pAggCharge);

		if(aggCharge == NULL)
			return E_POINTER;

		long ID = aggCharge->ID;

		if(ID == 0)
			MT_THROW_COM_ERROR( MTPC_OBJECT_NO_STATE );


		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		rowset->SetQueryTag("__GET_AGGREGATE_CHARGE_PROPERTIES_BY_ID__");
		rowset->AddParam("%%ID_PROP%%", ID);

		rowset->Execute();

		if(rowset->GetRecordCount() == 0)
			MT_THROW_COM_ERROR(MTPC_ITEM_NOT_FOUND_BY_ID, PCENTITY_TYPE_AGGREGATE_CHARGE, ID);

		//loads the cycle
		MTPRODUCTCATALOGLib::IMTPCCyclePtr cycle = aggCharge->Cycle;
		CMTPCCycleReader::LoadCycleFromRowset(reinterpret_cast<IMTPCCycle*>(cycle.GetInterfacePtr()),
																					reinterpret_cast<IMTSQLRowset*>(rowset.GetInterfacePtr()));

		//loads counters
		LoadCounters(apCtxt, pAggCharge);
	}
	catch (_com_error & err) { return ReturnComError(err); }

	context.Complete();

	return S_OK;
}

void CMTAggregateChargeReader::LoadCounters(IMTSessionContext* apCtxt, IMTAggregateCharge *pAggCharge) {
	MTPRODUCTCATALOGLib::IMTAggregateChargePtr aggCharge(pAggCharge);

	// find information about associated counters
	MTPRODUCTCATALOGEXECLib::IMTCounterMapReaderPtr mapReader( __uuidof(MTPRODUCTCATALOGEXECLib::MTCounterMapReader));

	// use template ID to find counter map
	long lAggregateChargeID = aggCharge->IsTemplate() ? aggCharge->ID : aggCharge->ParentID;

	ROWSETLib::IMTSQLRowsetPtr rowset = mapReader->GetPIMappingsAsRowset(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), aggCharge->ID);

	MTPRODUCTCATALOGLib::IMTProductCatalogPtr catalog( __uuidof(MTPRODUCTCATALOGLib::MTProductCatalog));

	while(rowset->GetRowsetEOF().boolVal == VARIANT_FALSE) {
		long iCPDID = rowset->GetValue("id_cpd");
		long iCounterID = rowset->GetValue("id_counter");

		// create and load new counter by ID
		MTPRODUCTCATALOGLib::IMTCounterPtr counter = catalog->GetCounter(iCounterID);

		// attach it to the AggregateCharge
		aggCharge->SetCounter(iCPDID, counter);

		rowset->MoveNext();
	}
}
