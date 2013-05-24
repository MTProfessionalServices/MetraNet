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
#include "MTPriceListWriter.h"
#include <pcexecincludes.h>

using MTPRODUCTCATALOGEXECLib::IMTPriceListPtr;

/////////////////////////////////////////////////////////////////////////////
// CMTPriceListWriter

/******************************************* error interface ***/
STDMETHODIMP CMTPriceListWriter::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTPriceListWriter
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

HRESULT CMTPriceListWriter::Activate()
{
	HRESULT hr = GetObjectContext(&mpObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTPriceListWriter::CanBePooled()
{
	return FALSE;
} 

void CMTPriceListWriter::Deactivate()
{
	mpObjectContext.Release();
} 


STDMETHODIMP CMTPriceListWriter::Create(IMTSessionContext* apCtxt, IMTPriceList *apList, long *apID)
{
	MTAutoContext context(mpObjectContext);
	if (!apList || !apID)
		return E_POINTER;

	try
	{
		IMTPriceListPtr priceList(apList);

		//check for existing name
		VerifyName(apCtxt, apList);


		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);

		//insert into base prop
		MTPRODUCTCATALOGEXECLib::IMTBasePropsWriterPtr baseWriter(__uuidof(MTBasePropsWriter));
		long plId = baseWriter->Create( reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), 
																		(long)PCENTITY_TYPE_PRICE_LIST,
																		priceList->Name,
																		priceList->Description);


		rowset->SetQueryTag(L"__ADD_PRICELIST__");
		rowset->AddParam(L"%%ID_PL%%", plId);

		//rowset->AddParam(L"%%SHAREABLE%%", MTTypeConvert::BoolToString(priceList->GetShareable()));
		long tmp_type = (long) priceList->GetType();
		rowset->AddParam(L"%%TYPE%%", tmp_type);
		rowset->AddParam(L"%%CURRENCY_CODE%%", priceList->GetCurrencyCode());

		rowset->Execute();

		*apID = plId;

		MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr pContext(apCtxt);
		PCCache::GetAuditor()->FireEvent(1300,pContext->AccountID,2,plId,"");

	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	context.Complete();
	return S_OK;
}

STDMETHODIMP CMTPriceListWriter::Update(IMTSessionContext* apCtxt, IMTPriceList *apList)
{
	MTAutoContext context(mpObjectContext);
	if (!apList)
		return E_POINTER;

	try
	{
		IMTPriceListPtr priceList(apList);

		//check for existing name
		VerifyName(apCtxt, apList);

		MTPRODUCTCATALOGEXECLib::IMTBasePropsWriterPtr baseWriter(__uuidof(MTBasePropsWriter));
		baseWriter->Update(MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr(apCtxt),
											 priceList->GetName(), priceList->GetDescription(),
											 priceList->GetID());

		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);

		rowset->SetQueryTag(L"__UPDATE_PRICELIST__");
		rowset->AddParam(L"%%ID_PL%%", priceList->GetID());
		//rowset->AddParam(L"%%SHAREABLE%%", MTTypeConvert::BoolToString(priceList->GetShareable()));
		rowset->AddParam(L"%%TYPE%%", (long) priceList->GetType());
		rowset->AddParam(L"%%CURRENCY_CODE%%", priceList->GetCurrencyCode());

		rowset->Execute();

		MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr pContext(apCtxt);
		PCCache::GetAuditor()->FireEvent(1301,pContext->AccountID,2,priceList->GetID(),"");

	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	context.Complete();
	return S_OK;
}

STDMETHODIMP CMTPriceListWriter::Remove(IMTSessionContext* apCtxt, long aPricelistID)
{
	// Todo: check for existence before deleting?
	// Todo: decide where business rules should be checked, on query? or here.

	MTAutoContext context(mpObjectContext);
	try
	{
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);

		// Attempt to delete rate schedule - the stored proc will figure out the rate table to
		// delete rules from
		rowset->InitializeForStoredProc("sp_DeletePricelist");
		rowset->AddInputParameterToStoredProc("a_plID", MTTYPE_INTEGER, INPUT_PARAM, aPricelistID);
		rowset->AddOutputParameterToStoredProc ("status", MTTYPE_INTEGER, OUTPUT_PARAM);
		rowset->ExecuteStoredProc();

		// Treat possible errors
		long statuscode = rowset->GetParameterFromStoredProc("status");
		switch(statuscode)
		{
			case 1:
				MT_THROW_COM_ERROR(IID_IMTPriceListWriter, MTPCUSER_CANNOT_DELETE_PRICELIST_POUSED);
				break;
			case 2:
				MT_THROW_COM_ERROR(IID_IMTPriceListWriter, MTPCUSER_CANNOT_DELETE_PRICELIST_ACCUSED);
				break;
		}

    AuditEventsLib::MTAuditEvent event = AuditEventsLib::AUDITEVENT_UNKNOWN;
    event = AuditEventsLib::AUDITEVENT_PL_DELETE;
    char buffer[512];
    sprintf(buffer,"Pricelist Id: %d", aPricelistID);
    MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr pContext(apCtxt);

		/* TODO: Fix 4th argument, used to be a pricelist id, does it make sense here?  */
    PCCache::GetAuditor()->FireEvent(event,pContext->AccountID,2,-1,buffer);
	}
	catch (_com_error & err)
	{ 
		return ReturnComError(err); 
	}

	context.Complete();
	return S_OK;
}


// check name of pricelist
// throws _com_error if prc list with that name already exists for a different pricelist
void CMTPriceListWriter::VerifyName(IMTSessionContext* apCtxt, IMTPriceList *apList)
{
	if (PCCache::IsBusinessRuleEnabled( PCCONFIGLib::MTPC_BUSINESS_RULE_PriceList_NoDuplicateName ))
	{	
		IMTPriceListPtr priceList(apList);

		// only check names for regular pricelists, since ICB and non-shared (aka private) pricelists have no meaningfull name
		if( priceList->GetType() == PRICELIST_TYPE_REGULAR)
		{
			MTPRODUCTCATALOGEXECLib::IMTPriceListReaderPtr reader(__uuidof(MTPriceListReader));
			MTPRODUCTCATALOGEXECLib::IMTPriceListPtr existingPriceList;
			existingPriceList = reader->FindByName((MTPRODUCTCATALOGEXECLib::IMTSessionContext *) apCtxt, priceList->GetName());

			if (existingPriceList != NULL && existingPriceList->ID != priceList->ID)
				MT_THROW_COM_ERROR(IID_IMTPriceListWriter, MTPCUSER_PRICE_LIST_EXISTS, (const char*)priceList->GetName());
		}
	}
}
