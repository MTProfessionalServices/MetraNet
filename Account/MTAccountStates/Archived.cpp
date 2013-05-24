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
#include "Archived.h"

/////////////////////////////////////////////////////////////////////////////
// CArchived

STDMETHODIMP CArchived::InterfaceSupportsErrorInfo(REFIID riid)
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

void CArchived::InitializeState(MTACCOUNTSTATESLib::IMTAccountStateMetaDataPtr metadataPtr)
{
	// get archived state meta data
	mpBizRules = metadataPtr->GetArchived();

}

//
//
//
STDMETHODIMP CArchived::ChangeState(IMTSessionContext* pCtx,
																		IMTSQLRowset* pRowset, 
																		long lAccountID, 
																		long lIntervalID, 
																		BSTR statename, 
																		DATE StartDate,
																		DATE EndDate)
{
	return Error ("Account is in an Archived state.  No operations are permitted");
}

//
//
//
STDMETHODIMP CArchived::ReverseState(IMTSessionContext* pCtx,
																		IMTSQLRowset* pRowset, 
																		long lAccountID, 
																		long lIntervalID, 
																		BSTR statename, 
																		DATE StartDate,
																		DATE EndDate)
{
	return S_OK;
}


//
//
//
STDMETHODIMP CArchived::CanChangeToPendingActiveApproval(long lAccountID, DATE StartDate)
{
	return Error ("Account is in an Archived state.  No operations are permitted");
}

//
//
//
STDMETHODIMP CArchived::CanChangeToActive(long lAccountID, DATE StartDate)
{
	return Error ("Account is in an Archived state.  No operations are permitted");
}

//
//
//
STDMETHODIMP CArchived::CanChangeToSuspended(long lAccountID, DATE StartDate)
{
	return Error ("Account is in an Archived state.  No operations are permitted");
}

//
//
//
STDMETHODIMP CArchived::CanChangeToPendingFinalBill(long lAccountID, DATE StartDate)
{
	return Error ("Account is in an Archived state.  No operations are permitted");
}

//
//
//
STDMETHODIMP CArchived::CanChangeToClosed(long lAccountID, DATE StartDate)
{
	return Error ("Account is in an Archived state.  No operations are permitted");
}

//
//
//
STDMETHODIMP CArchived::CanChangeToArchived(long lAccountID, DATE StartDate)
{
	return Error ("Account is in an Archived state.  No operations are permitted");
}

