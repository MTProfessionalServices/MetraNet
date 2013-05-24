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
***************************************************************************/

#include "StdAfx.h"
#include <metralite.h>
#include <comdef.h>
#include "MTAccountStates.h"
#include "MTAccountStateMetaData.h"
#include "MTState.h"

#include "MTAccountStatesDefs.h" 
#include <mtcomerr.h>
#include <mtprogids.h>

#import <RCD.tlb>
#include <SetIterate.h>
#include <RcdHelper.h>

#import <MTAccountStates.tlb> rename ("EOF", "RowsetEOF")
/////////////////////////////////////////////////////////////////////////////
// CMTAccountStateMetaData

STDMETHODIMP CMTAccountStateMetaData::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTAccountStateMetaData
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

//
//
//
HRESULT CMTAccountStateMetaData::FinalConstruct()
{
  HRESULT hr = S_OK;
	bool bDone = false;

	VARIANT_BOOL aCheckSumMatch;
	const char* procName = "CMTAccountStateMetaData::Initialize";

	try 
	{
		// start processing the configuration
		MTConfigLib::IMTConfigPtr aConfig(MTPROGID_CONFIG);

		RCDLib::IMTRcdPtr aRCD(MTPROGID_RCD);
		aRCD->Init();
		RCDLib::IMTRcdFileListPtr aFileList = aRCD->RunQuery(
			MTACCOUNT_STATES_XML_FILE,
			VARIANT_TRUE);

		if(aFileList->GetCount() == 0) 
		{
			// log error that we can't find any configuration
			const char* pErrorMsg = "Can not find any configuration files";
			mLogger->LogThis(LOG_ERROR,pErrorMsg);
			return Error(pErrorMsg);
		}

		SetIterator<RCDLib::IMTRcdFileListPtr, _variant_t> it;
		if(FAILED(it.Init(aFileList))) return E_FAIL;

		while(!bDone) 
		{
			_variant_t aVariant= it.GetNext();
			_bstr_t afile = aVariant;
			if(afile.length() == 0) 
			{
				bDone = true;
				break;
			}

			MTConfigLib::IMTConfigPropSetPtr aPropSet = 
				aConfig->ReadConfiguration(afile,&aCheckSumMatch);

			// 1. read the state transition rules and store it
			long aAge = aPropSet->NextLongWithName(L"archiveage");

			// 2. now iterate over the states
			MTConfigLib::IMTConfigPropSetPtr aStateSet = aPropSet->NextSetWithName(STATE_SET_TAG);
			
			// check for missing state tag
			if (aStateSet == NULL)
				return Error("Missing state sets");

			while (aStateSet != NULL)
			{
				if (!ProcessStateMetaData(aAge, aStateSet))
					return Error ("Error processing account states configuration file");
					
				aStateSet = aPropSet->NextSetWithName(STATE_SET_TAG);
			}
		}
	}
	catch(_com_error& e) 
	{
		_bstr_t bstrError = e.Description();
		if(bstrError.length() == 0) 
		  bstrError = "No detailed information"; 

		mLogger->LogVarArgs(LOG_ERROR, 
												"%s : failed with error \"%s\"", 
												procName, 
												(const char*)bstrError);
		return ReturnComError(e);
	}

	return S_OK;
} 

//
//
//
BOOL 
CMTAccountStateMetaData::ProcessStateMetaData(long aAge,
	MTConfigLib::IMTConfigPropSetPtr& aPropSet)
{
	HRESULT hr(S_OK);

	// create the MTState object
	CComObject<CMTState>* pMTState;
	hr = CComObject<CMTState>::CreateInstance(&pMTState);
	ASSERT (SUCCEEDED(hr));

	// check for the name first
	_bstr_t name = aPropSet->NextStringWithName(NAME_TAG);
	_bstr_t bstrLongName = aPropSet->NextStringWithName(LONGNAME_TAG);
	_bstr_t bstrProgID = aPropSet->NextStringWithName(PROGID_TAG);

	//
	if (0 == _wcsicmp(name, PENDING_ACTIVE_APPROVAL))
		put_PendingActiveApproval(pMTState);
	else if (0 == _wcsicmp(name, ACTIVE))
		put_Active(pMTState);
	else if (0 == _wcsicmp(name, SUSPENDED))
		put_Suspended(pMTState);
	else if (0 == _wcsicmp(name, PENDING_FINAL_BILL))
		put_PendingFinalBill(pMTState);
	else if (0 == _wcsicmp(name, CLOSED))
		put_Closed(pMTState);
	else if (0 == _wcsicmp(name, ARCHIVED))
		put_Archived(pMTState);
	else
	{
  	mLogger->LogVarArgs(LOG_ERROR, "Unknown account state <%s>!", name);
		return (FALSE);
	}

	pMTState->put_ArchiveAge(aAge);
	pMTState->put_Name(name);
	pMTState->put_LongName(bstrLongName);
	pMTState->put_ProgID(bstrProgID);

	// iterate thru biz rules
	MTConfigLib::IMTConfigPropSetPtr aBizRuleSet = 
			aPropSet->NextSetWithName(BUSINESSRULES_SET_TAG);

	if (aBizRuleSet == NULL)
	{
		mLogger->LogThis(LOG_ERROR, 
										 "Business Rules not found in the configuration file!");
		return FALSE;
	}

	while (aBizRuleSet != NULL)
	{
		MTConfigLib::IMTConfigPropPtr rule = aBizRuleSet->NextWithName(L"rule");

		while (rule != NULL)
		{
			MTConfigLib::IMTConfigAttribSetPtr attribSet = rule->GetAttribSet();

			// this will get back : rateusage, generaterc, etc.
			_bstr_t bstrRule = attribSet->GetAttrValue("type");
			_bstr_t bstrLowerCaseRule = _strlwr((char*)bstrRule);
		
			// this will get the Y or N string
			_bstr_t bstrRuleValue = rule->GetValueAsString();
			if ((0 == _wcsicmp(bstrRuleValue, L"TRUE")) ||
					(0 == _wcsicmp(bstrRuleValue, L"T")) ||
					(0 == _wcsicmp(bstrRuleValue, L"YES")) ||
					(0 == _wcsicmp(bstrRuleValue, L"Y")))
			{
				pMTState->AddConfiguredBusinessRules(bstrLowerCaseRule, VARIANT_TRUE);
			}
			else if ((0 == _wcsicmp(bstrRuleValue, L"FALSE")) ||
							 (0 == _wcsicmp(bstrRuleValue, L"F")) ||
							 (0 == _wcsicmp(bstrRuleValue, L"NO")) ||
							 (0 == _wcsicmp(bstrRuleValue, L"N")))
			{	
				pMTState->AddConfiguredBusinessRules(bstrLowerCaseRule, VARIANT_FALSE);
			}
			else
			{
				mLogger->LogVarArgs(LOG_ERROR, 
														"Unknown flag for the rule <%s>", bstrRuleValue);
				return FALSE;
			}
			rule = aBizRuleSet->Next();
		}
		
		// iterate
		aBizRuleSet = aPropSet->NextSetWithName(BUSINESSRULES_SET_TAG);
	}

	return TRUE;
}

//
//
//
STDMETHODIMP CMTAccountStateMetaData::Initialize()
{
	return S_OK;
}

//
//
//
STDMETHODIMP CMTAccountStateMetaData::InitializeWithState(BSTR StateName)
{
	return S_OK;
}


// Pending Active Approval
// -----------------------------------------------------------------------
STDMETHODIMP CMTAccountStateMetaData::get_PendingActiveApproval(IMTState** pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = NULL;
	
	if (mpPendingActiveApproval != NULL)
	  mpPendingActiveApproval->QueryInterface(IID_IMTState, 
																						reinterpret_cast<void**>(pVal));
	else
	  return S_FALSE;

	return S_OK;
}

STDMETHODIMP CMTAccountStateMetaData::put_PendingActiveApproval(IMTState *pState)
{
	mpPendingActiveApproval = pState;
	return S_OK;
}


// Active
// -----------------------------------------------------------------------
STDMETHODIMP CMTAccountStateMetaData::get_Active(IMTState * * pVal)
{
    if (pVal == NULL)
	  return E_POINTER;
	if (!pVal)
		return E_POINTER;
	else
		*pVal = NULL;
	
	if (mpActive != NULL)
	  mpActive->QueryInterface(IID_IMTState, reinterpret_cast<void**>(pVal));
	else
	  return S_FALSE;

	return S_OK;
}

STDMETHODIMP CMTAccountStateMetaData::put_Active(IMTState *pState)
{
	mpActive = pState;
	return S_OK;
}

// Suspended
// -----------------------------------------------------------------------
STDMETHODIMP CMTAccountStateMetaData::get_Suspended(IMTState * * pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = NULL;
	
	if (mpSuspended != NULL)
	  mpSuspended->QueryInterface(IID_IMTState, reinterpret_cast<void**>(pVal));
	else
	  return S_FALSE;

	return S_OK;
}

STDMETHODIMP CMTAccountStateMetaData::put_Suspended(IMTState *pState)
{
	mpSuspended = pState;
	return S_OK;
}

// Pending Final Bill
// -----------------------------------------------------------------------
STDMETHODIMP CMTAccountStateMetaData::get_PendingFinalBill(IMTState * * pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = NULL;
	
	if (mpPendingFinalBill != NULL)
	  mpPendingFinalBill->QueryInterface(IID_IMTState, reinterpret_cast<void**>(pVal));
	else
	  return S_FALSE;

	return S_OK;
}

STDMETHODIMP CMTAccountStateMetaData::put_PendingFinalBill(IMTState *pState)
{
	mpPendingFinalBill = pState;
	return S_OK;
}

// Closed
// -----------------------------------------------------------------------
STDMETHODIMP CMTAccountStateMetaData::get_Closed(IMTState * * pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = NULL;
	
	if (mpClosed != NULL)
	  mpClosed->QueryInterface(IID_IMTState, reinterpret_cast<void**>(pVal));
	else
	  return S_FALSE;

	return S_OK;
}

STDMETHODIMP CMTAccountStateMetaData::put_Closed(IMTState *pState)
{
	mpClosed = pState;
	return S_OK;
}

// Archived
// -----------------------------------------------------------------------
STDMETHODIMP CMTAccountStateMetaData::get_Archived(IMTState * * pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = NULL;
	
	if (mpArchived != NULL)
	  mpArchived->QueryInterface(IID_IMTState, reinterpret_cast<void**>(pVal));
	else
	  return S_FALSE;

	return S_OK;
}

STDMETHODIMP CMTAccountStateMetaData::put_Archived(IMTState *pState)
{
	mpArchived = pState;
	return S_OK;
}

