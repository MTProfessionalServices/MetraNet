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
#include "PendingActiveApproval.h"
#include <RowsetDefs.h>
#include <mtcomerr.h>
#include <mtglobal_msg.h>
#include <corecapabilities.h>
#include <autherr.h>
#include <mttime.h>

#import <MTAuth.tlb> rename ("EOF", "RowsetEOF")

/////////////////////////////////////////////////////////////////////////////
// CPendingActiveApproval

STDMETHODIMP CPendingActiveApproval::InterfaceSupportsErrorInfo(REFIID riid)
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

void CPendingActiveApproval::InitializeState(MTACCOUNTSTATESLib::IMTAccountStateMetaDataPtr metadataPtr)
{
	mpBizRules = metadataPtr->GetPendingActiveApproval();
}

//
//
//
STDMETHODIMP CPendingActiveApproval::ChangeState(IMTSessionContext* pCtx,
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
STDMETHODIMP CPendingActiveApproval::ReverseState(IMTSessionContext* pCtx,
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
STDMETHODIMP CPendingActiveApproval::CanChangeToPendingActiveApproval(long lAccountID, DATE StartDate)
{
	_bstr_t buffer;
	long lReturnVal;
	HRESULT hr(S_OK);

	try 
	{
		// Business Rule 1: Check for generic business rules
		CheckAccountStateDateRules(lAccountID, L"PA", L"PA", StartDate, lReturnVal);
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
STDMETHODIMP CPendingActiveApproval::CanChangeToActive(long lAccountID, DATE StartDate)
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
STDMETHODIMP CPendingActiveApproval::CanChangeToSuspended(long lAccountID, DATE StartDate)
{
	return Error ("State Transition from PendingActiveApproval to Suspended is not allowed");
}

//
//
//
STDMETHODIMP CPendingActiveApproval::CanChangeToPendingFinalBill(long lAccountID, DATE StartDate)
{
	return Error ("State Transition from PendingActiveApproval to PendingFinalBill is not allowed");
}

//
//
//
STDMETHODIMP CPendingActiveApproval::CanChangeToClosed(long lAccountID, DATE StartDate)
{
	return Error ("State Transition from PendingActiveApproval to Closed is not allowed");
}

//
//
//
STDMETHODIMP CPendingActiveApproval::CanChangeToArchived(long lAccountID, DATE StartDate)
{
	return Error ("State Transition from PendingActiveApproval to Archived is not allowed");
}


// --------------------------- Helper Methods -------------------------
void
CPendingActiveApproval::CheckAccountStateDateRules (long lAccountID, 
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

//
//
//
void
CPendingActiveApproval::UpdateDBState (long lAccountID, 
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

