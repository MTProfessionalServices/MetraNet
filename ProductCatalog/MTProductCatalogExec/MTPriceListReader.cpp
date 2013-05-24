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
#include "MTPriceListReader.h"
#include "pcexecincludes.h"
#define MTPROGID_PRICE_LIST L"MetraTech.MTPriceList.1"

#define FIND_PRICE_LIST_BY_ID L"__FIND_PRICELIST_BY_ID__"
#define FIND_PRICE_LIST_BY_NAME L"__FIND_PRICELIST_BY_NAME__"

using MTPRODUCTCATALOGLib::IMTPriceListPtr;

/////////////////////////////////////////////////////////////////////////////
// CMTPriceListReader

/******************************************* error interface ***/
STDMETHODIMP CMTPriceListReader::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTPriceListReader
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTPriceListReader::Activate()
{
	HRESULT hr = GetObjectContext(&mpObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTPriceListReader::CanBePooled()
{
	return FALSE;
} 

void CMTPriceListReader::Deactivate()
{
	mpObjectContext.Release();
} 


// ----------------------------------------------------------------
// Name:     	
// Arguments:     
//                
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTPriceListReader::Find(IMTSessionContext* apCtxt, long aID, IMTPriceList **apPriceList)
{
	MTAutoContext context(mpObjectContext);
	try
	{
		if (!apCtxt)
			return E_POINTER;

		long languageID;
		HRESULT hr = apCtxt->get_LanguageID(&languageID);
		if (FAILED(hr))
			return hr;

		ROWSETLib::IMTSQLRowsetPtr rs;
		hr = rs.CreateInstance(MTPROGID_SQLROWSET);
		if (FAILED(hr))
			return hr;

		rs->Init(CONFIG_DIR);
		rs->SetQueryTag(FIND_PRICE_LIST_BY_ID);
		rs->AddParam("%%ID%%", aID);
		rs->AddParam(L"%%ID_LANG%%", languageID);

		rs->Execute();
		
		hr = PopulatePriceListObject(apCtxt,rs, apPriceList);
		if (FAILED(hr))
			return hr;
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	context.Complete();
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	
// Arguments:     
//                
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------


STDMETHODIMP CMTPriceListReader::FindByName(IMTSessionContext* apCtxt, BSTR aName, IMTPriceList **apPriceList)
{
	MTAutoContext context(mpObjectContext);

	if(!apPriceList)
		return E_POINTER;

	*apPriceList = NULL;

	try
	{
		if (!apCtxt)
			return E_POINTER;

		long languageID;
		HRESULT hr = apCtxt->get_LanguageID(&languageID);
		if (FAILED(hr))
			return hr;

		ROWSETLib::IMTSQLRowsetPtr rs;
		hr = rs.CreateInstance(MTPROGID_SQLROWSET);
		if (FAILED(hr))
			return hr;

		rs->Init(CONFIG_DIR);
		rs->SetQueryTag(FIND_PRICE_LIST_BY_NAME);
		rs->AddParam("%%NAME%%", aName);
		rs->AddParam(L"%%ID_LANG%%", languageID);
		rs->Execute();

		//if item not found just return NULL
		if(rs->GetRowsetEOF().boolVal == VARIANT_FALSE)
		{	hr = PopulatePriceListObject(apCtxt,rs, apPriceList);
			if (FAILED(hr))
				return hr;
		}
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	context.Complete();
	return S_OK;
}


// ----------------------------------------------------------------
// Name:     	
// Arguments:     
//                
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

HRESULT CMTPriceListReader::PopulatePriceListObject(IMTSessionContext* apCtxt,
																										ROWSETLib::IMTSQLRowsetPtr aRowset,
																										IMTPriceList **apPriceList)
{
	if (aRowset->GetRowsetEOF().boolVal == VARIANT_TRUE)
			MT_THROW_COM_ERROR(IID_IMTPriceListReader, MTPC_ITEM_NOT_FOUND);
	
	IMTPriceListPtr pricelist(MTPROGID_PRICE_LIST);
	pricelist->SetSessionContext(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(apCtxt));

	long id = aRowset->GetValue(L"id_pricelist");
// TODO:
//		long returnedId = aRowset->GetValue("id_sched");
//		ASSERT(returnedId == id);
//		if (returnedId != id)
//			return Error("rate schedule ID returned from the database is invalid");

	_variant_t val;

	pricelist->PutID(id);

		// TODO: not localized
	val = aRowset->GetValue(L"nm_name");

	if(val.vt != VT_NULL) {
		pricelist->PutName((_bstr_t) val);
	}
	else {
		pricelist->PutName("");
	}

	val = aRowset->GetValue(L"nm_desc");
	if(val.vt != VT_NULL) {
		pricelist->PutDescription((_bstr_t) val);
	}
	else {
		pricelist->PutDescription("");
	}

	val = aRowset->GetValue(L"nm_currency_code");
	pricelist->PutCurrencyCode((_bstr_t) val);

	// The Shareable property has been deprecated in favor of the type property on the pricelist obj
	// _bstr_t bstrVal = aRowset->GetValue(L"b_shareable");
	// pricelist->PutShareable(MTTypeConvert::StringToBool(bstrVal));

	long lngVal = aRowset->GetValue(L"n_type");
	pricelist->PutType((MTPRODUCTCATALOGLib::MTPriceListType) lngVal);

	*apPriceList = (IMTPriceList *) pricelist.Detach();

	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	    FindAsRowset
// Arguments:     aParamTblDefID - parameter table definition to use when checking rateschedules, can be -1
//                aPrcItemTmplID - priceable item template to use when checking rateschedules, can be -1
//                aFilter - optional filter
//                apRowset - resulting rowset, with pricelist columns and column 'rateschedules'
// Return Value:  
// Errors Raised: 
// Description:   Column 'rateschedules' contains the number of rateschedules
//                for that price list and any passed in ParamTblDef, PrcItemTmpl.
//                Column 'rateschedules' is NULL if there aren't any appropriate rateschedules.
//                If aParamTblDefID or aPrcItemTmplID is -1, they will not be checked.
// ----------------------------------------------------------------

STDMETHODIMP CMTPriceListReader::FindAsRowset(IMTSessionContext* apCtxt, long aParamTblDefID, long aPrcItemTmplID, VARIANT aFilter, IMTSQLRowset **apRowset)
{
	MTAutoContext context(mpObjectContext);

	if (!apRowset)
		return E_POINTER;

	try
	{
		if (!apCtxt)
			return E_POINTER;

		long languageID;
		HRESULT hr = apCtxt->get_LanguageID(&languageID);
		if (FAILED(hr))
			return hr;

		MTPRODUCTCATALOGLib::IMTProductCatalogPtr pc(__uuidof(MTProductCatalog));
		MTPRODUCTCATALOGLib::IMTDataFilterPtr aDataFilter = 
      pc->GetMetaData(MTPRODUCTCATALOGLib::PCENTITY_TYPE_PRICE_LIST)->TranslateFilter(aFilter);

    _bstr_t filter = (aDataFilter == NULL) ? "" : aDataFilter->FilterString;
    if(filter.length() < 1)
      filter = "1=1";

		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		// construct rateschedule where clause from aParamTblDefID, aPrcItemTmplID, like
		// "where rs.id_pt = %%ID_PT%% and id_pi_template = %%ID_PI_TMP%%"
		// skip IDs that are -1
		_bstr_t whereClause;
	
		if (aParamTblDefID != PROPERTIES_BASE_NO_ID)
		{	char buff[100];
			sprintf(buff, "where rs.id_pt=%d", aParamTblDefID);
			whereClause += buff;
		}

		if (aPrcItemTmplID != PROPERTIES_BASE_NO_ID)
		{	char buff[100];
		  if (whereClause.length() == 0)
				sprintf(buff, "where id_pi_template=%d", aPrcItemTmplID);
			else
				sprintf(buff, " and id_pi_template=%d", aPrcItemTmplID);
			whereClause += buff;
		}

		rowset->SetQueryTag(L"__GET_PRICELISTS__");
		rowset->AddParam(L"%%RS_WHERE%%", whereClause);
		rowset->AddParam(L"%%ID_LANG%%", languageID);
    rowset->AddParam(L"%%FILTER%%", filter, true);
		rowset->Execute();

		*apRowset = reinterpret_cast<IMTSQLRowset*>(rowset.Detach());
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	context.Complete();
	return S_OK;
}

// ----------------------------------------------------------------
// Name:     	
// Arguments:     
//                
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------

STDMETHODIMP CMTPriceListReader::FindByAccountID(IMTSessionContext* apCtxt, long accountID, IMTPriceList **ppVal)
{
	ASSERT(ppVal);
	if(!ppVal) return E_POINTER;
	MTAutoContext context(mpObjectContext);

	try {

		ROWSETLib::IMTSQLRowsetPtr rs;
		HRESULT hr = rs.CreateInstance(MTPROGID_SQLROWSET);
		if (FAILED(hr))
			return hr;

		rs->Init(CONFIG_DIR);
		rs->SetQueryTag("FIND_DEFAULT_PRICE_LIST_BY_ACCOUNT_ID");
		rs->AddParam("%%ACC_ID%%", accountID);

		// step 1: run query that returns default account pricelist based on the account
		rs->Execute();
		// step 2: populate the returned pricelist object
		if(rs->GetRowsetEOF().boolVal == VARIANT_TRUE) {
			// no default pricelist found
			*ppVal = NULL;
			return S_OK;
		}
		else {
			hr = PopulatePriceListObject(apCtxt,rs, ppVal);
			if (FAILED(hr))
				return hr;
			}
	}
	catch(_com_error& e) {
		return ReturnComError(e); 
	}

	context.Complete();
	return S_OK;
}

