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
* $Header: c:\development35\ProductCatalog\MTProductCatalogExec\MTDiscountReader.cpp, 37, 7/9/2002 3:56:25 PM, Alon Becker$
* 
***************************************************************************/

// MTDiscountReader.cpp : Implementation of CMTDiscountReader
#include "StdAfx.h"
#include "MTProductCatalogExec.h"
#include "MTDiscountReader.h"
//#include <MTCounter.h>

#include <pcexecincludes.h>
#include <mtcomerr.h>

#include "pcexecincludes.h"
#include <set>


/////////////////////////////////////////////////////////////////////////////
// CMTDiscountReader

/******************************************* error interface ***/
STDMETHODIMP CMTDiscountReader::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTDiscountReader
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTDiscountReader::Activate()
{
	HRESULT hr = GetObjectContext(&m_spObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTDiscountReader::CanBePooled()
{
	return FALSE;
} 

void CMTDiscountReader::Deactivate()
{
	m_spObjectContext.Release();
} 

STDMETHODIMP CMTDiscountReader::FindCountersAsRowset(IMTSessionContext* apCtxt, /*[in]*/long aDiscountDBID, /*[out, retval]*/IMTSQLRowset** apRowset)
{
	MTAutoContext context(m_spObjectContext);

	try {
		PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTDiscountReader::FindCountersAsRowset(%d)", aDiscountDBID);

		MTPRODUCTCATALOGLib::IMTProductCatalogPtr ProductCatalog( __uuidof(MTPRODUCTCATALOGLib::MTProductCatalog));
		MTPRODUCTCATALOGLib::IMTDiscountPtr Discount = ProductCatalog->GetPriceableItem(aDiscountDBID);

		MTPRODUCTCATALOGEXECLib::IMTCounterMapReaderPtr mapReader( __uuidof(MTPRODUCTCATALOGEXECLib::MTCounterMapReader));
		ROWSETLib::IMTSQLRowsetPtr rs = mapReader->GetExtendedPIMappingsAsRowset(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), 
				aDiscountDBID,
				Discount->PriceableItemType->ID);

		*apRowset = reinterpret_cast<IMTSQLRowset*>(rs.Detach());
	}
	catch (_com_error & err)
	{
		PCCache::GetLogger().LogVarArgs(LOG_ERROR, "CMTDiscountReader::FindCountersAsRowset(%d) caught error 0x%08h", aDiscountDBID, err.Error());
		return ReturnComError(err);
	}

	context.Complete();

	PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTDiscountReader::FindCountersAsRowset(%d) succeeded", aDiscountDBID);

	return S_OK;

}

STDMETHODIMP CMTDiscountReader::PopulateDiscountProperties(IMTSessionContext* apCtxt, IMTDiscount *piDiscount)
{
	MTAutoContext context(m_spObjectContext);

	try
	{
		MTPRODUCTCATALOGLib::IMTDiscountPtr pDiscount(piDiscount);

		if(pDiscount == NULL)
			MT_THROW_COM_ERROR(E_POINTER);

		long ID = pDiscount->ID;

		if(ID == 0)
			MT_THROW_COM_ERROR(MTPC_OBJECT_NO_STATE);

		PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTDiscountReader::PopulateDiscountProperties(%d)", ID);

		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		rowset->SetQueryTag("__GET_DISCOUNT_PROPERTIES_BY_ID__");
		rowset->AddParam("%%ID_PROP%%", ID);

		rowset->Execute();

		if(0 == rowset->GetRecordCount())
			MT_THROW_COM_ERROR(MTPC_ITEM_NOT_FOUND_BY_ID, PCENTITY_TYPE_DISCOUNT, ID);

    //get distributionCPD
    _variant_t val = rowset->GetValue("id_distribution_cpd");
    if (val.vt != VT_NULL)
      pDiscount->DistributionCPDID = (long) val;

		// load cycle information
		MTPRODUCTCATALOGLib::IMTPCCyclePtr pCycle = pDiscount->Cycle;
		CMTPCCycleReader::LoadCycleFromRowset(reinterpret_cast<IMTPCCycle*>(pCycle.GetInterfacePtr()),
							reinterpret_cast<IMTSQLRowset*>(rowset.GetInterfacePtr()));

		// load counters
		LoadCounters(apCtxt, piDiscount);
	}
	catch (_com_error & err)
	{
		PCCache::GetLogger().LogVarArgs(LOG_ERROR, "CMTDiscountReader::PopulateDiscountProperties() caught error 0x%08h", err.Error());
		return ReturnComError(err);
	}

	context.Complete();
	PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTDiscountReader::PopulateDiscountProperties() succeeded");

	return S_OK;
}


void CMTDiscountReader::LoadCounters(IMTSessionContext* apCtxt, IMTDiscount *piDiscount)
{
	try 
	{
		MTPRODUCTCATALOGLib::IMTDiscountPtr pDiscount(piDiscount);

		// find information about associated counters
		MTPRODUCTCATALOGEXECLib::IMTCounterMapReaderPtr mapReader( __uuidof(MTPRODUCTCATALOGEXECLib::MTCounterMapReader));

		// use template ID to find counter map
		long lDiscountID = pDiscount->IsTemplate() ? pDiscount->ID : pDiscount->TemplateID;

		PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTDiscountReader::LoadCounters() : loading counters for PriceableItemID=%d", lDiscountID);

		ROWSETLib::IMTSQLRowsetPtr rs = mapReader->GetPIMappingsAsRowset(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), lDiscountID);

		MTPRODUCTCATALOGLib::IMTProductCatalogPtr ProductCatalog( __uuidof(MTPRODUCTCATALOGLib::MTProductCatalog));

		while(rs->GetRowsetEOF().boolVal == VARIANT_FALSE)
		{
			long iCPDID = rs->GetValue("id_cpd");
			long iCounterID = rs->GetValue("id_counter");

			// create and load new counter by ID
			MTPRODUCTCATALOGLib::IMTCounterPtr Counter = ProductCatalog->GetCounter(iCounterID);
      Counter->PriceableItemID = lDiscountID;

			// attach it to the discount
			pDiscount->SetCounter(iCPDID, Counter);

			PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTDiscountReader::LoadCounters() : CPDID=%d, CounterID=%d", iCPDID, iCounterID);

			rs->MoveNext();
		}
	}
	catch (_com_error & err)
	{
		PCCache::GetLogger().LogVarArgs(LOG_ERROR, "CMTDiscountReader::LoadCounters() caught error 0x%08h", err.Error());
		throw;
	}
}




//////////////////////////////////////////////////////////
// CMTPCCycleReader Implementation
//////////////////////////////////////////////////////////

// TODO: break this out into its own file


// throws
void CMTPCCycleReader::LoadCycleFromRowset(IMTPCCycle* piCycle, IMTSQLRowset *piRowset)
{
	try {
		MTPRODUCTCATALOGLib::IMTPCCyclePtr pCycle(piCycle);
		ROWSETLib::IMTSQLRowsetPtr pRowset(piRowset);

		if((pCycle == NULL) || (pRowset == NULL))
			MT_THROW_COM_ERROR(MTPC_OBJECT_NO_STATE);

		_variant_t vCycleID = pRowset->GetValue("id_usage_cycle");
		_variant_t vCycleTypeID = pRowset->GetValue("id_cycle_type");

		pCycle->Relative = (vCycleID.vt == VT_NULL) ? VARIANT_TRUE : VARIANT_FALSE;

		if(pCycle->Relative)
		{
			pCycle->CycleTypeID = (vCycleTypeID.vt == VT_NULL) ? 0L : vCycleTypeID;
			PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTPCCycleReader::LoadCycleFromRowset() : relative cycle type=%d", long(pCycle->CycleTypeID));
		}
		else
		{
			pCycle->CycleID		= vCycleID;
			PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTPCCycleReader::LoadCycleFromRowset() : absolute cycle=%d", long(vCycleID));
			pCycle->ComputePropertiesFromCycleID();
		}
	}
	catch (_com_error & err)
	{
		PCCache::GetLogger().LogVarArgs(LOG_ERROR, "CMTPCCycleReader::LoadCycleFromRowset() caught error 0x%08h", err.Error());
		throw;
	}
}


//
// loads cycles of EBCR-aware pribable items
//
void CMTPCCycleReader::LoadCycleFromRowsetEx(MTPRODUCTCATALOGLib::IMTPCCyclePtr cycle,
																						 ROWSETLib::IMTSQLRowsetPtr rowset)
{
	try 
	{
		_variant_t cycleID = rowset->GetValue("id_usage_cycle");
		_variant_t cycleTypeID = rowset->GetValue("id_cycle_type");
		_variant_t cycleMode = rowset->GetValue("tx_cycle_mode");

		DecodeCycle(cycleID, cycleTypeID, cycleMode, cycle);
	}
	catch (_com_error & err)
	{
		PCCache::GetLogger().LogVarArgs(LOG_ERROR, "CMTPCCycleReader::LoadCycleFromRowsetEx() caught error 0x%08h", err.Error());
		throw;
	}
}


// decodes the persistable representation into a given cycle (EBCR-aware)
void CMTPCCycleReader::DecodeCycle(_variant_t cycleID,      
																	 _variant_t cycleTypeID,  
																	 _variant_t cycleMode,
																	 MTPRODUCTCATALOGLib::IMTPCCyclePtr cycle)    
{
	MTCycleMode mode = ConverCycleModeStringToEnum(_bstr_t(cycleMode));
	cycle->Mode = (MTPRODUCTCATALOGLib::MTCycleMode) mode;

	switch (mode)
	{
	case CYCLE_MODE_FIXED:
		cycle->CycleID	= cycleID;
		cycle->ComputePropertiesFromCycleID();

		PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTPCCycleReader::DecodeCycle() : Fixed (cycle = %d)", long(cycleID));
		break;

	case CYCLE_MODE_BCR:
		cycle->CycleID = 0;
		cycle->CycleTypeID = 0;

		PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTPCCycleReader::DecodeCycle() : BCR (unconstrained)");
		break;

	case CYCLE_MODE_BCR_CONSTRAINED:
		cycle->CycleID = 0;
		cycle->CycleTypeID = cycleTypeID;			

		PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTPCCycleReader::DecodeCycle() : BCR Constrained (cycle type = %d)",
																		long(cycleTypeID));
		break;

	case CYCLE_MODE_EBCR:
		cycle->CycleID = 0;
		cycle->CycleTypeID = cycleTypeID;			

		PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTPCCycleReader::DecodeCycle() : EBCR (cycle type = %d)",
																		long(cycleTypeID));
		break;

	default:
		MT_THROW_COM_ERROR("Unknown cycle mode!");
		}
	}


//
// converts a tx_cycle_mode style string into an MTCycleMode enum
//
MTCycleMode CMTPCCycleReader::ConverCycleModeStringToEnum(_bstr_t modeStr)
	{
	if (modeStr == _bstr_t("Fixed"))
		return CYCLE_MODE_FIXED;
	else if (modeStr == _bstr_t("BCR"))
		return CYCLE_MODE_BCR;
	else if (modeStr == _bstr_t("BCR Constrained"))
		return CYCLE_MODE_BCR_CONSTRAINED;
	else if (modeStr == _bstr_t("EBCR"))
		return CYCLE_MODE_EBCR;

	_bstr_t msg = "Unknown cycle mode! '" + modeStr + "'";
	MT_THROW_COM_ERROR((const char *) msg);
}
