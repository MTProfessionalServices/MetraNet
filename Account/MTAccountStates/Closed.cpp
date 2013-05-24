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
#include "Closed.h"
#include <RowsetDefs.h>
#include <mtglobal_msg.h>
#include <mttime.h>

/////////////////////////////////////////////////////////////////////////////
// CClosed

STDMETHODIMP CClosed::InterfaceSupportsErrorInfo(REFIID riid)
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
void CClosed::InitializeState(MTACCOUNTSTATESLib::IMTAccountStateMetaDataPtr metadataPtr)
{
	mpBizRules = metadataPtr->GetClosed();
}


//
//
//
STDMETHODIMP CClosed::ChangeState(IMTSessionContext* pCtx,
																	IMTSQLRowset* pRowset, 
																	long lAccountID, 
																	long lIntervalID, 
																	BSTR statename, 
																	DATE StartDate,
																	DATE EndDate)
{
	_bstr_t buffer;
	HRESULT hr(S_OK);

	// implement each state's change and just call it from here
	_bstr_t bstrStateName(statename);

	// check to see if the state can be changed to the new state
	try 
	{
		if (0 == _wcsicmp(bstrStateName, PENDING_ACTIVE_APPROVAL))
			hr = CanChangeToPendingActiveApproval(lAccountID, StartDate);
		else if (0 == _wcsicmp(bstrStateName, ACTIVE))
			hr = CanChangeToActive(lAccountID, StartDate);
		else if (0 == _wcsicmp(bstrStateName, SUSPENDED))
			hr = CanChangeToSuspended(lAccountID, StartDate);
		else if (0 == _wcsicmp(bstrStateName, PENDING_FINAL_BILL))
		{
			hr = CanChangeToPendingFinalBill(lAccountID, StartDate);
			if (FAILED(hr))
				MT_THROW_COM_ERROR(hr);
			else
				UpdateDBStateFromClosedToPFB(StartDate, EndDate);
		}
		else if (0 == _wcsicmp(bstrStateName, CLOSED))
			hr = CanChangeToClosed(lAccountID, StartDate);
		else if (0 == _wcsicmp(bstrStateName, ARCHIVED))
		{
			hr = CanChangeToArchived(lAccountID, StartDate);
			if (FAILED(hr))
				MT_THROW_COM_ERROR(hr);
			else
			{
				long lAge;
				mpBizRules->get_ArchiveAge(&lAge);
				if (lAge == 0)
				{
					buffer = "Age is configured to be 0. This account will not be archived";
					mLogger->LogThis (LOG_DEBUG, (const char*) buffer);
					return S_OK;
				}
				UpdateDBStateFromClosedToArchived(StartDate, EndDate, lAge);
			}
		}
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
		buffer = "The state could not be changed from <Closed> to <";
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
STDMETHODIMP CClosed::ReverseState(IMTSessionContext* pCtx,
																	IMTSQLRowset* pRowset, 
																	long lAccountID, 
																	long lIntervalID, 
																	BSTR statename, 
																	DATE StartDate,
																	DATE EndDate)
{
	_bstr_t buffer;
	_bstr_t bstrStateName(statename);

	// return right away if the reversal is requested to states other than
	// pending final bill or archived
	try
	{
		if (0 == _wcsicmp(bstrStateName, ARCHIVED))
		{
			long lAge;
			mpBizRules->get_ArchiveAge(&lAge);
			ReverseUpdateDBStateFromClosedToArchived(StartDate, EndDate, lAge);
		}
		else if (0 == _wcsicmp(bstrStateName, PENDING_FINAL_BILL))
			ReverseUpdateDBStateFromClosedToPFB(StartDate, EndDate);
#if 0
		else
		{
			buffer = "Illegal state transition requested! Cannot reverse from Closed to <";
			buffer += bstrStateName;
			buffer += ">";
			mLogger->LogThis (LOG_ERROR, (const char*) buffer);
			return Error((const char*)buffer); 
		}
#endif
	}
	catch (_com_error& e)
	{
		buffer = "Exception while reversing the action from Closed to <";
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
STDMETHODIMP CClosed::CanChangeToPendingActiveApproval(long lAccountID, DATE StartDate)
{
	return Error ("State Transition from Closed to Pending Active Approval is not allowed");
}

//
//
//
STDMETHODIMP CClosed::CanChangeToActive(long lAccountID, DATE StartDate)
{
		return Error ("State Transition from Closed to Active is not allowed");
	}	

//
//
//
STDMETHODIMP CClosed::CanChangeToSuspended(long lAccountID, DATE StartDate)
{
	return Error ("State Transition from Closed to Suspended is not allowed");
}

//
//
//
STDMETHODIMP CClosed::CanChangeToPendingFinalBill(long lAccountID, DATE StartDate)
{
	return S_OK;
}

//
//
//
STDMETHODIMP CClosed::CanChangeToClosed(long lAccountID, DATE StartDate)
{
	return Error("State Transition from Closed to self is not allowed");
}

//
//
//
STDMETHODIMP CClosed::CanChangeToArchived(long lAccountID, DATE StartDate)
{
	_bstr_t buffer;
	long lReturnVal;
	HRESULT hr(S_OK);

	try
	{
    // 2. Check if this account is a folder and if it has descendents that are
    // in archived state 
		CheckForNotArchivedDescendents(lAccountID, StartDate, lReturnVal);
		switch (lReturnVal) 
		{
			// not a folder
			case -486604799:
				hr = MT_ACCOUNT_NOT_A_FOLDER;
				buffer = "This account has no descendents.  No need to check for archived descendents";
				mLogger->LogThis(LOG_INFO, (const char*) buffer);
				return S_OK;
				break;

			//	0 rows found or more than 0 rows found is success condition
		  case 1:
				hr = MT_ACCOUNT_IS_FOLDER_AND_HAS_NO_DESCENDENTS_IN_ARCHIVED_STATE;
				buffer = "This account has no descendents that are in archived state";
				mLogger->LogThis(LOG_INFO, (const char*) buffer);
				return S_OK;
				break;

		  default:
				hr = MT_ACCOUNT_IS_FOLDER_AND_HAS_DESCENDENTS_IN_STATE_OTHER_THAN_ARCHIVED;
				buffer = "This account has descendents that are in a state other than archived";
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

// --------------------------- Helper Methods -------------------------
void
CClosed::CheckForNotArchivedDescendents (long lAccountID, DATE dRefDate, long& lStatus)
{
	// 
	_bstr_t bstrVal;
	
	MTACCOUNTSTATESLib::IMTSQLRowsetPtr rs(MTPROGID_SQLROWSET);
	rs->Init("\\Queries\\AccountStates");
	rs->InitializeForStoredProc("CheckForNotArchivedDescendents");
		
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
// --------------------------- Helper Methods -------------------------

//
//
//
void
CClosed::UpdateDBStateFromClosedToPFB (DATE StartDate, DATE EndDate)
{
	// 
	MTACCOUNTSTATESLib::IMTSQLRowsetPtr rs(MTPROGID_SQLROWSET);
	rs->Init("\\Queries\\AccountStates");
	rs->InitializeForStoredProc("UpdateStateFromClosedToPFB");

	// if there are no problems, update the state in the database
	_variant_t systemDate = GetMTOLETime();
	rs->AddInputParameterToStoredProc("system_date",
																			MTTYPE_DATE,
																			INPUT_PARAM,
																			systemDate);

	long status = -1;
	// the ref date here does not make any sense.  it should be the system
	// date.  but, we want to keep the api such that the date gets passed in
	// and if SIs want to change it, they can change the stored procedure
	rs->AddInputParameterToStoredProc("p_start_date", 
																		MTTYPE_DATE, 
																		INPUT_PARAM, 
																		StartDate);
	rs->AddInputParameterToStoredProc("p_end_date", 
																		MTTYPE_DATE, 
																		INPUT_PARAM, 
																		EndDate);
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
CClosed::UpdateDBStateFromClosedToArchived (DATE StartDate, 
																						DATE EndDate,
																						long lAge)
{
	// 
	MTACCOUNTSTATESLib::IMTSQLRowsetPtr rs(MTPROGID_SQLROWSET);
	rs->Init("\\Queries\\AccountStates");
	rs->InitializeForStoredProc("UpdStateFromClosedToArchived");

	// if there are no problems, update the state in the database
	long status = -1;

	_variant_t systemDate = GetMTOLETime();
	rs->AddInputParameterToStoredProc("system_date",
																		MTTYPE_DATE,
																		INPUT_PARAM,
																		systemDate);
	rs->AddInputParameterToStoredProc("p_start_date",
																		MTTYPE_DATE,
																		INPUT_PARAM,
																		StartDate);
	rs->AddInputParameterToStoredProc("p_end_date",
																		MTTYPE_DATE,
																		INPUT_PARAM,
																		EndDate);
	rs->AddInputParameterToStoredProc("age", 
																		MTTYPE_INTEGER, 
																		INPUT_PARAM, 
																		lAge);
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
CClosed::ReverseUpdateDBStateFromClosedToPFB (DATE StartDate, DATE EndDate)
{
	// 
	MTACCOUNTSTATESLib::IMTSQLRowsetPtr rs(MTPROGID_SQLROWSET);
	rs->Init("\\Queries\\AccountStates");
	rs->InitializeForStoredProc("Rev_UpdateStateFromClosedToPFB");

	// if there are no problems, update the state in the database
	_variant_t systemDate = GetMTOLETime();
	rs->AddInputParameterToStoredProc("system_date",
																			MTTYPE_DATE,
																			INPUT_PARAM,
																			systemDate);

	long status = -1;
	// the ref date here does not make any sense.  it should be the system
	// date.  but, we want to keep the api such that the date gets passed in
	// and if SIs want to change it, they can change the stored procedure
	rs->AddInputParameterToStoredProc("p_start_date", 
																		MTTYPE_DATE, 
																		INPUT_PARAM, 
																		StartDate);
	rs->AddInputParameterToStoredProc("p_end_date", 
																		MTTYPE_DATE, 
																		INPUT_PARAM, 
																		EndDate);
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
CClosed::ReverseUpdateDBStateFromClosedToArchived (DATE StartDate,
																									 DATE EndDate,
																									 long lAge)
{
	// 
	MTACCOUNTSTATESLib::IMTSQLRowsetPtr rs(MTPROGID_SQLROWSET);
	rs->Init("\\Queries\\AccountStates");
	rs->InitializeForStoredProc("Rev_UpdStateFromClosedToArchiv");

	// if there are no problems, update the state in the database
	long status = -1;

	_variant_t systemDate = GetMTOLETime();
	rs->AddInputParameterToStoredProc("system_date",
																		MTTYPE_DATE,
																		INPUT_PARAM,
																		systemDate);
	rs->AddInputParameterToStoredProc("p_start_date",
																		MTTYPE_DATE,
																		INPUT_PARAM,
																		StartDate);
	rs->AddInputParameterToStoredProc("p_end_date",
																		MTTYPE_DATE,
																		INPUT_PARAM,
																		EndDate);
	rs->AddInputParameterToStoredProc("age", 
																		MTTYPE_INTEGER, 
																		INPUT_PARAM, 
																		lAge);
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
