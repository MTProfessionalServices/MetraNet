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
#include "Suspended.h"
#include <RowsetDefs.h>
#include <mtcomerr.h>
#include <mtglobal_msg.h>
#include <corecapabilities.h>
#include <autherr.h>
#include <mttime.h>

#import <MTAuth.tlb> rename ("EOF", "RowsetEOF")

/////////////////////////////////////////////////////////////////////////////
// CSuspended

STDMETHODIMP CSuspended::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTAccountStateInterface
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

void CSuspended::InitializeState(MTACCOUNTSTATESLib::IMTAccountStateMetaDataPtr metadataPtr)
{
	mpBizRules = metadataPtr->GetSuspended();
}


//
//
//
STDMETHODIMP CSuspended::ChangeState(IMTSessionContext* pCtx,
																		 IMTSQLRowset* pRowset, 
																		 long lAccountID, 
																		 long lIntervalID, 
																		 BSTR statename, 
																		 DATE StartDate,
																		 DATE EndDate)
{
	_bstr_t buffer;
	HRESULT hr(S_OK);
	_bstr_t bstrStateName(statename);

	AuditEventsLib::MTAuditEvent deniedEvent = AuditEventsLib::AUDITEVENT_UNKNOWN;

	// check to see if the state can be changed to the new state
	try 
	{
		deniedEvent = AuditEventsLib::AUDITEVENT_ACCOUNT_UPDATE_DENIED;

		// implement each state's change and just call it from here
		MTAUTHLib::IMTSecurityPtr pSec(__uuidof(MTAUTHLib::MTSecurity));
		MTACCOUNTSTATESLib::IMTSQLRowsetPtr pRowsetPtr;
		if (pRowset != NULL)
			pRowsetPtr = pRowset;
		else // if its not part of a transaction, rowset will be NULL. create it
		{
			hr = pRowsetPtr.CreateInstance(MTPROGID_SQLROWSET);
			if (FAILED(hr))
			{
				buffer = "Unable to create Rowset instance";
				mLogger->LogThis (LOG_ERROR, (const char*) buffer);
				return Error((const char*)buffer); 
			}
			pRowsetPtr->Init("\\Queries\\AccountStates");
		}

		if (0 == _wcsicmp(bstrStateName, L"PA"))
			hr = CanChangeToPendingActiveApproval(lAccountID, StartDate);
		else if (0 == _wcsicmp(bstrStateName, L"AC"))
		{
			MTAUTHLib::IMTSessionContextPtr pCurrentCtxPtr(pCtx);
			if (pCurrentCtxPtr != NULL)
			{
				pCurrentCtxPtr->SecurityContext->CheckAccess
      		(pSec->GetCapabilityTypeByName(UPD_FROM_SUSPENDED_TO_ACTIVE_CAP)->CreateInstance());
			}

			hr = CanChangeToActive(lAccountID, StartDate);
		}
		else if (0 == _wcsicmp(bstrStateName, L"SU"))
			hr = CanChangeToSuspended(lAccountID, StartDate);
		else if (0 == _wcsicmp(bstrStateName, L"PF"))
			hr = CanChangeToPendingFinalBill(lAccountID, StartDate);
		else if (0 == _wcsicmp(bstrStateName, L"CL"))
			hr = CanChangeToClosed(lAccountID, StartDate);
		else if (0 == _wcsicmp(bstrStateName, L"AR"))
			hr = CanChangeToArchived(lAccountID, StartDate);
		else
		{
			buffer = "Unknown account state <";
			buffer += bstrStateName;
			buffer += ">";
			mLogger->LogThis (LOG_ERROR, (const char*) buffer);
			return Error((const char*)buffer); 
		}

		// check for hr
		if (FAILED(hr))
			return hr;
		
		// if there are no problems, update the state in the database
		UpdateDBState(lAccountID, bstrStateName, StartDate, pRowsetPtr);
	}
	catch (_com_error& e)
	{
		long userID;
		pCtx->get_AccountID(&userID);
		AuditAuthFailures(e, deniedEvent, userID, 
											AuditEventsLib::AUDITENTITY_TYPE_ACCOUNT,
											lAccountID);

		buffer = "The state could not be changed in the database from <Suspended> to <";
		buffer += bstrStateName;
		buffer += ">";
		mLogger->LogThis (LOG_ERROR, (const char*) buffer);

		return ReturnComError(e);
	}

	return S_OK;
}

//
//
//
STDMETHODIMP CSuspended::ReverseState(IMTSessionContext* pCtx,
																			IMTSQLRowset* pRowset, 
																			long lAccountID, 
																			long lIntervalID, 
																			BSTR statename, 
																			DATE StartDate,
																			DATE EndDate)
{
	return Error ("Reverse State is available only for End of Period processing state transitions.  Call ChangeState() instead");
}


//
//
//
STDMETHODIMP CSuspended::CanChangeToPendingActiveApproval(long lAccountID, DATE StartDate)
{
	return Error (
		"State Transition from Suspended to Pending Active Approval is not allowed");
}

//
//
//
STDMETHODIMP CSuspended::CanChangeToActive(long lAccountID, DATE StartDate)
{
	_bstr_t buffer;
	long lReturnVal;
	HRESULT hr(S_OK);

	try 
	{
		// Business Rule 1: Check for generic business rules
		CheckAccountStateDateRules(lAccountID, L"SU", L"AC", StartDate, lReturnVal);
		switch (lReturnVal) 
		{
			case -486604754:
				hr = MT_START_DATE_BEFORE_ACCOUNT_INCEPTION_DATE_NOT_ALLOWED;
				buffer = "An attempt is being made to set the start date for the account to be before the accounts inception date.  This operation is not allowed";
				return Error ((const char*)buffer, IID_IMTAccountStateInterface, hr);
				break;

			case 1:
				break;
		}
	}
	catch (_com_error& e)
	{
		return ReturnComError(e);
	}
	return S_OK;
}

//
//
//
STDMETHODIMP CSuspended::CanChangeToSuspended(long lAccountID, DATE StartDate)
{
	_bstr_t buffer;
	long lReturnVal;
	HRESULT hr(S_OK);

	try 
	{
		// Business Rule 1: Check for generic business rules
		CheckAccountStateDateRules(lAccountID, L"SU", L"SU", StartDate, lReturnVal);
		switch (lReturnVal) 
		{
			case -486604754:
				hr = MT_START_DATE_BEFORE_ACCOUNT_INCEPTION_DATE_NOT_ALLOWED;
				buffer = "An attempt is being made to set the start date for the account to be before the accounts inception date.  This operation is not allowed";
				return Error ((const char*)buffer, IID_IMTAccountStateInterface, hr);
				break;

			case -486604711:
				hr = MT_START_DATE_AFTER_ACCOUNT_INCEPTION_DATE_NOT_ALLOWED;
				buffer = "An attempt is being made to set the start date for the account to be after the accounts inception date.  This operation is not allowed";
				return Error ((const char*)buffer, IID_IMTAccountStateInterface, hr);
				break;

			case 1:
				break;
		}
	}
	catch (_com_error& e)
	{
		return ReturnComError(e);
	}
	return S_OK;
}

//
//
//
STDMETHODIMP CSuspended::CanChangeToPendingFinalBill(long lAccountID, DATE StartDate)
{
	return Error ("State Transition from Suspended to Archived is not allowed");
}

//
//
//
STDMETHODIMP CSuspended::CanChangeToClosed(long lAccountID, DATE StartDate)
{
		_bstr_t buffer;
	long lReturnVal;
	HRESULT hr(S_OK);

	try 
	{
		// Business Rule 1: Check for generic business rules
		CheckAccountStateDateRules(lAccountID, L"SU", L"CL", StartDate, lReturnVal);
		switch (lReturnVal) 
		{
			case -486604754:
				hr = MT_START_DATE_BEFORE_ACCOUNT_INCEPTION_DATE_NOT_ALLOWED;
				buffer = "An attempt is being made to set the start date for the account to be before the accounts inception date.  This operation is not allowed";
				return Error ((const char*)buffer, IID_IMTAccountStateInterface, hr);
				break;

			case 1:
				break;
		}
	}
	catch (_com_error& e)
	{
		return ReturnComError(e);
	}
	return S_OK;

//return Error ("State Transition from Suspended to Closed is not allowed");
}

//
//
//
STDMETHODIMP CSuspended::CanChangeToArchived(long lAccountID, DATE StartDate)
{
	return Error ("State Transition from Suspended to Archived is not allowed");
}


// --------------------------- Helper Methods -------------------------
//
//
//
void
CSuspended::UpdateDBState (long lAccountID, 
													 _bstr_t bstrNewState,
													 DATE StartDate,
													 MTACCOUNTSTATESLib::IMTSQLRowsetPtr& rs)
{
	// 
	rs->Init("\\Queries\\AccountStates");
	rs->InitializeForStoredProc("UpdateAccountState");

	// if there are no problems, update the state in the database
	long status = -1;
	rs->AddInputParameterToStoredProc("p_id_acc", 
																		MTTYPE_INTEGER, 
																		INPUT_PARAM, 
																		lAccountID);
	rs->AddInputParameterToStoredProc("p_new_status", 
																		MTTYPE_VARCHAR, 
																		INPUT_PARAM, 
																		bstrNewState);
	rs->AddInputParameterToStoredProc("p_start_date", 
																		MTTYPE_DATE, 
																		INPUT_PARAM, 
																		StartDate);

	_variant_t systemDate = GetMTOLETime();
	rs->AddInputParameterToStoredProc("system_date",
																		MTTYPE_DATE,
																		INPUT_PARAM,
																		systemDate);

	rs->AddOutputParameterToStoredProc("status", 
																		 MTTYPE_INTEGER, 
																		 OUTPUT_PARAM);
	rs->ExecuteStoredProc();
	status = rs->GetParameterFromStoredProc("status");

	// 1 is success condition
	if(status != 1) 
	{
		MT_THROW_COM_ERROR(status);
	}
	
	return;
}

void
CSuspended::CheckAccountStateDateRules (long lAccountID, 
																		 BSTR OldStatus,
																		 BSTR NewStatus,
																		 DATE StartDate, 
																		 long& lStatus)
{
	// 
	MTACCOUNTSTATESLib::IMTSQLRowsetPtr rs(MTPROGID_SQLROWSET);
	rs->Init("\\Queries\\AccountStates");
	rs->InitializeForStoredProc("CheckAccountStateDateRules");
	
	rs->AddInputParameterToStoredProc("p_id_acc", 
																		MTTYPE_INTEGER,
																		INPUT_PARAM,
																		lAccountID);
	
	rs->AddInputParameterToStoredProc("p_old_status", 
																		MTTYPE_VARCHAR,
																		INPUT_PARAM,
																		OldStatus);
	
	rs->AddInputParameterToStoredProc("p_new_status", 
																		MTTYPE_VARCHAR,
																		INPUT_PARAM,
																		NewStatus);

	_variant_t vtDate = StartDate;
	vtDate.vt = VT_DATE;
	rs->AddInputParameterToStoredProc("p_ref_date", 
																		MTTYPE_DATE, 
																		INPUT_PARAM, 
																		vtDate);
	rs->AddOutputParameterToStoredProc("status", 
																		 MTTYPE_INTEGER, 
																		 OUTPUT_PARAM);
	rs->ExecuteStoredProc();
	lStatus = rs->GetParameterFromStoredProc("status");
	
	return;
}
// --------------------------- Helper Methods -------------------------
