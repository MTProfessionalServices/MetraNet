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
#include "MTParamTableDefinitionWriter.h"
#include "pcexecincludes.h"
#include <ParamTable.h>

/////////////////////////////////////////////////////////////////////////////
// CMTParamTableDefinitionWriter

/******************************************* error interface ***/
STDMETHODIMP CMTParamTableDefinitionWriter::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTParamTableDefinitionWriter
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

CMTParamTableDefinitionWriter::CMTParamTableDefinitionWriter()
{
	mpObjectContext = NULL;
}


/****************************************** IObjectControl ***/
HRESULT CMTParamTableDefinitionWriter::Activate()
{
	HRESULT hr = GetObjectContext(&mpObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTParamTableDefinitionWriter::CanBePooled()
{
	return TRUE;
} 

void CMTParamTableDefinitionWriter::Deactivate()
{
	mpObjectContext.Release();
} 

/****************************************** CMTParamTableDefinitionWriter ***/

STDMETHODIMP CMTParamTableDefinitionWriter::Create(IMTSessionContext* apCtxt, IMTParamTableDefinition* apParamTblDef, /*[out, retval]*/ long* apID)
{
	MTAutoContext context(mpObjectContext);

	if (!apParamTblDef || !apID)
		return E_POINTER;

	//init out var
	*apID = 0;
	
	try
	{
		_variant_t vtParam;
		MTPRODUCTCATALOGEXECLib::IMTParamTableDefinitionPtr paramTblDef = apParamTblDef;

		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		//insert into base prop
		MTPRODUCTCATALOGEXECLib::IMTBasePropsWriterPtr baseWriter(__uuidof(MTBasePropsWriter));
		long idProp = baseWriter->CreateWithDisplayName( reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), PCENTITY_TYPE_PARAM_TABLE_DEF, paramTblDef->Name, "",paramTblDef->DisplayName);

		//insert into t_rulesetdefinition
		rowset->SetQueryTag("__ADD_PARAMTABLE__");

		rowset->AddParam("%%ID_PARAM%%",idProp);
		rowset->AddParam("%%TABLENAME%%", paramTblDef->DBTableName);
		rowset->Execute();

		*apID = idProp;
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}


STDMETHODIMP CMTParamTableDefinitionWriter::Update(IMTSessionContext* apCtxt, IMTParamTableDefinition *apParamTblDef)
{
	MTAutoContext context(mpObjectContext);

	if (!apParamTblDef)
		return E_POINTER;

	try
	{
		_variant_t vtParam;
		MTPRODUCTCATALOGEXECLib::IMTParamTableDefinitionPtr paramTblDef = apParamTblDef;

		// update base props
		MTPRODUCTCATALOGEXECLib::IMTBasePropsWriterPtr baseWriter(__uuidof(MTBasePropsWriter));
		baseWriter->UpdateWithDisplayName( reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt),
																			 paramTblDef->Name, "",paramTblDef->DisplayName, paramTblDef->ID);
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}

STDMETHODIMP CMTParamTableDefinitionWriter::Remove(IMTSessionContext* apCtxt, long aParamTblDefID)
{
	MTAutoContext context(mpObjectContext);
	
	try
	{
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
	
		rowset->SetQueryTag("__DELETE_PARAM_TABLE__");
		rowset->AddParam("%%ID_PROP%%", aParamTblDefID);
		rowset->Execute();
		
		MTPRODUCTCATALOGEXECLib::IMTBasePropsWriterPtr baseWriter(__uuidof(MTBasePropsWriter));
		baseWriter->Delete(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt),
											 aParamTblDefID);
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}

