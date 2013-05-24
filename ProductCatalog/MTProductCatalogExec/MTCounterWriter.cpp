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
#include "MTCounterWriter.h"


#include <pcexecincludes.h>

/////////////////////////////////////////////////////////////////////////////
// CMTCounterWriter

/******************************************* error interface ***/
STDMETHODIMP CMTCounterWriter::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTCounterWriter
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTCounterWriter::Activate()
{
	HRESULT hr = GetObjectContext(&mpObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTCounterWriter::CanBePooled()
{
	return FALSE;
} 

void CMTCounterWriter::Deactivate()
{
	mpObjectContext.Release();
} 


STDMETHODIMP CMTCounterWriter::Create(IMTSessionContext* apCtxt, IMTCounter *apCounter, long *apDBID)
{
	HRESULT hr(S_OK);

  MTAutoContext context(mpObjectContext);
	
	
  try
  {
    if (!apCtxt)
      return E_POINTER;
    
    
    ROWSETLib::IMTSQLRowsetPtr rs;
    MTPRODUCTCATALOGEXECLib::IMTCounterParamWriterPtr paramWriter
      (__uuidof(MTPRODUCTCATALOGEXECLib::MTCounterParamWriter));
    MTPRODUCTCATALOGEXECLib::IMTCounterWriterPtr thisPtr = this;
    MTCOUNTERLib::IMTCounterPtr CounterPtr = apCounter;
    MTCOUNTERLib::IMTCounterParameterPtr CounterParamPtr;
    MTCOUNTERLib::IMTCounterParameterPredicatePtr CounterParamPredicatePtr;
    GENERICCOLLECTIONLib::IMTCollectionPtr CollPtr;
    GENERICCOLLECTIONLib::IMTCollectionPtr PredicateCollPtr;
    
    long lNewCounterID;
    
    hr = rs.CreateInstance(MTPROGID_SQLROWSET) ;
    _ASSERTE(SUCCEEDED(hr));
    
    hr = CollPtr.CreateInstance(MTPROGID_MTCOLLECTION) ;
    _ASSERTE(SUCCEEDED(hr));
    
    _variant_t vtNULL;
    vtNULL.vt =  VT_NULL;
    
    long languageID;
    HRESULT hr = apCtxt->get_LanguageID(&languageID);
    if (FAILED(hr))
      return hr;
    
    
    rs->Init(CONFIG_DIR) ;
    
    rs->InitializeForStoredProc("AddCounterInstance");
    _variant_t val;
    
    val = languageID;
    rs->AddInputParameterToStoredProc (	"id_lang_code", MTTYPE_INTEGER, 
      INPUT_PARAM, val);
    
    val = (long)170;
    rs->AddInputParameterToStoredProc (	"n_kind", MTTYPE_INTEGER, 
      INPUT_PARAM, val);
    val =  CounterPtr->GetName();	
    rs->AddInputParameterToStoredProc (	"nm_name", MTTYPE_VARCHAR, 
      INPUT_PARAM, val);
    _bstr_t desc = CounterPtr->GetDescription();
    val = (desc.length() > 0) ? desc : vtNULL ;
    rs->AddInputParameterToStoredProc (	"nm_desc", MTTYPE_VARCHAR, 
      INPUT_PARAM, val);
    val = CounterPtr->TypeID;
    rs->AddInputParameterToStoredProc (	"counter_type_id", MTTYPE_INTEGER, 
      INPUT_PARAM, val);
    
    //init output
    rs->AddOutputParameterToStoredProc ("id_prop", MTTYPE_INTEGER, 
      OUTPUT_PARAM);
    
    rs->ExecuteStoredProc();
    
    //Get PK from newly created entry
    val = rs->GetParameterFromStoredProc("id_prop");
    
    lNewCounterID = val.lVal;
    
    //init return value
    *apDBID = lNewCounterID;
    CounterPtr->ID = lNewCounterID;
    
    //Now for every parameter in this counter instance create an entry in DB
    
    CollPtr = CounterPtr->GetParameters();
    long numParams = CollPtr->GetCount();
    
    if(!numParams)
    {
      context.Complete();
      return hr;
    }
    
    for (int i=1; i <= numParams; ++i)
    {
      _variant_t ip = CollPtr->GetItem(i);
      hr = ip.pdispVal->QueryInterface(__uuidof(IMTCounterParameter), (void**)&CounterParamPtr);

      //Part of CR 5954 fix:
			//Since now hardcoded parameters are also in the parameter collection
			//recoginze those by the fact that htey are read-only and NOT
			//save them into database
			VARIANT_BOOL bReadOnly = CounterParamPtr->ReadOnly;
			if(bReadOnly)
				continue;

      //if parameter is not owned by it's counter (aka Shared parameter), then we only need to create the mapping.
      //Otherwise we create a counter parameter record
      //If Counter property is set on the parameter, then it's owned by this counter
      if(CounterParamPtr->Shared == VARIANT_FALSE)
			{
				paramWriter->Create
		        (reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext *>(apCtxt), lNewCounterID, 
			      reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTCounterParameter*>(CounterParamPtr.GetInterfacePtr()));
			}
      else
        thisPtr->CreateParameterMapping(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext *>(apCtxt),
          CounterPtr->ID,
          reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTCounterParameter*>(CounterParamPtr.GetInterfacePtr()));
    }
    
  }
  catch(_com_error& e)
  {
    return ReturnComError(e);
  }

  context.Complete();

	return hr;
}

STDMETHODIMP CMTCounterWriter::Remove(IMTSessionContext* apCtxt, long aDBID)
{
	HRESULT hr(S_OK);
	ROWSETLib::IMTSQLRowsetPtr rs;
  MTAutoContext context(mpObjectContext);

	hr = rs.CreateInstance(MTPROGID_SQLROWSET) ;
	_ASSERTE(SUCCEEDED(hr));

	try
	{
		rs->Init(CONFIG_DIR);
		rs->InitializeForStoredProc("RemoveCounterInstance");
		_variant_t val;
		
		val = aDBID;

		rs->AddInputParameterToStoredProc (	"id_prop", MTTYPE_INTEGER, 
																				INPUT_PARAM, val);
		rs->ExecuteStoredProc();

	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}

  context.Complete();

	return hr;
}

STDMETHODIMP CMTCounterWriter::Update(IMTSessionContext* apCtxt, IMTCounter *apCounter)
{
	HRESULT hr(S_OK);

  MTAutoContext context(mpObjectContext);
	
	try
	{
    _variant_t vLanguageCode = (long)840; // LANGID TODO: get from Prod Cat
		_variant_t val;
    

    ROWSETLib::IMTSQLRowsetPtr rs;
    MTCOUNTERLib::IMTCounterPtr CounterPtr = apCounter;
    MTCOUNTERLib::IMTCounterParameterPtr CounterParamPtr;
    MTPRODUCTCATALOGEXECLib::IMTCounterWriterPtr thisPtr = this;
    GENERICCOLLECTIONLib::IMTCollectionPtr CollPtr;
    MTPRODUCTCATALOGEXECLib::IMTCounterParamWriterPtr paramWriter
      (__uuidof(MTPRODUCTCATALOGEXECLib::MTCounterParamWriter));
    
    long lCounterID = (long) CounterPtr->ID;
    _variant_t vCounterID = lCounterID;
    
    hr = rs.CreateInstance(MTPROGID_SQLROWSET) ;
    _ASSERTE(SUCCEEDED(hr));

  	rs->Init(CONFIG_DIR);
		rs->InitializeForStoredProc("UpdateCounterInstance");
	
    rs->AddInputParameterToStoredProc (	"id_lang_code", MTTYPE_INTEGER, 
																				INPUT_PARAM, vLanguageCode);
  	rs->AddInputParameterToStoredProc (	"id_prop", MTTYPE_INTEGER, 
																				INPUT_PARAM, vCounterID);
		val =  CounterPtr->TypeID;	
		rs->AddInputParameterToStoredProc (	L"counter_type_id", MTTYPE_INTEGER, 
																				INPUT_PARAM, val);
		val = CounterPtr->GetName();
		rs->AddInputParameterToStoredProc (	"nm_name", MTTYPE_VARCHAR, 
																				INPUT_PARAM, val);
		val = CounterPtr->GetDescription();
		rs->AddInputParameterToStoredProc (	"nm_desc", MTTYPE_VARCHAR, 
																				INPUT_PARAM, val);
		
		rs->ExecuteStoredProc();


		CollPtr = CounterPtr->GetParameters();
		long numParams = CollPtr->GetCount();

		//remove all parameters first
		rs->Clear();
		rs->InitializeForStoredProc("DeleteCounterParamInstances");
		rs->AddInputParameterToStoredProc (	L"id_counter", MTTYPE_INTEGER, INPUT_PARAM, vCounterID);
		//insert new parameters
		rs->ExecuteStoredProc();
		
		for (int i=1; i <= numParams; ++i)
		{
	  	_variant_t ip = CollPtr->GetItem(i);
			hr = ip.pdispVal->QueryInterface(__uuidof(IMTCounterParameter), (void**)&CounterParamPtr);

			if(FAILED(hr)) return hr;

			//Part of CR 5954 fix:
			//Since now hardcoded parameters are also in the parameter collection
			//recoginze those by the fact that htey are read-only and NOT
			//save them into database
			VARIANT_BOOL bReadOnly = CounterParamPtr->ReadOnly;
			if(bReadOnly)
				continue;

		  //if parameter is not owned by it's counter (aka Shared parameter), then we only need to create the mapping.
      //Otherwise we create a counter parameter record
      //If Counter property is set on the parameter, then it's owned by this counter
      if(CounterParamPtr->Shared == VARIANT_FALSE)
        paramWriter->Create
          (reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext *>(apCtxt), lCounterID, 
          reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTCounterParameter*>(CounterParamPtr.GetInterfacePtr()));
      else
        thisPtr->CreateParameterMapping(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext *>(apCtxt),
          CounterPtr->ID,
          reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTCounterParameter*>(CounterParamPtr.GetInterfacePtr()));
    }
	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}

  context.Complete();

	return hr;
}
STDMETHODIMP CMTCounterWriter::CreateParameterMapping(IMTSessionContext *apCtx, long aCounterID, IMTCounterParameter *apParam)
{
	HRESULT hr(S_OK);
	ROWSETLib::IMTSQLRowsetPtr rs;

	hr = rs.CreateInstance(MTPROGID_SQLROWSET) ;
	_ASSERTE(SUCCEEDED(hr));
  MTAutoContext context(mpObjectContext);

	try
	{
    MTCOUNTERLib::IMTCounterParameterPtr paramPtr = apParam;
    if(paramPtr->ID < 0)
      MT_THROW_COM_ERROR(MTPC_COUNTER_PARAM_NOT_SAVED);
    rs->Init(CONFIG_DIR);
		rs->SetQueryTag("__CREATE_COUNTER_PARAM_MAPPING__");

		rs->AddParam("%%ID_COUNTER%%",aCounterID);
		rs->AddParam("%%ID_PARAM%%", paramPtr->ID);
		rs->AddParam("%%ID_COUNTER_PARAM_META%%", paramPtr->TypeID);
		rs->Execute();
	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}

  context.Complete();
	return hr;
}
