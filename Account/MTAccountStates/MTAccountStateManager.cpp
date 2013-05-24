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
#include "MTAccountStates.h"
#include "MTAccountStatesDefs.h"
#include "MTAccountStateManager.h"
#include <mtcomerr.h>
#include <mtprogids.h>
#include <mtglobal_msg.h>

/////////////////////////////////////////////////////////////////////////////
// CMTAccountStateManager

STDMETHODIMP CMTAccountStateManager::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTAccountStateManager
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
STDMETHODIMP CMTAccountStateManager::Initialize(long lAccountID,
																								BSTR StateName)
{
  HRESULT hr(S_OK);

	mAccountID = lAccountID;

	// set the state
	_bstr_t bstrState (StateName);

	// instantiate the appropriate state object
	if (0 == _wcsicmp(bstrState, PENDING_ACTIVE_APPROVAL))
		mpAccountState.CreateInstance(MTPROGID_MTPENDINGACTIVEAPPROVALSTATE);
	else if (0 == _wcsicmp(bstrState, ACTIVE))
		mpAccountState.CreateInstance(MTPROGID_MTACTIVESTATE);
	else if (0 == _wcsicmp(bstrState, SUSPENDED))
		mpAccountState.CreateInstance(MTPROGID_MTSUSPENDEDSTATE);
	else if (0 == _wcsicmp(bstrState, PENDING_FINAL_BILL))
		mpAccountState.CreateInstance(MTPROGID_MTPENDINGFINALBILLSTATE);
	else if (0 == _wcsicmp(bstrState, CLOSED))
		mpAccountState.CreateInstance(MTPROGID_MTCLOSEDSTATE);
	else if (0 == _wcsicmp(bstrState, ARCHIVED))
		mpAccountState.CreateInstance(MTPROGID_MTARCHIVEDSTATE);
	else
	{
		mLogger->LogVarArgs(LOG_ERROR, "Unknown account state <%s>!", bstrState);
		return Error("Unknown account state");
	}

	// 
	mState = _bstr_t(StateName);
		
	// initialize
	mpAccountState->Initialize();
	
	return S_OK;
}

//
//
//
STDMETHODIMP CMTAccountStateManager::GetStateObject(IMTAccountStateInterface** pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = NULL;

	MTACCOUNTSTATESLib::IMTAccountStateInterfacePtr aPtr = mpAccountState;
	*pVal = (IMTAccountStateInterface*)aPtr.Detach();

	return S_OK;
}

//
//
// not sure if this is going to be used
STDMETHODIMP CMTAccountStateManager::GetCurrentStateObject(long lAccountID,
																													 IMTAccountStateInterface** pVal)
{
	if (!pVal)
		return E_POINTER;
	else
		*pVal = NULL;

	// not sure if anyone needs it right now, so returning E_NOTIMP
	return E_NOTIMPL;
}

// --------------------------- Helper Methods -------------------------
BOOL
CMTAccountStateManager::GetCurrentState (MTACCOUNTSTATESLib::IMTSQLRowsetPtr& aRowset, 
																				 long lAccountID, 
																				 _bstr_t& bstrCurrentState)
{
	// 
	try
	{
		aRowset->SetQueryTag("__GET_CURRENT_STATE__");
		aRowset->AddParam("%%ID_ACC%%", lAccountID);
		aRowset->Execute();
	
		bstrCurrentState = aRowset->GetValue("status");
	}
	catch (_com_error& )
	{
		return FALSE; 
	}
	
	return TRUE;
}
// --------------------------- Helper Methods -------------------------
