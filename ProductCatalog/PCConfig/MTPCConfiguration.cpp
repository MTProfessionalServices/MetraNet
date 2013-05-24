/**************************************************************************
 * @doc SIMPLE
 *
 * Copyright 1999 by MetraTech Corporation
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
 * NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech Corporation MAKES NO
 * REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
 * PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
 * DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
 * COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech Corporation,
 * and USER agrees to preserve the same.
 *
 * Created by: Boris Partensky
 *
 * $Date: 10/1/2002 11:04:34 AM$
 * $Author: Fabricio Pettena$
 * $Revision: 16$
 ***************************************************************************/

#include "StdAfx.h"
#include "PCConfig.h"
#include "MTPCConfiguration.h"
#include <loggerconfig.h>
#include "PropValType.h"

struct BusRuleStruct
{
	MTPC_BUSINESS_RULE type;
	const wchar_t*     name;
};

//map between MTPC_BUSINESS_RULE enum and name in PCConfig.xml
//this maps needs to be modified for each new MTPC_BUSINESS_RULE
const BusRuleStruct gBusRuleMap[] =
	{
		{ MTPC_BUSINESS_RULE_All_NoEmptyRequiredProperty,      L"All_NoEmptyRequiredProperty" },
		{ MTPC_BUSINESS_RULE_All_CheckStringLength,            L"All_CheckStringLength" },
		{ MTPC_BUSINESS_RULE_Account_NoConflictingProdOff,     L"Account_NoConflictingProdOff" },
		{ MTPC_BUSINESS_RULE_Account_NoDuplicateProdOff,       L"Account_NoDuplicateProdOff" },
		{ MTPC_BUSINESS_RULE_Account_CheckBillingCycleChange,  L"Account_CheckBillingCycleChange" },
		{ MTPC_BUSINESS_RULE_EffDate_CheckDateCompatibility,   L"EffDate_CheckDateCompatibility" },
		{ MTPC_BUSINESS_RULE_EffDate_NoEndBeforeStart,         L"EffDate_NoEndBeforeStart" },
		{ MTPC_BUSINESS_RULE_PITempl_NoDuplicateName,          L"PITempl_NoDuplicateName" },
		{ MTPC_BUSINESS_RULE_PIType_NoDuplicateName,           L"PIType_NoDuplicateName" },
		{ MTPC_BUSINESS_RULE_PIType_NoRemoveIfTemplate,        L"PIType_NoRemoveIfTemplate" },
		{ MTPC_BUSINESS_RULE_PriceList_NoDuplicateName,        L"PriceList_NoDuplicateName" },
		{ MTPC_BUSINESS_RULE_ProdOff_CheckConfiguration,       L"ProdOff_CheckConfiguration" },
		{ MTPC_BUSINESS_RULE_ProdOff_CheckCurrency,            L"ProdOff_CheckCurrency" },
		{ MTPC_BUSINESS_RULE_ProdOff_CheckDates,               L"ProdOff_CheckDates" },
		{ MTPC_BUSINESS_RULE_ProdOff_CheckModification,        L"ProdOff_CheckModification" },
		{ MTPC_BUSINESS_RULE_ProdOff_NoDuplicateUsageTemplate, L"ProdOff_NoDuplicateUsageTemplate" },
		{ MTPC_BUSINESS_RULE_ProdOff_NoDuplicateTemplate,      L"ProdOff_NoDuplicateTemplate" },
		{ MTPC_BUSINESS_RULE_ProdOff_NoDuplicateInstanceName,  L"ProdOff_NoDuplicateInstanceName" },
		{ MTPC_BUSINESS_RULE_ProdOff_NoDuplicateName,          L"ProdOff_NoDuplicateName" },
		{ MTPC_BUSINESS_RULE_ProdOff_NoModificationIfAvailable,L"ProdOff_NoModificationIfAvailable" },
		{ MTPC_BUSINESS_RULE_IgnoreDateCheckOnGroupSubDelete,L"IgnoreDateCheckOnGroupSubDelete" },
		{ MTPC_BUSINESS_RULE_IgnoreDateCheckOnSubscriptionDelete,L"IgnoreDateCheckOnSubscriptionDelete" },
		{ MTPC_BUSINESS_RULE_OnlyAbsoluteRateSchedulesWithGroupSubscription,L"OnlyAbsoluteRateSchedulesWithGroupSubscription" },
		{ MTPC_BUSINESS_RULE_PI_CheckCycleChange,              L"PI_CheckCycleChange" },
		{ MTPC_BUSINESS_RULE_Rates_DeleteOverride,             L"Rates_DeleteOverride" },
		{ MTPC_BUSINESS_RULE_Adjustments_NoGreaterThanCharge,  L"Adjustments_NoGreaterThanCharge" },
		{ MTPC_BUSINESS_RULE_Hierarchy_RestrictedOperations,   L"Hierarchy_RestrictedOperations" },
		{ MTPC_BUSINESS_RULE_Subscription_TruncateTimeValues, L"Subscription_TruncateTimeValues" },
		//Following 2 new rules added for FEAT-142 and FEAT-147
		{ MTPC_BUSINESS_RULE_ProdOff_AllowAccountPOCurrencyMismatch,   L"ProdOff_AllowAccountPOCurrencyMismatch" },
		{ MTPC_BUSINESS_RULE_ProdOff_AllowMultiplePISubscriptionRCNRC, L"ProdOff_AllowMultiplePISubscriptionRCNRC" }

	};


/////////////////////////////////////////////////////////////////////////////
// CMTPCConfiguration

STDMETHODIMP CMTPCConfiguration::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTPCConfiguration
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

CMTPCConfiguration::CMTPCConfiguration()
{
	m_pUnkMarshaler = NULL;
	mBusinessRules = new BUSINESSRULES;
  mbDebugTempTables = VARIANT_FALSE;

	LoggerConfigReader configReader;
	mLogger.Init(configReader.ReadConfiguration("logging\\ProductCatalog"), "[ProductCatalog]");
}

CMTPCConfiguration::~CMTPCConfiguration() 
{
	BUSINESSRULES::iterator it;
	for (it = mBusinessRules->begin(); it != mBusinessRules->end(); it++)
	{
		BusinessRule* ptr = (*it).second;
		if(ptr != NULL)
		{
			delete ptr;
			ptr = NULL;
		}
	}
	delete mBusinessRules;
	mBusinessRules = NULL;
}

HRESULT CMTPCConfiguration::FinalConstruct()
{
	GetMTConfigDir(mConfigFile);
	mConfigFile += string("ProductCatalog\\PCConfig.xml");
	HRESULT hr = mConfig.CreateInstance(MTPROGID_CONFIG);

	if(FAILED(hr))
		return hr;

	mObserver.Init();
	mObserver.AddObserver(*this);
	
	if (!mObserver.StartThread())
	{
		return Error("Could not start config change thread");
	}

	return CoCreateFreeThreadedMarshaler(
		GetControllingUnknown(), &m_pUnkMarshaler.p);
}


// ----------------------------------------------------------------
// Name:     	Load
// Arguments:     
// Return Value:  void
// Errors Raised: 
// Description:   Loads internal collections from PCConfig.xml
// ----------------------------------------------------------------

STDMETHODIMP CMTPCConfiguration::Load()
{
	HRESULT hr(S_OK);
	MTConfigLib::IMTConfigPropSetPtr RulesSet;
	MTConfigLib::IMTConfigPropSetPtr RuleSet;
	MTConfigLib::IMTConfigPropSetPtr confSet;
	MTConfigLib::IMTConfigPropPtr prop;
	VARIANT_BOOL bChecksum;
	_bstr_t bstrRule;
	
	MTPC_BUSINESS_RULE eRule;
	bool bEnabled;
	BusinessRule* pRule;

	try
	{
		AutoCriticalSection alock(&mLock);
		confSet = mConfig->ReadConfiguration(mConfigFile.c_str(),&bChecksum);

		//1. Get PLChaining Rule
		_bstr_t bstrPLChaining = confSet->NextStringWithName("PLChainingRule");

		mPLChainingRule = ConvertPLChainingStringToEnum( (const wchar_t*) bstrPLChaining);

		if (mPLChainingRule == MTPC_PRICELIST_CHAIN_RULE_UNKNOWN)
			MT_THROW_COM_ERROR (MTPC_UNKNOWN_PL_CHAINING_RULE);

		//2. Get BatchSubmitTimeout
		mlBatchTimeout = confSet->NextLongWithName("BatchSubmitTimeout");

    //3. Debug Temp Tables?
  	if (confSet->NextMatches(L"DebugTempTables", MTConfigLib::PROP_TYPE_BOOLEAN))
      mbDebugTempTables = confSet->NextBoolWithName("DebugTempTables");
    else
      mbDebugTempTables = VARIANT_FALSE;

    //4. Max RS Cache size
  	if (confSet->NextMatches(L"RSCacheMaxSize", MTConfigLib::PROP_TYPE_INTEGER))
	  	mlRSCacheMaxSize = confSet->NextLongWithName(L"RSCacheMaxSize");
	  else
    {
		  mlRSCacheMaxSize = 5000000L;
    }
	
		//5. Init business rules
		RulesSet = confSet->NextSetWithName("BusinessRules");

		if(RulesSet == NULL)
			MT_THROW_COM_ERROR (MTPC_INVALID_CONFIGURATION_FILE);

		while ( (RuleSet = RulesSet->NextSetWithName("BusinessRule")) != NULL) 
		{
			prop = RuleSet->NextWithName("type");
			
			if(prop != NULL && prop->GetPropType() == PROP_TYPE_STRING)
			{
				bstrRule = prop->GetValueAsString();
				eRule = ConvertBRStringToEnum((const wchar_t*)bstrRule);
				if (eRule == MTPC_BUSINESS_RULE_UNKNOWN)
						MT_THROW_COM_ERROR (MTPC_UNKNOWN_BUSINESS_RULE);
			}
			else
				MT_THROW_COM_ERROR (MTPC_INVALID_CONFIGURATION_FILE);
			
			prop = RuleSet->NextWithName("Enabled");

			if(prop != NULL && prop->GetPropType() == PROP_TYPE_BOOLEAN)
			{
				_variant_t vtEnabled = prop->GetPropValue();
				bEnabled = (vtEnabled.boolVal == VARIANT_TRUE) ? true : false;
			}
			else
				MT_THROW_COM_ERROR (MTPC_INVALID_CONFIGURATION_FILE);

			//add rule to the map
			pRule = new BusinessRule(eRule, bEnabled);
			mBusinessRules->insert(BUSINESSRULES::value_type(eRule, pRule));
		}
	}

	catch(_com_error& e)
	{
		return LogAndReturnComError(mLogger, e);
	}

	return hr;
}

// ----------------------------------------------------------------
// Name:     	GetPLChaining
// Arguments:     
// Return Value:  MTPC_PRICELIST_CHAIN_RULE
// Errors Raised: 
// Description:   Returns the PL chaining rule - NONE, ALL or PC_ONLY
// ----------------------------------------------------------------

STDMETHODIMP CMTPCConfiguration::GetPLChaining(MTPC_PRICELIST_CHAIN_RULE* apChainRule)
{
	HRESULT hr(S_OK);
	AutoCriticalSection alock(&mLock);
	(*apChainRule) = mPLChainingRule;
	return hr;
}

// ----------------------------------------------------------------
// Name:     	IsBusinessRuleEnabled
// Arguments:     
// Return Value:  VARIANT_BOOL
// Errors Raised: 
// Description:   Returns the flag indicating whether a particular rule is enabled
//								NOTE: It may be desirable to iterate through all the rules.. for
//											now we won't support that
// ----------------------------------------------------------------

STDMETHODIMP CMTPCConfiguration::IsBusinessRuleEnabled(MTPC_BUSINESS_RULE aBusRule, VARIANT_BOOL *apEnabledFlag)
{
	HRESULT hr(S_OK);
	try
	{
		AutoCriticalSection alock(&mLock);
		BUSINESSRULES::iterator it = mBusinessRules->find(aBusRule);

		if(it == mBusinessRules->end())
		{	MT_THROW_COM_ERROR (MTPC_UNKNOWN_BUSINESS_RULE);
		}
		else
			(*apEnabledFlag) = it->second->IsEnabled() ? VARIANT_TRUE : VARIANT_FALSE;

		if (mLogger.IsOkToLog(LOG_DEBUG))
		{
			mLogger.LogVarArgs( LOG_DEBUG, "%s business rule %S",
			  														 *apEnabledFlag ? "Checking" : "Ignoring disabled",
				  													 ConvertEnumToBRString(aBusRule)	);
		}
	}
	catch(_com_error& e)
	{
		return LogAndReturnComError(mLogger, e);
	}

	return hr;
}

// ----------------------------------------------------------------
// Name:     	ConfigurationHasChanged
// Arguments:     
// Return Value:  void
// Errors Raised: 
// Description:   INTERNAL USE ONLY
// ----------------------------------------------------------------

//Got refresh event, reinitialize
void CMTPCConfiguration::ConfigurationHasChanged()
{
	mLogger.LogThis(LOG_DEBUG, "Refresh event received, reinitializing...");
	Load();
}

MTPC_PRICELIST_CHAIN_RULE CMTPCConfiguration::ConvertPLChainingStringToEnum(const wchar_t* aPLChainRule)
{
	if (!aPLChainRule) 
		return MTPC_PRICELIST_CHAIN_RULE_UNKNOWN;
	if (!wcsicmp(aPLChainRule, L"ALL"))
		return MTPC_PRICELIST_CHAIN_RULE_ALL;
	if (!wcsicmp(aPLChainRule, L"NONE"))
		return MTPC_PRICELIST_CHAIN_RULE_NONE;
	if (!wcsicmp(aPLChainRule, L"PO_ONLY"))
		return MTPC_PRICELIST_CHAIN_RULE_PO_ONLY;
	return MTPC_PRICELIST_CHAIN_RULE_UNKNOWN;
}	


MTPC_BUSINESS_RULE CMTPCConfiguration::ConvertBRStringToEnum(const wchar_t* aBusinessRule)
{
	if (!aBusinessRule) 
		return MTPC_BUSINESS_RULE_UNKNOWN;
	
	long numRules = sizeof(gBusRuleMap)/sizeof(gBusRuleMap[0]);
	for (int i = 0; i < numRules; i++)
	{
		if (!wcsicmp(aBusinessRule, gBusRuleMap[i].name))
			return gBusRuleMap[i].type;
	}

	return MTPC_BUSINESS_RULE_UNKNOWN;
}	

const wchar_t* CMTPCConfiguration::ConvertEnumToBRString(MTPC_BUSINESS_RULE aBusinessRule)
{
	long numRules = sizeof(gBusRuleMap)/sizeof(gBusRuleMap[0]);
	for (int i = 0; i < numRules; i++)
	{
		if (aBusinessRule == gBusRuleMap[i].type)
			return gBusRuleMap[i].name;
	}

	return L"";
}

// Business Rule

BusinessRule::BusinessRule(MTPC_BUSINESS_RULE aRule, BOOL aEnabled) : mBusinessRule(MTPC_BUSINESS_RULE_UNKNOWN), mbEnabled(FALSE) 
{
	mBusinessRule = aRule;
	mbEnabled = aEnabled;
}


STDMETHODIMP CMTPCConfiguration::GetBatchSubmitTimeout(long *apTimeout)
{
	(*apTimeout) = mlBatchTimeout;
	return S_OK;
}

STDMETHODIMP CMTPCConfiguration::GetDebugTempTables(VARIANT_BOOL *apDTT)
{
	(*apDTT) = mbDebugTempTables;
	return S_OK;
}

STDMETHODIMP CMTPCConfiguration::GetRSCacheMaxSize(long *apMax)
{
	(*apMax) = mlRSCacheMaxSize;
	return S_OK;
}

STDMETHODIMP CMTPCConfiguration::OverrideBusinessRule(MTPC_BUSINESS_RULE aBusRule,VARIANT_BOOL aVal)
{
	try
	{
		AutoCriticalSection alock(&mLock);
		BUSINESSRULES::iterator it = mBusinessRules->find(aBusRule);
		if(it == mBusinessRules->end())
		{	
      MT_THROW_COM_ERROR (MTPC_UNKNOWN_BUSINESS_RULE);
		}
    else {
      it->second->SetEnableStatus(aVal == VARIANT_TRUE ? TRUE : FALSE);
    }
  }
	catch(_com_error& e)
	{
		return LogAndReturnComError(mLogger, e);
	}
	return S_OK;
}

