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

// MTPriceListMappingReader.cpp : Implementation of CMTPriceListMappingReader
#include "StdAfx.h"

#include "MTProductCatalogExec.h"
#include "MTPriceListMappingReader.h"
#include <pcexecincludes.h>
#include <comdef.h>

/////////////////////////////////////////////////////////////////////////////
// CMTPriceListMappingReader

/******************************************* error interface ***/
STDMETHODIMP CMTPriceListMappingReader::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTPriceListMappingReader
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

CMTPriceListMappingReader::CMTPriceListMappingReader()
{
	mpObjectContext = NULL;
}


HRESULT CMTPriceListMappingReader::Activate()
{
	HRESULT hr = GetObjectContext(&mpObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTPriceListMappingReader::CanBePooled()
{
	return TRUE;
} 

void CMTPriceListMappingReader::Deactivate()
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


STDMETHODIMP CMTPriceListMappingReader::FindByInstance(IMTSessionContext* apCtxt, long aPrcItemInstID, long aParamTblDefID, IMTPriceListMapping **apPrcLstMap)
{
	MTAutoContext context(mpObjectContext);

	if (!apPrcLstMap)
		return E_POINTER;

	//init out var
	*apPrcLstMap = NULL;

	try
	{
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);

		rowset->SetQueryTag("__GET_PRC_LST_MAPPING__");
		rowset->AddParam("%%ID_PI%%", aPrcItemInstID);
		rowset->AddParam("%%ID_PTD%%", aParamTblDefID);
		rowset->Execute();

		if((bool) rowset->GetRowsetEOF())
		{
			return S_OK; //not found
		}

		HRESULT hr = PopulatePriceListMapping(apCtxt, aPrcItemInstID,aParamTblDefID,rowset,apPrcLstMap);
		if( FAILED(hr))
			return hr;
		
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}

// ----------------------------------------------------------------
// Name: PopulatePriceListMapping    	
// Arguments:  instnace ID, paramtable ID, rowset, and mapping interface ptr   
//                
// Return Value:  
// Errors Raised: 
// Description:   Generic helper function to populate IMTPriceListMapping pointer
// ----------------------------------------------------------------

HRESULT CMTPriceListMappingReader::PopulatePriceListMapping(IMTSessionContext* apCtxt,
																														long aPrcItemInstID,
																														long aParamTblDefID,
																														ROWSETLib::IMTSQLRowsetPtr aRowset,
																														IMTPriceListMapping **ppMapping)
{

	MTPRODUCTCATALOGLib::IMTPriceListMappingPtr prcLstMap(__uuidof(MTPriceListMapping));
	
	//set the session context
	prcLstMap->SetSessionContext(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(apCtxt));

	prcLstMap->PriceableItemID = aPrcItemInstID;
	prcLstMap->ParamTableDefinitionID = aParamTblDefID;

	_variant_t val;
	val = aRowset->GetValue("id_pricelist");
	if(val.vt == VT_NULL)
		prcLstMap->PriceListID = -1;
	else
		prcLstMap->PriceListID = val.lVal;
	
	_bstr_t strVal = aRowset->GetValue("b_canICB").bstrVal;
	prcLstMap->CanICB = MTTypeConvert::StringToBool(strVal);

	*ppMapping = reinterpret_cast<IMTPriceListMapping *>(prcLstMap.Detach());
	return S_OK;

}


// ----------------------------------------------------------------
// Name:    FindICB_ByInstance 	
// Arguments:   Priceitem instance ID, parameter table ID, subscription ID,Pricelistmapping pointer
//                
// Return Value:  S_OK,E_FAIL
// Errors Raised: 
// Description:   Returns an ICB pricelist mapping, if available
// ----------------------------------------------------------------

STDMETHODIMP CMTPriceListMappingReader::FindICB_ByInstance(IMTSessionContext* apCtxt, 
																													 long aPrcItemInstID, long aParamTblDefID, 
																													 long id_sub, IMTPriceListMapping **ppMapping)
{
	ASSERT(ppMapping);
	if(!ppMapping) return E_POINTER;

	MTAutoContext context(mpObjectContext);

	try {

		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);

		rowset->SetQueryTag("__GET_ICB_PRC_LST_MAPPING__");
		rowset->AddParam("%%ID_PI%%", aPrcItemInstID);
		rowset->AddParam("%%ID_PTD%%", aParamTblDefID);
		rowset->AddParam("%%SUB_ID%%", id_sub);
		rowset->Execute();

		if((bool) rowset->GetRowsetEOF())
		{
			*ppMapping = NULL;
			return S_OK; //not found
		}

		HRESULT hr = PopulatePriceListMapping(apCtxt, aPrcItemInstID,aParamTblDefID,rowset,ppMapping);
		if (FAILED(hr))
			return hr;
	}
	catch(_com_error& err) {
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}

// ----------------------------------------------------------------
// Name: GetCountOfTypeByPO
// Arguments: long aProdOffID as the product offering ID, aNonSharedPLID as the Product Offering Nonshared Price List ID
//                
// Return Value: apCount as the number of pricelist mappings for this PO, according to the type requested
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------
STDMETHODIMP CMTPriceListMappingReader::GetCountOfTypeByPO(IMTSessionContext* apCtxt, long aProdOffID, long aNonSharedPLID, MTPriceListMappingType aType, long *apCount)
{
  MTAutoContext context(mpObjectContext);

  try
  {
    if (!apCount)
      return E_POINTER;
    
    *apCount = 0;
    
		//Build where clause based on type requested
/*
	select count(*) from t_pl_map 
		%%JOIN_CLAUSE%%
		where id_po = %%ID_PO%% and id_pricelist is not NULL
		%%OTHER_WHERE_CLAUSES%%
*/

		_bstr_t join = L"";
		_bstr_t where_compl = L"";

		switch (aType)
		{
			case MAPPING_ALL:
				// Do nothing, query does it by default
				break;
			case MAPPING_NORMAL:
				where_compl = L"and id_pricelist != " + _bstr_t(aNonSharedPLID) + L" and id_sub is NULL";
				break;
			case MAPPING_ICB_SUBSCRIPTION:
				join = L"inner join t_sub sub on plm.id_sub = sub.id_sub";
				where_compl = L"and id_group is NULL";
				break;
			case MAPPING_ICB_GROUP_SUBSCRIPTION:
				join = L"inner join t_sub sub on plm.id_sub = sub.id_sub";
				where_compl = L"and id_group is not NULL";
				break;
			case MAPPING_PO_PRICELIST:
				where_compl = L"and id_pricelist = " + _bstr_t(aNonSharedPLID) + L" and id_sub is NULL";
				break;
			default:
				break;
		}

    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);
    rowset->SetQueryTag("__GET_PLMAP_COUNT_BY_PO__");
    rowset->AddParam("%%ID_PO%%", aProdOffID);
		rowset->AddParam("%%JOIN_CLAUSE%%", join);
		rowset->AddParam("%%WHERE_COMPLEMENT%%", where_compl);
    rowset->Execute();

    *apCount = rowset->GetValue(0L);
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}
