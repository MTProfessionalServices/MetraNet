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

// MTCounterMapWriter.cpp : Implementation of CMTCounterMapWriter
#include "StdAfx.h"
#include "MTProductCatalogExec.h"
#include "MTCounterMapWriter.h"

/////////////////////////////////////////////////////////////////////////////
// CMTCounterMapWriter

/******************************************* error interface ***/
STDMETHODIMP CMTCounterMapWriter::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTCounterMapWriter
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTCounterMapWriter::Activate()
{
	HRESULT hr = GetObjectContext(&mpObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTCounterMapWriter::CanBePooled()
{
	return FALSE;
} 

void CMTCounterMapWriter::Deactivate()
{
	mpObjectContext.Release();
} 

HRESULT CMTCounterMapWriter::AddMapping(IMTSessionContext* apCtxt, long aCounterDBID, long aPIDBID, long aCPDDBID)
{
	HRESULT hr(S_OK);
	ROWSETLib::IMTSQLRowsetPtr rs;
	
	hr = rs.CreateInstance(MTPROGID_SQLROWSET) ;
	_ASSERTE(SUCCEEDED(hr));

	MTAutoContext context(mpObjectContext);
	try
	{
		rs->Init(CONFIG_DIR);
		rs->SetQueryTag(ADD_COUNTER_MAPPING); 

		rs->AddParam("%%ID_COUNTER%%", _variant_t(aCounterDBID));
		rs->AddParam("%%ID_PI%%", _variant_t(aPIDBID));
		rs->AddParam("%%ID_CPD%%", _variant_t(aCPDDBID));
		rs->Execute();
	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}
	context.Complete();
	return hr;
}

HRESULT CMTCounterMapWriter::RemoveMapping(IMTSessionContext* apCtxt, long aPIDBID, long aCounterDBID)
{
	HRESULT hr(S_OK);
	ROWSETLib::IMTSQLRowsetPtr rs;
	
	hr = rs.CreateInstance(MTPROGID_SQLROWSET) ;
	_ASSERTE(SUCCEEDED(hr));

	MTAutoContext context(mpObjectContext);
	try
	{
		rs->Init(CONFIG_DIR);
		rs->SetQueryTag(REMOVE_COUNTER_MAPPING); 
		rs->AddParam("%%ID_COUNTER%%", _variant_t(aCounterDBID));
		rs->AddParam("%%ID_PI%%", _variant_t(aPIDBID));
		rs->Execute();
	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}
	context.Complete();
	return hr;
}

STDMETHODIMP CMTCounterMapWriter::RemoveMappingByPIDBID(IMTSessionContext* apCtxt, long aPIDBID)
{
	MTAutoContext context(mpObjectContext);

	try
	{
		// first clear counter map by removing all old mapping, and inserting new.
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		rowset->SetQueryTag("__REMOVE_COUNTER_MAPPING_BY_PI_ID__");
		rowset->AddParam("%%ID_PI%%", aPIDBID);
		rowset->Execute();
	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}

	context.Complete();

	return S_OK;
}
