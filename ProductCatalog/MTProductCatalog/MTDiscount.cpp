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
#include "MTProductCatalog.h"
#include "MTDiscount.h"
#include <mtcomerr.h>
#include <mtglobal_msg.h> 
/////////////////////////////////////////////////////////////////////////////
// CMTDiscount

STDMETHODIMP CMTDiscount::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
    &IID_IMTDiscount,
    &IID_IMTPCBase
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

// ----------------------------------------------------------------
// Name:          CopyNonBaseMembersTo
// Arguments:     apPrcItemTarget - PI template or instanc
//                
// Errors Raised: _com_error
// Description:   copy the members that are not in the base class
//                this method can be called for templates or instances
// ----------------------------------------------------------------
void CMTDiscount::CopyNonBaseMembersTo(IMTPriceableItem* apPrcItemTarget)
{
	MTPRODUCTCATALOGLib::IMTDiscountPtr source = this;
	MTPRODUCTCATALOGLib::IMTDiscountPtr target = apPrcItemTarget;

	target->DistributionCPDID = source->DistributionCPDID;


	// copy Cycle here
	source->Cycle->CopyTo(target->Cycle);

	// copy counters here
	// ....
	MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr discountType = source->PriceableItemType;
	MTPRODUCTCATALOGEXECLib::IMTCollectionPtr counterPropertyDefinitions = discountType->GetCounterPropertyDefinitions();

	int iCPDCount = counterPropertyDefinitions->Count;
	int i;

	// now iterate through counters and save them.
	for(i = 1; i <= iCPDCount; ++i)
	{
		// get CPD
		MTPRODUCTCATALOGLib::IMTCounterPropertyDefinitionPtr cpd = counterPropertyDefinitions->GetItem(i);
		long lCPDID = cpd->ID;
		// copy the counter!
		target->SetCounter(lCPDID, source->GetCounter(lCPDID));
	}
}

HRESULT CMTDiscount::FinalConstruct()
{
	try
	{
		HRESULT hr = CoCreateFreeThreadedMarshaler(GetControllingUnknown(), &m_pUnkMarshaler.p);
		if (FAILED(hr))
			throw _com_error(hr);

		//load meta data
		LoadPropertiesMetaData( PCENTITY_TYPE_DISCOUNT );

		// set kind
		put_Kind( PCENTITY_TYPE_DISCOUNT );

		// create MTPCCycle isntance
		MTPRODUCTCATALOGLib::IMTPCCyclePtr cyclePtr(__uuidof(MTPCCycle));
		PutPropertyObject("Cycle", cyclePtr);

	}	
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

void CMTDiscount::OnSetSessionContext(IMTSessionContext* apSessionContext)
{
	// session context for nested objects can't be set inside the constructor
	// (since this object does not have a session context at the time it constructs its nested objects)
	// so set session context of derived objects now
	// caller will catch any exceptions

	CMTPriceableItem::OnSetSessionContext(apSessionContext); //any base work first

	MTPRODUCTCATALOGLib::IMTDiscountPtr thisPtr = this;

	thisPtr->Cycle->SetSessionContext(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(apSessionContext));
}

STDMETHODIMP CMTDiscount::get_Cycle(IMTPCCycle **pVal)
{
	return GetPropertyObject( "Cycle", reinterpret_cast<IDispatch**>(pVal) );
}

/////////////////////////////////////////////////////////////////////////////////////////
// FUNCTION		: CMTDiscount::GetCounter()
// DESCRIPTION	: 
// RETURN		: STDMETHODIMP
// ARGUMENTS	: IMTCounterPropertyDefinition *pProperty
// 				: IMTCounter **ppCounter
// EXCEPTIONS	: 
// COMMENTS		: returns S_FALSE if there is no counter associated with given property.
// CREATED		: 4/27/2001, Michael A. Efimov
// MODIFIED		: 
//				: 
/////////////////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CMTDiscount::GetCounter(long lCounterPropertyDefinitionID, IMTCounter **ppCounter)
{
	try
	{
		// first, check, if there was a counter assigned to given property
		mapCounterPropertyDefIDtoCounter::iterator itMapCounter = m_mapCounters.find(lCounterPropertyDefinitionID);

		size_t mapSize = m_mapCounters.size();
		mapCounterPropertyDefIDtoCounter::iterator itMapCounterEnd = m_mapCounters.end();

		// if there is no counter, return NULL
		if(itMapCounter == m_mapCounters.end())
		{
			*ppCounter = NULL;
			if(IsValidCounterPropertyDefinitionID(lCounterPropertyDefinitionID))
				return S_OK;
			else
				MT_THROW_COM_ERROR(MTPC_WRONG_COUNTER_PROPERTY_DEFINITION);
		}

		// return Counter object to caller...
		MTPRODUCTCATALOGLib::IMTCounterPtr counter = itMapCounter->second.GetInterfacePtr();
		// addref on the object before returning it
		counter->AddRef();

		*ppCounter = reinterpret_cast<IMTCounter*>(counter.GetInterfacePtr());
	}
	catch(_com_error& e)
	{
		return LogAndReturnComError(PCCache::GetLogger(),e);
	}

	return S_OK;
}

/////////////////////////////////////////////////////////////////////////////////////////
// FUNCTION		: CMTDiscount::SetCounter()
// DESCRIPTION	: associates counter with given CounterPropertyDefinition. Updates map if necessary
// RETURN		: STDMETHODIMP
// ARGUMENTS	: IMTCounterPropertyDefinition *pProperty
// 				: IMTCounter *pCounter
// EXCEPTIONS	: 
// COMMENTS		: 
// CREATED		: 4/27/2001, Michael A. Efimov
// MODIFIED		: 
//				: 
/////////////////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CMTDiscount::SetCounter(long lCounterPropertyDefinitionID, IMTCounter *pCounter)
{
	try
	{
		if(!IsValidCounterPropertyDefinitionID(lCounterPropertyDefinitionID))
			MT_THROW_COM_ERROR( MTPC_WRONG_COUNTER_PROPERTY_DEFINITION );

		MTPRODUCTCATALOGLib::IMTCounterPtr Counter(pCounter);

		// first, check, if there was a counter assigned to given property
		mapCounterPropertyDefIDtoCounter::iterator itMapCounter = m_mapCounters.find(lCounterPropertyDefinitionID);

		bool bOldCounterExists = (itMapCounter != m_mapCounters.end());
		bool bNewCounterIsNull = (Counter == NULL);

		long newCounterID = 0;
		if(!bNewCounterIsNull)
		{
			newCounterID = Counter->ID;
		}

		// if there already was a counter, and it is not the same as new one...
		if(bOldCounterExists && (bNewCounterIsNull || (itMapCounter->second->ID != newCounterID)))
		{
			// move it to the list of old counters, so it will be deleted on Save();
			m_listOldCounters.push_back(itMapCounter->second->ID);
		}

		// set new counter in the map
		if(!bNewCounterIsNull)
			m_mapCounters[lCounterPropertyDefinitionID] = Counter;
		else
			m_mapCounters.erase(lCounterPropertyDefinitionID);
	}
	catch(_com_error& e)
	{
		ReturnComError(e);
	}

	return S_OK;
}

/////////////////////////////////////////////////////////////////////////////////////////
// FUNCTION		: CMTDiscount::GetCountersAsRowset()
// DESCRIPTION	: 
// RETURN		: STDMETHODIMP
// ARGUMENTS	: IMTRowSet **apRowset
// EXCEPTIONS	: 
// COMMENTS		: You have to SAVE discount in order to use this method
// CREATED		: 5/2/2001, Michael A. Efimov
// MODIFIED		: 
//				: 
/////////////////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CMTDiscount::GetCountersAsRowset(IMTRowSet **apRowset)
{
	try
	{
		// create instance of COM+ executant
		MTPRODUCTCATALOGEXECLib::IMTDiscountReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTDiscountReader));
		MTPRODUCTCATALOGLib::IMTDiscountPtr pDiscount(this);

		// use template ID to find counter map
		long lDiscountID = pDiscount->IsTemplate() ? pDiscount->ID : pDiscount->TemplateID;

		// use discount reader to get counters as rowset
		MTPRODUCTCATALOGEXECLib::IMTRowSetPtr aReturnRowset = reader->FindCountersAsRowset(GetSessionContextPtr(), lDiscountID);
		*apRowset = reinterpret_cast<IMTRowSet*>(aReturnRowset.Detach());
		return S_OK;
	}
	catch (_com_error & err)
	{ return LogAndReturnComError(PCCache::GetLogger(),err); }
}

STDMETHODIMP CMTDiscount::RemoveCounter(long lCounterPropertyDefinitionID)
{
	try {
		// first, check, if there was a counter assigned to given property
		mapCounterPropertyDefIDtoCounter::iterator itMapCounter = m_mapCounters.find(lCounterPropertyDefinitionID);

		// if counter is found ...
		if(itMapCounter != m_mapCounters.end())
		{
			// move it to the list of old counters, so it will be deleted on Save();
			m_listOldCounters.push_back(itMapCounter->second->ID);
			// remove counter from the map
			m_mapCounters.erase(itMapCounter);
		}
		else
		{
			// CPDID is not found, so counter is not there, and there is nothing to remove ...
			if(IsValidCounterPropertyDefinitionID(lCounterPropertyDefinitionID))
				return S_OK;
			else
				MT_THROW_COM_ERROR( MTPC_WRONG_COUNTER_PROPERTY_DEFINITION );
		}
	}
	catch(_com_error& err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}
	return S_OK;
}

/////////////////////////////////////////////////////////////////////////////////////////
// FUNCTION		: CMTDiscount::get_RemovedCounters()
// DESCRIPTION	: returns list of counters, that have been removed, so Database can be updated
// RETURN		: STDMETHODIMP
// ARGUMENTS	: IMTCollection **pVal
// EXCEPTIONS	: 
// COMMENTS		: 
// CREATED		: 5/2/2001, Michael A. Efimov
// MODIFIED		: 
//				: 
/////////////////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CMTDiscount::get_RemovedCounters(IMTCollection **apColl)
{
	try
	{
		GENERICCOLLECTIONLib::IMTCollectionPtr coll(__uuidof(GENERICCOLLECTIONLib::MTCollection));


		for(listCountersID::iterator itCounterID = m_listOldCounters.begin(); itCounterID != m_listOldCounters.end(); ++itCounterID)
		{
			coll->Add(*itCounterID);
		}
		
		*apColl = reinterpret_cast<IMTCollection*>(coll.Detach());

	}
	catch(_com_error e)
	{
		return e.Error();
	}

	return S_OK;
}

bool CMTDiscount::IsValidCounterPropertyDefinitionID(long lCounterPropertyDefinitionID)
{
	return true;
	// TODO: get it to work
	try {
		// load counter property definition by ID
		MTPRODUCTCATALOGEXECLib::IMTCounterPropertyDefinitionReaderPtr cpdReader( __uuidof(MTPRODUCTCATALOGEXECLib::MTCounterPropertyDefinitionReader));
		MTPRODUCTCATALOGLib::IMTCounterPropertyDefinitionPtr cpd = cpdReader->Find(GetSessionContextPtr(), lCounterPropertyDefinitionID);
		MTPRODUCTCATALOGLib::IMTDiscountPtr Discount(this);
		MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr type = Discount->PriceableItemType;

		return (cpd->PITypeID == type->GetID());
	}
	catch(_com_error e)
	{
		return false;
	}

	// shouldn't be here.
	return false;
}

void CMTDiscount::CheckConfigurationForDerived(IMTCollection* apErrors)
{
	MTPRODUCTCATALOGLib::IMTCollectionPtr errors = apErrors;

	//make sure there's a counter for each CPD

	MTPRODUCTCATALOGLib::IMTDiscountPtr thisPtr = this;

	MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr prcItemType;
	prcItemType = thisPtr->PriceableItemType;

	// if this is a template check this,
	// if this is an instance check its template
	// since counter are only configured for the template
	MTPRODUCTCATALOGLib::IMTDiscountPtr discountTemplate;
	discountTemplate = thisPtr->GetTemplate();

	if (discountTemplate == NULL)
		discountTemplate = thisPtr;

	//get the collection of CPDs
	MTPRODUCTCATALOGLib::IMTCollectionPtr cpds;
	cpds = prcItemType->GetCounterPropertyDefinitions();

	MTPRODUCTCATALOGLib::IMTCounterPropertyDefinitionPtr cpd;
	MTPRODUCTCATALOGLib::IMTCounterPtr counter;

	// loop over all param table defs
	long count = cpds->GetCount();
	for (long i = 1; i <= count; ++i) // collection indexes are 1-based
	{
		cpd = cpds->GetItem(i);

		counter = discountTemplate->GetCounter(cpd->ID);

		if (counter == NULL)
		{	
			Message message(MTPCUSER_PRC_ITEM_HAS_NO_COUNTER);
			string msgString;
			message.FormatErrorMessage(msgString, TRUE,
																(const char*)thisPtr->Name,
																(const char*)cpd->Name);

			errors->Add(msgString.c_str());
		}
	}
}

STDMETHODIMP CMTDiscount::get_DistributionCPDID(long *pVal)
{
	return GetPropertyValue("DistributionCPDID", pVal);
}

STDMETHODIMP CMTDiscount::put_DistributionCPDID(long newVal)
{
	return PutPropertyValue("DistributionCPDID", newVal);
}

STDMETHODIMP CMTDiscount::GetDistributionCounter(IMTCounter** apCounter)
{
	ASSERT(apCounter);
	if(!apCounter) return E_POINTER;

	try
	{
    //init out var
    *apCounter = NULL;

    MTPRODUCTCATALOGLib::IMTDiscountPtr thisPtr = this;
    long distributionCPDID = thisPtr->DistributionCPDID;
    
    if (distributionCPDID != PROPERTIES_BASE_NO_ID)
    { 
      MTPRODUCTCATALOGLib::IMTCounterPtr counter;
      counter = thisPtr->GetCounter(distributionCPDID);
      *apCounter = reinterpret_cast<IMTCounter*>(counter.Detach());
    }
	}
	catch(_com_error& e)
	{
		return LogAndReturnComError(PCCache::GetLogger(),e);
	}
	return S_OK;
}

STDMETHODIMP CMTDiscount::SetDistributionCounter(IMTCounter* apDistrCounter)
{
	try
	{
    long distributionCPDID = PROPERTIES_BASE_NO_ID;
    MTPRODUCTCATALOGLib::IMTDiscountPtr thisPtr = this;

    if (apDistrCounter != NULL) //null counter sets distributionCPDID to -1
    {
      MTPRODUCTCATALOGLib::IMTCounterPtr distrCounter = apDistrCounter;

      //make sure that counter is valid for distribution
      VARIANT_BOOL validForDist = distrCounter->Type->ValidForDistribution;
      if (!validForDist)
        MT_THROW_COM_ERROR(MTPC_COUNTER_NOT_FOR_DISTRIBUTION);
      
      // look up counter among current counters
      // and store the CPDID for that one
      std::map<long, MTPRODUCTCATALOGLib::IMTCounterPtr>::iterator itr;
      for( itr = m_mapCounters.begin(); itr != m_mapCounters.end(); ++itr)
      {
        long cpdID = itr->first;
        MTPRODUCTCATALOGLib::IMTCounterPtr counter = itr->second;

        if (distrCounter->ID != PROPERTIES_BASE_NO_ID)
        {
          //if counter has an ID compare the IDs
          if (distrCounter->ID == counter->ID)
          { distributionCPDID = cpdID;
            break;
          }
        }
        else
        { // if counter has no ID (eg just created)
          // compare the IUnknown pointers
          if (distrCounter == counter)
          { distributionCPDID = cpdID;
            break;
          }
        }
      }

      //if counter has not been found throw error
      if (distributionCPDID == PROPERTIES_BASE_NO_ID)
        MT_THROW_COM_ERROR(MTPC_COUNTER_NOT_IN_DISCOUNT);
    }

    thisPtr->DistributionCPDID = distributionCPDID;
	}
	catch(_com_error& e)
	{
		return LogAndReturnComError(PCCache::GetLogger(),e);
	}
	return S_OK;
}
