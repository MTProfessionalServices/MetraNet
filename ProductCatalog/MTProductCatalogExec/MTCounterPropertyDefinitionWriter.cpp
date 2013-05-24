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
#include "MTCounterPropertyDefinitionWriter.h"

/////////////////////////////////////////////////////////////////////////////
// CMTCounterPropertyDefinitionWriter

/******************************************* error interface ***/
STDMETHODIMP CMTCounterPropertyDefinitionWriter::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTCounterPropertyDefinitionWriter
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTCounterPropertyDefinitionWriter::Activate()
{
	HRESULT hr = GetObjectContext(&mpObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTCounterPropertyDefinitionWriter::CanBePooled()
{
	return FALSE;
} 

void CMTCounterPropertyDefinitionWriter::Deactivate()
{
	mpObjectContext.Release();
} 

STDMETHODIMP CMTCounterPropertyDefinitionWriter::Create(IMTSessionContext* apCtxt, IMTCounterPropertyDefinition* apCPD, long* apDBID)
{
	HRESULT hr(S_OK);
	ROWSETLib::IMTSQLRowsetPtr rs;
	MTPRODUCTCATALOGLib::IMTCounterPropertyDefinitionPtr CPDPtr = apCPD;
	MTAutoContext context(mpObjectContext);

	_variant_t vPrincipal = (long)230;
	_variant_t vLanguageCode = (long)840; // LANGID TODO: get from Prod Cat
	_variant_t val;

	long lNewPropID;
	
	hr = rs.CreateInstance(MTPROGID_SQLROWSET) ;
	_ASSERTE(SUCCEEDED(hr));
	/*
	@id_lang_code int,
											@n_kind int,
											@nm_name nvarchar(255),
											@nm_display_name int,
											@id_pi int,
											@nm_servicedefprop nvarchar(255),
											@nm_preferredcountertype nvarchar(255),
											@n_order int, 
											@id_prop int OUTPUT 

	*/

	try
	{
		rs->Init(CONFIG_DIR) ;

		rs->InitializeForStoredProc("CreateCounterPropDef");

		rs->AddInputParameterToStoredProc (	"id_lang_code", MTTYPE_INTEGER, 
																				INPUT_PARAM, vLanguageCode);
				
		rs->AddInputParameterToStoredProc (	"n_kind", MTTYPE_INTEGER, 
																				INPUT_PARAM, vPrincipal);
		val =  CPDPtr->GetName();	
		rs->AddInputParameterToStoredProc (	"nm_name", MTTYPE_VARCHAR, 
																				INPUT_PARAM, val);
		val =  CPDPtr->GetDisplayName();	
		rs->AddInputParameterToStoredProc (	"nm_display_name", MTTYPE_VARCHAR, 
																				INPUT_PARAM, val);

		val = CPDPtr->PITypeID;
		rs->AddInputParameterToStoredProc (	"id_pi", MTTYPE_INTEGER, 
																				INPUT_PARAM, val);

		val =  CPDPtr->GetServiceDefProperty();	
		rs->AddInputParameterToStoredProc (	"nm_servicedefprop", MTTYPE_VARCHAR, 
																				INPUT_PARAM, val);
		val =  CPDPtr->GetPreferredCounterTypeName();	
		rs->AddInputParameterToStoredProc (	"nm_preferredcountertype", MTTYPE_VARCHAR, 
																				INPUT_PARAM, val);
		val =  CPDPtr->GetOrder();	
		rs->AddInputParameterToStoredProc ("n_order", MTTYPE_INTEGER, 
																				INPUT_PARAM, val);
		
		//init output
		rs->AddOutputParameterToStoredProc ("id_prop", MTTYPE_INTEGER, 
																				OUTPUT_PARAM);

		rs->ExecuteStoredProc();

		//Get PK from newly created entry
		val = rs->GetParameterFromStoredProc("id_prop");

		lNewPropID = val.lVal;
		
		//init return value
		*apDBID = lNewPropID;
	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}

	context.Complete();
	return hr;
}



STDMETHODIMP CMTCounterPropertyDefinitionWriter::Update(IMTSessionContext* apCtxt, IMTCounterPropertyDefinition* apCPD)
{
	HRESULT hr(S_OK);
	ROWSETLib::IMTSQLRowsetPtr rs;
	MTPRODUCTCATALOGLib::IMTCounterPropertyDefinitionPtr CPDPtr = apCPD;
	MTAutoContext context(mpObjectContext);

	_variant_t vLanguageCode = (long)840; // LANGID TODO: get from Prod Cat
	_variant_t val;

	hr = rs.CreateInstance(MTPROGID_SQLROWSET) ;
	_ASSERTE(SUCCEEDED(hr));
	/*
											@id_lang_code int,
											@id_prop int,
											@nm_name nvarchar(255),
											@nm_display_name int,
											@id_pi int,
											@nm_servicedefprop nvarchar(255),
											@nm_preferredcountertype nvarchar(255),
											@n_order int

	*/

	try
	{
		rs->Init(CONFIG_DIR) ;

		rs->InitializeForStoredProc("UpdateCounterPropDef");

		rs->AddInputParameterToStoredProc (	"id_lang_code", MTTYPE_INTEGER, 
																				INPUT_PARAM, vLanguageCode);
		val =  CPDPtr->GetID();	
    rs->AddInputParameterToStoredProc (	"id_prop", MTTYPE_INTEGER, 
																				INPUT_PARAM, val);
		val =  CPDPtr->GetName();	
		rs->AddInputParameterToStoredProc (	"nm_name", MTTYPE_VARCHAR, 
																				INPUT_PARAM, val);
		val =  CPDPtr->GetDisplayName();	
		rs->AddInputParameterToStoredProc (	"nm_display_name", MTTYPE_VARCHAR, 
																				INPUT_PARAM, val);
		val = CPDPtr->PITypeID;
		rs->AddInputParameterToStoredProc (	"id_pi", MTTYPE_INTEGER, 
																				INPUT_PARAM, val);
		val =  CPDPtr->GetServiceDefProperty();	
		rs->AddInputParameterToStoredProc (	"nm_servicedefprop", MTTYPE_VARCHAR, 
																				INPUT_PARAM, val);
		val =  CPDPtr->GetPreferredCounterTypeName();	
		rs->AddInputParameterToStoredProc (	"nm_preferredcountertype", MTTYPE_VARCHAR, 
																				INPUT_PARAM, val);
		val =  CPDPtr->GetOrder();	
		rs->AddInputParameterToStoredProc ("n_order", MTTYPE_INTEGER, 
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

STDMETHODIMP CMTCounterPropertyDefinitionWriter::Remove(IMTSessionContext* apCtxt, long aDBID)
{
	HRESULT hr(S_OK);
	ROWSETLib::IMTSQLRowsetPtr rs;
	MTAutoContext context(mpObjectContext);
	_variant_t val;
	hr = rs.CreateInstance(MTPROGID_SQLROWSET) ;
	_ASSERTE(SUCCEEDED(hr));
	/*
	@id_prop int

	*/

	try
	{
		rs->Init(CONFIG_DIR) ;

		rs->InitializeForStoredProc("RemoveCounterPropDef");

		val = (long)aDBID;	
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
