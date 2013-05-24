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

// MTProductViewWriter.cpp : Implementation of CMTProductViewWriter
#include "StdAfx.h"
#include "MTProductCatalogExec.h"
#include "MTProductViewWriter.h"

/////////////////////////////////////////////////////////////////////////////
// CMTProductViewWriter

/******************************************* error interface ***/
STDMETHODIMP CMTProductViewWriter::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTProductViewWriter
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTProductViewWriter::Activate()
{
	HRESULT hr = GetObjectContext(&mpObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTProductViewWriter::CanBePooled()
{
	return FALSE;
} 

void CMTProductViewWriter::Deactivate()
{
	mpObjectContext.Release();
} 

STDMETHODIMP CMTProductViewWriter::RemoveProductViewRecords(/*[in]*/ IMTSessionContext* apCtxt,
																														/*[in]*/ BSTR aPVTable,
																														/*[in]*/ long aPITemplateID,
																														/*[in]*/ long aIntervalID,
																														/*[in]*/ long aViewID)
{
	HRESULT hr(S_OK);
	ROWSETLib::IMTSQLRowsetPtr rs;
	MTAutoContext context(mpObjectContext);
	_variant_t val;
	_bstr_t bstrPVTable = aPVTable;

	hr = rs.CreateInstance(MTPROGID_SQLROWSET) ;
	_ASSERTE(SUCCEEDED(hr));
	/*
										@nm_productview varchar(255),
										@id_pi_template int,
										@id_interval int
	*/

	try
	{
		rs->Init(CONFIG_DIR) ;

		rs->InitializeForStoredProc("DeleteProductViewRecords");

		val = bstrPVTable; 

		rs->AddInputParameterToStoredProc (	"nm_productview", MTTYPE_VARCHAR, 
																				INPUT_PARAM, val);
		val =  (long)aPITemplateID;
		rs->AddInputParameterToStoredProc (	"id_pi_template", MTTYPE_INTEGER, 
																				INPUT_PARAM, val);
		val =  (long)aIntervalID;
		rs->AddInputParameterToStoredProc (	"id_interval", MTTYPE_INTEGER, 
																				INPUT_PARAM, val);
		val =  (long)aViewID;
		rs->AddInputParameterToStoredProc (	"id_view", MTTYPE_INTEGER, 
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

STDMETHODIMP CMTProductViewWriter::RemoveProductViewRecordsForAccount(/*[in]*/ IMTSessionContext* apCtxt,
																																			/*[in]*/ BSTR aPVTable,
																																			/*[in]*/ long aPITemplateID,
																																			/*[in]*/ long aIntervalID,
																																			/*[in]*/ long aViewID,
																																			/*[in]*/ long aAccountID)
{
	HRESULT hr(S_OK);
	ROWSETLib::IMTSQLRowsetPtr rs;
	MTAutoContext context(mpObjectContext);
	_variant_t val;
	_bstr_t bstrPVTable = aPVTable;

	hr = rs.CreateInstance(MTPROGID_SQLROWSET) ;
	_ASSERTE(SUCCEEDED(hr));


	try
	{
		rs->Init(CONFIG_DIR) ;

		rs->InitializeForStoredProc("DelPVRecordsForAcct");

		val = bstrPVTable; 

		rs->AddInputParameterToStoredProc (	"nm_productview", MTTYPE_VARCHAR, 
																				INPUT_PARAM, val);
		val =  (long)aPITemplateID;
		rs->AddInputParameterToStoredProc (	"id_pi_template", MTTYPE_INTEGER, 
																				INPUT_PARAM, val);
		val =  (long)aIntervalID;
		rs->AddInputParameterToStoredProc (	"id_interval", MTTYPE_INTEGER, 
																				INPUT_PARAM, val);
		val =  (long)aViewID;
		rs->AddInputParameterToStoredProc (	"id_view", MTTYPE_INTEGER, 
																				INPUT_PARAM, val);
		val =  (long)aAccountID;
		rs->AddInputParameterToStoredProc (	"id_acc", MTTYPE_INTEGER, 
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

STDMETHODIMP CMTProductViewWriter::RemoveProductViewRecordsForService(/*[in]*/ IMTSessionContext* apCtxt,
                                                                      /*[in]*/ BSTR aPVTable,
                                                                      /*[in]*/ long aPITemplateID,
                                                                      /*[in]*/ long aIntervalID,
                                                                      /*[in]*/ long aViewID,
																																			/*[in]*/ long aSvcID)
{
	HRESULT hr(S_OK);
	ROWSETLib::IMTSQLRowsetPtr rs;
	MTAutoContext context(mpObjectContext);
	_variant_t val;
	_bstr_t bstrPVTable = aPVTable;

	hr = rs.CreateInstance(MTPROGID_SQLROWSET) ;
	_ASSERTE(SUCCEEDED(hr));
	try
	{
    rs->Init(CONFIG_DIR) ;
    wchar_t buf[512];
    swprintf(buf, L"t_acc_usage.id_pi_template=%d AND t_acc_usage.id_usage_interval=%d AND t_acc_usage.id_view=%d AND t_acc_usage.id_svc=%d",
             aPITemplateID, aIntervalID, aViewID, aSvcID);
    rs->SetQueryTag(L"__DELETE_FROM_PRODUCT_VIEW__");
    rs->AddParam(L"%%PV_TABLE%%", aPVTable);
    rs->AddParam(L"%%WHERE_CLAUSE%%", buf);
    rs->Execute();
    rs->SetQueryTag(L"__DELETE_FROM_ACC_USAGE__");
    rs->AddParam(L"%%WHERE_CLAUSE%%", buf);
    rs->Execute();
	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}

	context.Complete();
	return hr;
}

STDMETHODIMP CMTProductViewWriter::RemoveProductViewRecordsForServiceForAccount(/*[in]*/ IMTSessionContext* apCtxt,
																																			/*[in]*/ BSTR aPVTable,
																																			/*[in]*/ long aPITemplateID,
																																			/*[in]*/ long aIntervalID,
																																			/*[in]*/ long aViewID,
																																			/*[in]*/ long aSvcID,
																																			/*[in]*/ long aAccountID)
{
	HRESULT hr(S_OK);
	ROWSETLib::IMTSQLRowsetPtr rs;
	MTAutoContext context(mpObjectContext);
	_variant_t val;
	_bstr_t bstrPVTable = aPVTable;

	hr = rs.CreateInstance(MTPROGID_SQLROWSET) ;
	_ASSERTE(SUCCEEDED(hr));


	try
	{
		rs->Init(CONFIG_DIR) ;
    wchar_t buf[512];
    swprintf(buf, L"t_acc_usage.id_pi_template=%d AND t_acc_usage.id_usage_interval=%d AND t_acc_usage.id_view=%d AND t_acc_usage.id_svc=%d AND t_acc_usage.id_acc=%d",
             aPITemplateID, aIntervalID, aViewID, aSvcID, aAccountID);
    rs->SetQueryTag(L"__DELETE_FROM_PRODUCT_VIEW__");
    rs->AddParam(L"%%PV_TABLE%%", aPVTable);
    rs->AddParam(L"%%WHERE_CLAUSE%%", buf);
    rs->Execute();
    rs->SetQueryTag(L"__DELETE_FROM_ACC_USAGE__");
    rs->AddParam(L"%%WHERE_CLAUSE%%", buf);
    rs->Execute();
	}
	catch(_com_error& e)
	{
		return ReturnComError(e);
	}

	context.Complete();
	return hr;
}
