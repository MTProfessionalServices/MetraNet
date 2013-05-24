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
#include "Active.h"
#include <RowsetDefs.h>
#include <mtcomerr.h>
#include <mtglobal_msg.h>
#include <corecapabilities.h>
#include <autherr.h>
#include <mttime.h>

#import <MTAuth.tlb> rename ("EOF", "RowsetEOF")

/////////////////////////////////////////////////////////////////////////////
// CActive

STDMETHODIMP CActive::InterfaceSupportsErrorInfo(REFIID riid)
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

//
//
//
void CActive::InitializeState(MTACCOUNTSTATESLib::IMTAccountStateMetaDataPtr metadataPtr)
{
	// get active state meta data
	mpBizRules = metadataPtr->GetActive();
}

//
//
//
STDMETHODIMP CActive::ChangeState(IMTSessionContext* pCtx,
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

		if (0 == _wcsicmp(bstrStateName, PENDING_ACTIVE_APPROVAL))
			hr = CanChangeToPendingActiveApproval(lAccountID, StartDate);
		else if (0 == _wcsicmp(bstrStateName, ACTIVE))
			hr = CanChangeToActive(lAccountID, StartDate);
		else if (0 == _wcsicmp(bstrStateName, SUSPENDED))
		{
			MTAUTHLib::IMTSessionContextPtr pCurrentCtxPtr(pCtx);
			if (pCurrentCtxPtr != NULL)
			{
				pCurrentCtxPtr->SecurityContext->CheckAccess
					(pSec->GetCapabilityTypeByName(UPD_FROM_ACTIVE_TO_SUSPENDED_CAP)->CreateInstance());
			}
			hr = CanChangeToSuspended(lAccountID, StartDate);
		}
		else if (0 == _wcsicmp(bstrStateName, PENDING_FINAL_BILL))
			hr = CanChangeToPendingFinalBill(lAccountID, StartDate);
		else if (0 == _wcsicmp(bstrStateName, CLOSED))
		{
			MTAUTHLib::IMTSessionContextPtr pCurrentCtxPtr(pCtx);
			if (pCurrentCtxPtr != NULL)
			{
				pCurrentCtxPtr->SecurityContext->CheckAccess
					(pSec->GetCapabilityTypeByName(UPD_FROM_ACTIVE_TO_CLOSED_CAP)->CreateInstance());
			}

			hr = CanChangeToClosed(lAccountID, StartDate);
		}
		else if (0 == _wcsicmp(bstrStateName, ARCHIVED))
			hr = CanChangeToArchived(lAccountID, StartDate);
		else
		{
			buffer = "Unknown account state <";
			buffer += bstrStateName;
			buffer += ">";
			mLogger->LogThis (LOG_ERROR, (const char*) buffer);
			return Error((const char*)buffer); 
		}

		//  if we are changing from active to closed, we need to change it to
		//  pending final bill first
		if (hr == ACTIVE_TO_CLOSED_NOT_ALLOWED)
		{
			hr = CanChangeToPendingFinalBill(lAccountID, StartDate);
			if (FAILED(hr))
				return hr;

			bstrStateName = PENDING_FINAL_BILL;
			UpdateDBState(lAccountID, bstrStateName, StartDate, pRowsetPtr);
			return hr;
		}

		if (FAILED(hr))
			return hr;
		
		UpdateDBState(lAccountID, bstrStateName, StartDate, pRowsetPtr);
	}
	catch (_com_error& e)
	{
		long userID;
		pCtx->get_AccountID(&userID);
		AuditAuthFailures(e, deniedEvent, userID, 
											AuditEventsLib::AUDITENTITY_TYPE_ACCOUNT,
											lAccountID);

		buffer = "The state could not be changed from <Active> to <";
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
STDMETHODIMP CActive::ReverseState(IMTSessionContext* pCtx,
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
STDMETHODIMP CActive::CanChangeToPendingActiveApproval(long lAccountID, DATE StartDate)
{
	return Error ("State Transition from Active to PendingActiveApproval is not allowed");
}

//
//
//
STDMETHODIMP CActive::CanChangeToActive(long lAccountID, DATE StartDate)
{
	_bstr_t buffer;
	long lReturnVal;
	HRESULT hr(S_OK);

	try 
	{
		// Business Rule 1: Check for generic business rules
		CheckAccountStateDateRules(lAccountID, L"AC", L"AC", StartDate, lReturnVal);
		switch (lReturnVal) 
		{
			case -486604754:
				hr = MT_START_DATE_BEFORE_ACCOUNT_INCEPTION_DATE_NOT_ALLOWED;
				buffer = "An attempt is being made to set the start date for the account to be before the accounts inception date.  This operation is not allowed";
				return Error ((const char*)buffer, IID_IMTAccountStateInterface, hr);
				break;

			case -469368818:
				hr = ACCOUNT_CONTAINS_USAGE_ACTIVE_DATE_MOVE_IN_FUTURE_NOT_ALLOWED;
				buffer = "This account contains usage and is currently active.  Attempt to move the start date for this account in the future is not allowed.  Please Close this account first";
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

		// Business Rule 2: Check if this account is billable and if it has
		// payees
		IsAccBillableAndPayingForOthers(lAccountID, StartDate, lReturnVal);
		switch (lReturnVal) 
		{
			/*
			case -486604795:
				hr = MT_ACCOUNT_IS_NOT_BILLABLE;
				buffer = "This account does not have billable flag set. It cannot be suspended.";
				return Error ((const char*)buffer, IID_IMTAccountStateInterface, hr);
				break;
			*/

		  case -486604752:
				hr = MT_ACCOUNT_PAYING_FOR_OTHERS;
				buffer = "The account is marked billable and is paying for other subscribers now or in the future.";
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
STDMETHODIMP CActive::CanChangeToSuspended(long lAccountID, DATE StartDate)
{
	_bstr_t buffer;
	long lReturnVal;
	HRESULT hr(S_OK);

	try 
	{
		// Business Rule 1: Check for generic business rules
		CheckAccountStateDateRules(lAccountID, L"AC", L"SU", StartDate, lReturnVal);
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

		// Business Rule 2: Check if this account is billable and if it has
		// payees
		IsAccBillableAndPayingForOthers(lAccountID, StartDate, lReturnVal);
		switch (lReturnVal) 
		{
			/*
			case -486604795:
				hr = MT_ACCOUNT_IS_NOT_BILLABLE;
				buffer = "This account does not have billable flag set. It cannot be suspended.";
				return Error ((const char*)buffer, IID_IMTAccountStateInterface, hr);
				break;
			*/

		  case -486604752:
				hr = MT_ACCOUNT_PAYING_FOR_OTHERS;
				buffer = "The account is marked billable and is paying for other subscribers now or in the future.";
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
STDMETHODIMP CActive::CanChangeToPendingFinalBill(long lAccountID, DATE StartDate)
{
	_bstr_t buffer;
	HRESULT hr(S_OK);

	long lReturnVal;

	try 
	{
		// Business Rule 1: Check for generic business rules
		CheckAccountStateDateRules(lAccountID, L"AC", L"PF", StartDate, lReturnVal);
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

    // 2. Check if this account is billable and if it has payees underneath
		IsAccBillableAndPayingForOthers(lAccountID, StartDate, lReturnVal);

		switch (lReturnVal) 
		{
			/*
			case -486604795:
				hr = MT_ACCOUNT_IS_NOT_BILLABLE;
				buffer = "This account does not have billable flag set. It cannot be closed.";
				return Error ((const char*)buffer, IID_IMTAccountStateInterface, hr);
				break;
			*/

		  case -486604752:
				hr = MT_ACCOUNT_PAYING_FOR_OTHERS;
				buffer = "The account is marked billable and is paying for other subscribers now or in the future.";
				return Error ((const char*)buffer, IID_IMTAccountStateInterface, hr);
				break;
				
			case 0:
				return S_OK;
		}

    // 2. Check if this account is a folder and if it has descendents that are
    // in closed state 
		CheckForNotClosedDescendents(lAccountID, StartDate, lReturnVal);
		switch (lReturnVal) 
		{
			// not a folder
			case -486604799:
				hr = MT_ACCOUNT_NOT_A_FOLDER;
				buffer = "This account has no descendents.  No need to check for closed descendents";
				mLogger->LogThis(LOG_INFO, (const char*) buffer);
				return S_OK;
				break;

			//	0 rows found or more than 0 rows found is success condition
		  case 1:
				hr = MT_ACCOUNT_IS_FOLDER_AND_HAS_NO_DESCENDENTS_IN_CLOSED_STATE;
				buffer = "This account has no descendents that are in closed state";
				mLogger->LogThis(LOG_INFO, (const char*) buffer);
				return S_OK;
				break;

		  default:
				hr = MT_ACCOUNT_IS_FOLDER_AND_HAS_DESCENDENTS_IN_STATE_OTHER_THAN_CLOSED;
				buffer = "This account has descendents that are state other than closed";
				return Error((const char*) buffer, IID_IMTAccountStateInterface, hr);
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
STDMETHODIMP CActive::CanChangeToClosed(long lAccountID, DATE StartDate)
{
	HRESULT hr (S_OK);
	_bstr_t buffer;

		hr = ACTIVE_TO_CLOSED_NOT_ALLOWED;
		buffer = "State transition from Active to Closed is not allowed.";
		buffer += "The system will change to Pending Final Bill.";
		mLogger->LogThis (LOG_WARNING, (const char*) buffer);

	return hr;
}

//
//
//
STDMETHODIMP CActive::CanChangeToArchived(long lAccountID, DATE StartDate)
{
	_bstr_t buff;
	HRESULT hr (S_OK);

	hr = ACTIVE_TO_ARCHIVED_FAILED;
	buff = "State Transition from Active to Archived is not allowed";
	return Error ((const char*)buff, IID_IMTAccountStateInterface, hr);
}


// --------------------------- Helper Methods -------------------------
void
CActive::IsAccBillableAndPayingForOthers (long lAccountID, DATE StartDate, long& lStatus)
{
	// 
	MTACCOUNTSTATESLib::IMTSQLRowsetPtr rs(MTPROGID_SQLROWSET);
	rs->Init("\\Queries\\AccountStates");
	rs->InitializeForStoredProc("IsAccBillableNPayingForOthers");
	
	rs->AddInputParameterToStoredProc("p_id_acc", 
																		MTTYPE_INTEGER,
																		INPUT_PARAM,
																		lAccountID);
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

void
CActive::CheckAccountStateDateRules (long lAccountID, 
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

void
CActive::CheckForNotClosedDescendents (long lAccountID, DATE dRefDate, long& lStatus)
{
	// 
	MTACCOUNTSTATESLib::IMTSQLRowsetPtr rs(MTPROGID_SQLROWSET);
	rs->Init("\\Queries\\AccountStates");
	rs->InitializeForStoredProc("CheckForNotClosedDescendents");
		
	rs->AddInputParameterToStoredProc("p_id_acc", 
																		MTTYPE_INTEGER,
																		INPUT_PARAM,
																		lAccountID);
	rs->AddInputParameterToStoredProc("p_ref_date", 
																		MTTYPE_DATE, 
																		INPUT_PARAM, 
																		dRefDate);
	rs->AddOutputParameterToStoredProc("status", 
																	 	MTTYPE_INTEGER, 
																	 	OUTPUT_PARAM);
	rs->ExecuteStoredProc();
	lStatus = rs->GetParameterFromStoredProc("status");
	
	return;
}

//
//
//
void
CActive::UpdateDBState (long lAccountID, 
												_bstr_t bstrNewState,
												DATE StartDate,
												MTACCOUNTSTATESLib::IMTSQLRowsetPtr& rs)
{
	// 
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

	_variant_t vtDate = StartDate;
	vtDate.vt = VT_DATE;
	rs->AddInputParameterToStoredProc("p_start_date", 
																		MTTYPE_DATE, 
																		INPUT_PARAM, 
																		vtDate);

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
// --------------------------- Helper Methods -------------------------

