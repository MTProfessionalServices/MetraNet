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

// MTPriceListMappingWriter.cpp : Implementation of CMTPriceListMappingWriter
#include "StdAfx.h"

#include "MTProductCatalogExec.h"
#include "MTPriceListMappingWriter.h"
#include <pcexecincludes.h>
#include "MTYAACExec.h"
#import <QueryAdapter.tlb> rename( "GetUserName", "QAGetUserName" )

/////////////////////////////////////////////////////////////////////////////
// CMTPriceListMappingWriter

/******************************************* error interface ***/
STDMETHODIMP CMTPriceListMappingWriter::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTPriceListMappingWriter
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTPriceListMappingWriter::Activate()
{
	HRESULT hr = GetObjectContext(&mpObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTPriceListMappingWriter::CanBePooled()
{
	return TRUE;
} 

void CMTPriceListMappingWriter::Deactivate()
{
	mpObjectContext.Release();
} 


STDMETHODIMP CMTPriceListMappingWriter::Update(IMTSessionContext* apCtxt, IMTPriceListMapping *apPrcLstMap)
{
	MTAutoContext context(mpObjectContext);
	if (!apPrcLstMap)
		return E_POINTER;

	try
	{
		MTPRODUCTCATALOGLib::IMTPriceListMappingPtr prcLstMap = apPrcLstMap; //use comptr for convenience

		MTPRODUCTCATALOGLib::IMTPriceableItemPtr prcItem = prcLstMap->GetPriceableItem();
		MTPRODUCTCATALOGLib::IMTProductOfferingPtr prodOff = prcItem->GetProductOffering();
		MTPRODUCTCATALOGLib::IMTPriceListPtr prcList = prcLstMap->GetPriceList();

    //Details for audit info
    char buffer[512];
    long oldPriceListId;
		// verify: price list currency is same as product offerings currency
		if (PCCache::IsBusinessRuleEnabled( PCCONFIGLib::MTPC_BUSINESS_RULE_ProdOff_CheckCurrency))
		{
			_bstr_t prodOffCurrency = prodOff->GetCurrencyCode();
			_bstr_t priceListCurrency = prcList->CurrencyCode;
				
			// Compare the currency of the pricelist with the currency of the product offering's private pricelist
			// If they are not equal, throw error
			if (prodOffCurrency != priceListCurrency)
			{
				//error: "Currency 'CUR' of pricelist 'PLNAME' does not match currency 'CUR' of product offering 'PROD OFF'"
				MT_THROW_COM_ERROR(IID_IMTPriceListMappingWriter, MTPCUSER_CURRENCY_DOES_NOT_MATCH_PRODOFF, 
					(char*)priceListCurrency, (char*)prcList->Name,
					(char*)prodOffCurrency, (char*)prodOff->Name);
			}
			else
			{
				ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
				rowset->Init(CONFIG_DIR);
        rowset->SetQueryTag("__GET_PRC_LST_MAPPING__");
        rowset->AddParam("%%ID_PI%%", prcLstMap->PriceableItemID);
        rowset->AddParam("%%ID_PTD%%", prcLstMap->ParamTableDefinitionID);
        rowset->Execute();

		    if(0 == rowset->GetRecordCount())
			  {
          //This should never happen -- we should have already checked this before we got to this point
				  MT_THROW_COM_ERROR(IID_IMTPriceListMappingWriter,MTPCUSER_PRC_ITEM_HAS_NO_PRICE_LIST,
            (char*)priceListCurrency, (char*)prcList->Name,
					(char*)prodOffCurrency, (char*)prodOff->Name);
			  }
        _variant_t val = rowset->GetValue("id_pricelist");
        if (val.vt != VT_NULL) 
        {
         oldPriceListId = (long) val;
        }
        //_bstr_t canIcb = (_bstr_t)rs->Value["b_canICB"];



				rowset->SetQueryTag(L"__UPDATE_PRC_LST_MAPPING__");
				rowset->AddParam(L"%%ID_PI%%", prcLstMap->PriceableItemID);
				rowset->AddParam(L"%%ID_PTD%%", prcLstMap->ParamTableDefinitionID);
				rowset->AddParam(L"%%ID_PL%%", prcLstMap->PriceListID);
				rowset->AddParam(L"%%CAN_ICB%%", MTTypeConvert::BoolToString(prcLstMap->CanICB));
				rowset->Execute();
			}
      // audit info
      sprintf(buffer, "Successfully updated price list mapping %s for product offering %s. Old prices list ID was %d, new ID is %d.", 
        (char*)prcList->Name, (char*)prodOff->Name, oldPriceListId, prcLstMap->PriceListID);
		}
		
		MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr pContext(apCtxt);
		PCCache::GetAuditor()->FireEvent(AuditEventsLib::AUDITEVENT_PO_UPDATEPLM,pContext->AccountID,2,prodOff->ID,buffer);
		
	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	context.Complete();
	return S_OK;
}
