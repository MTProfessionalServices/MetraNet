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
* $Header: MTRecurringCharge.cpp, 15, 10/17/2002 9:29:12 AM, David Blair$
* 
***************************************************************************/

#include "StdAfx.h"
#include "MTProductCatalog.h"
#include "MTRecurringCharge.h"
#include <mtcomerr.h>
#include <limits.h>
#include <MTDec.h>

/////////////////////////////////////////////////////////////////////////////
// CMTRecurringCharge

STDMETHODIMP CMTRecurringCharge::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
    &IID_IMTRecurringCharge,
    &IID_IMTPriceableItem,
    &IID_IMTPCBase
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTRecurringCharge::FinalConstruct()
{
	try
	{
		HRESULT hr = CoCreateFreeThreadedMarshaler(GetControllingUnknown(), &m_pUnkMarshaler.p);
		if (FAILED(hr))
			throw _com_error(hr);

		//load meta data
		LoadPropertiesMetaData( PCENTITY_TYPE_RECURRING );

		// set kind
		put_Kind( PCENTITY_TYPE_RECURRING );

		// create MTPCCycle isntance
		MTPRODUCTCATALOGLib::IMTPCCyclePtr cyclePtr(__uuidof(MTPCCycle));
		PutPropertyObject("Cycle", cyclePtr);

		// For backward compatibility, set per participant to true
		// and initialize unit dependent properties.
		PutPropertyValue("ChargePerParticipant", VARIANT_TRUE);
		PutPropertyValue("UnitName", L"  ");
    PutPropertyValue("UnitDisplayName", L"  ");

		PutPropertyValue("RatingType", (long) UDRCRATING_TYPE_TAPERED);

		PutPropertyValue("IntegerUnitValue", VARIANT_FALSE);
		DECIMAL val;
		DECIMAL_SETZERO(val);

		// TODO: Find out what the correct default are.
		// 0 seems to be the most sensible default value (negative unit
		// values result in negative charges!).  Will these max/min values work for Oracle
		// and SQL Server?
		val.Lo64 = 999999999i64;
		val.Hi32 = 0;
		PutPropertyValue("MaxUnitValue", val);
		val.Lo64 = 0i64;
		PutPropertyValue("MinUnitValue", val);
	}	
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

void CMTRecurringCharge::OnSetSessionContext(IMTSessionContext* apSessionContext)
{
	// session context for nested objects can't be set inside the constructor
	// (since this object does not have a session context at the time it constructs its nested objects)
	// so set session context of derived objects now
	// caller will catch any exceptions

	MTPRODUCTCATALOGLib::IMTRecurringChargePtr thisPtr = this;

	thisPtr->Cycle->SetSessionContext(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(apSessionContext));
}


// ----------------------------------------------------------------
// Name:          CopyNonBaseMembersTo
// Arguments:     apPrcItemTarget - PI template or instanc
//                
// Errors Raised: _com_error
// Description:   copy the members that are not in the base class
//                this method can be called for templates or instances
// ----------------------------------------------------------------
void CMTRecurringCharge::CopyNonBaseMembersTo(IMTPriceableItem* apPrcItemTarget)
{
	MTPRODUCTCATALOGLib::IMTRecurringChargePtr source = this;
	MTPRODUCTCATALOGLib::IMTRecurringChargePtr target = apPrcItemTarget;

	target->ChargeInAdvance = source->ChargeInAdvance;
	target->ProrateOnActivation = source->ProrateOnActivation;
	target->ProrateInstantly = source->ProrateInstantly;
	target->ProrateOnDeactivation = source->ProrateOnDeactivation;
	target->ProrateOnRateChange = source->ProrateOnRateChange;
	target->FixedProrationLength = source->FixedProrationLength;
	target->ChargePerParticipant = source->ChargePerParticipant;
	target->UnitName = source->UnitName;
   target->UnitDisplayName = source->UnitDisplayName;
	target->IntegerUnitValue = source->IntegerUnitValue;
	target->MaxUnitValue = source->MaxUnitValue;
	target->MinUnitValue = source->MinUnitValue;
	target->RatingType = source->RatingType;

	//copy localized unitdisplaynames
    MetraTech_Localization::ILocalizedEntityPtr sourceUnitDisplayNameLocalizationPtr(source->UnitDisplayNames);
    MetraTech_Localization::ILocalizedEntityPtr targetUnitDisplayNameLocalizationPtr(target->UnitDisplayNames);
    targetUnitDisplayNameLocalizationPtr->Copy(sourceUnitDisplayNameLocalizationPtr);

	MTPRODUCTCATALOGLib::IMTCollectionPtr col;
	col = source->GetUnitValueEnumerations();

	for (long i = 1; i <= col->GetCount(); i++)
	{
		target->AddUnitValueEnumeration((DECIMAL)col->GetItem(i));
	}

	// copy Cycle here
	source->Cycle->CopyTo(target->Cycle);
}

STDMETHODIMP CMTRecurringCharge::get_ChargeInAdvance(VARIANT_BOOL *pVal)
{
	return GetPropertyValue("ChargeInAdvance", pVal);
}

STDMETHODIMP CMTRecurringCharge::put_ChargeInAdvance(VARIANT_BOOL newVal)
{
	return PutPropertyValue("ChargeInAdvance", newVal);
}

STDMETHODIMP CMTRecurringCharge::get_ProrateOnActivation(VARIANT_BOOL *pVal)
{
	return GetPropertyValue("ProrateOnActivation", pVal);
}

STDMETHODIMP CMTRecurringCharge::put_ProrateOnActivation(VARIANT_BOOL newVal)
{
	return PutPropertyValue("ProrateOnActivation", newVal);
}

STDMETHODIMP CMTRecurringCharge::get_ProrateInstantly(VARIANT_BOOL *pVal)
{
	return GetPropertyValue("ProrateInstantly", pVal);
}

STDMETHODIMP CMTRecurringCharge::put_ProrateInstantly(VARIANT_BOOL newVal)
{
	return PutPropertyValue("ProrateInstantly", newVal);
}

STDMETHODIMP CMTRecurringCharge::get_ProrateOnDeactivation(VARIANT_BOOL *pVal)
{
	return GetPropertyValue("ProrateOnDeactivation", pVal);
}

STDMETHODIMP CMTRecurringCharge::put_ProrateOnDeactivation(VARIANT_BOOL newVal)
{
	return PutPropertyValue("ProrateOnDeactivation", newVal);
}

STDMETHODIMP CMTRecurringCharge::get_ProrateOnRateChange(VARIANT_BOOL *pVal)
{
	return GetPropertyValue("ProrateOnRateChange", pVal);
}

STDMETHODIMP CMTRecurringCharge::put_ProrateOnRateChange(VARIANT_BOOL newVal)
{
	return PutPropertyValue("ProrateOnRateChange", newVal);
}

STDMETHODIMP CMTRecurringCharge::get_FixedProrationLength(VARIANT_BOOL *pVal)
{
	return GetPropertyValue("FixedProrationLength", pVal);
}

STDMETHODIMP CMTRecurringCharge::put_FixedProrationLength(VARIANT_BOOL newVal)
{
	return PutPropertyValue("FixedProrationLength", newVal);
}

STDMETHODIMP CMTRecurringCharge::get_ChargePerParticipant(VARIANT_BOOL *pVal)
{
	return GetPropertyValue("ChargePerParticipant", pVal);
}

STDMETHODIMP CMTRecurringCharge::put_ChargePerParticipant(VARIANT_BOOL newVal)
{
	return PutPropertyValue("ChargePerParticipant", newVal);
}

STDMETHODIMP CMTRecurringCharge::get_UnitName(BSTR *pVal)
{
	return GetPropertyValue("UnitName", pVal);
}

STDMETHODIMP CMTRecurringCharge::put_UnitName(BSTR newVal)
{
	return PutPropertyValue("UnitName", newVal);
}

STDMETHODIMP CMTRecurringCharge::get_UnitDisplayName(BSTR *pVal)
{
	return GetPropertyValue("UnitDisplayName", pVal);
}

STDMETHODIMP CMTRecurringCharge::put_UnitDisplayName(BSTR newVal)
{
	return PutPropertyValue("UnitDisplayName", newVal);
}

STDMETHODIMP CMTRecurringCharge::get_IntegerUnitValue(VARIANT_BOOL *pVal)
{
	return GetPropertyValue("IntegerUnitValue", pVal);
}

STDMETHODIMP CMTRecurringCharge::put_IntegerUnitValue(VARIANT_BOOL newVal)
{
	return PutPropertyValue("IntegerUnitValue", newVal);
}

STDMETHODIMP CMTRecurringCharge::get_MaxUnitValue(DECIMAL *pVal)
{
	return GetPropertyValue("MaxUnitValue", pVal);
}

STDMETHODIMP CMTRecurringCharge::put_MaxUnitValue(DECIMAL newVal)
{
	return PutPropertyValue("MaxUnitValue", newVal);
}

STDMETHODIMP CMTRecurringCharge::get_MinUnitValue(DECIMAL *pVal)
{
	return GetPropertyValue("MinUnitValue", pVal);
}

STDMETHODIMP CMTRecurringCharge::put_MinUnitValue(DECIMAL newVal)
{
	return PutPropertyValue("MinUnitValue", newVal);
}

STDMETHODIMP CMTRecurringCharge::AddUnitValueEnumeration(DECIMAL newVal)
{
	mEnums.insert(newVal);
	return S_OK;
}

STDMETHODIMP CMTRecurringCharge::RemoveUnitValueEnumeration(DECIMAL newVal)
{
	mEnums.erase(newVal);
	return S_OK;
}

STDMETHODIMP CMTRecurringCharge::GetUnitValueEnumerations(IMTCollection ** apEnums)
{
	if (apEnums == NULL) 
		return E_POINTER;

	*apEnums = NULL;

	try
	{
		GENERICCOLLECTIONLib::IMTCollectionPtr coll(__uuidof(GENERICCOLLECTIONLib::MTCollection));
		for(std::set<DECIMAL, DECIMAL_less>::iterator e = mEnums.begin(); e != mEnums.end(); e++)
		{
			coll->Add(*e);
		}
		
		*apEnums = reinterpret_cast<IMTCollection*>(coll.Detach());
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

STDMETHODIMP CMTRecurringCharge::get_UnitValueEnumeration(IMTCollection ** apEnums)
{
	return GetUnitValueEnumerations(apEnums);
}

STDMETHODIMP CMTRecurringCharge::ValidateUnitValue(DECIMAL newVal)
{
	try
	{
		MTPRODUCTCATALOGLib::IMTRecurringChargePtr pThis(this);
		
		if (pThis->IntegerUnitValue == VARIANT_TRUE)
		{			
			long lVal;
			HRESULT hr = VarI4FromDec((LPDECIMAL)&newVal, &lVal);
			if(FAILED(hr)) 
			{
				PCCache::GetLogger().LogThis(LOG_ERROR, "Failure converting decimal to integer while validating"
																		 " that unit value is integer");
				return hr;
			}

			DECIMAL decVal;
			hr = VarDecFromI4(lVal, &decVal);
			if(FAILED(hr)) 
			{
				PCCache::GetLogger().LogThis(LOG_ERROR, "Failure converting integer to decimal while validating"
																		 " that unit value is integer");
				return hr;
			}

			if(VARCMP_EQ != VarDecCmp((LPDECIMAL) &newVal, (LPDECIMAL)&decVal))
			{
				PCCache::GetLogger().LogThis(LOG_DEBUG, "Unit value failed integrality constraint check");
				MT_THROW_COM_ERROR(MTPCUSER_UDRC_INTEGER_CONSTRAINT, (const char *)pThis->UnitName);
			}
		}

		// Check max and min constraints
		DECIMAL maxVal = pThis->MaxUnitValue;
		DECIMAL minVal = pThis->MinUnitValue;
		if(VARCMP_GT == VarDecCmp((LPDECIMAL) &newVal, (LPDECIMAL)&maxVal))
		{
			PCCache::GetLogger().LogThis(LOG_DEBUG, "Unit value failed max value check");
			MT_THROW_COM_ERROR(MTPCUSER_UDRC_MIN_MAX_CONSTRAINT, 
												 (const char *)pThis->UnitName,
												 MTDecimal(minVal).Format(-1, -2, -2, -2).c_str(),
												 MTDecimal(maxVal).Format(-1, -2, -2, -2).c_str());
		}

		if(VARCMP_LT == VarDecCmp((LPDECIMAL) &newVal, (LPDECIMAL)&minVal))
		{
			PCCache::GetLogger().LogThis(LOG_DEBUG, "Unit value failed min value check");
			MT_THROW_COM_ERROR(MTPCUSER_UDRC_MIN_MAX_CONSTRAINT, 
												 (const char *)pThis->UnitName,
												 MTDecimal(minVal).Format(-1, -2, -2, -2).c_str(),
												 MTDecimal(maxVal).Format(-1, -2, -2, -2).c_str());
		}

		// If we have an enumeration constraint, check it
		if(mEnums.size() > 0)
		{
			bool found = false;
			for(std::set<DECIMAL, DECIMAL_less>::iterator e = mEnums.begin(); e != mEnums.end(); e++)
			{
				DECIMAL tmp = *e;
				if (VARCMP_EQ == VarDecCmp(const_cast<DECIMAL *> (&newVal), const_cast<DECIMAL *> (&tmp)))
				{
					found = true;
					break;
				}
			}
			if (!found)
			{
				PCCache::GetLogger().LogThis(LOG_DEBUG, "Unit value failed enumeration check");
				std::string enumString;
				for(std::set<DECIMAL, DECIMAL_less>::iterator e = mEnums.begin(); e != mEnums.end(); e++)
				{
					if(enumString.size() > 0) enumString += "; ";

					enumString += MTDecimal(*e).Format(-1, -2, -2, -2);
				}
				MT_THROW_COM_ERROR(MTPCUSER_UDRC_ENUM_CONSTRAINT, 
													 (const char *)pThis->UnitName,
													 enumString.c_str());
			}
		}
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

STDMETHODIMP CMTRecurringCharge::get_Cycle(IMTPCCycle **pVal)
{
	return GetPropertyObject( "Cycle", reinterpret_cast<IDispatch**>(pVal) );
}

STDMETHODIMP CMTRecurringCharge::get_RatingType(MTUDRCRatingType *pVal)
{
	return GetPropertyValue("RatingType", (long *)pVal);
}

STDMETHODIMP CMTRecurringCharge::put_RatingType(MTUDRCRatingType newVal)
{
	return PutPropertyValue("RatingType", (long) newVal);
}

bool CMTRecurringCharge::IsParameterTableInUse(IMTParamTableDefinition* apParamTable)
{
	MTPRODUCTCATALOGLib::IMTParamTableDefinitionPtr pParamTable(apParamTable);
	MTPRODUCTCATALOGLib::IMTRecurringChargePtr This(this);

	if (This->PriceableItemType->Kind == PCENTITY_TYPE_RECURRING_UNIT_DEPENDENT)
	{
		// If the UDRC is configured to be tiered then, only the tiered
		// table is necessary.  Vice-versa for tapered.
		if(This->RatingType == UDRCRATING_TYPE_TIERED)
		{
			return pParamTable->Name == _bstr_t(L"metratech.com/udrctiered");
		}
		else
		{
			return pParamTable->Name == _bstr_t(L"metratech.com/udrctapered");
		}
	}
	else
		return true;
}

STDMETHODIMP CMTRecurringCharge::get_UnitDisplayNames(IDispatch **pVal)
{
  //Here we delay the construction of the nested Localization object until it is actually needed.
  HRESULT hr;
  hr=GetPropertyObject( "UnitDisplayNames", reinterpret_cast<IDispatch**>(pVal) );
  if (FAILED(hr))
  {
   	MetraTech_Localization::ILocalizedEntityPtr displayNameLocalizationPtr(__uuidof(MetraTech_Localization::LocalizedEntity));
		PutPropertyObject("UnitDisplayNames", displayNameLocalizationPtr);
    hr=GetPropertyObject( "UnitDisplayNames", reinterpret_cast<IDispatch**>(pVal) );
  }
  
  return hr;
}
