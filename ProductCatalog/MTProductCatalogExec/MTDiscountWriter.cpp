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

// MTDiscountWriter.cpp : Implementation of CMTDiscountWriter
#include "StdAfx.h"
#include "MTProductCatalogExec.h"
#include "MTDiscountWriter.h"

#include <pcexecincludes.h>
#include <mtcomerr.h>
#include <vector>

#include "pcexecincludes.h"

/////////////////////////////////////////////////////////////////////////////
// CMTDiscountWriter

/******************************************* error interface ***/
STDMETHODIMP CMTDiscountWriter::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTDiscountWriter
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTDiscountWriter::Activate()
{
	HRESULT hr = GetObjectContext(&m_spObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTDiscountWriter::CanBePooled()
{
	return FALSE;
} 

void CMTDiscountWriter::Deactivate()
{
	m_spObjectContext.Release();
} 


STDMETHODIMP CMTDiscountWriter::AddCounterMap(IMTSessionContext* apCtxt, long aDiscountDBID, long aCounterDBID, BSTR aDescriptor)
{
	HRESULT hr(S_OK);

	return hr;
}

STDMETHODIMP CMTDiscountWriter::RemoveCounterMap(IMTSessionContext* apCtxt, long aDiscountDBID, long aCounterDBID, BSTR aDescriptor)
{
	HRESULT hr(S_OK);

	return hr;
}

STDMETHODIMP CMTDiscountWriter::CreateDiscountProperties(IMTSessionContext* apCtxt, IMTDiscount *apDiscount)
{
	return RunDBInsertOrUpdateQuery(apCtxt, apDiscount, "__INSERT_DISCOUNT_PROPERTIES_BY_ID__");
}

STDMETHODIMP CMTDiscountWriter::UpdateDiscountProperties(IMTSessionContext* apCtxt, IMTDiscount *apDiscount)
{
	MTAutoContext context(m_spObjectContext);

	try 
	{
		MTPRODUCTCATALOGLib::IMTDiscountPtr pDiscount(apDiscount);

		if(pDiscount == NULL)
			MT_THROW_COM_ERROR(E_POINTER);

		long ID = pDiscount->ID;

		if(ID == 0)
			MT_THROW_COM_ERROR(MTPC_OBJECT_NO_STATE);

		PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTDiscountWriter::UpdateDiscountProperties(%d)", ID);

		_bstr_t stDiscountCycleUpdate = CMTPCCycleWriter::GetUpdateString(reinterpret_cast<IMTPCCycle*>(pDiscount->Cycle.GetInterfacePtr()));
		MTPRODUCTCATALOGLib::IMTPropertyPtr propCycle(pDiscount->Properties->GetItem("Cycle"));

		bool bCycleOverridable = (propCycle->Overrideable == VARIANT_TRUE);

		PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTDiscountWriter::UpdateDiscountProperties(%d): Cycle %s overridable", ID, bCycleOverridable ? "is" : "is not");

		MTPRODUCTCATALOGLib::IMTProductCatalogPtr productCatalog(__uuidof(MTProductCatalog));
		MTPRODUCTCATALOGLib::IMTPropertyMetaDataSetPtr metaData = productCatalog->GetMetaData(pDiscount->Kind);

		if (pDiscount->IsTemplate() == VARIANT_TRUE)
		{
			PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTDiscountWriter::UpdateDiscountProperties(%d): Update template", ID);

			// Update all properties in the template
			metaData->UpdateProperties(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(apCtxt), 
										 pDiscount->Properties,
									   VARIANT_FALSE, // VARIANT_BOOL aOverrideableOnly,
									   "t_discount",
									   stDiscountCycleUpdate
									   );

			// don't propagate cycle if it is overridable
			if(bCycleOverridable)
			{
				stDiscountCycleUpdate = "";
			}
			else
			{
				PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTDiscountWriter::UpdateDiscountProperties(%d): Update cycle: [%s]", ID, LPCSTR(stDiscountCycleUpdate));
			}

			PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTDiscountWriter::UpdateDiscountProperties(%d): Propagate template properties", ID);

			// propagate properties to the instances
			metaData->PropagateProperties(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(apCtxt), pDiscount->Properties, "t_discount", stDiscountCycleUpdate);

			PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTDiscountWriter::UpdateDiscountProperties(%d): Save template counters", ID);

			// update counters
			SaveCounters(apCtxt, apDiscount);
		}
		else
		{
			PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTDiscountWriter::UpdateDiscountProperties(%d): Update instance", ID);

			// don't override cycle unless it is overridable
			if(!bCycleOverridable)
			{
				stDiscountCycleUpdate = "";
			}
			else
			{
				PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTDiscountWriter::UpdateDiscountProperties(%d): Update cycle: [%s]", ID, LPCSTR(stDiscountCycleUpdate ));
			}


			// update only overridable properties in the instance
			metaData->UpdateProperties(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(apCtxt), 
										 pDiscount->Properties,
									   VARIANT_TRUE, // VARIANT_BOOL aOverrideableOnly,
									   "t_discount",
									   stDiscountCycleUpdate
									   );
		}
	}
	catch (_com_error & err)
	{
		PCCache::GetLogger().LogVarArgs(LOG_ERROR, "CMTDiscountWriter::UpdateDiscountProperties() caught error 0x%08h", err.Error());
		return ReturnComError(err);
	}

	context.Complete();

	return S_OK;

}

STDMETHODIMP CMTDiscountWriter::RemoveDiscountProperties(IMTSessionContext* apCtxt, long aID)
{
	MTAutoContext context(m_spObjectContext);

	try
	{
		long ID = aID;

		if(ID == 0)
			MT_THROW_COM_ERROR(MTPC_OBJECT_NO_STATE);

		PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTDiscountWriter::RemoveDiscountProperties(%d)", ID);

		RemoveCounters(apCtxt, ID);

		PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTDiscountWriter::RemoveDiscountProperties(%d): removed counters", ID);

		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		rowset->SetQueryTag("__DELETE_DISCOUNT_PROPERTIES_BY_ID__");
		rowset->AddParam("%%ID_PROP%%", ID);

		rowset->Execute();

		PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTDiscountWriter::RemoveDiscountProperties(%d): success", ID);
	}
	catch (_com_error & err)
	{
		PCCache::GetLogger().LogVarArgs(LOG_ERROR, "CMTDiscountWriter::RemoveDiscountProperties() caught error 0x%08h", err.Error());
		return ReturnComError(err);
	}

	context.Complete();

	return S_OK;
}

HRESULT CMTDiscountWriter::RunDBInsertOrUpdateQuery(IMTSessionContext* apCtxt, IMTDiscount *apDiscount, LPCSTR lpQueryName)
{
	MTAutoContext context(m_spObjectContext);

	try
	{
		MTPRODUCTCATALOGLib::IMTDiscountPtr pDiscount(apDiscount);

		if(pDiscount == NULL)
			MT_THROW_COM_ERROR(E_POINTER);

		long ID = pDiscount->ID;

		if(ID == 0)
			MT_THROW_COM_ERROR(MTPC_OBJECT_NO_STATE);

		PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTDiscountWriter::RunDBInsertOrUpdateQuery(%d, %s)", ID, lpQueryName);

		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		rowset->SetQueryTag(lpQueryName);
		rowset->AddParam("%%ID_PROP%%", ID);

		// TODO: remove this column/parameter
		rowset->AddParam("%%N_VALUE_TYPE%%", (long) 0);

    // set distributionCPD
    long distributionCPDID = pDiscount->DistributionCPDID;
    variant_t vtParam;
		if (distributionCPDID == PROPERTIES_BASE_NO_ID)		
			vtParam = "NULL";
		else
			vtParam = distributionCPDID;    
    rowset->AddParam("%%ID_DISTRIBUTION_CPD%%", vtParam);

		PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTDiscountWriter::RunDBInsertOrUpdateQuery(%d, %s): prepare cycle.", ID, lpQueryName);

		// save cycle information
		MTPRODUCTCATALOGLib::IMTPCCyclePtr pCycle = pDiscount->Cycle;
		CMTPCCycleWriter::SaveCycleToRowset(reinterpret_cast<IMTPCCycle*>(pCycle.GetInterfacePtr()), reinterpret_cast<IMTSQLRowset*>(rowset.GetInterfacePtr()));

		rowset->Execute();

		PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTDiscountWriter::RunDBInsertOrUpdateQuery(%d, %s): save counters.", ID, lpQueryName);

		SaveCounters(apCtxt, apDiscount);

		PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTDiscountWriter::RunDBInsertOrUpdateQuery(%d, %s): succeeded.", ID, lpQueryName);

	}
	catch (_com_error & err)
	{
		PCCache::GetLogger().LogVarArgs(LOG_ERROR, "CMTDiscountWriter::RunDBInsertOrUpdateQuery() caught error 0x%08h", err.Error());
		return ReturnComError(err);
	}

	context.Complete();

	return S_OK;
}

// throws
void CMTDiscountWriter::SaveCounters(IMTSessionContext* apCtxt, IMTDiscount *piDiscount)
{
	try
	{
		MTPRODUCTCATALOGLib::IMTDiscountPtr pDiscount(piDiscount);

		// we don't store counter mapping for instances.
		if(pDiscount->IsTemplate() == VARIANT_FALSE)
		{
			PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTDiscountWriter::SaveCounters(): item is an instance, don't save anything");
			return;
		}

		PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTDiscountWriter::SaveCounters(): remove counter mapping");

		// first remove all existing counter mapping
		MTPRODUCTCATALOGEXECLib::IMTCounterMapWriterPtr mapWriter( __uuidof(MTPRODUCTCATALOGEXECLib::MTCounterMapWriter));
		mapWriter->RemoveMappingByPIDBID(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), pDiscount->ID);

		// now save all the counters, and their mapping.
		PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTDiscountWriter::SaveCounters(): get CPDs");

		// get CounterPropertyDefinition information;
		MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr discountType = pDiscount->PriceableItemType;
		MTPRODUCTCATALOGEXECLib::IMTCollectionPtr counterPropertyDefinitions = discountType->GetCounterPropertyDefinitions();

		int iCPDCount = counterPropertyDefinitions->Count;
		int i;

		PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTDiscountWriter::SaveCounters(): saving counters");

		// now iterate through counters and save them.
		for(i = 1; i <= iCPDCount; ++i)
		{
			// get CPD
			MTPRODUCTCATALOGLib::IMTCounterPropertyDefinitionPtr cpd = counterPropertyDefinitions->GetItem(i);
			long lCPDID = cpd->ID;
			// save the counter!
			SaveCounterAndMapping(apCtxt, piDiscount, lCPDID);
		}

		PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTDiscountWriter::SaveCounters(): remove removed counters");

		// now go through counters to be removed, and remove them!
		MTPRODUCTCATALOGEXECLib::IMTCollectionPtr removedCounters = pDiscount->RemovedCounters;
		MTPRODUCTCATALOGEXECLib::IMTCounterWriterPtr counterWriter( __uuidof(MTPRODUCTCATALOGEXECLib::MTCounterWriter) );
		
		long lCount = removedCounters->Count;
		for(i = 1; i <= lCount; i++)
		{
			long lCounterID = removedCounters->GetItem(i);
			counterWriter->Remove(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), lCounterID);
			PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTDiscountWriter::SaveCounters(): remove removed counter %d", lCounterID);
		}
	}
	catch (_com_error & err)
	{
		PCCache::GetLogger().LogVarArgs(LOG_ERROR, "CMTDiscountWriter::SaveCounters() caught error 0x%08h", err.Error());
		throw;
	}

	// that's all, folks!
}

// throws
/////////////////////////////////////////////////////////////////////////////////////////
// FUNCTION		: CMTDiscountWriter::RemoveCounters()
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
void CMTDiscountWriter::RemoveCounters(IMTSessionContext* apCtxt, long lPIID)
{
	try 
	{
		// find information about associated counters
		MTPRODUCTCATALOGEXECLib::IMTCounterMapReaderPtr mapReader( __uuidof(MTPRODUCTCATALOGEXECLib::MTCounterMapReader));

		PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTDiscountWriter::RemoveCounters(%d)", lPIID);

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

		PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTDiscountWriter::RemoveCounters(%d): remove counter mapping", lPIID);

		// first remove all existing counter mapping
		MTPRODUCTCATALOGEXECLib::IMTCounterMapWriterPtr mapWriter( __uuidof(MTPRODUCTCATALOGEXECLib::MTCounterMapWriter));
		mapWriter->RemoveMappingByPIDBID(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), lPIID);

		// now remove all counters.
		MTPRODUCTCATALOGEXECLib::IMTCounterWriterPtr counterWriter( __uuidof(MTPRODUCTCATALOGEXECLib::MTCounterWriter) );

		for(std::vector<long>::iterator itCounter = counters.begin(); itCounter != counters.end(); ++itCounter)
		{
			PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTDiscountWriter::RemoveCounters(%d): remove counter %d", lPIID, *itCounter);
			counterWriter->Remove(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), *itCounter);
		}
	}
	catch (_com_error & err)
	{
		PCCache::GetLogger().LogVarArgs(LOG_ERROR, "CMTDiscountWriter::RemoveCounters() caught error 0x%08h", err.Error());
		throw;
	}
}


/////////////////////////////////////////////////////////////////////////////////////////
// FUNCTION		: CMTDiscountWriter::SaveCounterAndMapping()
// DESCRIPTION	: Saves the counter and inserts it into the mapping table
// RETURN		: void
// ARGUMENTS	: IMTDiscount *apDiscount
// 				: long lCPDID
// EXCEPTIONS	: 
// COMMENTS		: 
// CREATED		: 5/2/2001, Michael A. Efimov
// MODIFIED		: 
//				: 
/////////////////////////////////////////////////////////////////////////////////////////
void CMTDiscountWriter::SaveCounterAndMapping(IMTSessionContext* apCtxt, IMTDiscount *apDiscount, long lCPDID)
{
	try 
	{
		MTPRODUCTCATALOGLib::IMTDiscountPtr pDiscount(apDiscount);
		MTPRODUCTCATALOGLib::IMTCounterPtr Counter = pDiscount->GetCounter(lCPDID);
		MTPRODUCTCATALOGEXECLib::IMTCounterMapWriterPtr mapWriter( __uuidof(MTPRODUCTCATALOGEXECLib::MTCounterMapWriter));

		// if counter is specified, save it!
		if(Counter != NULL)
		{
			PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTDiscountWriter::SaveCounterAndMapping(): saving a counter for CPDID=%d", lCPDID);

			// save a counter
			Counter->Save();

			long lCounterID = Counter->ID;

			// insert a record into the mapping table
			mapWriter->AddMapping(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), lCounterID, pDiscount->ID, lCPDID);

			PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTDiscountWriter::SaveCounterAndMapping(): CPDID=%d, CounterID=%d", lCPDID, lCounterID);
		}
		else
		{
			PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTDiscountWriter::SaveCounterAndMapping(): counter for CPDID=%d is not set", lCPDID);
		}
	}
	catch (_com_error & err)
	{
		PCCache::GetLogger().LogVarArgs(LOG_ERROR, "CMTDiscountWriter::RemoveCounters() caught error 0x%08h", err.Error());
		throw;
	}
}




//////////////////////////////////////////////////////////
// CMTPCCycleWriter Implementation
//////////////////////////////////////////////////////////

// TODO: break this out into its own file

void CMTPCCycleWriter::SaveCycleToRowset(IMTPCCycle* piCycle, IMTSQLRowset *piRowset)
{
	try
	{
		MTPRODUCTCATALOGLib::IMTPCCyclePtr pCycle(piCycle);
		ROWSETLib::IMTSQLRowsetPtr pRowset(piRowset);

		if((pCycle == NULL) || (pRowset == NULL))
			MT_THROW_COM_ERROR(E_POINTER);

		_variant_t vCycleID = "null"; 
		_variant_t vCycleTypeID = "null"; 

		//by default, the cycle is not relative, however the cycle type id and cycle id are both 0
		//we will intrepret this as a relative unconstrained cycle			
		if ((pCycle->CycleTypeID == 0) && (pCycle->CycleID == 0)) {
			PCCache::GetLogger().LogThis(LOG_DEBUG, "CMTPCCycleWriter::SaveCycleToRowset(): coercing cycle to relative cycle");
			pCycle->Relative = VARIANT_TRUE;
		}

		if(pCycle->Relative) {
			//if the cycle is relative constrained write out NULL/NULL, otherwise write out cycleTypeID/NULL
			if (pCycle->CycleTypeID == 0)  //unconstrained
				PCCache::GetLogger().LogThis(LOG_DEBUG, "CMTPCCycleWriter::SaveCycleToRowset(): relative cycle type=NULL (unconstrained)");
			else {                         //constrained
				vCycleTypeID = pCycle->CycleTypeID;
				PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTPCCycleWriter::SaveCycleToRowset(): relative cycle type=%d", long(vCycleTypeID));
			}
		} else {
			//absolute cycle, write out NULL/CycleID
			PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTPCCycleWriter::SaveCycleToRowset() : compute absolute cycle id from properties");
			pCycle->ComputeCycleIDFromProperties();
			vCycleID = pCycle->CycleID;
			PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTPCCycleWriter::SaveCycleToRowset() : absolute cycle=%d", long(vCycleID));
		}

		pRowset->AddParam("%%ID_USAGE_CYCLE%%", vCycleID);
		pRowset->AddParam("%%ID_CYCLE_TYPE%%", vCycleTypeID);
	}
	catch (_com_error & err)
	{
		PCCache::GetLogger().LogVarArgs(LOG_ERROR, "CMTPCCycleWriter::SaveCycleToRowset() caught error 0x%08h", err.Error());
		throw;
	}
}

// throws
_bstr_t CMTPCCycleWriter::GetUpdateString(IMTPCCycle* piCycle)
{
	try
	{
		MTPRODUCTCATALOGLib::IMTPCCyclePtr pCycle(piCycle);

		if((pCycle == NULL))
			MT_THROW_COM_ERROR(E_POINTER);

		_variant_t vCycleID = "null"; 
		_variant_t vCycleTypeID = "null"; 

		// compute IDs
		if(pCycle->Relative)
		{
			if (pCycle->CycleTypeID == 0)			
				PCCache::GetLogger().LogThis(LOG_DEBUG, "CMTPCCycleWriter::GetUpdateString(): relative NULL cycle");
			else
			{	vCycleTypeID = pCycle->CycleTypeID;
				PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTPCCycleWriter::GetUpdateString(): relative cycle type=%d", long(vCycleTypeID));
			}
		}
		else
		{
			PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTPCCycleWriter::GetUpdateString() : compute absolute cycle id from properties");
			pCycle->ComputeCycleIDFromProperties();
			vCycleID = pCycle->CycleID;
			PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTPCCycleWriter::GetUpdateString() : absolute cycle=%d", long(vCycleID));
		}

		_bstr_t strResult = " id_usage_cycle = " + _bstr_t(vCycleID) + ", id_cycle_type = " + _bstr_t(vCycleTypeID) + " ";

		PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTPCCycleWriter::GetUpdateString() : [%s]", LPCSTR(strResult));

		return strResult;
	}
	catch (_com_error & err)
	{
		PCCache::GetLogger().LogVarArgs(LOG_ERROR, "CMTPCCycleWriter::GetUpdateString() caught error 0x%08h", err.Error());
		throw;
	}
}


//
// EBCR-aware version of SaveCycleToRowset
//
void CMTPCCycleWriter::SaveCycleToRowsetEx(MTPRODUCTCATALOGLib::IMTPCCyclePtr cycle,
																					 ROWSETLib::IMTSQLRowsetPtr rowset)
{
	try
	{
		_variant_t cycleID = "";
		_variant_t cycleTypeID = ""; 
		_variant_t cycleMode = "";

		EncodeCycle(cycle, cycleID, cycleTypeID, cycleMode);

		rowset->AddParam("%%ID_USAGE_CYCLE%%", cycleID);
		rowset->AddParam("%%ID_CYCLE_TYPE%%",  cycleTypeID);
		rowset->AddParam("%%TX_CYCLE_MODE%%",  _bstr_t(cycleMode));
	}
	catch (_com_error & err)
	{
		PCCache::GetLogger().LogVarArgs(LOG_ERROR, "CMTPCCycleWriter::SaveCycleToRowsetEx() caught error 0x%08h", err.Error());
		throw;
	}
}


//
// EBCR-aware version of GetUpdateString
//
_bstr_t CMTPCCycleWriter::GetUpdateStringEx(MTPRODUCTCATALOGLib::IMTPCCyclePtr cycle)
{
	try
	{
		_variant_t cycleID;
		_variant_t cycleTypeID; 
		_variant_t cycleMode;

		EncodeCycle(cycle, cycleID, cycleTypeID, cycleMode);

		_bstr_t str = 
			" id_usage_cycle = "  + _bstr_t(cycleID) +
			", id_cycle_type = "  + _bstr_t(cycleTypeID) +
			", tx_cycle_mode = '" + _bstr_t(cycleMode) + "' ";

		PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTPCCycleWriter::GetUpdateStringEx() : [%s]", LPCSTR(str));

		return str;
	}
	catch (_com_error & err)
	{
		PCCache::GetLogger().LogVarArgs(LOG_ERROR, "CMTPCCycleWriter::GetUpdateStringEx() caught error 0x%08h", err.Error());
		throw;
	}
}



//
// encodes the given cycle into a persistable representation 
//
void CMTPCCycleWriter::EncodeCycle(MTPRODUCTCATALOGLib::IMTPCCyclePtr cycle,
																	 _variant_t & cycleID,      
																	 _variant_t & cycleTypeID,  
																	 _variant_t & cycleMode)    
{
	MTCycleMode mode = (MTCycleMode) cycle->Mode;

	switch (mode)
	{
	case CYCLE_MODE_FIXED:
		cycle->ComputeCycleIDFromProperties();

		cycleMode = "Fixed";
		cycleID = cycle->CycleID;
		cycleTypeID = "null";

		PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTPCCycleWriter::EncodeCycle() : Fixed (cycle = %d)", long(cycleID));
		break;
			
	case CYCLE_MODE_BCR:
		cycleMode = "BCR";
		cycleID = "null";
		cycleTypeID = "null";
		
		PCCache::GetLogger().LogThis(LOG_DEBUG, "CMTPCCycleWriter::EncodeCycle(): BCR (unconstrained)");
		break;
		
	case CYCLE_MODE_BCR_CONSTRAINED:
		cycleMode = "BCR Constrained";
		cycleID = "null";
		cycleTypeID = cycle->CycleTypeID;
		
		PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTPCCycleWriter::EncodeCycle(): BCR Constrained (cycle type = %d)", long(cycleTypeID));
		break;
		
	case CYCLE_MODE_EBCR:
		cycleMode = "EBCR";
		cycleID = "null";
		cycleTypeID = cycle->CycleTypeID;

		// disallows daily or semi-monthly charge cycle types 
		if (((long) cycleTypeID == 3) || ((long) cycleTypeID == 6))
			MT_THROW_COM_ERROR("Cycle in EBCR mode does not support Daily or Semi-Monthly cycle types!");
		
		PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTPCCycleWriter::EncodeCycle(): EBCR, (cycle type = %d)", long(cycleTypeID));
		break;

	default:
		PCCache::GetLogger().LogVarArgs(LOG_ERROR, "CMTPCCycleWriter::EncodeCycle(): Unknown cycle mode! %d", long(mode));
		MT_THROW_COM_ERROR("Unknown cycle mode!");
	}
}
