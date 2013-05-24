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
* $Header: 
* 
***************************************************************************/

#include "StdAfx.h"
#include "MTProductCatalogExec.h"
#include "MTCounterPropertyDefinitionReader.h"


/////////////////////////////////////////////////////////////////////////////
// CMTCounterPropertyDefinitionReader

/******************************************* error interface ***/
STDMETHODIMP CMTCounterPropertyDefinitionReader::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTCounterPropertyDefinitionReader
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTCounterPropertyDefinitionReader::Activate()
{
	HRESULT hr = GetObjectContext(&mpObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTCounterPropertyDefinitionReader::CanBePooled()
{
	return FALSE;
} 

void CMTCounterPropertyDefinitionReader::Deactivate()
{
	mpObjectContext.Release();
} 

HRESULT CMTCounterPropertyDefinitionReader::FindAsRowset(IMTSessionContext* apCtxt, VARIANT aFilter, IMTSQLRowset** apRowset)
{
	HRESULT hr(S_OK);
	ROWSETLib::IMTSQLRowsetPtr rs;

	_bstr_t filter;
	
	hr = rs.CreateInstance(MTPROGID_SQLROWSET) ;
	_variant_t vLanguageCode = (long)840; // LANGID TODO: get from Prod Cat
	_ASSERTE(SUCCEEDED(hr));

	MTAutoContext context(mpObjectContext);
	
	MTPRODUCTCATALOGLib::IMTProductCatalogPtr pc(__uuidof(MTProductCatalog));
	MTPRODUCTCATALOGLib::IMTDataFilterPtr aDataFilter = 
		pc->GetMetaData(MTPRODUCTCATALOGLib::PCENTITY_TYPE_COUNTER_META_DATA)->TranslateFilter(aFilter);

	try
	{
		rs->Init(CONFIG_DIR);
		rs->SetQueryTag(GET_FILTERED_COUNTERPROPDEFS); 

		rs->AddParam("%%ID_LANG%%", vLanguageCode);
		rs->AddParam("%%FILTERS%%", filter);

		// apply filter... XXX replace ADO filter with customized SQL
		// for better performance
		rs->Execute();
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

HRESULT CMTCounterPropertyDefinitionReader::Find(IMTSessionContext* apCtxt, long aDBID, IMTCounterPropertyDefinition** apDef)
{
	HRESULT hr(S_OK);
	ROWSETLib::IMTSQLRowsetPtr rs;
	MTObjectCollection<IMTCounterPropertyDefinition> coll;
	MTPRODUCTCATALOGLib::IMTCounterPropertyDefinitionPtr CPDPtr;
	int NumRecords;
	_variant_t vLanguageCode = (long)840; // LANGID TODO: get from Prod Cat
	
	hr = rs.CreateInstance(MTPROGID_SQLROWSET) ;
	_ASSERTE(SUCCEEDED(hr));

	MTAutoContext context(mpObjectContext);
	
	try
	{
		rs->Init(CONFIG_DIR);
		rs->SetQueryTag(GET_COUNTERPROPDEF);
		rs->AddParam(MTPARAM_ID_PROP, aDBID);
		rs->AddParam("%%ID_LANG%%", vLanguageCode);
		
		rs->Execute();
		NumRecords = rs->GetRecordCount();

		if(!NumRecords)
		{	MT_THROW_COM_ERROR( MTPC_ITEM_NOT_FOUND_BY_ID, PCENTITY_TYPE_COUNTER_PROPERTY_DEF, aDBID);
		}

		if(NumRecords > 1)
		{
			//should never get here with 
			//current DB schema
			//TODO: return custom error
		}
		/*
		cpd.id_prop, cpd.id_pi, bp.nm_name, td.tx_desc as 'nm_display_name',
						cpd.nm_servicedefprop, cpd.nm_preferredcountertype, cpd.n_order
					FROM t_counterpropdef cpd, t_description td, t_base_props bp

		*/

		//transform rowset into collection
		while(rs->GetRowsetEOF().boolVal == VARIANT_FALSE)
		{
			_variant_t val;
			hr = CPDPtr.CreateInstance(MTPROGID_MTCOUNTERPROPDEF) ;
			_ASSERTE(SUCCEEDED(hr));
			CPDPtr->SetSessionContext(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(apCtxt));
			
			val = rs->GetValue("id_prop");
			CPDPtr->PutID(val.lVal);

			val = rs->GetValue("id_pi");
			CPDPtr->PutPITypeID(val.lVal);

			val = rs->GetValue("nm_name");
			val = MTMiscUtil::GetString(val);
			CPDPtr->PutName(val.bstrVal);

			val = rs->GetValue("nm_display_name");
			val = MTMiscUtil::GetString(val);
			CPDPtr->PutDisplayName(val.bstrVal);

			val = rs->GetValue("nm_servicedefprop");
			val = MTMiscUtil::GetString(val);
			CPDPtr->PutServiceDefProperty(val.bstrVal);

			val = rs->GetValue("nm_preferredcountertype");
			val = MTMiscUtil::GetString(val);
			CPDPtr->PutPreferredCounterTypeName(val.bstrVal);

			val = rs->GetValue("n_order");
			CPDPtr->PutOrder(val.lVal);

			rs->MoveNext();
		}
		
		(*apDef) = (IMTCounterPropertyDefinition*) CPDPtr.Detach();
	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}
	context.Complete();
	return hr;

} 

HRESULT CMTCounterPropertyDefinitionReader::FindByPIType(IMTSessionContext* apCtxt, long aPITypeDBID, IMTCollection** apColl)
{
	HRESULT hr(S_OK);
	ROWSETLib::IMTSQLRowsetPtr rs;
	MTObjectCollection<IMTCounterPropertyDefinition> coll;
	MTPRODUCTCATALOGLib::IMTCounterPropertyDefinitionPtr CPDPtr;
	_variant_t vLanguageCode = (long)840; // LANGID TODO: get from Prod Cat
	
	hr = rs.CreateInstance(MTPROGID_SQLROWSET) ;
	_ASSERTE(SUCCEEDED(hr));

	MTAutoContext context(mpObjectContext);
	
	try
	{
		rs->Init(CONFIG_DIR);
		rs->SetQueryTag(GET_COUNTERPROPDEFS_BY_PIID);
		rs->AddParam("%%ID_PI%%", aPITypeDBID);
		rs->AddParam("%%ID_LANG%%", vLanguageCode);
		rs->Execute();

  	/*
		cpd.id_prop, cpd.id_pi, bp.nm_name, td.tx_desc as 'nm_display_name',
						cpd.nm_servicedefprop, cpd.nm_preferredcountertype, cpd.n_order
					FROM t_counterpropdef cpd, t_description td, t_base_props bp

		*/

		//transform rowset into collection
		while(rs->GetRowsetEOF().boolVal == VARIANT_FALSE)
		{
			_variant_t val;
			hr = CPDPtr.CreateInstance(MTPROGID_MTCOUNTERPROPDEF) ;
			_ASSERTE(SUCCEEDED(hr));
			CPDPtr->SetSessionContext(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(apCtxt));
			
			val = rs->GetValue("id_prop");
			CPDPtr->PutID(val.lVal);

			val = rs->GetValue("id_pi");
			CPDPtr->PutPITypeID(val.lVal);

			val = rs->GetValue("nm_name");
			val = MTMiscUtil::GetString(val);
			CPDPtr->PutName(val.bstrVal);

			val = rs->GetValue("nm_display_name");
			val = MTMiscUtil::GetString(val);
			CPDPtr->PutDisplayName(val.bstrVal);

			val = rs->GetValue("nm_servicedefprop");
			val = MTMiscUtil::GetString(val);
			CPDPtr->PutServiceDefProperty(val.bstrVal);

			val = rs->GetValue("nm_preferredcountertype");
			val = MTMiscUtil::GetString(val);
			CPDPtr->PutPreferredCounterTypeName(val.bstrVal);

			val = rs->GetValue("n_order");
			CPDPtr->PutOrder(val.lVal);

			coll.Add( (IMTCounterPropertyDefinition*) CPDPtr.GetInterfacePtr());
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


