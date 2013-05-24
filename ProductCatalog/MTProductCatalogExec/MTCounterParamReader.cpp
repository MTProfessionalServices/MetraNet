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
#include "MTCounterParamReader.h"

/////////////////////////////////////////////////////////////////////////////
// CMTCounterParamReader

/******************************************* error interface ***/
STDMETHODIMP CMTCounterParamReader::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTCounterParamReader
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTCounterParamReader::Activate()
{
	HRESULT hr = GetObjectContext(&mpObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTCounterParamReader::CanBePooled()
{
	return FALSE;
} 

void CMTCounterParamReader::Deactivate()
{
	mpObjectContext.Release();
} 


STDMETHODIMP CMTCounterParamReader::FindParameterTypes(IMTSessionContext* apCtxt, IMTCounter* aCounter, IMTCollection **apParamTypes)
{
	HRESULT hr(S_OK);
	ROWSETLib::IMTSQLRowsetPtr rs;
	MTObjectCollection<IMTCounterParameter> coll;
	MTCOUNTERLib::IMTCounterParameterPtr CounterParameterPtr;
	
	hr = rs.CreateInstance(MTPROGID_SQLROWSET) ;
	_ASSERTE(SUCCEEDED(hr));
	
	try
	{
		if (!apCtxt)
			return E_POINTER;

    MTCOUNTERLib::IMTCounterPtr counterPtr = aCounter;

		long languageID;
		HRESULT hr = apCtxt->get_LanguageID(&languageID);
		if (FAILED(hr))
			return hr;

		rs->Init(CONFIG_DIR);
		rs->SetQueryTag(GET_PARAM_TYPES);
		rs->AddParam(MTPARAM_ID_PROP, counterPtr->TypeID);
		rs->AddParam(L"%%ID_LANG%%", languageID);
		rs->Execute();
		
		//transform rowset into collection
		while(rs->GetRowsetEOF().boolVal == VARIANT_FALSE)
		{
			_variant_t val;
			hr = CounterParameterPtr.CreateInstance(MTPROGID_MTCOUNTERPARAMETER) ;
			_ASSERTE(SUCCEEDED(hr));
			//TODO: SetContext!!
			
			//cpm.id_prop, nm_name, ParamType, DBType 

			val = rs->GetValue("id_prop");
			
			CounterParameterPtr->TypeID = val.lVal;	

			val = rs->GetValue("nm_name");
			
			
      CounterParameterPtr->Name = (_bstr_t)val;
      //Hack: put display name and description same as Name for now
      CounterParameterPtr->DisplayName = (_bstr_t)val;
      CounterParameterPtr->Description = (_bstr_t)val;

			val = rs->GetValue("ParamType");
			CounterParameterPtr->PutKind(val.bstrVal);

			val = rs->GetValue("DBType");
			val = MTMiscUtil::GetString(val);
			CounterParameterPtr->PutDBType(val.bstrVal);
      
      CounterParameterPtr->Counter = counterPtr;

			coll.Add( (IMTCounterParameter *) CounterParameterPtr.GetInterfacePtr());
			rs->MoveNext();
		}
		
		coll.CopyTo(apParamTypes);

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

STDMETHODIMP CMTCounterParamReader::FindParameters(IMTSessionContext* apCtxt, IMTCounter* aCounter, IMTCollection **apParameters)
{
	HRESULT hr(S_OK);
	
	MTObjectCollection<IMTCounterParameter> coll;
	MTCOUNTERLib::IMTCounterParameterPtr CounterParameterPtr;
  
	MTAutoContext context(mpObjectContext);

	try
	{
		
    if (!apCtxt || !aCounter)
			return E_POINTER;

    MTCOUNTERLib::IMTCounterPtr counterPtr = aCounter;

    //TODO: Boris! Fix me later, don't create 2 rowset objects, get all params and predicates
    // in one query

    ROWSETLib::IMTSQLRowsetPtr rs(MTPROGID_SQLROWSET);
    MTPRODUCTVIEWEXECLib::IMTProductViewPropertyReaderPtr pvreader("Metratech.MTProductViewPropertyReader");
    

		long languageID;
		hr = apCtxt->get_LanguageID(&languageID);
		if (FAILED(hr))
			return hr;

		rs->Init(CONFIG_DIR);
    
		rs->SetQueryTag("__GET_COUNTER_PARAMS__");
   

		rs->AddParam(L"%%ID_PROP%%", counterPtr->ID);
		rs->AddParam(L"%%ID_LANG%%", languageID);
		rs->Execute();
		
		//transform rowset into collection
		while(rs->GetRowsetEOF().boolVal == VARIANT_FALSE)
		{
			_variant_t val;
			hr = CounterParameterPtr.CreateInstance(MTPROGID_MTCOUNTERPARAMETER) ;
			_ASSERTE(SUCCEEDED(hr));
			//TODO:SetContext!!
			
			// id_counter_param, Value, id_counter_param_meta, nm_name, ParamType, DBType

			val = rs->GetValue("id_counter_param");
			CounterParameterPtr->ID = (long)val;	
			
      val = rs->GetValue("id_counter_param_meta");
			CounterParameterPtr->TypeID = (long)val;	

			val = rs->GetValue("ParamName");
  		CounterParameterPtr->Name =  (_bstr_t)val;

      val = rs->GetValue("ParamDescription");
      CounterParameterPtr->Description = MTMiscUtil::GetString(val);

      val = rs->GetValue("ParamDisplayName");
      CounterParameterPtr->DisplayName = MTMiscUtil::GetString(val);


			val = rs->GetValue("ParamType");
			CounterParameterPtr->PutKind((_bstr_t)val);

			val = rs->GetValue("DBType");
			val = MTMiscUtil::GetString(val);
			CounterParameterPtr->PutDBType((_bstr_t)val);

			val = rs->GetValue("Value");
			val = MTMiscUtil::GetString(val);
      
      //if parameter is owned by this counter, then set counter property
      if(stricmp((char*)(_bstr_t)rs->GetValue("IsShared"), "F") == 0)
        CounterParameterPtr->Counter = reinterpret_cast<MTCOUNTERLib::IMTCounter*>(counterPtr.GetInterfacePtr());
      
			CounterParameterPtr->Value = (_bstr_t)val;

      //Get Predicates in a separate query
      //TODO: Later Modify the above query to retrieve everything in one shot
      ROWSETLib::IMTSQLRowsetPtr predicaters(MTPROGID_SQLROWSET);
      predicaters->Init(CONFIG_DIR);
      predicaters->SetQueryTag("__GET_PARAM_PREDICATES__");
      predicaters->AddParam(L"%%ID_LANG%%", languageID);
      predicaters->AddParam(L"%%ID_PROP%%", (long)CounterParameterPtr->ID);
		  predicaters->Execute();
      while(predicaters->GetRowsetEOF().boolVal == VARIANT_FALSE)
		  {
        MTCOUNTERLib::IMTCounterParameterPredicatePtr predicatePtr =
          CounterParameterPtr->CreatePredicate();//("Metratech.MTCounterParameterPredicate");
        predicatePtr->ID = predicaters->GetValue("id_prop");
        predicatePtr->Operator = (MTCOUNTERLib::MTOperatorType)StringToOp((_bstr_t)predicaters->GetValue("nm_op"));
        //initialize ProductViewProperty object
        long pvpropID = predicaters->GetValue("id_pv_prop");
        MTPRODUCTVIEWLib::IProductViewCatalogPtr prodviewcat("Metratech.ProductViewCatalog");
        prodviewcat->SessionContext = reinterpret_cast<MTPRODUCTVIEWLib::IMTSessionContext*>(apCtxt);
        
        MTPRODUCTVIEWLib::IProductViewPropertyPtr pvprop = prodviewcat->GetProductViewProperty(pvpropID);
       
        predicatePtr->ProductViewProperty = reinterpret_cast<MTCOUNTERLib::IProductViewProperty*>(pvprop.GetInterfacePtr());
        predicatePtr->Value = predicaters->GetValue("nm_value");
        
        predicaters->MoveNext();
      }
			coll.Add( (IMTCounterParameter *) CounterParameterPtr.GetInterfacePtr());

			rs->MoveNext();
		}
		
		coll.CopyTo(apParameters);

	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}

  context.Complete();
	
	return hr;
}

STDMETHODIMP CMTCounterParamReader::FindSharedAsRowset(IMTSessionContext *aCtx, VARIANT aFilter, IMTSQLRowset **apRowset)
{
  
  HRESULT hr(S_OK);
  ROWSETLib::IMTSQLRowsetPtr rs;
  
  _bstr_t filter;
  
  hr = rs.CreateInstance(MTPROGID_SQLROWSET) ;
  _variant_t vLanguageCode = (long)840; // LANGID TODO: get from Prod Cat
  _ASSERTE(SUCCEEDED(hr));
  
  MTAutoContext context(mpObjectContext);
  
  MTPRODUCTCATALOGLib::IMTProductCatalogPtr pc(__uuidof(MTProductCatalog));
  MTPRODUCTCATALOGLib::IMTDataFilterPtr aDataFilter;
   //= 
  //  pc->GetMetaData(PCENTITY_TYPE_COUNTER_PARAM)->TranslateFilter(aFilter);
  
  try
  {
    rs->Init(CONFIG_DIR);
    rs->SetQueryTag("__GET_SHARED_COUNTER_PARAMS__"); 
    
    rs->AddParam("%%ID_LANG%%", vLanguageCode);
    //rs->AddParam("%%FILTERS%%", filter);
    
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

STDMETHODIMP CMTCounterParamReader::Find(IMTSessionContext *apCtx, long aDBID, IMTCounterParameter **apParam)
{
	HRESULT hr(S_OK);
	ROWSETLib::IMTSQLRowsetPtr rs;
	
	int NumRecords;
	
	hr = rs.CreateInstance(MTPROGID_SQLROWSET) ;
	_ASSERTE(SUCCEEDED(hr));

	MTAutoContext context(mpObjectContext);
	
	try
	{
		if (!apCtx || !apParam)
			return E_POINTER;
    (*apParam) = NULL;

    MTCOUNTERLib::IMTCounterParameterPtr paramPtr("Metratech.MTCounterParameter");
    MTPRODUCTVIEWLib::IProductViewCatalogPtr pvcat("Metratech.ProductViewCatalog");
    MTPRODUCTVIEWLib::IProductViewPropertyPtr pvprop("Metratech.ProductViewProperty");

    _variant_t val;
    _variant_t vCounterParamID;
    _variant_t vCounterParamValue;
    _variant_t vCounterParamName;
    _variant_t vCounterParamDesc;
    _variant_t vCounterParamDisplayName;
    _variant_t vCounterParamPredicatePVPropID;
    _variant_t vCounterParamPredicateOperator;
    _variant_t vCounterParamPredicateValue;
    bool bFirstRow = true;


		long languageID;
		hr = apCtx->get_LanguageID(&languageID);
		if (FAILED(hr))
			return hr;

		rs->Init(CONFIG_DIR);
		rs->SetQueryTag("__GET_COUNTER_PARAMETER__");
		rs->AddParam(L"%%ID_COUNTER_PARAM%%", aDBID);
		rs->AddParam(L"%%ID_LANG%%", languageID);
		rs->Execute();
		NumRecords = rs->GetRecordCount();
		
		if(!NumRecords)
			MT_THROW_COM_ERROR(MTPC_ITEM_NOT_FOUND_BY_ID, PCENTITY_TYPE_COUNTER_PARAM, aDBID);

		while(rs->GetRowsetEOF().boolVal == VARIANT_FALSE)
		{
      if(bFirstRow)
      {
        vCounterParamID = rs->GetValue("id_counter_param");
        paramPtr->ID = (long)vCounterParamID;
        vCounterParamValue = rs->GetValue("nm_value");
        paramPtr->Value = (_bstr_t)vCounterParamValue;
        vCounterParamName = rs->GetValue("nm_name");
        paramPtr->Name = (_bstr_t)vCounterParamName;
        vCounterParamDesc = rs->GetValue("nm_desc");
        paramPtr->Description = (_bstr_t)vCounterParamDesc;
        vCounterParamDisplayName = rs->GetValue("nm_display_name");
        paramPtr->DisplayName = (_bstr_t)vCounterParamDisplayName;
        bFirstRow = false;
      }
      //create predicates
      vCounterParamPredicatePVPropID = rs->GetValue("id_pv_prop");
      if(V_VT(&vCounterParamPredicatePVPropID) == NULL)
        continue;
      MTCOUNTERLib::IMTCounterParameterPredicatePtr predicatePtr = paramPtr->CreatePredicate();
      vCounterParamPredicateOperator = rs->GetValue("nm_op");
      vCounterParamPredicateValue = rs->GetValue("predicate_value");
      pvprop = pvcat->GetProductViewProperty((long)vCounterParamPredicatePVPropID);
      if(pvprop == NULL)
        MT_THROW_COM_ERROR("Product View Property Not found by database ID!");
      predicatePtr->ProductViewProperty = reinterpret_cast<MTCOUNTERLib::IProductViewProperty*>(pvprop.GetInterfacePtr());
      predicatePtr->Operator = (MTCOUNTERLib::MTOperatorType)StringToOp((_bstr_t)vCounterParamPredicateOperator);
      predicatePtr->Value = (_bstr_t)vCounterParamPredicateValue;

			rs->MoveNext();
		}
		(*apParam) = reinterpret_cast<IMTCounterParameter*>(paramPtr.Detach());
	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}
	context.Complete();
	return hr;
}
