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

// MTCounterTypeWriter.cpp : Implementation of CMTCounterTypeWriter
#include "StdAfx.h"
#include "MTProductCatalogExec.h"
#include "MTCounterTypeWriter.h"


/////////////////////////////////////////////////////////////////////////////
// CMTCounterTypeWriter

/******************************************* error interface ***/
STDMETHODIMP CMTCounterTypeWriter::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTCounterTypeWriter
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTCounterTypeWriter::Activate()
{
	HRESULT hr = GetObjectContext(&mpObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTCounterTypeWriter::CanBePooled()
{
	return FALSE;
} 

void CMTCounterTypeWriter::Deactivate()
{
	mpObjectContext.Release();
} 

STDMETHODIMP CMTCounterTypeWriter::Create(IMTSessionContext* apCtxt, IMTCounterType *apCounterType, long* apDBID)
{
	HRESULT hr(S_OK);
	ROWSETLib::IMTSQLRowsetPtr rs;
	MTCOUNTERLib::IMTCounterTypePtr CounterTypePtr = apCounterType;
	MTCOUNTERLib::IMTCounterParameterPtr CounterParamPtr;
	GENERICCOLLECTIONLib::IMTCollectionPtr CollPtr;

	MTAutoContext context(mpObjectContext);

	long lNewCounterTypeID;
	
	hr = rs.CreateInstance(MTPROGID_SQLROWSET) ;
	_ASSERTE(SUCCEEDED(hr));

	hr = CollPtr.CreateInstance(MTPROGID_MTCOLLECTION) ;
	_ASSERTE(SUCCEEDED(hr));
	
	try
	{
		if (!apCtxt)
			return E_POINTER;

		long languageID;
		HRESULT hr = apCtxt->get_LanguageID(&languageID);
		if (FAILED(hr))
			return hr;

		rs->Init(CONFIG_DIR) ;
		/*
	   create proc AddCounterType
		 @id_lang id_lang_code,
		 @kind int,
		 @nm_name varchar(255),
		 @nm_desc varchar(255),
		 @nm_formula_template varchar(1000),
		 @id_prop int OUTPUT


		*/

		rs->InitializeForStoredProc("AddCounterType");
		_variant_t val;
		
		val = languageID;
		rs->AddInputParameterToStoredProc (	"id_lang_code", MTTYPE_INTEGER, 
																				INPUT_PARAM, val);

		val = (long)180;
		rs->AddInputParameterToStoredProc (	"n_kind", MTTYPE_INTEGER, 
																				INPUT_PARAM, val);
		val =  CounterTypePtr->GetName();	
		rs->AddInputParameterToStoredProc (	"nm_name", MTTYPE_VARCHAR, 
																				INPUT_PARAM, val);
		val = CounterTypePtr->GetDescription();
		rs->AddInputParameterToStoredProc (	"nm_desc", MTTYPE_VARCHAR, 
																				INPUT_PARAM, val);
		val = CounterTypePtr->GetFormulaTemplate();
		rs->AddInputParameterToStoredProc (	"nm_formula_template", MTTYPE_VARCHAR, 
																				INPUT_PARAM, val);

 		val = MTTypeConvert::BoolToString(CounterTypePtr->GetValidForDistribution());
		rs->AddInputParameterToStoredProc (	"valid_for_dist", MTTYPE_VARCHAR, 
																				INPUT_PARAM, val);

		//init output
		rs->AddOutputParameterToStoredProc ("id_prop", MTTYPE_INTEGER, 
																				OUTPUT_PARAM);

		rs->ExecuteStoredProc();

		//Get PK from newly created entry
		val = rs->GetParameterFromStoredProc("id_prop");

		lNewCounterTypeID = (long)val;
		
		//init return value
		*apDBID = lNewCounterTypeID;

		//entry was already there
		if(lNewCounterTypeID < 0)
			return S_OK;
		
    //Now for every parameter in this counter type create an entry in DB
		CounterTypePtr->PutID(lNewCounterTypeID);
		CollPtr = CounterTypePtr->GetParameters();
		long numParams = CollPtr->GetCount();

		if(!numParams)
		{
			context.Complete();
			return hr;
		}
		//TODO: Below statement will never be executed. (because lNewCounterTypeID will be -1)
    //Basically we don't support update case for counter
    //types. IN the future we should proabably check for existing instances and not allow update
    //otherwise update.
    //First delete all the parameters for this type (Support for Update Case)
		rs->Clear();
		rs->InitializeForStoredProc("DeleteCounterParamTypes");
		rs->AddInputParameterToStoredProc (	L"id_counter_type", MTTYPE_INTEGER, INPUT_PARAM, val);
		
		rs->ExecuteStoredProc();
		
		for (int i=1; i <= numParams; ++i)
		{
			_variant_t ip = CollPtr->GetItem(i);
			hr = ip.pdispVal->QueryInterface(__uuidof(IMTCounterParameter), (void**)&CounterParamPtr);
			
			if(FAILED(hr)) return hr;

			/*
			 create proc AddCounterParamType
			 @id_lang_code int,
			 @n_kind int,
			 @nm_name varchar(255),
			@id_counter_type int,
			@nm_param_type varchar(255),
			 @nm_param_dbtype varchar(255),
			@identity int OUTPUT
			*/
			rs->Clear();
			rs->InitializeForStoredProc("AddCounterParamType");

			val = languageID;
			rs->AddInputParameterToStoredProc ("id_lang_code", MTTYPE_INTEGER, 
																				INPUT_PARAM, val);

			val = (long)190;
			rs->AddInputParameterToStoredProc (	"n_kind", MTTYPE_INTEGER, 
																				INPUT_PARAM, val);

			val =  CounterParamPtr->GetName();	
			rs->AddInputParameterToStoredProc (	"nm_name", MTTYPE_VARCHAR, 
																				INPUT_PARAM, val);
		
			val = lNewCounterTypeID;

			rs->AddInputParameterToStoredProc (L"id_counter_type", MTTYPE_INTEGER, 
																		INPUT_PARAM, val);

			MTCOUNTERLib::MTCounterParamKind kind = CounterParamPtr->GetKind();

			switch (kind)
			{
			case MTCOUNTERLib::PARAM_PRODUCT_VIEW_PROPERTY:
				val = "ProductViewProperty";
				break;
			case MTCOUNTERLib::PARAM_PRODUCT_VIEW:
				val = "ProductView";
				break;
			case MTCOUNTERLib::PARAM_CONST:
				val = "Const";
				break;
			default:
				_ASSERTE(0);
				break;
			}

			rs->AddInputParameterToStoredProc (L"nm_param_type", MTTYPE_VARCHAR, 
																		INPUT_PARAM, val);

			MTCOUNTERLib::MTCounterParamDBType dbtype = CounterParamPtr->GetDBType();

			switch (dbtype)
			{
			case MTCOUNTERLib::PARAM_NUMERIC:
				val = "Numeric";
				break;
			case MTCOUNTERLib::PARAM_STRING:
				val = "String";
				break;
			default:
				_ASSERTE(0);
				break;
			}

			rs->AddInputParameterToStoredProc (L"nm_param_dbtype", MTTYPE_VARCHAR, 
																		INPUT_PARAM, val);

			//init output
			rs->AddOutputParameterToStoredProc ("id_prop", MTTYPE_INTEGER, 
																		OUTPUT_PARAM);

			rs->ExecuteStoredProc();

			//Get PK from newly created entry
			val = rs->GetParameterFromStoredProc("id_prop");

			CounterParamPtr->PutID(val.lVal);
		}
	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}

	context.Complete();

	return hr;

}

STDMETHODIMP CMTCounterTypeWriter::Update(IMTSessionContext* apCtxt, IMTCounterType *apCounterType)
{
	// TODO: Add your implementation code here

	return S_OK;
}

STDMETHODIMP CMTCounterTypeWriter::Remove(IMTSessionContext* apCtxt, long aDBID)
{
	// TODO: Add your implementation code here

	return S_OK;
}
