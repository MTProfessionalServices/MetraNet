/**************************************************************************
* Copyright 1997-2001 by MetraTech
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
* $Header$
* 
***************************************************************************/

#include "StdAfx.h"
#include "MTProductCatalogExec.h"
#include "MTAccountWriter.h"
#include <comdef.h>
#include <mtcomerr.h>
#include <metra.h>
#include <mtautocontext.h>
#include <mtprogids.h>

#include "pcexecincludes.h"

/////////////////////////////////////////////////////////////////////////////
// CMTAccountWriter

/******************************************* error interface ***/
STDMETHODIMP CMTAccountWriter::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTAccountWriter
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTAccountWriter::Activate()
{
	HRESULT hr = GetObjectContext(&m_spObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTAccountWriter::CanBePooled()
{
	return TRUE;
} 

void CMTAccountWriter::Deactivate()
{
	m_spObjectContext.Release();
} 

// ----------------------------------------------------------------
// Name:     	
// Arguments:     
//                
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTAccountWriter::UpdateDefaultPricelist(IMTSessionContext* apCtxt, long accountID,long PriceListID)
{
	MTAutoContext context(m_spObjectContext);

	try {

		ROWSETLib::IMTSQLRowsetPtr rs;
		HRESULT hr = rs.CreateInstance(MTPROGID_SQLROWSET);
		if (FAILED(hr))
			return hr;

		rs->Init(CONFIG_DIR);
		rs->SetQueryTag("__UPDATE_DEFAULT_ACCOUNT_PL__");
		rs->AddParam("%%ACC_ID%%", accountID);
		rs->AddParam("%%PL_ID%%", PriceListID);

		// step 1: run query that returns default account pricelist based on the account
		rs->Execute();
	}
	catch(_com_error& e) {
		return ReturnComError(e); 
	}

	context.Complete();
	return S_OK;
}



STDMETHODIMP CMTAccountWriter::UpdateICBPriceList(IMTSessionContext* apCtxt, long accountID, long PriceListID)
{
	MTAutoContext context(m_spObjectContext);

	try {

		ROWSETLib::IMTSQLRowsetPtr rs;
		HRESULT hr = rs.CreateInstance(MTPROGID_SQLROWSET);
		if (FAILED(hr))
			return hr;

		rs->Init(CONFIG_DIR);
		rs->SetQueryTag("__UPDATE_ICB_ACCOUNT_PL__");
		rs->AddParam("%%ACC_ID%%", accountID);
		rs->AddParam("%%PL_ID%%", PriceListID);

		// step 1: run query that returns default account pricelist based on the account
		rs->Execute();
	}
	catch(_com_error& e) {
		return ReturnComError(e); 
	}

	context.Complete();
	return S_OK;
}
