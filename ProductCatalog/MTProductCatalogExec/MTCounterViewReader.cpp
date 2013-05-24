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

// MTCounterViewReader.cpp : Implementation of CMTCounterViewReader
#include "StdAfx.h"
#include "MTProductCatalogExec.h"
#include "MTCounterViewReader.h"

/////////////////////////////////////////////////////////////////////////////
// CMTCounterViewReader

/******************************************* error interface ***/
STDMETHODIMP CMTCounterViewReader::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTCounterViewReader
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTCounterViewReader::Activate()
{
	HRESULT hr = GetObjectContext(&mpObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTCounterViewReader::CanBePooled()
{
	return FALSE;
} 

void CMTCounterViewReader::Deactivate()
{
	mpObjectContext.Release();
} 


STDMETHODIMP CMTCounterViewReader::ViewExists(IMTSessionContext* apCtxt, BSTR aViewName, VARIANT_BOOL *abFlag)
{
	HRESULT hr(S_OK);
	ROWSETLib::IMTSQLRowsetPtr rs;
	_bstr_t bstrViewName = aViewName;
	_variant_t vtParam;
	
	hr = rs.CreateInstance(MTPROGID_SQLROWSET) ;
	_ASSERTE(SUCCEEDED(hr));
	try
	{
		rs->Init(CONFIG_DIR);
		rs->SetQueryTag(CHECK_COUNTER_UNION_VIEW);
		vtParam = bstrViewName;
		rs->AddParam (MTPARAM_VIEWNAME, vtParam) ;
		rs->Execute();

		if(rs->GetRecordCount() > 0)
		{
			(*abFlag) = VARIANT_TRUE;
		}
		else
			(*abFlag) = VARIANT_FALSE;

		if (mpObjectContext)
			mpObjectContext->SetComplete();
	}
	catch(_com_error& e)
	{
		if (mpObjectContext)
			mpObjectContext->SetAbort();
		return ReturnComError(e);
	}
	return hr;
}
