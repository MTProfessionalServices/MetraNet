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
#include "MTAccountReader.h"
#include <metra.h>
#include <formatdbvalue.h>

/////////////////////////////////////////////////////////////////////////////
// CMTAccountReader

/******************************************* error interface ***/
STDMETHODIMP CMTAccountReader::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTAccountReader
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTAccountReader::Activate()
{
	HRESULT hr = GetObjectContext(&m_spObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTAccountReader::CanBePooled()
{
	return TRUE;
} 

void CMTAccountReader::Deactivate()
{
	m_spObjectContext.Release();
} 


STDMETHODIMP CMTAccountReader::GetDefaultPriceList(IMTSessionContext* apCtxt, long accountID, IMTPriceList **ppVal)
{
	ASSERT(ppVal);
	if(!ppVal) return E_POINTER;

	// step 1: look up the default account pricelist for the 

	// step 2: create the executant for the pricelist

	return S_OK;
}

		
STDMETHODIMP CMTAccountReader::GetNextBillingIntervalEndDate(IMTSessionContext* apCtxt, long accountID, DATE datecheck, VARIANT *pVal)
{
	ROWSETLib::IMTSQLRowsetPtr rowset;
	
	HRESULT hr = rowset.CreateInstance(MTPROGID_SQLROWSET);
	_ASSERTE(SUCCEEDED(hr));

	_bstr_t strDate = datecheck;

	try
	{
		// Step 1: Run query to find date
		rowset->Init(CONFIG_DIR);
		rowset->ClearQuery();
		rowset->SetQueryTag("__GET_NEXT_BILLING_ENDDATE__");
		rowset->AddParam("%%ID_ACC%%", accountID);

		// Convert Date and add it as input param
		_variant_t vtDate = datecheck;
		vtDate.vt = VT_DATE;
		wstring DateVal;
		BOOL bSuccess = FormatValueForDB(vtDate,FALSE,DateVal);
		if (bSuccess == FALSE)
		{
			return E_FAIL;
		}
		
		rowset->AddParam("%%DT_DATECHECK%%", DateVal.c_str(),VARIANT_TRUE);
		rowset->Execute();
		
		*pVal = rowset->GetValue("maxdate");

//		if (var.vt == VT_NULL)
//		{
//			pVal = NULL;
//		}
//		else
//		{
//			*pVal = rowset->GetValue("maxdate");
//		}


	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}

	return S_OK;
}
	