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
#include "MTCounterTypeReader.h"

#include <pcexecincludes.h>

/////////////////////////////////////////////////////////////////////////////
// CMTCounterTypeReader

/******************************************* error interface ***/
STDMETHODIMP CMTCounterTypeReader::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTCounterTypeReader
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTCounterTypeReader::Activate()
{
	HRESULT hr = GetObjectContext(&mpObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTCounterTypeReader::CanBePooled()
{
	return FALSE;
} 

void CMTCounterTypeReader::Deactivate()
{
	mpObjectContext.Release();
} 


STDMETHODIMP CMTCounterTypeReader::GetAllTypes(IMTSessionContext* apCtxt, IMTCollection **apColl)
{
	HRESULT hr(S_OK);
	ROWSETLib::IMTSQLRowsetPtr rs;
	MTObjectCollection<IMTCounterType> coll;
	MTCOUNTERLib::IMTCounterTypePtr CounterTypePtr;

	hr = rs.CreateInstance(MTPROGID_SQLROWSET) ;
	_ASSERTE(SUCCEEDED(hr));

	MTAutoContext context(mpObjectContext);

	try
	{
		if (!apCtxt)
			return E_POINTER;

		long languageID;
		hr = apCtxt->get_LanguageID(&languageID);
		if (FAILED(hr))
			return hr;

		rs->Init(CONFIG_DIR);
		rs->SetQueryTag(GET_ALL_TYPES);
		rs->AddParam(L"%%ID_LANG%%", languageID);
		rs->Execute();
		
		//transform rowset into collection
		while(rs->GetRowsetEOF().boolVal == VARIANT_FALSE)
		{
			_variant_t val;
			hr = CounterTypePtr.CreateInstance(MTPROGID_MTCOUNTERTYPE) ;
			_ASSERTE(SUCCEEDED(hr));
			//TODO: SetContext!!
			
			//ct.id_prop, nm_name, nm_desc, FormulaTemplate 

			val = rs->GetValue("id_prop");
			CounterTypePtr->PutID(val.lVal);
	
			val = rs->GetValue("nm_name");
			val = MTMiscUtil::GetString(val);
			CounterTypePtr->PutName(val.bstrVal);

			val = rs->GetValue("nm_desc");
			val = MTMiscUtil::GetString(val);
			CounterTypePtr->PutDescription(val.bstrVal);

			val = rs->GetValue("FormulaTemplate");
			val = MTMiscUtil::GetString(val);
			CounterTypePtr->PutFormulaTemplate(val.bstrVal);
			
			val = rs->GetValue("b_valid_for_dist");
			val = MTMiscUtil::GetString(val);
			CounterTypePtr->PutValidForDistribution(MTTypeConvert::StringToBool(val.bstrVal));

			coll.Add( (IMTCounterType*) CounterTypePtr.GetInterfacePtr());
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

STDMETHODIMP CMTCounterTypeReader::Find(IMTSessionContext* apCtxt, long aDBID, IMTCounterType **apType)
{
	HRESULT hr(S_OK);
	ROWSETLib::IMTSQLRowsetPtr rs;
	MTCOUNTERLib::IMTCounterTypePtr CounterTypePtr;
	int NumRecords;
	
	hr = rs.CreateInstance(MTPROGID_SQLROWSET) ;
	_ASSERTE(SUCCEEDED(hr));

	hr = CounterTypePtr.CreateInstance(MTPROGID_MTCOUNTERTYPE) ;
	_ASSERTE(SUCCEEDED(hr));
	//TODO: SetContext!!

	MTAutoContext context(mpObjectContext);
	
	try
	{
		if (!apCtxt)
			return E_POINTER;

		long languageID;
		hr = apCtxt->get_LanguageID(&languageID);
		if (FAILED(hr))
			return hr;

		rs->Init(CONFIG_DIR);
		rs->SetQueryTag(GET_TYPE);
		rs->AddParam(MTPARAM_ID_PROP, aDBID);
		rs->AddParam(L"%%ID_LANG%%", languageID);
		rs->Execute();
		NumRecords = rs->GetRecordCount();
		
		if(!NumRecords)
			MT_THROW_COM_ERROR(MTPC_ITEM_NOT_FOUND_BY_ID, PCENTITY_TYPE_COUNTER_META_DATA, aDBID);

		if(rs->GetRecordCount() > 1)
		{
			//should never get here with 
			//current DB schema
			//TODO: return custom error
		}
		
		//transform rowset row into object
		while(rs->GetRowsetEOF().boolVal == VARIANT_FALSE)
		{
			_variant_t val;
			
			//ct.id_prop, nm_name, nm_desc, FormulaTemplate 

			val = rs->GetValue("id_prop");
			CounterTypePtr->PutID(val.lVal);
	
			val = rs->GetValue("nm_name");
			val = MTMiscUtil::GetString(val);
			CounterTypePtr->PutName(val.bstrVal);

			val = rs->GetValue("nm_desc");
			val = MTMiscUtil::GetString(val);
			CounterTypePtr->PutDescription(val.bstrVal);

			val = rs->GetValue("FormulaTemplate");
			val = MTMiscUtil::GetString(val);
			CounterTypePtr->PutFormulaTemplate(val.bstrVal);

			val = rs->GetValue("b_valid_for_dist");
			val = MTMiscUtil::GetString(val);
			CounterTypePtr->PutValidForDistribution(MTTypeConvert::StringToBool(val.bstrVal));

			rs->MoveNext();
		}
		(*apType) = (IMTCounterType*) CounterTypePtr.Detach();
	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}
	context.Complete();
	return hr;
}

STDMETHODIMP CMTCounterTypeReader::FindByName(IMTSessionContext* apCtxt, BSTR aName, IMTCounterType **apType)
{
	HRESULT hr(S_OK);
	ROWSETLib::IMTSQLRowsetPtr rs;
	MTCOUNTERLib::IMTCounterTypePtr CounterTypePtr;
	int NumRecords;
	
	hr = rs.CreateInstance(MTPROGID_SQLROWSET) ;
	_ASSERTE(SUCCEEDED(hr));

	hr = CounterTypePtr.CreateInstance(MTPROGID_MTCOUNTERTYPE) ;
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
		rs->SetQueryTag(GET_TYPE_BY_NAME);
		rs->AddParam(MTPARAM_NM_NAME, aName);
		rs->AddParam(L"%%ID_LANG%%", languageID);
		rs->Execute();
		NumRecords = rs->GetRecordCount();
		
		if(!NumRecords)
		{	// in case name is not found, return NULL
			// do not create an error
			*apType = NULL;
		}
		else
		{
			if(rs->GetRecordCount() > 1)
			{
				//Error condition,
				//however it's not enforced on DB level
				MT_THROW_COM_ERROR( MTPC_MULTIPLE_ITEMS_WITH_SAME_NAME );
			}

			//transform rowset row into object
			while(rs->GetRowsetEOF().boolVal == VARIANT_FALSE)
			{
				_variant_t val;
				
				//ct.id_prop, nm_name, nm_desc, FormulaTemplate 

				val = rs->GetValue("id_prop");
				CounterTypePtr->PutID(val.lVal);

				val = rs->GetValue("nm_name");
				val = MTMiscUtil::GetString(val);
				CounterTypePtr->PutName(val.bstrVal);

				val = rs->GetValue("nm_desc");
				val = MTMiscUtil::GetString(val);
				CounterTypePtr->PutDescription(val.bstrVal);

				val = rs->GetValue("FormulaTemplate");
				val = MTMiscUtil::GetString(val);
				CounterTypePtr->PutFormulaTemplate(val.bstrVal);
				
				val = rs->GetValue("b_valid_for_dist");
				val = MTMiscUtil::GetString(val);
				CounterTypePtr->PutValidForDistribution(MTTypeConvert::StringToBool(val.bstrVal));
			
				rs->MoveNext();
			}
			
			(*apType) = (IMTCounterType*) CounterTypePtr.Detach();
		}
	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}
	context.Complete();
	return hr;
}
