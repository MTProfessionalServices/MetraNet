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
#include "MTExtendedPropWriter.h"
#include "pcexecincludes.h"
#include <ExtendedProp.h>

/////////////////////////////////////////////////////////////////////////////
// CMTExtendedPropWriter

/******************************************* error interface ***/
STDMETHODIMP CMTExtendedPropWriter::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTExtendedPropWriter
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTExtendedPropWriter::Activate()
{
	HRESULT hr = GetObjectContext(&m_spObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTExtendedPropWriter::CanBePooled()
{
	return TRUE;
} 

void CMTExtendedPropWriter::Deactivate()
{
	m_spObjectContext.Release();
} 

STDMETHODIMP CMTExtendedPropWriter::UpsertExtendedPropertyTable(IMTSessionContext* apCtxt, BSTR tableName,BSTR aUpdateList,BSTR aInsertList,BSTR aColumnList,long aID)
{
	ASSERT(aUpdateList && tableName && aColumnList && aInsertList);
	if(!(aUpdateList && tableName && aColumnList && aInsertList)) return E_POINTER;
	MTAutoContext context(m_spObjectContext);

	try {
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
    rowset->InitializeForStoredProc("ExtendedUpsert");
		rowset->AddInputParameterToStoredProc("table_name", MTTYPE_VARCHAR, INPUT_PARAM, tableName);
		rowset->AddInputParameterToStoredProc("update_list", MTTYPE_VARCHAR, INPUT_PARAM, aUpdateList);
		rowset->AddInputParameterToStoredProc("insert_list", MTTYPE_VARCHAR, INPUT_PARAM, aInsertList);
		rowset->AddInputParameterToStoredProc("clist", MTTYPE_VARCHAR, INPUT_PARAM, aColumnList);
		rowset->AddInputParameterToStoredProc("id_prop", MTTYPE_INTEGER, INPUT_PARAM, aID);
    rowset->AddOutputParameterToStoredProc("status", MTTYPE_INTEGER, OUTPUT_PARAM);
		rowset->ExecuteStoredProc();

    // Check status
		long status = rowset->GetParameterFromStoredProc("status");
		if (status != 0)
       MT_THROW_COM_ERROR(L"Unable to update extended properties, status %d", status);
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}


STDMETHODIMP CMTExtendedPropWriter::PropagateProperties(IMTSessionContext* apCtxt, BSTR tableName,BSTR aUpdateList,BSTR aInsertList,BSTR aColumnList,long aTemplateID)
{
	ASSERT(aUpdateList && tableName && aColumnList && aInsertList);
	if(!(aUpdateList && tableName && aColumnList && aInsertList)) return E_POINTER;
	MTAutoContext context(m_spObjectContext);

	try {
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);

    rowset->InitializeForStoredProc("PropagateProperties");
		rowset->AddInputParameterToStoredProc("table_name", MTTYPE_VARCHAR, INPUT_PARAM, tableName);
		rowset->AddInputParameterToStoredProc("update_list", MTTYPE_VARCHAR, INPUT_PARAM, aUpdateList);
		rowset->AddInputParameterToStoredProc("insert_list", MTTYPE_VARCHAR, INPUT_PARAM, aInsertList);
		rowset->AddInputParameterToStoredProc("clist", MTTYPE_VARCHAR, INPUT_PARAM, aColumnList);
		rowset->AddInputParameterToStoredProc("id_pi_template", MTTYPE_INTEGER, INPUT_PARAM, aTemplateID);
		rowset->ExecuteStoredProc();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}

STDMETHODIMP CMTExtendedPropWriter::RemoveFromExtendedPropertyTable(IMTSessionContext* apCtxt, BSTR aTableName, long aID)
{
	ASSERT(aTableName && aID);
	if(!(aTableName && aID)) return E_POINTER;
	MTAutoContext context(m_spObjectContext);

	try {
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		rowset->SetQueryTag("__REMOVE_EXTENDED_PROPERTIES__");
		rowset->AddParam("%%TABLE_NAME%%",aTableName);
		rowset->AddParam("%%ID_PROP%%",aID);
		rowset->Execute();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}

