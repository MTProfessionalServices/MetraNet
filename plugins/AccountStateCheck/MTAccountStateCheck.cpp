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
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/


#include <PlugInSkeleton.h>
#include <string.h>
#include <metra.h>
#include <map>
#import <MTAccountStates.tlb> rename ("EOF", "RowsetEOF")
#include <MTAccountStatesDefs.h>
#include <propids.h>
#include <mtcomerr.h>

typedef std::map<std::string, MTACCOUNTSTATESLib::IMTAccountStateInterfacePtr> KnownStatesMap;
typedef std::map<std::string, MTACCOUNTSTATESLib::IMTAccountStateInterfacePtr>::const_iterator MapIt;


CLSID CLSID_MTAccountStateCheck = { 
	0xae47b8fb, 
	0xed91, 
	0x4a7e, { 
		0x83, 
		0x4c, 
		0x01, 
		0x7a, 
		0x10, 
		0x15, 
		0x7a, 
		0x02 } 
};

/////////////////////////////////////////////////////////////////////////////
// MTAccountStateCheck
/////////////////////////////////////////////////////////////////////////////


class ATL_NO_VTABLE MTAccountStateCheck
	: public MTPipelinePlugIn<MTAccountStateCheck, &CLSID_MTAccountStateCheck>
{
protected:
	virtual HRESULT PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																	MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																	MTPipelineLib::IMTNameIDPtr aNameID,
                                  MTPipelineLib::IMTSystemContextPtr aSysContext);

	// Shutdown the processor.  The processor can release any resources
	// it no longer needs.
	virtual HRESULT PlugInShutdown();

	virtual HRESULT PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession);

protected: 

private: // data
	MTPipelineLib::IMTLogPtr mLogger;
	long mAccountState;
	long mAccountStateRule;
  KnownStatesMap mStates;
  MapIt mIt;
  MTACCOUNTSTATESLib::IMTAccountStateManagerPtr mStateManagerPtr;
  MTACCOUNTSTATESLib::IMTAccountStateInterfacePtr CreateStateObject(const wchar_t* aStateStr);

	
};


PLUGIN_INFO(CLSID_MTAccountStateCheck, MTAccountStateCheck,
						"MTPipeline.MTAccountStateCheck.1", "MTPipeline.MTAccountStateCheck", "Free")

/////////////////////////////////////////////////////////////////////////a////
//PlugInConfigure
/////////////////////////////////////////////////////////////////////////////

#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "MTAccountStateCheck::PlugInConfigure"
HRESULT MTAccountStateCheck::PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																				MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																				MTPipelineLib::IMTNameIDPtr aNameID,
                                        MTPipelineLib::IMTSystemContextPtr aSysContext)
{
	mLogger = aLogger;

	// return the default account price list only if requested by the plugin
	mAccountStateRule = -1;

	DECLARE_PROPNAME_MAP(inputs)
		DECLARE_PROPNAME("_accountstate",&mAccountState)
		DECLARE_PROPNAME_OPTIONAL("accountstaterule",&mAccountStateRule)
	END_PROPNAME_MAP
	
	HRESULT hr = ProcessProperties(inputs, aPropSet, aNameID, aLogger,PROCEDURE);
	if (FAILED(hr))
		return hr;

	try 
	{
    PipelinePropIDs::Init();

    mAccountState = PipelinePropIDs::AccountState();
    HRESULT hr = mStateManagerPtr.CreateInstance("MTAccountStates.MTAccountStateManager");
    if(FAILED(hr))
      return hr;

    //cache interface pointers for known account states
    MTACCOUNTSTATESLib::IMTAccountStateInterfacePtr suspendedPtr;
    MTACCOUNTSTATESLib::IMTAccountStateInterfacePtr archivedPtr;
    MTACCOUNTSTATESLib::IMTAccountStateInterfacePtr closedPtr;
    MTACCOUNTSTATESLib::IMTAccountStateInterfacePtr paaPtr;
    MTACCOUNTSTATESLib::IMTAccountStateInterfacePtr pfbPtr;
    MTACCOUNTSTATESLib::IMTAccountStateInterfacePtr activePtr;

    suspendedPtr = CreateStateObject(SUSPENDED);
    mStates["SU"] = suspendedPtr;
    mStates["su"] = suspendedPtr;

    archivedPtr =  CreateStateObject(ARCHIVED);
    mStates["AR"] = archivedPtr;
    mStates["ar"] = archivedPtr;

    closedPtr = CreateStateObject(CLOSED);
    mStates["CL"] = closedPtr;
    mStates["cl"] = closedPtr;

    paaPtr = CreateStateObject(PENDING_ACTIVE_APPROVAL);
    mStates["PA"] = paaPtr;
    mStates["pa"] = paaPtr;

    pfbPtr = CreateStateObject(PENDING_FINAL_BILL);
    mStates["PF"] = pfbPtr;
    mStates["pf"] = pfbPtr;

    activePtr = CreateStateObject(ACTIVE);
    mStates["AC"] = activePtr;
    mStates["ac"] = activePtr;
	}
	catch (_com_error&)
	{
			const char *errmsg = "Failed To initialize Account States objects";
			return Error(errmsg);
	}

	return S_OK;
}

/////////////////////////////////////////////////////////////////////////////
//PlugInProcessSession
/////////////////////////////////////////////////////////////////////////////

#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "MTAccountStateCheck::PlugInProcessSession"
HRESULT MTAccountStateCheck::PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession)
{
	HRESULT hr(S_OK);
	_bstr_t bstrAccountState;
  char buf[512];

  if (aSession->PropertyExists(mAccountState, 
															 MTPipelineLib::SESS_PROP_TYPE_STRING) == VARIANT_FALSE)
  {
    sprintf(buf,
					"AccountState property not found in session.  No account state rules will be checked");
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buf);
    return S_OK;
	}

	bstrAccountState = aSession->GetStringProperty(mAccountState);
  ASSERT(bstrAccountState.length() > 0);
      
  //check if it's OK to meter against the state this account is in
  mIt = mStates.find((char*)bstrAccountState);
  if(mIt == mStates.end())
  {
    sprintf(buf, "State [%s] is unknown!", (char*)bstrAccountState);
    mLogger->LogString(MTPipelineLib::PLUGIN_LOG_ERROR, buf);      
    return Error(buf);
  }

	// check if the account state rule has been set
	if (aSession->PropertyExists(mAccountStateRule, 
															 MTPipelineLib::SESS_PROP_TYPE_STRING) == VARIANT_TRUE)
	{
		// check for the recurring charges rule
		_bstr_t bstrAccountStateRule = aSession->GetStringProperty(mAccountStateRule);
		if (0 == _wcsicmp(bstrAccountStateRule, L"generaterc"))
		{
			if(mIt->second->CanApplyRecurringCharges() == VARIANT_FALSE)
       	MT_THROW_COM_ERROR(RECURRING_CHARGES_NOT_ALLOWED_FOR_THIS_STATE, 
													 mIt->first.c_str());
		}
		// check for the non recurring charges rule
		else if (0 == _wcsicmp(bstrAccountStateRule, L"generatenrc"))
		{
			if(mIt->second->CanApplyNonRecurringCharges() == VARIANT_FALSE)
       	MT_THROW_COM_ERROR(NON_RECURRING_CHARGES_NOT_ALLOWED_FOR_THIS_STATE, 
													 mIt->first.c_str());
		}
		else if (0 == _wcsicmp(bstrAccountStateRule, L"generatediscount"))
		// check for the discounts rule
		{
			if(mIt->second->CanApplyDiscounts() == VARIANT_FALSE)
       	MT_THROW_COM_ERROR(DISCOUNTS_NOT_ALLOWED_FOR_THIS_STATE, 
													 mIt->first.c_str());
		}
		// check for the addcharge rule
		else if (0 == _wcsicmp(bstrAccountStateRule, L"addcharge"))
		{
			if(mIt->second->CanAddCharges() == VARIANT_FALSE)
       	MT_THROW_COM_ERROR(ADDITIONAL_CHARGES_NOT_ALLOWED_FOR_THIS_STATE, 
													 mIt->first.c_str());
		}
		// check for the applycredit rule
		else if (0 == _wcsicmp(bstrAccountStateRule, L"applycredit"))
		{
			if(mIt->second->CanApplyCredits() == VARIANT_FALSE)
       	MT_THROW_COM_ERROR(CREDITS_NOT_ALLOWED_FOR_THIS_STATE, 
													 mIt->first.c_str());
		}
		// check for rateusage
		else if (0 == _wcsicmp(bstrAccountStateRule, L"rateusage"))
		{
			if(mIt->second->CanRateUsage() == VARIANT_FALSE)
       	MT_THROW_COM_ERROR(USAGE_NOT_ALLOWED_FOR_THIS_STATE, 
													 mIt->first.c_str());
		}
		else
		{
			sprintf(buf, "Unknown account state rule <%s>. No rules will be applied", bstrAccountStateRule);
			mLogger->LogString(MTPipelineLib::PLUGIN_LOG_INFO, buf);
		}
	}
	else
  {
     sprintf(buf,
						"AccountStateRule property not found in session.  No account state rule checks will be done.");
     mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, buf);
	}

	return S_OK;
}


/////////////////////////////////////////////////////////////////////////////
//PlugInShutdown
/////////////////////////////////////////////////////////////////////////////

HRESULT MTAccountStateCheck::PlugInShutdown()
{
	
	return S_OK;
}

MTACCOUNTSTATESLib::IMTAccountStateInterfacePtr MTAccountStateCheck::CreateStateObject(const wchar_t* aStateStr)
{
  MTACCOUNTSTATESLib::IMTAccountStateInterfacePtr outPtr;
  mStateManagerPtr->Initialize(-99, aStateStr);
  outPtr = mStateManagerPtr->GetStateObject();	
	return outPtr;
}
