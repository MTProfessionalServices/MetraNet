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
* $Header: MTRecurringChargeReader.cpp, 11, 10/17/2002 9:29:14 AM, David Blair$
* 
***************************************************************************/

// MTRecurringChargeReader.cpp : Implementation of CMTRecurringChargeReader
#include "StdAfx.h"
#include "MTProductCatalogExec.h"
#include "MTRecurringChargeReader.h"
#include "MTDiscountReader.h"

#include <pcexecincludes.h>
#include <mtcomerr.h>
#import <MetraTech.Localization.tlb> inject_statement("using namespace mscorlib;") no_function_mapping

/////////////////////////////////////////////////////////////////////////////
// CMTRecurringChargeReader

/******************************************* error interface ***/
STDMETHODIMP CMTRecurringChargeReader::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTRecurringChargeReader
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTRecurringChargeReader::Activate()
{
	HRESULT hr = GetObjectContext(&m_spObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTRecurringChargeReader::CanBePooled()
{
	return FALSE;
} 

void CMTRecurringChargeReader::Deactivate()
{
	m_spObjectContext.Release();
} 

STDMETHODIMP CMTRecurringChargeReader::PopulateProperties(IMTSessionContext* apCtxt, IMTRecurringCharge *apRC)
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

		PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTRecurringChargeReader::PopulateProperties(%d)", ID);
    
    long languageID;
		ASSERT(apCtxt);
		HRESULT hr = apCtxt->get_LanguageID(&languageID);
		if (FAILED(hr))
		  return hr;

		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		rowset->SetQueryTag("__GET_RECURRING_CHARGE_PROPERTIES_BY_ID__");
		rowset->AddParam("%%ID_PROP%%", ID);
    rowset->AddParam("%%ID_LANG_CODE%%", languageID);

		rowset->Execute();

		if(0 == rowset->GetRecordCount())
			MT_THROW_COM_ERROR(MTPC_ITEM_NOT_FOUND_BY_ID, PCENTITY_TYPE_RECURRING, ID);

		//Because recurring charge and unit dependent recurring charges are handled by the same class
		//We need to explicitly set the Kind here based on which priceable item we are loading
		pRC->Kind = static_cast<MTPRODUCTCATALOGLib::MTPCEntityType>((long)rowset->GetValue("n_kind"));

		pRC->ChargeInAdvance = MTTypeConvert::StringToBool((_bstr_t)rowset->GetValue("b_advance"));
		pRC->ProrateOnActivation = MTTypeConvert::StringToBool((_bstr_t)rowset->GetValue("b_prorate_on_activate"));
		pRC->ProrateInstantly = MTTypeConvert::StringToBool((_bstr_t)rowset->GetValue("b_prorate_instantly"));
		pRC->ProrateOnDeactivation = MTTypeConvert::StringToBool((_bstr_t)rowset->GetValue("b_prorate_on_deactivate"));
		pRC->ProrateOnRateChange = MTTypeConvert::StringToBool((_bstr_t)rowset->GetValue("b_prorate_on_rate_change"));
		pRC->FixedProrationLength = MTTypeConvert::StringToBool((_bstr_t)rowset->GetValue("b_fixed_proration_length"));
		pRC->ChargePerParticipant = MTTypeConvert::StringToBool((_bstr_t)rowset->GetValue("b_charge_per_participant"));
    _variant_t val = rowset->GetValue("nm_unit_name");
    if (val.vt != VT_NULL)
    {
		  pRC->UnitName = (_bstr_t)val;
    }
    
    val = rowset->GetValue("nm_unit_display_name");
    if (val.vt != VT_NULL)
    {
      pRC->UnitDisplayName = (_bstr_t)val;
    }

		pRC->RatingType = (MTPRODUCTCATALOGLib::MTUDRCRatingType)((long)rowset->GetValue("n_rating_type"));
		pRC->IntegerUnitValue = MTTypeConvert::StringToBool((_bstr_t)rowset->GetValue("b_integral"));
		pRC->MaxUnitValue = (DECIMAL)rowset->GetValue("max_unit_value");
		pRC->MinUnitValue = (DECIMAL)rowset->GetValue("min_unit_value");

    _variant_t dispId = rowset->GetValue(L"n_unit_display_name");
    if (dispId.vt != VT_NULL && (long)dispId > 0)
    {
      MetraTech_Localization::ILocalizedEntityPtr unitNameLocalizationPtr(pRC->UnitDisplayNames);
      unitNameLocalizationPtr->ID = (long)dispId;
    }


		// load cycle information
		CMTPCCycleReader::LoadCycleFromRowsetEx(pRC->Cycle, rowset);

		// Go get the enumeration constraints on a UDRC
		rowset->Clear();
		rowset->SetQueryTag("__GET_RECURRING_CHARGE_ENUMS_BY_ID__");
		rowset->AddParam("%%ID_PROP%%", ID);

		rowset->Execute();

		while(!bool(rowset->RowsetEOF))
		{
			pRC->AddUnitValueEnumeration((DECIMAL) rowset->GetValue("enum_value"));
			rowset->MoveNext();
		}		
	}
	catch (_com_error & err)
	{
		PCCache::GetLogger().LogVarArgs(LOG_ERROR, "CMTRecurringChargeReader::PopulateProperties() caught error 0x%08h", err.Error());
		return ReturnComError(err);
	}

	context.Complete();
	PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTRecurringChargeReader::PopulateProperties() succeeded");

	return S_OK;
}
