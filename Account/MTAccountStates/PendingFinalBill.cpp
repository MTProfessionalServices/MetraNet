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
#include "PendingFinalBill.h"
#include <RowsetDefs.h>
#include <mtglobal_msg.h>
#include <corecapabilities.h>
#include <autherr.h>
#include <mttime.h>
#include <mtparamnames.h>

#import <MTAuth.tlb> rename ("EOF", "RowsetEOF")

/////////////////////////////////////////////////////////////////////////////
// CPendingFinalBill

STDMETHODIMP CPendingFinalBill::InterfaceSupportsErrorInfo(REFIID riid)
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
void CPendingFinalBill::InitializeState(MTACCOUNTSTATESLib::IMTAccountStateMetaDataPtr metadataPtr)
{
	mpBizRules = metadataPtr->GetPendingFinalBill();
}

//
//
//
STDMETHODIMP CPendingFinalBill::ChangeState(IMTSessionContext* pCtx,
																	          IMTSQLRowset* pRowset, 
																	          long lAccountID, 
                                            long lBillingGroupID,
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
		{
			MTAUTHLib::IMTSessionContextPtr pCurrentCtxPtr(pCtx);
			if (pCurrentCtxPtr != NULL)
			{
				pCurrentCtxPtr->SecurityContext->CheckAccess
					(pSec->GetCapabilityTypeByName(UPD_FROM_PENDINGFINALBILL_TO_ACTIVE_CAP)->CreateInstance());
			}
			hr = CanChangeToActive(lAccountID, StartDate);
			if (FAILED(hr))
				return hr;
			UpdateDBState(lAccountID, bstrStateName, StartDate, pRowsetPtr);
		}
		else if (0 == _wcsicmp(bstrStateName, SUSPENDED))
			hr = CanChangeToSuspended(lAccountID, StartDate);
		else if (0 == _wcsicmp(bstrStateName, PENDING_FINAL_BILL))
			hr = CanChangeToPendingFinalBill(lAccountID, StartDate);
		else if (0 == _wcsicmp(bstrStateName, CLOSED))
		{
			hr = CanChangeToClosed(lAccountID, StartDate);
			if (FAILED(hr))
			{
				if (hr == INTERVAL_NOT_HARD_CLOSED)
					return S_OK;
				else
					MT_THROW_COM_ERROR(hr);
			}
			else
				UpdateDBStateFromPFBToClosed(lBillingGroupID, StartDate);
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

		// check for hr
		if (FAILED(hr))
			return hr;
	}
	catch (_com_error& e)
	{
		buffer = "The state could not be changed from <PendingFinalBill> to <";
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
STDMETHODIMP CPendingFinalBill::ReverseState(IMTSessionContext* pCtx,
																						 IMTSQLRowset* pRowset, 
																						 long lAccountID, 
																						 long lBillingGroupID,
																						 BSTR statename, 
																						 DATE StartDate,
																						 DATE EndDate)
{
	_bstr_t buffer;

	// return right away if the reversal is requested to states other than
	// closed
	_bstr_t bstrStateName(statename);
	if (0 != _wcsicmp(bstrStateName, CLOSED))
	{
		buffer = "Illegal state transition requested! Cannot reverse from PendingFinalBill to <";
		buffer += bstrStateName;
		buffer += ">";
		mLogger->LogThis (LOG_ERROR, (const char*) buffer);
		return Error((const char*)buffer); 
	}

	// now we can move on with the transitions
	try
	{
		ReverseUpdateDBStateFromPFBToClosed(lBillingGroupID, StartDate);
	}
	catch (_com_error& e)
	{
		buffer = "Exception while reversing the action from PendingFinalBill to <";
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
STDMETHODIMP CPendingFinalBill::CanChangeToPendingActiveApproval(long lAccountID, DATE StartDate)
{
	return Error ("State Transition from Pending Final Bill to Pending Active Approval is not allowed");
}

//
//
//
STDMETHODIMP CPendingFinalBill::CanChangeToActive(long lAccountID, DATE StartDate)
{
	_bstr_t buffer;
	long lReturnVal;
	HRESULT hr(S_OK);

	try 
	{
		// Business Rule 1: Check for generic business rules
		CheckAccountStateDateRules(lAccountID, L"PF", L"AC", StartDate, lReturnVal);
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
STDMETHODIMP CPendingFinalBill::CanChangeToSuspended(long lAccountID, DATE StartDate)
{
	return Error ("State Transition from Pending Final Bill to Suspended is not allowed");
}

//
//
//
STDMETHODIMP CPendingFinalBill::CanChangeToPendingFinalBill(long lAccountID, DATE StartDate)
{
	_bstr_t buffer;
	long lReturnVal;
	HRESULT hr(S_OK);

	try 
	{
		// Business Rule 1: Check for generic business rules
		CheckAccountStateDateRules(lAccountID, L"PF", L"PF", StartDate, lReturnVal);
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
STDMETHODIMP CPendingFinalBill::CanChangeToClosed(long lAccountID, DATE StartDate)
{
	_bstr_t buffer;
//	long lReturnVal;
	HRESULT hr(S_OK);

	try 
	{
		// Business Rule 1: Check for generic business rules
    // The date is going to be passed by the system.  So, we dont need to do
    // this
#if 0
		CheckAccountStateDateRules(lAccountID, L"PF", L"CL", StartDate, lReturnVal);
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
#endif

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
STDMETHODIMP CPendingFinalBill::CanChangeToArchived(long lAccountID, DATE StartDate)
{
	return Error ("State Transition from Pending Final Bill to Archived is not allowed");
}

// --------------------------- Helper Methods -------------------------
//
//
//
void
CPendingFinalBill::UpdateDBStateFromPFBToClosed(long lBillingGroupID, 
																							  DATE StartDate)
{
	// 
	MTACCOUNTSTATESLib::IMTSQLRowsetPtr rs(MTPROGID_SQLROWSET);
	rs->Init("\\Queries\\Database");
	rs->InitializeForStoredProc("UpdateStateFromPFBToClosed");

	// if there are no problems, update the state in the database
	long status = -1;
	rs->AddInputParameterToStoredProc("id_billgroup", 
																		MTTYPE_INTEGER, 
																		INPUT_PARAM, 
																		lBillingGroupID);
	rs->AddInputParameterToStoredProc("ref_date", 
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

	if(status != 1) 
	{
		MT_THROW_COM_ERROR(status);
	}
	return;
}

void
CPendingFinalBill::CheckAccountStateDateRules(long lAccountID, 
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
CPendingFinalBill::UpdateDBState (long lAccountID, 
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

//
//
//
void
CPendingFinalBill::ReverseUpdateDBStateFromPFBToClosed(long lBillingGroupID, 
																								       DATE StartDate)
{
	// 
	MTACCOUNTSTATESLib::IMTSQLRowsetPtr rs(MTPROGID_SQLROWSET);
	rs->Init("\\Queries\\Database");
	rs->InitializeForStoredProc("Rev_UpdateStateFromPFBToClosed");

	// if there are no problems, update the state in the database
	long status = -1;
	rs->AddInputParameterToStoredProc("id_billgroup", 
																		MTTYPE_INTEGER, 
																		INPUT_PARAM, 
																		lBillingGroupID);
	rs->AddInputParameterToStoredProc("ref_date", 
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

	if(status != 1) 
	{
		MT_THROW_COM_ERROR(status);
	}
	return;
}

// --------------------------- Helper Methods -------------------------

