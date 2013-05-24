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
#include <comdef.h>
#include <mtcomerr.h>

#include "MTProductCatalog.h"
#include "MTParamTableDefinition.h"


using MTPRODUCTCATALOGLib::IMTRateSchedulePtr;
using MTPRODUCTCATALOGLib::IMTPriceListPtr;

using MTPRODUCTCATALOGEXECLib::IMTRateScheduleReaderPtr;
using MTPRODUCTCATALOGEXECLib::MTRateScheduleReader;
using MTPRODUCTCATALOGEXECLib::IMTRateScheduleWriterPtr;
using MTPRODUCTCATALOGEXECLib::MTRateScheduleWriter;


/////////////////////////////////////////////////////////////////////////////
// CMTParamTableDefinition

STDMETHODIMP CMTParamTableDefinition::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
    &IID_IMTParamTableDefinition,
    &IID_IMTPCBase
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

CMTParamTableDefinition::CMTParamTableDefinition()
{
	m_pUnkMarshaler = NULL;
	mSecondaryDataHasBeenLoaded = false;
	mSecondaryDataLoading = false;
}

HRESULT CMTParamTableDefinition::FinalConstruct()
{
	try
	{
		LoadPropertiesMetaData(PCENTITY_TYPE_PARAM_TABLE_DEF);

		return CoCreateFreeThreadedMarshaler(
			GetControllingUnknown(), &m_pUnkMarshaler.p);
	}
	catch (_com_error & err)
	{ return LogAndReturnComError(PCCache::GetLogger(),err); }
}

HRESULT CMTParamTableDefinition::OnGetProperties()
{
	// if client wants full property collection, make sure all are loaded
	return LoadSecondaryDataIfNeeded();
}


STDMETHODIMP CMTParamTableDefinition::get_ID(long *pVal)
{
	return GetPropertyValue("ID", pVal);
}

STDMETHODIMP CMTParamTableDefinition::put_ID(long newVal)
{
	return PutPropertyValue("ID", newVal);
}

STDMETHODIMP CMTParamTableDefinition::get_Name(BSTR *pVal)
{
	return GetPropertyValue("Name", pVal);
}

STDMETHODIMP CMTParamTableDefinition::put_Name(BSTR newVal)
{
	return PutPropertyValue("Name", newVal);
}

STDMETHODIMP CMTParamTableDefinition::get_DisplayName(BSTR *pVal)
{
  HRESULT hr = LoadSecondaryDataIfNeeded();
	if (FAILED(hr))
		return hr;
	return GetPropertyValue("DisplayName", pVal);
}

STDMETHODIMP CMTParamTableDefinition::put_DisplayName(BSTR newVal)
{
	return PutPropertyValue("DisplayName", newVal);
}

STDMETHODIMP CMTParamTableDefinition::get_ConditionHeader(BSTR *pVal)
{
  HRESULT hr = LoadSecondaryDataIfNeeded();
	if (FAILED(hr))
		return hr;
	return GetPropertyValue("ConditionHeader", pVal);
}

STDMETHODIMP CMTParamTableDefinition::put_ConditionHeader(BSTR newVal)
{
	return PutPropertyValue("ConditionHeader", newVal);
}

STDMETHODIMP CMTParamTableDefinition::get_ActionHeader(BSTR *pVal)
{
  HRESULT hr = LoadSecondaryDataIfNeeded();
	if (FAILED(hr))
		return hr;
	return GetPropertyValue("ActionHeader", pVal);
}

STDMETHODIMP CMTParamTableDefinition::put_ActionHeader(BSTR newVal)
{
	return PutPropertyValue("ActionHeader", newVal);
}

STDMETHODIMP CMTParamTableDefinition::get_HelpURL(BSTR *pVal)
{
  HRESULT hr = LoadSecondaryDataIfNeeded();
	if (FAILED(hr))
		return hr;
	return GetPropertyValue("HelpURL", pVal);
}

STDMETHODIMP CMTParamTableDefinition::put_HelpURL(BSTR newVal)
{
	return PutPropertyValue("HelpURL", newVal);
}

STDMETHODIMP CMTParamTableDefinition::get_DBTableName(BSTR *pVal)
{
	return GetPropertyValue("DBTableName", pVal);
}

STDMETHODIMP CMTParamTableDefinition::put_DBTableName(BSTR newVal)
{
	return PutPropertyValue("DBTableName", newVal);
}

STDMETHODIMP CMTParamTableDefinition::get_IndexedProperty(BSTR *pVal)
{
  HRESULT hr = LoadSecondaryDataIfNeeded();
	if (FAILED(hr))
		return hr;
	return GetPropertyValue("IndexedProperty", pVal);
}

STDMETHODIMP CMTParamTableDefinition::put_IndexedProperty(BSTR newVal)
{
	return PutPropertyValue("IndexedProperty", newVal);
}

STDMETHODIMP CMTParamTableDefinition::get_ConditionMetaData(IMTCollection **pVal)
{
  HRESULT hr = LoadSecondaryDataIfNeeded();
	if (FAILED(hr))
		return hr;
	return mConditions.CopyTo(pVal);
}

STDMETHODIMP CMTParamTableDefinition::get_ActionMetaData(IMTCollection **pVal)
{
  HRESULT hr = LoadSecondaryDataIfNeeded();
	if (FAILED(hr))
		return hr;
	return mActions.CopyTo(pVal);
}

STDMETHODIMP CMTParamTableDefinition::Save()
{
	// TODO: Add your implementation code here

	return S_OK;
}

STDMETHODIMP CMTParamTableDefinition::AddConditionMetaData(IMTConditionMetaData **pVal)
{
	if (!pVal)
		return E_POINTER;

	CComPtr<IMTConditionMetaData> condition;
	HRESULT hr = condition.CoCreateInstance(__uuidof(MTConditionMetaData));
	if (FAILED(hr))
		return hr;

	//pass the session context on to objects created from this one
	MTPRODUCTCATALOGLib::IMTSessionContextPtr ctxt = GetSessionContextPtr();
	condition->SetSessionContext((IMTSessionContext *) ctxt.GetInterfacePtr());

	hr = mConditions.Add(condition);
	if (FAILED(hr))
		return hr;

	return condition.CopyTo(pVal);
}

STDMETHODIMP CMTParamTableDefinition::AddActionMetaData(IMTActionMetaData **pVal)
{
	if (!pVal)
		return E_POINTER;

	CComPtr<IMTActionMetaData> action;
	HRESULT hr = action.CoCreateInstance(__uuidof(MTActionMetaData));
	if (FAILED(hr))
		return hr;

	//pass the session context on to objects created from this one
	MTPRODUCTCATALOGLib::IMTSessionContextPtr ctxt = GetSessionContextPtr();
	action->SetSessionContext((IMTSessionContext *) ctxt.GetInterfacePtr());

	hr = mActions.Add(action);
	if (FAILED(hr))
		return hr;


	return action.CopyTo(pVal);
}


STDMETHODIMP CMTParamTableDefinition::CreateRateSchedule(long aPriceListID,
																												 long aPrcItemTmplID, 
																												 IMTRateSchedule **apSchedule)
{
	if (!apSchedule)
		return E_POINTER;

	try
	{
		IMTRateSchedulePtr schedule(__uuidof(MTRateSchedule));

		//pass the session context on to objects created from this one
		MTPRODUCTCATALOGLib::IMTParamTableDefinitionPtr thisPtr = this;
		MTPRODUCTCATALOGLib::IMTSessionContextPtr ctxt = thisPtr->GetSessionContext();
		schedule->SetSessionContext(ctxt);
		
		schedule->PutParameterTableID(GetID());
		schedule->PutPriceListID(aPriceListID);
		schedule->PutTemplateID(aPrcItemTmplID);

		*apSchedule = (IMTRateSchedule *) schedule.Detach();
	}
	catch (_com_error & err)
	{ return LogAndReturnComError(PCCache::GetLogger(),err); }

	return S_OK;
}

STDMETHODIMP CMTParamTableDefinition::GetRateSchedule(long aScheduleID, IMTRateSchedule **apSchedule)
{
	if (!apSchedule)
		return E_POINTER;

  try
	{
		// create reader instance and pass through
		IMTRateScheduleReaderPtr rsReader(__uuidof(MTRateScheduleReader));

		IMTRateSchedulePtr schedule = rsReader->Find(GetSessionContextPtr(), aScheduleID);

		*apSchedule = (IMTRateSchedule *) schedule.Detach();
	}
	catch (_com_error & err)
	{ return LogAndReturnComError(PCCache::GetLogger(),err); }

	return S_OK;
}

STDMETHODIMP CMTParamTableDefinition::RemoveRateSchedule(long aRateScheduleID)
{
	AuditEventsLib::MTAuditEvent deniedEvent = AuditEventsLib::AUDITEVENT_UNKNOWN;

	// TODO: Make sure that auth errors and general errors don't get mixed up, since they are caught by the same catch.
	try
	{
		if (!PCCache::IsBusinessRuleEnabled(PCCONFIGLib::MTPC_BUSINESS_RULE_Rates_DeleteOverride))
			MT_THROW_COM_ERROR(IID_IMTProductCatalog, MTPCUSER_DOES_NOT_ALLOW_RATE_DELETE);

		deniedEvent = AuditEventsLib::AUDITEVENT_RS_DELETE_DENIED;
		CHECKCAP(DELETE_RATES_CAP);

		//pass the session context on to objects created from this one
		IMTRateScheduleWriterPtr rsWriter(__uuidof(MTRateScheduleWriter));
		rsWriter->Remove(GetSessionContextPtr(), aRateScheduleID);
	}
	catch (_com_error & err)
	{
		AuditAuthFailures(err, deniedEvent, GetSessionContextPtr()->AccountID, 
											AuditEventsLib::AUDITENTITY_TYPE_PRODCAT,
											aRateScheduleID);
		return LogAndReturnComError(PCCache::GetLogger(),err); 
	}

	return S_OK;
}

STDMETHODIMP CMTParamTableDefinition::GetRateSchedulesAsRowset(VARIANT aFilter, VARIANT aIncludeHidden, IMTRowSet **apRowset)
{
	//return ICB and non-ICB rate schedules
	return DoGetRateSchedulesAsRowset(VARIANT_TRUE, aIncludeHidden, aFilter, apRowset);
}

STDMETHODIMP CMTParamTableDefinition::GetRateSchedulesByPriceableItemTypeAsRowset(long aPriceableItemTypeID, IMTRowSet **apRowset)
{
	//return ICB and non-ICB rate schedules for the priceable item type
	return DoGetRateSchedulesByPriceableItemAsRowset(aPriceableItemTypeID, VARIANT_TRUE, apRowset );
}

STDMETHODIMP CMTParamTableDefinition::GetNonICBRateSchedulesAsRowset(VARIANT aFilter, IMTRowSet **apRowset)
{
	//return non-ICB rate schedules only
	_variant_t vtIncludeHidden = VARIANT_TRUE;
	return DoGetRateSchedulesAsRowset(VARIANT_FALSE, vtIncludeHidden, aFilter, apRowset);
}

STDMETHODIMP CMTParamTableDefinition::GetNonICBRateSchedulesByPriceableItemTypeAsRowset(long aPriceableItemTypeID, IMTRowSet **apRowset)
{
	//return non-ICB rate schedules for a priceable item type
	return DoGetRateSchedulesByPriceableItemAsRowset(aPriceableItemTypeID, VARIANT_FALSE, apRowset);
}

STDMETHODIMP CMTParamTableDefinition::DoGetRateSchedulesByPriceableItemAsRowset(long aPriceableItemTypeID, VARIANT_BOOL aIncludeICB, IMTRowSet **apRowset)
{
	if (!apRowset)
		return E_POINTER;

  try
	{
		// create reader instance and pass through
		IMTRateScheduleReaderPtr rsReader(__uuidof(MTRateScheduleReader));

		*apRowset = reinterpret_cast<IMTSQLRowset*> (rsReader->FindForParamTablePriceableItemTypeAsRowset(GetSessionContextPtr(), GetID(), aPriceableItemTypeID, aIncludeICB).Detach());
	}
	catch (_com_error & err)
	{ return LogAndReturnComError(PCCache::GetLogger(),err); }

	return S_OK;
}

STDMETHODIMP CMTParamTableDefinition::DoGetRateSchedulesAsRowset(VARIANT_BOOL aIncludeICB, VARIANT aIncludeHidden, VARIANT aFilter, IMTRowSet **apRowset)
{
	if (!apRowset)
		return E_POINTER;

  try
	{
		_variant_t vtIncludeHidden;
		if(!OptionalVariantConversion(aIncludeHidden,VT_BOOL,vtIncludeHidden)) {
			vtIncludeHidden = VARIANT_TRUE;
		}

		// create reader instance and pass through
		IMTRateScheduleReaderPtr rsReader(__uuidof(MTRateScheduleReader));
		*apRowset = reinterpret_cast<IMTSQLRowset*> (rsReader->FindForParamTableAsRowset(GetSessionContextPtr(), GetID(), aIncludeICB, vtIncludeHidden.boolVal, aFilter).Detach());
	}
	catch (_com_error & err)
	{ return LogAndReturnComError(PCCache::GetLogger(),err); }

	return S_OK;
}


STDMETHODIMP CMTParamTableDefinition::GetRateSchedulesByPriceListAsRowset(long aPricelistID, long aPITemplate, IMTRowSet **apRowset)
{
	if (!apRowset)
		return E_POINTER;

  try
	{
		// create reader instance and pass through
		IMTRateScheduleReaderPtr rsReader(__uuidof(MTRateScheduleReader));
		*apRowset = reinterpret_cast<IMTSQLRowset*> (rsReader->FindForParamTablePriceListAsRowset(GetSessionContextPtr(), GetID(), aPricelistID, aPITemplate).Detach());
	}
	catch (_com_error & err)
	{ return LogAndReturnComError(PCCache::GetLogger(),err); }

	return S_OK;
}

// for performance reason not all data members will be loaded immediately.
// LoadSecondaryData() checks if the on demand data has been loaded already,
// and if not loads it.
//
// the following (primary) data members will be loaded on intial read:
//   - ID
//   - Name
//   - DBTableName
// the following (secondary) data members will be loaded first time asked for:
//   - DisplayName(*)
//   - ActionHeader 
//   - ConditionHeader
//   - HelpUrl 
//   - IndexedProperty
//   - mConditions
//   - mActions
HRESULT CMTParamTableDefinition::LoadSecondaryDataIfNeeded()
{
  try
	{
		                                     //load secondary data:
		if (!mSecondaryDataHasBeenLoaded &&  // - only once
			  !mSecondaryDataLoading &&        // - disable reentrant call while loading
				HasID() )                        // - only load for already created objects
		{	
			mSecondaryDataLoading = true;
			
			// create reader instance and load the rest.
			MTPRODUCTCATALOGEXECLib::IMTParamTableDefinitionReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTParamTableDefinitionReader));
			reader->LoadSecondaryData(GetSessionContextPtr(), reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTParamTableDefinition *>(this));

			mSecondaryDataLoading = false;
			mSecondaryDataHasBeenLoaded = true;
		}
	}
	catch (_com_error & err)
	{	mSecondaryDataLoading = false;
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

