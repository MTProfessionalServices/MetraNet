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

// MTBasePropsWriter.cpp : Implementation of CMTBasePropsWriter
#include "StdAfx.h"

#include <metra.h>
#include <mtprogids.h>
#include <comdef.h>
#include <mtcomerr.h>

#include "MTProductCatalogExec.h"
#include "MTBasePropsWriter.h"

#include <mtautocontext.h>
#include <RowsetDefs.h>

#import <Rowset.tlb> rename ("EOF", "RowsetEOF") 


/////////////////////////////////////////////////////////////////////////////
// CMTBasePropsWriter

/******************************************* error interface ***/
STDMETHODIMP CMTBasePropsWriter::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTBasePropsWriter
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTBasePropsWriter::Activate()
{
	HRESULT hr = GetObjectContext(&mpObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTBasePropsWriter::CanBePooled()
{
	return TRUE;
} 

void CMTBasePropsWriter::Deactivate()
{
	mpObjectContext.Release();
} 

STDMETHODIMP CMTBasePropsWriter::Create(IMTSessionContext* apCtxt, long aKind, BSTR aName, BSTR aDescription, long *apID)
{
	return CreateWithDisplayName( apCtxt, aKind, aName, aDescription, NULL, apID);
}


STDMETHODIMP CMTBasePropsWriter::CreateWithDisplayName(IMTSessionContext* apCtxt, long aKind, BSTR aName, BSTR aDescription, BSTR aDisplayName, long *apID)
{
	MTAutoContext context(mpObjectContext);

	if (!apID)
		return E_POINTER;

	//init out var
	*apID = -1;
	
	if (!apCtxt)
		return E_POINTER;

	try
	{
		long languageID;
		ASSERT(apCtxt);
		HRESULT hr = apCtxt->get_LanguageID(&languageID);
		if (FAILED(hr))
			return hr;

		_variant_t val;
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);

		rowset->InitializeForStoredProc("InsertBaseProps");

		_variant_t vtNULL;
		vtNULL.vt = VT_NULL;

		_variant_t vtLangCode = languageID;

		_variant_t vtName;
		if (aName == NULL || wcslen(aName) == 0)
			vtName = vtNULL;
		else
			vtName = aName;
			
		_variant_t vtDescription;
		if (aDescription == NULL || wcslen(aDescription) == 0)
			vtDescription = vtNULL;
		else
			vtDescription = aDescription;

		_variant_t vtDisplayName;
		if (aDisplayName == NULL || wcslen(aDisplayName) == 0)
			vtDisplayName = vtNULL;
		else
			vtDisplayName = aDisplayName;

		rowset->AddInputParameterToStoredProc (	"id_lang_code", MTTYPE_INTEGER, INPUT_PARAM, vtLangCode);
		rowset->AddInputParameterToStoredProc (	"a_kind", MTTYPE_INTEGER, INPUT_PARAM, aKind);
		rowset->AddInputParameterToStoredProc (	"a_approved", MTTYPE_VARCHAR, INPUT_PARAM, "N");
		rowset->AddInputParameterToStoredProc (	"a_archive", MTTYPE_VARCHAR, INPUT_PARAM, "N");
		rowset->AddInputParameterToStoredProc (	"a_nm_name", MTTYPE_W_VARCHAR, INPUT_PARAM, vtName);
		rowset->AddInputParameterToStoredProc (	"a_nm_desc", MTTYPE_W_VARCHAR, INPUT_PARAM, vtDescription);
  	rowset->AddInputParameterToStoredProc (	"a_nm_display_name", MTTYPE_W_VARCHAR, INPUT_PARAM, vtDisplayName);

    rowset->AddOutputParameterToStoredProc ("a_id_prop", MTTYPE_INTEGER, OUTPUT_PARAM);

		rowset->ExecuteStoredProc();

		//Get PK from newly created entry
		val = rowset->GetParameterFromStoredProc("a_id_prop");
		*apID = val.lVal;
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}


STDMETHODIMP CMTBasePropsWriter::Update(IMTSessionContext* apCtxt, BSTR aName, BSTR aDescription, long aID)
{
	return UpdateWithDisplayName(apCtxt, aName, aDescription, NULL, aID);
}


STDMETHODIMP CMTBasePropsWriter::UpdateWithDisplayName(IMTSessionContext* apCtxt, BSTR aName, BSTR aDescription, BSTR aDisplayName, long aID)
{
	MTAutoContext context(mpObjectContext);

	if (!apCtxt)
		return E_POINTER;

	try
	{
		ASSERT(apCtxt);

		long languageID;
		HRESULT hr = apCtxt->get_LanguageID(&languageID);
		if (FAILED(hr))
			return hr;

		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);

		rowset->InitializeForStoredProc("UpdateBaseProps");

		_variant_t vtNULL;
		vtNULL.vt = VT_NULL;

		_variant_t vtLangCode = languageID;

		_variant_t vtName;
		if (aName == NULL || wcslen(aName) == 0)
			vtName = vtNULL;
		else
			vtName = aName;
			
		_variant_t vtDescription;
		if (aDescription == NULL || wcslen(aDescription) == 0)
			vtDescription = vtNULL;
		else
			vtDescription = aDescription;

		_variant_t vtDisplayName;
		if (aDisplayName == NULL || wcslen(aDisplayName) == 0)
			vtDisplayName = vtNULL;
		else
			vtDisplayName = aDisplayName;

		rowset->AddInputParameterToStoredProc (	"a_id_prop", MTTYPE_INTEGER, INPUT_PARAM, aID);
		rowset->AddInputParameterToStoredProc (	"a_id_lang", MTTYPE_INTEGER, INPUT_PARAM, vtLangCode);
		rowset->AddInputParameterToStoredProc (	"a_nm_name", MTTYPE_W_VARCHAR, INPUT_PARAM, vtName);
		rowset->AddInputParameterToStoredProc (	"a_nm_desc", MTTYPE_W_VARCHAR, INPUT_PARAM, vtDescription);
		rowset->AddInputParameterToStoredProc (	"a_nm_display_name", MTTYPE_W_VARCHAR, INPUT_PARAM, vtDisplayName);
		
		rowset->ExecuteStoredProc();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}


STDMETHODIMP CMTBasePropsWriter::Delete(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aID)
{
	MTAutoContext context(mpObjectContext);

	if (!apCtxt)
		return E_POINTER;

	try
	{
		ASSERT(apCtxt);

		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);

		rowset->InitializeForStoredProc("DeleteBaseProps");

		rowset->AddInputParameterToStoredProc (	"a_id_prop", MTTYPE_INTEGER, INPUT_PARAM, aID);
		rowset->ExecuteStoredProc();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}
