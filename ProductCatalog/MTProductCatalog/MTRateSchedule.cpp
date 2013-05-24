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
#include "MTRateSchedule.h"
#include <mtcomerr.h>
#include <mtprogids.h>

/////////////////////////////////////////////////////////////////////////////
// CMTRateSchedule

STDMETHODIMP CMTRateSchedule::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
    &IID_IMTRateSchedule,
    &IID_IMTPCBase
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTRateSchedule::FinalConstruct()
{
	try
	{
		LoadPropertiesMetaData(PCENTITY_TYPE_RATE_SCHEDULE);

    put_ScheduleType(MAPPING_NORMAL);

		// construct nested objects
		MTPRODUCTCATALOGLib::IMTPCTimeSpanPtr effectiveDatePtr(__uuidof(MTPCTimeSpan));
		PutPropertyObject("EffectiveDate", effectiveDatePtr);

		return CoCreateFreeThreadedMarshaler(
			GetControllingUnknown(), &m_pUnkMarshaler.p);
	}
	catch (_com_error & err)
	{ return LogAndReturnComError(PCCache::GetLogger(),err); }
}

CMTRateSchedule::CMTRateSchedule()
	: mRuleSetAvailable(TRUE)
{
	m_pUnkMarshaler = NULL;
}

void CMTRateSchedule::OnSetSessionContext(IMTSessionContext* apSessionContext)
{
	// session context for nested objects can't be set inside the constructor
	// (since this object does not have a session context at the time it constructs its nested objects)
	// so set session context of derived objects now
	// caller will catch any exceptions

	MTPRODUCTCATALOGLib::IMTRateSchedulePtr thisPtr = this;

	thisPtr->EffectiveDate->SetSessionContext(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(apSessionContext));
}


STDMETHODIMP CMTRateSchedule::get_ID(long *pVal)
{
	return GetPropertyValue("ID", pVal);
}

STDMETHODIMP CMTRateSchedule::put_ID(long newVal)
{
	return PutPropertyValue("ID", newVal);
}

STDMETHODIMP CMTRateSchedule::get_Description(BSTR *pVal)
{
	return GetPropertyValue("Description", pVal);
}

STDMETHODIMP CMTRateSchedule::put_Description(BSTR newVal)
{
	return PutPropertyValue("Description", newVal);
}

STDMETHODIMP CMTRateSchedule::get_EffectiveDate(IMTPCTimeSpan **pVal)
{
	return GetPropertyObject( "EffectiveDate", reinterpret_cast<IDispatch**>(pVal) );
}


STDMETHODIMP CMTRateSchedule::GetDatedRuleSet(VARIANT aRefDate, IMTRuleSet * *pVal)
{
	try
	{
    long id = -1;
		HRESULT hr = get_ID(&id);
		if (FAILED(hr))
			return hr;

		// create instance of COM+ executant
		MTPRODUCTCATALOGEXECLib::IMTRuleSetReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTRuleSetReader));

    IMTRuleSetPtr ruleSet;
    ruleSet = reader->CreateRuleSet(GetSessionContextPtr());
		

    IMTParamTableDefinition * paramTableInterface = NULL;
    hr = GetParameterTable(&paramTableInterface);
    if (FAILED(hr))
      return hr;

    // attach to it
    MTPRODUCTCATALOGEXECLib::IMTParamTableDefinitionPtr paramTable((MTPRODUCTCATALOGEXECLib::IMTParamTableDefinition *) paramTableInterface,
						    false);

    reader->FindWithID(GetSessionContextPtr(), id, paramTable,
									    (MTPRODUCTCATALOGEXECLib::IMTRuleSet *) ruleSet.GetInterfacePtr(),
                      aRefDate);

    *pVal = (IMTRuleSet *) ruleSet.GetInterfacePtr();
    return (*pVal)->AddRef();

  }
	catch (_com_error & err)
	{ return LogAndReturnComError(PCCache::GetLogger(),err); }

}
 

STDMETHODIMP CMTRateSchedule::get_RuleSet(IMTRuleSet **pVal)
{
	try
	{
		long id = -1;
		HRESULT hr = get_ID(&id);
		if (FAILED(hr))
			return hr;

		// create instance of COM+ executant
		MTPRODUCTCATALOGEXECLib::IMTRuleSetReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTRuleSetReader));

		if (mRuleSetAvailable && id != -1)
		{
			// we're real but haven't read out rates yet
			// we have the object ID but not the object itself

			IMTParamTableDefinition * paramTableInterface = NULL;
			hr = GetParameterTable(&paramTableInterface);
			if (FAILED(hr))
				return hr;

			// attach to it
			MTPRODUCTCATALOGEXECLib::IMTParamTableDefinitionPtr
				paramTable((MTPRODUCTCATALOGEXECLib::IMTParamTableDefinition *) paramTableInterface,
									 false);

      if (mRuleSet == NULL)
      {
	      mRuleSet = reader->CreateRuleSet(GetSessionContextPtr());
	      //hr = mRuleSet.CreateInstance(MTPROGID_MTRULESET);
	      //if (FAILED(hr))
	      //return hr;
      }

      _variant_t vtNull;
      vtNull.ChangeType(VT_NULL);

      reader->FindWithID(GetSessionContextPtr(), id, paramTable,
                            (MTPRODUCTCATALOGEXECLib::IMTRuleSet *) mRuleSet.GetInterfacePtr(),
                            vtNull);

      mRuleSetAvailable = FALSE; 
		}
		else
		{
			// either the rules have been read already or there aren't any
			if (mRuleSet == NULL)
			{
				mRuleSet = reader->CreateRuleSet(GetSessionContextPtr());
#if 0
				hr = mRuleSet.CreateInstance(MTPROGID_MTRULESET);
				if (FAILED(hr))
					return hr;
#endif
			}
		}

		*pVal = (IMTRuleSet *) mRuleSet.GetInterfacePtr();
		return (*pVal)->AddRef();
	}
	catch (_com_error & err)
	{ return LogAndReturnComError(PCCache::GetLogger(),err); }
}

STDMETHODIMP CMTRateSchedule::GetParameterTable(IMTParamTableDefinition **pVal)
{
	if (!pVal)
		return E_POINTER;

	try
	{
		// create reader instance
		IMTProductCatalogPtr catalog(__uuidof(MTProductCatalog));
		//TODO: use reader object to load ParamTbl!!

		long id = -1;
		HRESULT hr = get_ParameterTableID(&id);
		if (FAILED(hr))
			return Error(L"Error getting parameter table ID", IID_IMTPriceListMapping, hr);

		*pVal = reinterpret_cast<IMTParamTableDefinition*>
			(catalog->GetParamTableDefinition(id).Detach());
	}
	catch (_com_error & err)
	{ return LogAndReturnComError(PCCache::GetLogger(),err); }

	return S_OK;

#if 0
	if (!pVal)
		return E_POINTER;


	long paramTableID = -1;
	HRESULT hr = get_ParameterTableID(&paramTableID);
	if (FAILED(hr))
		return hr;

	if (paramTableID == -1)
	{
		// TODO:
		ASSERT(0);
		return Error("Parameter table is undefined");
	}

	try
	{
		// we have the object ID but not the object itself

		// create instance of COM+ executant
		MTPRODUCTCATALOGEXECLib::IMTParamTableDefinitionReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTParamTableDefinitionReader));

		MTPRODUCTCATALOGEXECLib::IMTParamTableDefinitionPtr paramTable
			= reader->FindByID(GetSessionContextPtr(), paramTableID);

		*pVal = (IMTParamTableDefinition *) paramTable.GetInterfacePtr();
		(*pVal)->AddRef();

	}
	catch (_com_error & err)
	{ return LogAndReturnComError(PCCache::GetLogger(),err); }

	return S_OK;
#endif
}

#if 0
STDMETHODIMP CMTRateSchedule::put_ParameterTable(IMTParamTableDefinition *newVal)
{
	try
	{
		IMTParamTableDefinitionPtr paramTable(newVal);
		long id = paramTable->GetID();
		return put_ParameterTableID(id);
	}
	catch (_com_error & err)
	{ return LogAndReturnComError(PCCache::GetLogger(),err); }

	return S_OK;
}
#endif

STDMETHODIMP CMTRateSchedule::GetPriceList(IMTPriceList **pVal)
{
	if (!pVal)
		return E_POINTER;

	try
	{
		// create reader instance
		IMTProductCatalogPtr catalog(__uuidof(MTProductCatalog));
		//TODO: use reader object to load ParamTbl!!

		long id = -1;
		HRESULT hr = get_PriceListID(&id);
		if (FAILED(hr))
			return Error(L"Error getting pricelist ID", IID_IMTPriceListMapping, hr);

		*pVal = reinterpret_cast<IMTPriceList*>
			(catalog->GetPriceList(id).Detach());
	}
	catch (_com_error & err)
	{ return LogAndReturnComError(PCCache::GetLogger(),err); }

	return S_OK;
}

#if 0
STDMETHODIMP CMTRateSchedule::put_PriceList(IMTPriceList *newVal)
{
	try
	{
		IMTPriceListPtr priceList(newVal);
		return put_PriceListID(priceList->GetID());
	}
	catch (_com_error & err)
	{ return LogAndReturnComError(PCCache::GetLogger(),err); }

	return S_OK;
}
#endif

STDMETHODIMP CMTRateSchedule::get_ParameterTableID(long *pVal)
{
	return GetPropertyValue("ParameterTableID", pVal);
}

STDMETHODIMP CMTRateSchedule::put_ParameterTableID(long newVal)
{
	return PutPropertyValue("ParameterTableID", newVal);
}


STDMETHODIMP CMTRateSchedule::get_PriceListID(long *pVal)
{
	return GetPropertyValue("PriceListID", pVal);
}

STDMETHODIMP CMTRateSchedule::put_PriceListID(long newVal)
{
	return PutPropertyValue("PriceListID", newVal);
}

STDMETHODIMP CMTRateSchedule::get_TemplateID(long *pVal)
{
	return GetPropertyValue("TemplateID", pVal);
}

STDMETHODIMP CMTRateSchedule::put_TemplateID(long newVal)
{
	return PutPropertyValue("TemplateID", newVal);
}

STDMETHODIMP CMTRateSchedule::get_ScheduleType(MTPriceListMappingType *pVal)
{
	return GetPropertyValue("MappingType", (long*)pVal);
}

STDMETHODIMP CMTRateSchedule::put_ScheduleType(MTPriceListMappingType newVal)
{
	return PutPropertyValue("MappingType", (long)newVal);
}


STDMETHODIMP CMTRateSchedule::Save()
{
	//save rate schedule properties only
	return DoSave( VARIANT_TRUE, VARIANT_FALSE);
}

STDMETHODIMP CMTRateSchedule::SaveRules()
{
	//save rules only
	return DoSave( VARIANT_FALSE, VARIANT_TRUE);
}

STDMETHODIMP CMTRateSchedule::SaveWithRules()
{
	//save both rate schedule and its rules
	return DoSave( VARIANT_TRUE, VARIANT_TRUE);
}

// do the work for all the permutations of the save methods
HRESULT CMTRateSchedule::DoSave( VARIANT_BOOL aSaveRateSchedule, VARIANT_BOOL aSaveRules )
{
	HRESULT hr = S_OK;
	AuditEventsLib::MTAuditEvent deniedEvent = AuditEventsLib::AUDITEVENT_UNKNOWN;
  try
	{
		//validate properties based on their meta data (required, length, ...)
		//throws _com_error on failure
		ValidateProperties();

    MTPRODUCTCATALOGLib::IMTRateSchedulePtr pThis = this;
    MTPRODUCTCATALOGLib::MTPriceListMappingType mapType = pThis->GetScheduleType();
    // validate security
    switch(mapType)
    {
      case MAPPING_NORMAL:
      {
        if (HasID())
          deniedEvent = AuditEventsLib::AUDITEVENT_RS_UPDATE_DENIED;
        else
          deniedEvent = AuditEventsLib::AUDITEVENT_RS_CREATE_DENIED;
        break;
      }
      
      case MAPPING_ICB_SUBSCRIPTION:
      {
        if (HasID())
          deniedEvent = AuditEventsLib::AUDITEVENT_ICB_UPDATE_DENIED;
        else
          deniedEvent = AuditEventsLib::AUDITEVENT_ICB_CREATE_DENIED;

        CHECKCAP(ICBSUB_CAP);
        break;
      }

      case MAPPING_ICB_GROUP_SUBSCRIPTION:
      {
        if (HasID())
          deniedEvent = AuditEventsLib::AUDITEVENT_GROUP_ICB_UPDATE_DENIED;
        else
          deniedEvent = AuditEventsLib::AUDITEVENT_GROUP_ICB_CREATE_DENIED;
        
        CHECKCAP(ICBGROUPSUB_CAP);
        break;
      }

      default:
      { ASSERT(0);
        break;
      }
    }

		// create instance of COM+ executant
		MTPRODUCTCATALOGEXECLib::IMTRateScheduleWriterPtr
			writer(__uuidof(MTPRODUCTCATALOGEXECLib::MTRateScheduleWriter));
		
		// just cast "this"
		MTPRODUCTCATALOGEXECLib::IMTRateSchedule* schedule
			= reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTRateSchedule *>(this);

		if (HasID())  // created
			writer->Update(GetSessionContextPtr(), schedule, aSaveRateSchedule, aSaveRules);
		else					// not yet created
		{	
			if(aSaveRateSchedule == VARIANT_FALSE)
			{
				return Error("Cannot create rules without creating rate schedule");
			}

			// save ID
			hr = put_ID(writer->Create(GetSessionContextPtr(), schedule, aSaveRules));
		}
	}
	catch (_com_error & err)
	{
		long rsid;
		get_ID(&rsid);
		AuditAuthFailures(err, deniedEvent, GetSessionContextPtr()->AccountID, 
											AuditEventsLib::AUDITENTITY_TYPE_PRODCAT,
											rsid);

		return LogAndReturnComError(PCCache::GetLogger(), err);
	}

	return S_OK;
}

STDMETHODIMP CMTRateSchedule::CreateCopy(IMTRateSchedule * * apSchedule)
{
	HRESULT hr = S_OK;

	if (!apSchedule)
		return E_POINTER;

  try
	{
		IMTRateSchedulePtr thisRSPtr = this;
		IMTRateSchedulePtr newRSPtr(__uuidof(MTRateSchedule));
		MTPRODUCTCATALOGLib::IMTSessionContextPtr ctxt = thisRSPtr->GetSessionContext();
		newRSPtr->SetSessionContext(ctxt);

		// We won't set the PriceList since it has to be different
		// newRSPtr->PutPriceListID(0);
		newRSPtr->PutDescription(thisRSPtr->Description);
		newRSPtr->PutParameterTableID(thisRSPtr->ParameterTableID);
		newRSPtr->PutTemplateID(thisRSPtr->TemplateID);
		
		// Copying the rules
		MTPRODUCTCATALOGLib::IMTConfigPropSetPtr rulebufferPtr = thisRSPtr->RuleSet->WriteToSet();
		rulebufferPtr->Reset();
		newRSPtr->RuleSet->ReadFromSet( reinterpret_cast<MTPRODUCTCATALOGLib::IMTConfigPropSet*>(rulebufferPtr.Detach()) );
		
		// Copy effective date
		MTPRODUCTCATALOGLib::IMTPCTimeSpanPtr newEffectiveDatePtr = newRSPtr->EffectiveDate;
		newEffectiveDatePtr->StartDate = thisRSPtr->EffectiveDate->StartDate;
		newEffectiveDatePtr->EndDate = thisRSPtr->EffectiveDate->EndDate;
		newEffectiveDatePtr->StartDateType = thisRSPtr->EffectiveDate->StartDateType;
		newEffectiveDatePtr->EndDateType = thisRSPtr->EffectiveDate->EndDateType;
		newEffectiveDatePtr->StartOffset = thisRSPtr->EffectiveDate->StartOffset;
		newEffectiveDatePtr->EndOffset = thisRSPtr->EffectiveDate->EndOffset;
		
		// Set return value - we are done!
		*apSchedule = reinterpret_cast<IMTRateSchedule*>(newRSPtr.Detach());
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(), err);
	}

	return hr;
}

