/**************************************************************************
* Copyright 1997-2002 by MetraTech
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
* $Header: MTSubscriptionBase.cpp, 6, 10/31/2002 4:38:43 PM, David Blair$
* 
***************************************************************************/

#include "StdAfx.h"
#include <MTSubscriptionBase.h>
#include "MTProductCatalog.h"
#include <metra.h>
#include <mtcomerr.h>
#include <comutil.h>
#include <comip.h>
#include <mtprogids.h>
#include <DBConstants.h>

TemporalProperty::Slice::Slice(VARIANT v, const DATE& b, const DATE& e)
	:
	value(v),
	begin(b),
	end(e)
{
}

TemporalProperty::Slice::Slice(const TemporalProperty::Slice& slice)
	:
	value(slice.value),
	begin(slice.begin),
	end(slice.end)
{
}

bool TemporalProperty::Slice::operator == (const TemporalProperty::Slice& slice) const
{
	return (value == slice.value) && (begin == slice.begin) && (end == slice.end);
}

DATE TemporalProperty::Slice::GetNextStart()
{
	// Add a second since we are using closed intervals with second granularity.
	return end; 
}
/// <remarks>
/// Get an "end" timestamp that is adjacent to the start of this interval.
/// This depends on the type of interval (half open or closed)
/// as well as the time granularity (second, day, ...).
/// </remarks>
DATE TemporalProperty::Slice::GetPreviousEnd()
{
	// Subtract a second since we are using closed intervals with second granularity.
	return begin; 
}
/// <remarks>
/// Returns true if this entry contains the start of the interval
/// but not the whole interval.  
/// </remarks>
bool TemporalProperty::Slice::LeftOverlaps(const TemporalProperty::Slice& he)
{
	return begin <= he.begin && end >= he.begin && end < he.end;
}

/// <remarks>
/// Returns true if this entry contains the end of the interval he
/// but not the whole interval.  
/// </remarks>
bool TemporalProperty::Slice::RightOverlaps(const TemporalProperty::Slice& he)
{
	return begin > he.begin && begin <= he.end && end >= he.end;
}

/// <remarks>
/// Returns true if this entry contains the entire interval he.
/// </remarks>
bool TemporalProperty::Slice::Contains(const TemporalProperty::Slice& he)
{
	return begin <= he.begin && end >= he.end;
}

/// <remarks>
/// Returns true if this entry contains the timestamp date
/// </remarks>
bool TemporalProperty::Slice::Contains(const DATE& date)
{
	return begin <= date && date <= end;
}

/// <remarks>
/// Returns true if this entry is strictly contained in the interval he.
/// </remarks>
bool TemporalProperty::Slice::ContainedIn(const TemporalProperty::Slice& he)
{
	return begin > he.begin && end < he.end;
}

std::list<TemporalProperty::Slice>::iterator TemporalProperty::begin()
{
	return mProperties.begin();
}

std::list<TemporalProperty::Slice>::iterator TemporalProperty::end()
{
	return mProperties.end();
}
	

// Set the value of the property to be val from the period
// from [begin, end].  Throws an exception if the property
// time interval is not contiguous.
void TemporalProperty::Upsert(VARIANT val, const DATE& begin, const DATE& end)
{
	Slice slice(val,begin,end);
	std::list<Slice> toRemove;
	std::list<Slice> toAdd;
	toAdd.push_back(slice);
	// Find the slice containing the 
	for(std::list<Slice>::iterator it = mProperties.begin(); it != mProperties.end(); it++)
	{
		if(slice.LeftOverlaps(*it))
		{
			it->begin = slice.GetNextStart();
		}
		else if(slice.RightOverlaps(*it))
		{
			it->end = slice.GetPreviousEnd();
		}
		else if(slice.Contains(*it))
		{
			toRemove.push_back(*it);
		}
		else if(slice.ContainedIn(*it))
		{
			Slice split(*it);
			split.begin = slice.GetNextStart();
			toAdd.push_back(split);
			it->end = slice.GetPreviousEnd();
		}
	}

	for(std::list<Slice>::iterator it = toRemove.begin(); it != toRemove.end(); it++)
	{
		mProperties.remove(*it);
	}

	for(std::list<Slice>::iterator it = toAdd.begin(); it != toAdd.end(); it++)
	{
		mProperties.push_back(*it);
	}
}


MTSubscriptionBase::MTSubscriptionBase()
{
}

MTSubscriptionBase::~MTSubscriptionBase()
{
	for(std::map<long, TemporalProperty*>::iterator it = mUnitValue.begin(); it!=mUnitValue.end(); it++)
	{
		delete it->second;
	}
}



// ----------------------------------------------------------------
// Name:  GetProductOffering   	
// Arguments:  nothing
//                
// Return Value:  S_OK,E_FAIL
// Errors Raised: error if product offering does not exist
// Description:   returns the full product offering definition based
// on what is stored in the subscription
// ----------------------------------------------------------------

STDMETHODIMP MTSubscriptionBase::GetProductOffering(IMTProductOffering **ppProductOffering)
{
	ASSERT(ppProductOffering);
	if(!ppProductOffering) return E_POINTER;

	try {
			// step 1: create the product offering reader executant
		MTPRODUCTCATALOGEXECLib::IMTProductOfferingReaderPtr PoReader(__uuidof(MTPRODUCTCATALOGEXECLib::MTProductOfferingReader));

			// step 2: get the product offering ID
		long aPO_ID;
		if(SUCCEEDED(GetPropertyValue("po", &aPO_ID))) {
		
			// step 3: return the product offering
			*ppProductOffering = reinterpret_cast<IMTProductOffering*>(PoReader->Find(GetSessionContextPtr(), aPO_ID).Detach());
		}
		else {
			ASSERT(!"Fix the error code path here");
			//return Error("Could not find product offering ID");
		}
	}
	catch(_com_error& err) {
		return LogAndReturnComError(PCCache::GetLogger(),err); 
	}
	return S_OK;
}

STDMETHODIMP MTSubscriptionBase::SetProductOffering(long aProductOfferingID)
{
	return PutPropertyValue("po", aProductOfferingID);
}

// ----------------------------------------------------------------
// Name: GetICBPriceListMapping    	
// Arguments: priceable item instance ID, paramtable instance ID, pricelistmapping object   
//                
// Return Value:  
// Errors Raised: Error if subscription ID does not exist
// Description:   Returns a single ICB pricelist mapping.  If a mapping does not exist,
// the result is S_OK but nothing is in the PriceListmapping object
// ----------------------------------------------------------------

STDMETHODIMP MTSubscriptionBase::GetICBPriceListMapping(long aPrcItemID, long ParamTableID, IMTPriceListMapping **ppMapping)
{
	ASSERT(ppMapping);
	if(!ppMapping) return E_POINTER;

	try {

		// step 1: create instance of Pricelistmapping reader executant
		MTPRODUCTCATALOGEXECLib::IMTPriceListMappingReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTPriceListMappingReader));

		// step 2: get the subscription ID
		long aID;
		if(SUCCEEDED(get_ID(&aID))) {
			// step 3: return pricelist mapping

      MTPRODUCTCATALOGEXECLib::IMTPriceListMappingPtr mapping = 
        reader->FindICB_ByInstance(GetSessionContextPtr(), aPrcItemID, ParamTableID,aID);

      if(mapping != NULL) {
        switch(mSubKind) {
        case SingleSubscription:
          mapping->PutMappingType(MTPRODUCTCATALOGEXECLib::MAPPING_ICB_SUBSCRIPTION); break;
        case GroupSubscription:
          mapping->PutMappingType(MTPRODUCTCATALOGEXECLib::MAPPING_ICB_GROUP_SUBSCRIPTION); break;
        }
      }

			*ppMapping = reinterpret_cast<IMTPriceListMapping*>(mapping.Detach());
		}
		else {
			// XXX Is this a correct error?
			ASSERT(!"Fix the error code path here");
			//return Error("subscription does not exist");
		}

	}
	catch(_com_error& error) {
		return LogAndReturnComError(PCCache::GetLogger(),error);
	}
	return S_OK;
}

// ----------------------------------------------------------------
// Name: SetICBPriceListMapping    	
// Arguments: Priceable Item instance ID, paramtable ID, pricelist ID
//                
// Return Value:  
// Errors Raised: 
// Description:   Adds an ICB mapping for a single priceable item instance and parameter table
// ----------------------------------------------------------------

STDMETHODIMP MTSubscriptionBase::SetICBPriceListMapping(long aPrcItemID, long aParamTblID,BSTR CurrencyCode)
{
	try {
		// step 1: create instance of subscription writer executant
		MTPRODUCTCATALOGEXECLib::IMTSubscriptionWriterPtr SubWriter(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionWriter));

		MTPRODUCTCATALOGEXECLib::IMTSubscriptionBasePtr base = dynamic_cast<IMTSubscriptionBase*>(this);
		return SubWriter->AddICBPriceListMapping(GetSessionContextPtr(), aPrcItemID,aParamTblID,
			reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSubscriptionBase*>(base.GetInterfacePtr()));
			
	}
	catch(_com_error& error) {
		return LogAndReturnComError(PCCache::GetLogger(),error);
	}
	return S_OK;
}

// ----------------------------------------------------------------
// Name: RemoveICBPriceListMapping    	
// Arguments:   Priceableitem instance ID, parameter table ID  
//                
// Return Value:  none
// Errors Raised: 
// Description:   Remove a ICB Pricelist mapping for the priceable item instance on the
// specified parameter table
// ----------------------------------------------------------------

STDMETHODIMP MTSubscriptionBase::RemoveICBPriceListMapping(long aPI_ID, long aPtdID)
{
	try {
		// step 1: create instance of subscription writer executant
		MTPRODUCTCATALOGEXECLib::IMTSubscriptionWriterPtr SubWriter(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionWriter));

		MTPRODUCTCATALOGEXECLib::IMTSubscriptionBasePtr base = dynamic_cast<IMTSubscriptionBase*>(this);
		// step 2: remove mapping
		return SubWriter->RemoveICBMapping(GetSessionContextPtr(), aPI_ID,aPtdID,
			reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSubscriptionBase*>(base.GetInterfacePtr()));
	}
	catch(_com_error& error) {
		return LogAndReturnComError(PCCache::GetLogger(),error);
	}
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     
// Arguments: 
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------


STDMETHODIMP MTSubscriptionBase::GetParamTablesAsRowset(::IMTSQLRowset **ppRowset)
{
  try {
		MTPRODUCTCATALOGEXECLib::IMTSubscriptionReaderPtr subReader(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionReader));
		MTPRODUCTCATALOGEXECLib::IMTSubscriptionBasePtr base = dynamic_cast<IMTSubscriptionBase*>(this);

		*ppRowset = reinterpret_cast<::IMTSQLRowset*>(subReader->GetSubParamTablesAsRowset(GetSessionContextPtr(),
			base->GetID()).Detach());
  }
  catch(_com_error& err) {
		return LogAndReturnComError(PCCache::GetLogger(), err);
  }
  return S_OK;
}

STDMETHODIMP MTSubscriptionBase::SetRecurringChargeUnitValue(long aPrcItemID,DECIMAL aUnitValue,DATE aStartDate, DATE aEndDate)
{
  try {
		MTPRODUCTCATALOGLib::IMTProductCatalogPtr pc(__uuidof(MTProductCatalog));
		MTPRODUCTCATALOGLib::IMTPriceableItemPtr pi = pc->GetPriceableItem(aPrcItemID);
		if (pi->Kind == PCENTITY_TYPE_RECURRING_UNIT_DEPENDENT)
		{
			MTPRODUCTCATALOGLib::IMTRecurringChargePtr rc (pi.GetInterfacePtr());
			_variant_t unitValue(aUnitValue);
			rc->ValidateUnitValue((DECIMAL) unitValue);
		}
		else
		{
			MT_THROW_COM_ERROR(MTPC_UNIT_VALUE_ONLY_ON_UDRC);
		}

		// Figure out whether the object exists in the database
		long id_sub=0;
		if(FAILED(get_ID(&id_sub)))
		{
			id_sub = 0;
		}
		if(id_sub != 0)
		{
			MTPRODUCTCATALOGEXECLib::IMTSubscriptionWriterPtr subWriter(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionWriter));
			MTPRODUCTCATALOGEXECLib::IMTSubscriptionBasePtr base = dynamic_cast<IMTSubscriptionBase*>(this);

			// Implement sequenced upsert functionality as sequenced delete then sequenced insert.
			subWriter->DeleteUnitValue(GetSessionContextPtr(), base, aPrcItemID, aStartDate, aEndDate);
			subWriter->SetUnitValue(GetSessionContextPtr(), base, aPrcItemID, aUnitValue, aStartDate, aEndDate);
      subWriter->FinalizeUnitValue(GetSessionContextPtr(), base);
		}
		else
		{
			// Just store the values in memory and write them out later.
			if(mUnitValue.find(aPrcItemID) == mUnitValue.end())
			{
				mUnitValue[aPrcItemID] = new TemporalProperty();
			}
			mUnitValue[aPrcItemID]->Upsert(_variant_t(aUnitValue), aStartDate, aEndDate);
		}
  }
  catch(_com_error& err) {
		return LogAndReturnComError(PCCache::GetLogger(), err);
  }
  return S_OK;
}

STDMETHODIMP MTSubscriptionBase::GetRecurringChargeUnitValue(long aPrcItemID,DATE aEffDate, DECIMAL* apUnitValue)
{
	// TODO: Business rule that enforces the fact that aPrcItemID is unit-dependent.
	try
	{
		MTPRODUCTCATALOGEXECLib::IMTSubscriptionReaderPtr subReader(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionReader));
		MTPRODUCTCATALOGEXECLib::IMTSubscriptionBasePtr base = dynamic_cast<IMTSubscriptionBase*>(this);

		*apUnitValue = subReader->GetUnitValue(GetSessionContextPtr(), base->GetID(), aPrcItemID, aEffDate);
	}
	catch(_com_error& err) {
		return LogAndReturnComError(PCCache::GetLogger(), err);
  }

  return S_OK;
}

STDMETHODIMP MTSubscriptionBase::GetRecurringChargeUnitValuesAsRowset(IMTRowSet* *apUnitValues)
{
	if(NULL == apUnitValues) 
		return E_POINTER;

  try {
		MTPRODUCTCATALOGEXECLib::IMTSubscriptionReaderPtr subReader(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionReader));
		MTPRODUCTCATALOGEXECLib::IMTSubscriptionBasePtr base = dynamic_cast<IMTSubscriptionBase*>(this);

		*apUnitValues = reinterpret_cast<IMTRowSet*>(subReader->GetUnitValuesAsRowset(GetSessionContextPtr(),
																																									base->GetID()).Detach());
  }
  catch(_com_error& err) {
		return LogAndReturnComError(PCCache::GetLogger(), err);
  }

	return S_OK;
}

STDMETHODIMP MTSubscriptionBase::GetRecurringChargeUnitValuesFromMemoryAsRowset(IMTRowSet* *apUnitValues)
{
	if(NULL == apUnitValues) 
		return E_POINTER;

  try {
		// Create an in-memory rowset from the values we have in memory.
		// BUG: We don't have the name of the unit value.
		ROWSETLib::IMTInMemRowsetPtr rowset(MTPROGID_INMEMROWSET);
		rowset->Init();
		rowset->AddColumnDefinition(L"id_prop", DB_INTEGER_TYPE);
		rowset->AddColumnDefinition(L"id_sub", DB_INTEGER_TYPE);
		rowset->AddColumnDefinition(L"n_value", DB_NUMERIC_TYPE);
		rowset->AddColumnDefinition(L"nm_unit_name", DB_STRING_TYPE);
		rowset->AddColumnDefinition(L"vt_start", DB_DATE_TYPE);
		rowset->AddColumnDefinition(L"vt_end", DB_DATE_TYPE);

		for(std::map<long, TemporalProperty*>::iterator it1 = mUnitValue.begin(); it1 != mUnitValue.end(); it1++)
		{
			for(std::list<TemporalProperty::Slice>::iterator it2 = it1->second->begin(); it2 != it1->second->end(); it2++)
			{
				rowset->AddRow();
				rowset->AddColumnData(L"id_prop", it1->first);
				rowset->AddColumnData(L"id_sub", -1L);
				rowset->AddColumnData(L"n_value", it2->value);
				rowset->AddColumnData(L"nm_unit_name", L"UNKNOWN");
				rowset->AddColumnData(L"vt_start", _variant_t(it2->begin, VT_DATE));
				rowset->AddColumnData(L"vt_end", _variant_t(it2->end, VT_DATE));
			}
		}

		*apUnitValues = reinterpret_cast<IMTRowSet*>(rowset.Detach());
  }
  catch(_com_error& err) {
		return LogAndReturnComError(PCCache::GetLogger(), err);
  }

	return S_OK;
}

STDMETHODIMP MTSubscriptionBase::get_ID(long *pVal)
{
	return GetPropertyValue("id_sub", pVal);
}

STDMETHODIMP MTSubscriptionBase::put_ID(long newVal)
{
	return PutPropertyValue("id_sub", newVal);
}




STDMETHODIMP MTSubscriptionBase::get_ProductOfferingID(long *pVal)
{
	return GetPropertyValue("po", pVal);
}

STDMETHODIMP MTSubscriptionBase::put_ProductOfferingID(long newVal)
{
	return PutPropertyValue("po", newVal);
}


STDMETHODIMP MTSubscriptionBase::get_EffectiveDate(IMTPCTimeSpan **pVal)
{
return GetPropertyObject( "EffectiveDate", reinterpret_cast<IDispatch**>(pVal) );
}


STDMETHODIMP MTSubscriptionBase::put_EffectiveDate(IMTPCTimeSpan *newVal)
{
	return PutPropertyObject("EffectiveDate",reinterpret_cast<IDispatch*>(newVal));
}



STDMETHODIMP MTSubscriptionBase::get_Cycle(IMTPCCycle** pCycle)
{
	return GetPropertyObject( "Cycle", reinterpret_cast<IDispatch**>(pCycle));
}

STDMETHODIMP MTSubscriptionBase::put_Cycle(IMTPCCycle* pCycle)
{
	return PutPropertyObject( "Cycle", reinterpret_cast<IDispatch*>(pCycle));
}

STDMETHODIMP MTSubscriptionBase::get_ExternalIdentifier(BSTR* ppGUID)
{
	return GetPropertyValue("ExternalIdentifier", ppGUID);
}


STDMETHODIMP MTSubscriptionBase::put_ExternalIdentifier(BSTR pGUID)
{
	return PutPropertyValue("ExternalIdentifier", pGUID);
}

STDMETHODIMP MTSubscriptionBase::get_WarnOnEBCRStartDateChange(VARIANT_BOOL *pVal)
{
  try
  {
		MTPRODUCTCATALOGEXECLib::IMTSubscriptionReaderPtr subReader(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionReader));
		MTPRODUCTCATALOGEXECLib::IMTSubscriptionBasePtr base = dynamic_cast<IMTSubscriptionBase*>(this);
		
		*pVal = subReader->GetWarnOnEBCRStartDateChange(base->GetID()); 
  }
  catch (_com_error & err)
  {
    return LogAndReturnComError(PCCache::GetLogger(),err);
  }

  return S_OK;
}



