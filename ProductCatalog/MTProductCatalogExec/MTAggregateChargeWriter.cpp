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

// MTAggregateChargeWriter.cpp : Implementation of CMTAggregateChargeWriter
#include "StdAfx.h"
#include "MTProductCatalogExec.h"
#include "MTAggregateChargeWriter.h"
#include "MTDiscountWriter.h"

#include <pcexecincludes.h>
#include <mtcomerr.h>

#include <vector>

#include "pcexecincludes.h"

/////////////////////////////////////////////////////////////////////////////
// CMTAggregateChargeWriter

/******************************************* error interface ***/
STDMETHODIMP CMTAggregateChargeWriter::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTAggregateChargeWriter
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTAggregateChargeWriter::Activate()
{
	HRESULT hr = GetObjectContext(&m_spObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTAggregateChargeWriter::CanBePooled()
{
	return FALSE;
} 

void CMTAggregateChargeWriter::Deactivate()
{
	m_spObjectContext.Release();
} 

STDMETHODIMP CMTAggregateChargeWriter::Create(IMTSessionContext* apCtxt, IMTAggregateCharge *apAggCharge)
{
	return RunDBInsertOrUpdateQuery(apCtxt, apAggCharge, "__INSERT_AGGREGATE_CHARGE_PROPERTIES_BY_ID__");
}

STDMETHODIMP CMTAggregateChargeWriter::Update(IMTSessionContext* apCtxt, IMTAggregateCharge *apAggCharge)
{
	MTAutoContext context(m_spObjectContext);

	try 
	{
		MTPRODUCTCATALOGLib::IMTAggregateChargePtr aggCharge(apAggCharge);

		if(aggCharge == NULL)
			return E_POINTER;

		long ID = aggCharge->ID;

		if(ID == 0)
			MT_THROW_COM_ERROR( MTPC_OBJECT_NO_STATE );

		_bstr_t stCycleUpdate = CMTPCCycleWriter::GetUpdateString(reinterpret_cast<IMTPCCycle*>(aggCharge->Cycle.GetInterfacePtr()));
		MTPRODUCTCATALOGLib::IMTPropertyPtr propCycle(aggCharge->Properties->GetItem("Cycle"));
		bool bCycleOverridable = (propCycle->Overrideable == VARIANT_TRUE);

		MTPRODUCTCATALOGLib::IMTProductCatalogPtr productCatalog(__uuidof(MTProductCatalog));
		MTPRODUCTCATALOGLib::IMTPropertyMetaDataSetPtr metaData = productCatalog->GetMetaData(aggCharge->Kind);
		
		if (aggCharge->IsTemplate() == VARIANT_TRUE)
		{
			// Update all properties in the template
			metaData->UpdateProperties(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(apCtxt), 
										 aggCharge->Properties,
									   VARIANT_FALSE, // VARIANT_BOOL aOverrideableOnly,
									   "t_aggregate",
									   stCycleUpdate
									   );

			// don't propagate cycle if it is overridable
			if(bCycleOverridable) 
				stCycleUpdate = "";
	

			// propagate properties to the instances
			metaData->PropagateProperties(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(apCtxt), aggCharge->Properties, "t_aggregate", stCycleUpdate);

			// update counters
			SaveCounters(apCtxt, apAggCharge);
		}
		else
		{
			// don't override cycle unless it is overridable
			if(!bCycleOverridable)
				stCycleUpdate = "";

			// update only overridable properties in the instance
			metaData->UpdateProperties(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(apCtxt), 
										 aggCharge->Properties,
									   VARIANT_TRUE, // VARIANT_BOOL aOverrideableOnly,
									   "t_aggregate",
									   stCycleUpdate);
		}
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();

	return S_OK;
}

STDMETHODIMP CMTAggregateChargeWriter::Remove(IMTSessionContext* apCtxt, long aID)
{
	MTAutoContext context(m_spObjectContext);

	try
	{
		long ID = aID;

		if(ID == 0)
			MT_THROW_COM_ERROR( MTPC_OBJECT_NO_STATE );

		RemoveCounters(apCtxt, ID);

		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		rowset->SetQueryTag("__DELETE_AGGREGATE_CHARGE_PROPERTIES_BY_ID__");
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

HRESULT CMTAggregateChargeWriter::RunDBInsertOrUpdateQuery(IMTSessionContext* apCtxt, IMTAggregateCharge *apAggCharge, LPCSTR lpQueryName) {
	MTAutoContext context(m_spObjectContext);

	try {
		MTPRODUCTCATALOGLib::IMTAggregateChargePtr aggCharge(apAggCharge);

		if (aggCharge == NULL)
			return E_POINTER;

		long ID = aggCharge->ID;
		if (ID == 0)
			MT_THROW_COM_ERROR( MTPC_OBJECT_NO_STATE );


		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		rowset->SetQueryTag(lpQueryName);
		rowset->AddParam("%%ID_PROP%%", ID);

		// save cycle information
		MTPRODUCTCATALOGLib::IMTPCCyclePtr cycle = aggCharge->Cycle;
		CMTPCCycleWriter::SaveCycleToRowset(reinterpret_cast<IMTPCCycle*>(cycle.GetInterfacePtr()),
																				reinterpret_cast<IMTSQLRowset*>(rowset.GetInterfacePtr()));

		rowset->Execute();

		SaveCounters(apCtxt, apAggCharge);
	}
	catch (_com_error & err) {return ReturnComError(err);	}

	context.Complete();
	return S_OK;
}

// throws
void CMTAggregateChargeWriter::SaveCounters(IMTSessionContext* apCtxt, IMTAggregateCharge *pAggCharge)
{
	MTPRODUCTCATALOGLib::IMTAggregateChargePtr aggCharge(pAggCharge);

	// we don't store counter mapping for instances.
	if(aggCharge->IsTemplate() == VARIANT_FALSE)
		return;

	// first remove all existing counter mapping
	MTPRODUCTCATALOGEXECLib::IMTCounterMapWriterPtr mapWriter( __uuidof(MTPRODUCTCATALOGEXECLib::MTCounterMapWriter));
	mapWriter->RemoveMappingByPIDBID(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), aggCharge->ID);

	// now save all the counters, and their mapping.

	// get CounterPropertyDefinition information;
	MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr AggregateChargeType = aggCharge->PriceableItemType;
	MTPRODUCTCATALOGEXECLib::IMTCollectionPtr counterPropertyDefinitions = AggregateChargeType->GetCounterPropertyDefinitions();

	int iCPDCount = counterPropertyDefinitions->Count;
	int i;

	// now iterate through counters and save them.
	for(i = 1; i <= iCPDCount; ++i)
	{
		// get CPD
		MTPRODUCTCATALOGLib::IMTCounterPropertyDefinitionPtr cpd = counterPropertyDefinitions->GetItem(i);
		long lCPDID = cpd->ID;
		// save the counter!
		SaveCounterAndMapping(apCtxt, pAggCharge, lCPDID);
	}

	// now go through counters to be removed, and remove them!
	MTPRODUCTCATALOGEXECLib::IMTCollectionPtr removedCounters = aggCharge->RemovedCounters;
	MTPRODUCTCATALOGEXECLib::IMTCounterWriterPtr counterWriter( __uuidof(MTPRODUCTCATALOGEXECLib::MTCounterWriter) );
	
	long lCount = removedCounters->Count;
	for(i = 1; i <= lCount; i++)
	{
		long lCounterID = removedCounters->GetItem(i);
		counterWriter->Remove(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), lCounterID);
	}

	// that's all, folks!
}


/////////////////////////////////////////////////////////////////////////////////////////
// FUNCTION		: CMTAggregateChargeWriter::SaveCounterAndMapping()
// DESCRIPTION	: Saves the counter and inserts it into the mapping table
// RETURN		: void
// ARGUMENTS	: IMTAggregateCharge *apAggCharge
// 				: long lCPDID
// EXCEPTIONS	: 
// COMMENTS		: 
// CREATED		: 5/2/2001, Michael A. Efimov
// MODIFIED		: 
//				: 
/////////////////////////////////////////////////////////////////////////////////////////
void CMTAggregateChargeWriter::SaveCounterAndMapping(IMTSessionContext* apCtxt, IMTAggregateCharge *apAggCharge, long lCPDID)
{
	MTPRODUCTCATALOGLib::IMTAggregateChargePtr aggCharge(apAggCharge);
	MTPRODUCTCATALOGLib::IMTCounterPtr Counter = aggCharge->GetCounter(lCPDID);
	MTPRODUCTCATALOGEXECLib::IMTCounterMapWriterPtr mapWriter( __uuidof(MTPRODUCTCATALOGEXECLib::MTCounterMapWriter));

	// if counter is specified, save it!
	if(Counter != NULL)
	{
		// save a counter
		Counter->Save();

		// insert a record into the mapping table
		mapWriter->AddMapping(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), Counter->ID, aggCharge->ID, lCPDID);
	}
}

// throws
/////////////////////////////////////////////////////////////////////////////////////////
// FUNCTION		: CMTAggregateChargeWriter::RemoveCounters()
// DESCRIPTION	: 
// RETURN		: void
// ARGUMENTS	: long lPIID
// EXCEPTIONS	: _com_error
// COMMENTS		: This method does not check, if item is an instance or a template,
//				: but instance does not have any mapped counters, so nothing will happen
// CREATED		: 5/25/2001, Michael A. Efimov
// MODIFIED		: 
//				: 
/////////////////////////////////////////////////////////////////////////////////////////
void CMTAggregateChargeWriter::RemoveCounters(IMTSessionContext* apCtxt, long lPIID)
{
	try 
	{
		// find information about associated counters
		MTPRODUCTCATALOGEXECLib::IMTCounterMapReaderPtr mapReader( __uuidof(MTPRODUCTCATALOGEXECLib::MTCounterMapReader));

		// use ID to find counters
		ROWSETLib::IMTSQLRowsetPtr rs = mapReader->GetPIMappingsAsRowset(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), lPIID);

		std::vector<long> counters;
		while(rs->GetRowsetEOF().boolVal == VARIANT_FALSE)
		{
			long lCounterID = rs->GetValue("id_counter");
			counters.push_back(lCounterID);
			rs->MoveNext();
		}

		rs.Release();

		// first remove all existing counter mapping
		MTPRODUCTCATALOGEXECLib::IMTCounterMapWriterPtr mapWriter( __uuidof(MTPRODUCTCATALOGEXECLib::MTCounterMapWriter));
		mapWriter->RemoveMappingByPIDBID(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), lPIID);

		// now remove all counters.
		MTPRODUCTCATALOGEXECLib::IMTCounterWriterPtr counterWriter( __uuidof(MTPRODUCTCATALOGEXECLib::MTCounterWriter) );

		for(std::vector<long>::iterator itCounter = counters.begin(); itCounter != counters.end(); ++itCounter)
		{
			counterWriter->Remove(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), *itCounter);
		}
	}
	catch (_com_error & err)
	{
		// return ReturnComError(err);
		(err);
		throw;
	}
}

