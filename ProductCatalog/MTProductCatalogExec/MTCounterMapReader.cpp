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

// MTCounterMapReader.cpp : Implementation of CMTCounterMapReader
#include "StdAfx.h"
#include "MTProductCatalogExec.h"
#include "MTCounterMapReader.h"

/////////////////////////////////////////////////////////////////////////////
// CMTCounterMapReader

/******************************************* error interface ***/
STDMETHODIMP CMTCounterMapReader::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTCounterMapReader
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTCounterMapReader::Activate()
{
	HRESULT hr = GetObjectContext(&mpObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTCounterMapReader::CanBePooled()
{
	return FALSE;
} 

void CMTCounterMapReader::Deactivate()
{
	mpObjectContext.Release();
} 


STDMETHODIMP CMTCounterMapReader::GetPIMappingsAsRowset(IMTSessionContext* apCtxt, long aPIDBID, IMTSQLRowset **apRowset)
{
	HRESULT hr(S_OK);
	ROWSETLib::IMTSQLRowsetPtr rs;
	
	hr = rs.CreateInstance(MTPROGID_SQLROWSET) ;
	_ASSERTE(SUCCEEDED(hr));

	MTAutoContext context(mpObjectContext);
	
	try
	{
		rs->Init(CONFIG_DIR);
		rs->SetQueryTag(GET_COUNTER_MAPPING); 

		rs->AddParam("%%ID_PROP%%", _variant_t(aPIDBID));
		rs->Execute();
		(*apRowset) = (IMTSQLRowset*) rs.Detach();
	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}
	context.Complete();
	return hr;
}


STDMETHODIMP CMTCounterMapReader::GetExtendedPIMappingsAsRowset(IMTSessionContext* apCtxt, long aPIDBID, long aPITypeDBID, IMTSQLRowset **apRowset)
{
	HRESULT hr(S_OK);
	ROWSETLib::IMTSQLRowsetPtr rs;
	
	hr = rs.CreateInstance(MTPROGID_SQLROWSET) ;
	_variant_t vLanguageCode = (long)840; // LANGID TODO: get from Prod Cat
	_ASSERTE(SUCCEEDED(hr));

	MTAutoContext context(mpObjectContext);
	
	try
	{
		rs->Init(CONFIG_DIR);
		rs->SetQueryTag(GET_EXTENDED_COUNTER_MAPPING); 

		rs->AddParam("%%ID_LANG%%", vLanguageCode);
		rs->AddParam("%%ID_PI%%", _variant_t(aPIDBID));
		rs->AddParam("%%ID_PI_TYPE%%", _variant_t(aPITypeDBID));

		//TODO: Set additional params from Filter
		rs->Execute();
		(*apRowset) = (IMTSQLRowset*) rs.Detach();
	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}
	context.Complete();
	return hr;
}

