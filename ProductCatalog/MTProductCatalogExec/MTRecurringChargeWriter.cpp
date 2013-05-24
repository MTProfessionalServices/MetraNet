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
* $Header: MTRecurringChargeWriter.cpp, 13, 10/17/2002 9:29:14 AM, David Blair$
* 
***************************************************************************/
// MTRecurringChargeWriter.cpp : Implementation of CMTRecurringChargeWriter
#include "StdAfx.h"
#include "MTProductCatalogExec.h"
#include "MTRecurringChargeWriter.h"
#include "MTDiscountWriter.h"

#include <pcexecincludes.h>
#include <mtcomerr.h>
#include <string>
#include <mttime.h>
#import <MetraTech.Localization.tlb> inject_statement("using namespace mscorlib;") no_function_mapping

/////////////////////////////////////////////////////////////////////////////
// CMTRecurringChargeWriter

/******************************************* error interface ***/
STDMETHODIMP CMTRecurringChargeWriter::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTRecurringChargeWriter
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTRecurringChargeWriter::Activate()
{
	HRESULT hr = GetObjectContext(&m_spObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTRecurringChargeWriter::CanBePooled()
{
	return FALSE;
} 

void CMTRecurringChargeWriter::Deactivate()
{
	m_spObjectContext.Release();
} 


STDMETHODIMP CMTRecurringChargeWriter::CreateProperties(IMTSessionContext* apCtxt, IMTRecurringCharge *apRC)
{
	return RunDBInsertOrUpdateQuery(apCtxt, apRC, "__INSERT_RECURRING_CHARGE_PROPERTIES_BY_ID__");
}

STDMETHODIMP CMTRecurringChargeWriter::UpdateProperties(IMTSessionContext* apCtxt, IMTRecurringCharge *apRC)
{
	MTAutoContext context(m_spObjectContext);

	try 
	{
		MTPRODUCTCATALOGLib::IMTRecurringChargePtr pRC(apRC);

		if(pRC == NULL)
			MT_THROW_COM_ERROR(E_POINTER);

		long ID = pRC->ID;

		if(ID == 0)
			MT_THROW_COM_ERROR(MTPC_OBJECT_NO_STATE);

		bool isUDRC(false);
		// Check that a UDRC has a non-empty unit name
		if(pRC->PriceableItemType->Kind == PCENTITY_TYPE_RECURRING_UNIT_DEPENDENT)
		{
			isUDRC = true;
			std::wstring unitName(pRC->UnitName);
      std::wstring unitDisplayName(pRC->UnitDisplayName);
      std::wstring::size_type npos(-1);
			if(unitName.find_first_not_of(L" ") == npos)
			{
				MT_THROW_COM_ERROR(MTPCUSER_UDRC_EMPTY_UNIT_VALUE, (const char *)pRC->DisplayName);
			}

      if(unitDisplayName.find_first_not_of(L" ") == npos)
      {
				pRC->UnitDisplayName = pRC->UnitName;
			}

			DECIMAL maxVal = pRC->MaxUnitValue;
			DECIMAL minVal = pRC->MinUnitValue;
			if(VARCMP_LT == ::VarDecCmp(&maxVal, &minVal))
			{
				MT_THROW_COM_ERROR(MTPCUSER_UDRC_MAX_LESS_THAN_MIN, (const char *)pRC->DisplayName);
			}
		}

		PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTRecurringChargeWriter::UpdateProperties(%d)", ID);

		_bstr_t strCycleUpdate = CMTPCCycleWriter::GetUpdateStringEx(pRC->Cycle);
		MTPRODUCTCATALOGLib::IMTPropertyPtr propCycle(pRC->Properties->GetItem("Cycle"));

		bool bCycleOverridable = (propCycle->Overrideable == VARIANT_TRUE);

		MTPRODUCTCATALOGLib::IMTPropertyPtr propUnitValueEnumeration(pRC->Properties->GetItem("UnitValueEnumeration"));

		bool bUnitValueEnumerationOverridable = (propUnitValueEnumeration->Overrideable == VARIANT_TRUE);

		PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTRecurringChargeWriter::UpdateProperties(%d): Cycle %s overridable; UnitValueEnumeration %s overrideable", 
																		ID, 
																		bCycleOverridable ? "is" : "is not",
																		bUnitValueEnumerationOverridable ? "is" : "is not");

		MTPRODUCTCATALOGLib::IMTProductCatalogPtr productCatalog(__uuidof(MTProductCatalog));
		MTPRODUCTCATALOGLib::IMTPropertyMetaDataSetPtr metaData = productCatalog->GetMetaData(pRC->Kind);

		if (pRC->IsTemplate() == VARIANT_TRUE)
		{
			PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTRecurringChargeWriter::UpdateProperties(%d): Update template", ID);

			// Update all properties in the template
			metaData->UpdateProperties(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(apCtxt), 
									   pRC->Properties,
									   VARIANT_FALSE, // VARIANT_BOOL aOverrideableOnly,
									   "t_recur",
									   strCycleUpdate
									   );

			// don't propagate cycle if it is overridable
			if(bCycleOverridable)
			{
				strCycleUpdate = "";
			}
			else
			{
				PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTRecurringChargeWriter::UpdateProperties(%d): Update cycle: [%s]", ID, LPCSTR(strCycleUpdate));
			}

			PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTRecurringChargeWriter::UpdateProperties(%d): Propagate template properties", ID);
			// propagate properties to the instances
			metaData->PropagateProperties(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(apCtxt), pRC->Properties, "t_recur", strCycleUpdate);
		}
		else
		{
			// don't override cycle unless it is overridable
			if(!bCycleOverridable)
			{
				strCycleUpdate = "";
			}
			else
			{
				PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTRecurringChargeWriter::UpdateProperties(%d): Update cycle: [%s]", ID, LPCSTR(strCycleUpdate));
			}

			// update only overridable properties in the instance
			metaData->UpdateProperties(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(apCtxt), 
									   pRC->Properties,
									   VARIANT_TRUE, // VARIANT_BOOL aOverrideableOnly,
									   "t_recur",
									   strCycleUpdate
									   );
		}

		if(bUnitValueEnumerationOverridable || (pRC->IsTemplate() == VARIANT_TRUE))
		{
			// For the enumeration values, we implement an update as a delete/insert.
			// We only do this if we have a template or if we have an instance and the
			// enumeration is set to be overrideable.
			PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTRecurringChargeWriter::UpdateProperties(%d): Set unit value enumeration", ID);
			ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
			rowset->Init(CONFIG_DIR);
			rowset->SetQueryTag("__DELETE_RECURRING_CHARGE_ENUMS_BY_ID__");
			rowset->AddParam("%%ID_PROP%%", ID);
			rowset->Execute();
			// Insert the new enumeration constraints.
			MTPRODUCTCATALOGLib::IMTCollectionPtr col;
			col = pRC->GetUnitValueEnumerations();
			for (long i = 1; i <= col->GetCount(); i++)
			{
				rowset->Clear();
				rowset->SetQueryTag("__INSERT_RECURRING_CHARGE_ENUMS_BY_ID__");
				rowset->AddParam("%%ID_PROP%%", ID);
				rowset->AddParam("%%ENUM_VALUE%%", (DECIMAL)col->GetItem(i));
				rowset->Execute();
			}
		}

		if (!bUnitValueEnumerationOverridable && (pRC->IsTemplate() == VARIANT_TRUE))
		{
			// Push template properties down to the instances based on it.  Once again, this
			// is a delete/insert instead of a single update statement.
			PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTRecurringChargeWriter::UpdateProperties(%d): Propagate unit value enumeration", ID);
			ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
			rowset->Init(CONFIG_DIR);
			rowset->SetQueryTag("__DELETE_RECURRING_CHARGE_ENUMS_BY_TEMPLATE_ID__");
			rowset->AddParam("%%ID_PROP%%", ID);
			rowset->Execute();
			rowset->Clear();
			rowset->SetQueryTag("__PROPAGATE_RECURRING_CHARGE_ENUMS_BY_TEMPLATE_ID__");
			rowset->AddParam("%%ID_PROP%%", ID);
			rowset->Execute();
		}

		// Check that the modifications that we have made are not incompatible
		// with any unit values in existing subscriptions that are effective now
		// or in the future (we allow "expired" unit values to break the constraint)
		if(isUDRC)
		{
			// We have a template, check all subscriptions to instances based on the template.
			// We have an instance, check only subscriptions to it.
			ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
			rowset->Init(CONFIG_DIR);
			rowset->SetQueryTag("__GET_UNIT_VALUE_CONSTRAINT_VIOLATIONS__");
			rowset->AddParam("%%TT_MAX%%", GetMaxMTOLETime());
			rowset->Execute();
			if(rowset->GetRecordCount() > 0)
			{
				MT_THROW_COM_ERROR(MTPCUSER_UDRC_CONSTRAINT_INVALID_SUBS);
			}

      //Localized Display Names
      rowset->Clear();
      rowset->SetQueryTag("__GET_UNITDISPLAYNAME_DESC_ID_FOR_UDRC__");
      rowset->AddParam("%%ID_PROP%%", ID);
      rowset->Execute();

      _variant_t dispId = rowset->GetValue(L"n_unit_display_name");
      if (dispId.vt != VT_NULL && (long)dispId > 0)
      {
        MetraTech_Localization::ILocalizedEntityPtr displayNameLocalizationPtr(pRC->UnitDisplayNames);
        displayNameLocalizationPtr->SaveWithID((long)rowset->GetValue(L"n_unit_display_name"));
      }
		}
	}
	catch (_com_error & err)
	{
		PCCache::GetLogger().LogVarArgs(LOG_ERROR, "CMTRecurringChargeWriter::UpdateProperties() caught error 0x%08h", err.Error());
		return ReturnComError(err);
	}

	context.Complete();

	return S_OK;
}

STDMETHODIMP CMTRecurringChargeWriter::RemoveProperties(IMTSessionContext* apCtxt, long lDBID)
{
	MTAutoContext context(m_spObjectContext);

	try
	{
		long ID = lDBID;

		if(ID == 0)
			MT_THROW_COM_ERROR(MTPC_OBJECT_NO_STATE);

		PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTRecurringChargeWriter::RemoveProperties(%d)", ID);

		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		// Delete all of the enumeration constraints
		rowset->SetQueryTag("__DELETE_RECURRING_CHARGE_ENUMS_BY_ID__");
		rowset->AddParam("%%ID_PROP%%", ID);
		rowset->Execute();

		// Delete the recurring charge itself
		rowset->Clear();
		rowset->SetQueryTag("__DELETE_RECURRING_CHARGE_PROPERTIES_BY_ID__");
		rowset->AddParam("%%ID_PROP%%", ID);

		rowset->Execute();

	}
	catch (_com_error & err)
	{
		PCCache::GetLogger().LogVarArgs(LOG_ERROR, "CMTRecurringChargeWriter::RemoveProperties() caught error 0x%08h", err.Error());
		return ReturnComError(err);
	}

	context.Complete();

	return S_OK;
}

HRESULT CMTRecurringChargeWriter::RunDBInsertOrUpdateQuery(IMTSessionContext* apCtxt, IMTRecurringCharge  *apRC, LPCSTR lpQueryName)
{
	MTAutoContext context(m_spObjectContext);

	try
	{
		MTPRODUCTCATALOGLib::IMTRecurringChargePtr pRC(apRC);

		if(pRC == NULL)
			MT_THROW_COM_ERROR(E_POINTER);

		long ID = pRC->ID;

		if(ID == 0)
			MT_THROW_COM_ERROR(MTPC_OBJECT_NO_STATE);

		// Check that a UDRC has a non-empty unit name and unit display name
		if(pRC->PriceableItemType->Kind == PCENTITY_TYPE_RECURRING_UNIT_DEPENDENT)
		{
			std::wstring unitName(pRC->UnitName);
      std::wstring unitDisplayName(pRC->UnitDisplayName);
			std::wstring::size_type npos(-1);
			if(unitName.find_first_not_of(L" ") == npos)
			{
				MT_THROW_COM_ERROR(MTPCUSER_UDRC_EMPTY_UNIT_VALUE, (const char *)pRC->DisplayName);
			}

      if(unitDisplayName.find_first_not_of(L" ") == npos)
      {
				pRC->UnitDisplayName = pRC->UnitName;
			}

			DECIMAL maxVal = pRC->MaxUnitValue;
			DECIMAL minVal = pRC->MinUnitValue;
			if(VARCMP_LT == ::VarDecCmp(&maxVal, &minVal))
			{
				MT_THROW_COM_ERROR(MTPCUSER_UDRC_MAX_LESS_THAN_MIN, (const char *)pRC->DisplayName);
			}
		}

    // Retrieve the language id
    long languageID;
		ASSERT(apCtxt);
		HRESULT hr = apCtxt->get_LanguageID(&languageID);
		if (FAILED(hr))
		  return hr;

		PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTRecurringChargeWriter::RunDBInsertOrUpdateQuery(%d, %s)", ID, lpQueryName);

		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		rowset->SetQueryTag(lpQueryName);
    rowset->AddParam("%%ID_PROP%%", ID);
		rowset->AddParam("%%ID_LANG_CODE%%", languageID);

		rowset->AddParam("%%B_ADVANCE%%", MTTypeConvert::BoolToString(pRC->ChargeInAdvance));
		rowset->AddParam("%%B_PRORATE_ON_ACTIVATE%%", MTTypeConvert::BoolToString(pRC->ProrateOnActivation));
		rowset->AddParam("%%B_PRORATE_INSTANTLY%%", MTTypeConvert::BoolToString(pRC->ProrateInstantly));
		rowset->AddParam("%%B_PRORATE_ON_DEACTIVATE%%", MTTypeConvert::BoolToString(pRC->ProrateOnDeactivation));
		rowset->AddParam("%%B_PRORATE_ON_RATE_CHANGE%%", MTTypeConvert::BoolToString(pRC->ProrateOnRateChange));
		rowset->AddParam("%%B_FIXED_PRORATION_LENGTH%%", MTTypeConvert::BoolToString(pRC->FixedProrationLength));
		rowset->AddParam("%%B_CHARGE_PER_PARTICIPANT%%", MTTypeConvert::BoolToString(pRC->ChargePerParticipant));
    _variant_t vtNULL;
		vtNULL.vt = VT_NULL;
    _bstr_t unitName(pRC->UnitName);
    _bstr_t unitDisplayName(pRC->UnitDisplayName);

    if (unitName.length() == 0)
    {
		  rowset->AddParam("%%NM_UNIT_NAME%%", vtNULL);
    }
    else
    {
      rowset->AddParam("%%NM_UNIT_NAME%%", pRC->UnitName);
    }

    if (unitDisplayName.length() == 0)
    {
		  rowset->AddParam("%%NM_UNIT_DISPLAY_NAME%%", vtNULL);
    }
    else
    {
      rowset->AddParam("%%NM_UNIT_DISPLAY_NAME%%", pRC->UnitDisplayName);
    }

		rowset->AddParam("%%N_RATING_TYPE%%", (long) pRC->RatingType);
		rowset->AddParam("%%B_INTEGRAL%%", MTTypeConvert::BoolToString(pRC->IntegerUnitValue));
		rowset->AddParam("%%MAX_UNIT_VALUE%%", pRC->MaxUnitValue);
		rowset->AddParam("%%MIN_UNIT_VALUE%%", pRC->MinUnitValue);

		PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTRecurringChargeWriter::RunDBInsertOrUpdateQuery(%d, %s): prepare cycle.", ID, lpQueryName);
		// saves cycle information
		CMTPCCycleWriter::SaveCycleToRowsetEx(pRC->Cycle, rowset);

		rowset->Execute();

    //Localized Display Names
    rowset->Clear();
    rowset->SetQueryTag("__GET_UNITDISPLAYNAME_DESC_ID_FOR_UDRC__");
    rowset->AddParam("%%ID_PROP%%", ID);
    rowset->Execute();
    
    _variant_t dispId = rowset->GetValue(L"n_unit_display_name");
    if (dispId.vt != VT_NULL && (long)dispId > 0)
    {
      MetraTech_Localization::ILocalizedEntityPtr displayNameLocalizationPtr(pRC->UnitDisplayNames);
      displayNameLocalizationPtr->SaveWithID((long)dispId);
    }

		// Delete all of the enumeration constraints (they won't exist in the insert case)
		rowset->Clear();
		rowset->SetQueryTag("__DELETE_RECURRING_CHARGE_ENUMS_BY_ID__");
		rowset->AddParam("%%ID_PROP%%", ID);
		rowset->Execute();
		// Insert the new enumeration constraints.
		MTPRODUCTCATALOGLib::IMTCollectionPtr col;
		col = pRC->GetUnitValueEnumerations();
		for (long i = 1; i <= col->GetCount(); i++)
		{
			rowset->Clear();
			rowset->SetQueryTag("__INSERT_RECURRING_CHARGE_ENUMS_BY_ID__");
			rowset->AddParam("%%ID_PROP%%", ID);
			rowset->AddParam("%%ENUM_VALUE%%", (DECIMAL)col->GetItem(i));
			rowset->Execute();
		}

		PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTRecurringChargeWriter::RunDBInsertOrUpdateQuery(%d, %s): succeeded.", ID, lpQueryName);
	}
	catch (_com_error & err)
	{
		PCCache::GetLogger().LogVarArgs(LOG_ERROR, "CMTRecurringChargeWriter::RunDBInsertOrUpdateQuery() caught error 0x%08h", err.Error());
		return ReturnComError(err);
	}

	context.Complete();

	return S_OK;
}
