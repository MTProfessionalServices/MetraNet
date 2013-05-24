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
#include "MTCounterReader.h"

#include <pcexecincludes.h>
#include <mtcomerr.h>
//#include <MTCounter.h>

/////////////////////////////////////////////////////////////////////////////
// CMTCounterReader

/******************************************* error interface ***/
STDMETHODIMP CMTCounterReader::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTCounterReader
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTCounterReader::Activate()
{
	HRESULT hr = GetObjectContext(&mpObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTCounterReader::CanBePooled()
{
	return TRUE;
} 

void CMTCounterReader::Deactivate()
{
	mpObjectContext.Release();
} 


STDMETHODIMP CMTCounterReader::FindAsRowset(IMTSessionContext* apCtxt, VARIANT aFilter, IMTSQLRowset **apRowset)
{
	HRESULT hr(S_OK);
	ROWSETLib::IMTSQLRowsetPtr rs;
	
	hr = rs.CreateInstance(MTPROGID_SQLROWSET) ;
	_ASSERTE(SUCCEEDED(hr));

	MTAutoContext context(mpObjectContext);

	MTPRODUCTCATALOGLib::IMTProductCatalogPtr pc(__uuidof(MTProductCatalog));
	MTPRODUCTCATALOGLib::IMTDataFilterPtr aDataFilter = 
		pc->GetMetaData(MTPRODUCTCATALOGLib::PCENTITY_TYPE_COUNTER)->TranslateFilter(aFilter);

	try
	{
		if (!apCtxt)
			return E_POINTER;

		long languageID;
		hr = apCtxt->get_LanguageID(&languageID);
		if (FAILED(hr))
			return hr;

		rs->Init(CONFIG_DIR);
		rs->SetQueryTag(GET_ALL_COUNTERS); //TODO: Change Query to take additional conditions?
		rs->AddParam(L"%%ID_LANG%%", languageID);
		rs->Execute();
		// apply filter... XXX replace ADO filter with customized SQL
		// for better performance
		if(aDataFilter != NULL) {
			rs->PutRefFilter(reinterpret_cast<ROWSETLib::IMTDataFilter*>(aDataFilter.GetInterfacePtr()));
		}

		(*apRowset) = (IMTSQLRowset*) rs.Detach();
	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}
	context.Complete();
	return hr;
}

STDMETHODIMP CMTCounterReader::Find(IMTSessionContext* apCtxt, /*[in]*/long aDBID, /*[out, retval]*/IMTCounter** apCounter)
{
	HRESULT hr(S_OK);
	ROWSETLib::IMTSQLRowsetPtr rs;
	MTCOUNTERLib::IMTCounterPtr CounterPtr;
	int NumRecords;

	_ASSERTE(SUCCEEDED(hr));

	hr = rs.CreateInstance(MTPROGID_SQLROWSET) ;
	_ASSERTE(SUCCEEDED(hr));

	hr = CounterPtr.CreateInstance(MTPROGID_MTCOUNTER) ;
	_ASSERTE(SUCCEEDED(hr));
	//TODO: SetContext!!

	MTAutoContext context(mpObjectContext);
	
	try
	{
		if (!apCtxt)
			return E_POINTER;

		long languageID;
		HRESULT hr = apCtxt->get_LanguageID(&languageID);
		if (FAILED(hr))
			return hr;

		rs->Init(CONFIG_DIR);
		rs->SetQueryTag(GET_COUNTER);
		rs->AddParam(MTPARAM_ID_PROP, aDBID);
		rs->AddParam(L"%%ID_LANG%%", languageID);
		rs->Execute();
		NumRecords = rs->GetRecordCount();
		
		if(!NumRecords)
			MT_THROW_COM_ERROR(MTPC_ITEM_NOT_FOUND_BY_ID, MTPRODUCTCATALOGLib::PCENTITY_TYPE_COUNTER, aDBID);
		if(NumRecords > 1)
		{
			//should never get here with 
			//current DB schema
			//TODO: return custom error
		}
		
		//transform rowset row into object
		while(rs->GetRowsetEOF().boolVal == VARIANT_FALSE)
		{
			_variant_t val;
			
			//c.id_prop, id_counter_type,  nm_name, nm_desc 

			val = rs->GetValue("id_prop");
			CounterPtr->PutID(val.lVal);

			val = rs->GetValue("id_counter_type");
			CounterPtr->PutTypeID(val.lVal);
			
			val = rs->GetValue("nm_name");
			val = MTMiscUtil::GetString(val);
			CounterPtr->PutName(val.bstrVal);

			val = rs->GetValue("nm_desc");
			val = MTMiscUtil::GetString(val);
			CounterPtr->PutDescription(val.bstrVal);

			rs->MoveNext();
		}
		(*apCounter) = (IMTCounter*) CounterPtr.Detach();
	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}
	context.Complete();
	return hr;
}

STDMETHODIMP CMTCounterReader::FindOfType(IMTSessionContext* apCtxt, long aDBTypeID, IMTCollection** apColl)
{
	HRESULT hr(S_OK);
	ROWSETLib::IMTSQLRowsetPtr rs;
	MTObjectCollection<IMTCounter> coll;
	MTCOUNTERLib::IMTCounterPtr CounterPtr;
	int NumRecords;
	
	hr = rs.CreateInstance(MTPROGID_SQLROWSET) ;
	_ASSERTE(SUCCEEDED(hr));

	MTAutoContext context(mpObjectContext);
	
	try
	{
		if (!apCtxt)
			return E_POINTER;

		long languageID;
		HRESULT hr = apCtxt->get_LanguageID(&languageID);
		if (FAILED(hr))
			return hr;

		rs->Init(CONFIG_DIR);
		rs->SetQueryTag(GET_COUNTERS_OF_TYPE);
		rs->AddParam(MTPARAM_ID_PROP, aDBTypeID);
		rs->AddParam(L"%%ID_LANG%%", languageID);
		rs->Execute();
		NumRecords = rs->GetRecordCount();

		if(!NumRecords)
			MT_THROW_COM_ERROR(MTPC_ITEM_NOT_FOUND);

		if(NumRecords > 1)
		{
			//should never get here with 
			//current DB schema
			//TODO: return custom error
		}
		
		//transform rowset into collection
		while(rs->GetRowsetEOF().boolVal == VARIANT_FALSE)
		{
			_variant_t val;
			hr = CounterPtr.CreateInstance(MTPROGID_MTCOUNTER) ;
			_ASSERTE(SUCCEEDED(hr));
			//TODO: SetContext!!
			
			val = rs->GetValue("id_prop");
			CounterPtr->PutID(val.lVal);

			val = rs->GetValue("id_counter_type");
			CounterPtr->PutTypeID(val.lVal);
	
	
			val = rs->GetValue("nm_name");
			val = MTMiscUtil::GetString(val);
			CounterPtr->PutName(val.bstrVal);

			val = rs->GetValue("nm_desc");
			val = MTMiscUtil::GetString(val);
			CounterPtr->PutDescription(val.bstrVal);

			coll.Add( (IMTCounter*) CounterPtr.GetInterfacePtr());
			rs->MoveNext();
		}
		
		coll.CopyTo(apColl);
	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}
	context.Complete();
	return hr;
}
