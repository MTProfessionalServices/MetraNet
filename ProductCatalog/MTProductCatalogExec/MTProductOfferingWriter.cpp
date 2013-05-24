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
* $Header: MTProductOfferingWriter.cpp, 43, 11/13/2002 6:09:26 PM, Fabricio Pettena$
* 
***************************************************************************/

#include "StdAfx.h"

#include "MTProductCatalogExec.h"
#include "MTProductOfferingWriter.h"
#include <pcexecincludes.h>
#include <comdef.h>

#import <MetraTech.Localization.tlb>

/////////////////////////////////////////////////////////////////////////////
// CMTProductOfferingWriter

/******************************************* error interface ***/
STDMETHODIMP CMTProductOfferingWriter::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTProductOfferingWriter
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

/****************************************** IObjectControl ***/
CMTProductOfferingWriter::CMTProductOfferingWriter()
{
	mpObjectContext = NULL;
}


HRESULT CMTProductOfferingWriter::Activate()
{
	HRESULT hr = GetObjectContext(&mpObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTProductOfferingWriter::CanBePooled()
{
	return FALSE;
} 

void CMTProductOfferingWriter::Deactivate()
{
 	mpObjectContext.Release();
} 

/****************************************** IMTProductOfferingWriter ***/
// ----------------------------------------------------------------
// Description:  Creates a new product offering in the database
// Arguments:    apProdOff - the product offering to create
//               apID - OUT: the ID of the created product offering 
// ----------------------------------------------------------------
STDMETHODIMP CMTProductOfferingWriter::Create(IMTSessionContext* apCtxt, 
																							/*[in]*/ IMTProductOffering* apProdOff,
																							/*[out, retval]*/ long* apID)
{
	MTAutoContext context(mpObjectContext);

	if (!apProdOff || !apID)
		return E_POINTER;

	//init out var
	*apID = 0;
	
	try
	{
		_variant_t vtParam;
		MTPRODUCTCATALOGEXECLib::IMTProductOfferingPtr prodOff = apProdOff; //use comptr for convenience
		// This instance will be used in more than one place
		MTPRODUCTCATALOGLib::IMTProductCatalogPtr productCatalog(__uuidof(MTProductCatalog));
    productCatalog->SetSessionContext(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(apCtxt));

		//check for existing name
		VerifyName(apCtxt, apProdOff);


		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		//create timespans
		MTPRODUCTCATALOGEXECLib::IMTPCTimeSpanWriterPtr timeSpanWriter(__uuidof(MTPCTimeSpanWriter));
		long idEffectiveDate = timeSpanWriter->Create(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), prodOff->EffectiveDate);
		prodOff->EffectiveDate->ID = idEffectiveDate;

		//create private, non-shared pricelist
		MTPRODUCTCATALOGLib::IMTPriceListPtr pricelistPtr = productCatalog->CreatePriceList();
		_bstr_t plname = "Nonshared PL for:" + prodOff->Name;
		// TODO: not hardcode 256
		if (plname.length() > 256)
		{
			std::string truncatedName(plname, 256);
			plname = truncatedName.c_str();
		}
		pricelistPtr->Name = plname;
		pricelistPtr->Description = plname;
		pricelistPtr->CurrencyCode = prodOff->GetCurrencyCode();
		pricelistPtr->Type = (MTPRODUCTCATALOGLib::MTPriceListType) PRICELIST_TYPE_PO;

		pricelistPtr->Save();
		prodOff->NonSharedPriceListID = pricelistPtr->ID;

		long idAvailabilityDate = timeSpanWriter->Create(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), prodOff->AvailabilityDate);
		prodOff->AvailabilityDate->ID = idAvailabilityDate;

		//insert into base prop
		MTPRODUCTCATALOGEXECLib::IMTBasePropsWriterPtr baseWriter(__uuidof(MTBasePropsWriter));
		long idProp = baseWriter->CreateWithDisplayName( reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), 
																											PCENTITY_TYPE_PRODUCT_OFFERING,
																											prodOff->Name,
																											prodOff->Description,
																											prodOff->DisplayName);

		//insert into po
		rowset->SetQueryTag("__ADD_PO__");

		vtParam = idProp;
		rowset->AddParam("%%ID_PO%%",vtParam);
		
		vtParam = idEffectiveDate;
		rowset->AddParam("%%ID_EFF_DATE%%",vtParam);
		
		vtParam = idAvailabilityDate;
		rowset->AddParam("%%ID_AVAIL%%",vtParam);

		vtParam = MTTypeConvert::BoolToString(prodOff->SelfSubscribable);
		rowset->AddParam("%%CAN_SUBSCRIBE%%", vtParam);

		vtParam = MTTypeConvert::BoolToString(prodOff->SelfUnsubscribable);
		rowset->AddParam("%%CAN_UNSUBSCRIBE%%", vtParam);

		vtParam = prodOff->NonSharedPriceListID;
		rowset->AddParam("%%ID_NONSHARED_PL%%", vtParam);

		vtParam = MTTypeConvert::BoolToString(prodOff->Hidden);
		rowset->AddParam("%%IS_HIDDEN%%", vtParam);

		rowset->Execute();


    //Localized Display Names
    rowset->SetQueryTag("__GET_DISPLAYNAME_DESC_ID_FOR_PC_ITEM__");

    vtParam = idProp;
    rowset->AddParam("%%ID_PROP%%",vtParam);

    rowset->Execute();
    if((long)rowset->GetValue(L"n_display_name") > 0)
    {
	    MetraTech_Localization::ILocalizedEntityPtr displayNameLocalizationPtr(prodOff->DisplayNames);
      displayNameLocalizationPtr->SaveWithID((long)rowset->GetValue(L"n_display_name"));
    }
    else
    {
      //Error
    }

    if((long)rowset->GetValue(L"n_desc") > 0)
    {
	    MetraTech_Localization::ILocalizedEntityPtr displayDescLocalizationPtr(prodOff->DisplayDescriptions);
      displayDescLocalizationPtr->SaveWithID((long)rowset->GetValue(L"n_desc"));
    }
    else
    {
      //Error
    }

    //refresh account type restriction mappings
    MTPRODUCTCATALOGEXECLib::IMTProductOfferingWriterPtr ThisPtr = this;
    MetraTech_Accounts_Type::IAccountTypeManagerPtr mgr(__uuidof(MetraTech_Accounts_Type::AccountTypeManager));
    for(int index = 1; index <= prodOff->SubscribableAccountTypes->GetCount(); index++) 
    {
      _bstr_t acctypename = prodOff->SubscribableAccountTypes->GetItem(index);
      MTAccountTypeLib::IMTAccountTypePtr at = mgr->GetAccountTypeByName
        (reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext *>(apCtxt), acctypename);

      if(at->CanSubscribe == VARIANT_FALSE)
        MT_THROW_COM_ERROR(MTPCUSER_ACCOUNT_TYPE_NOT_SUBSCRIBABLE);

      AddSubscribableAccountTypeByName(idProp, acctypename);
    }

		MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr pContext(apCtxt);
		PCCache::GetAuditor()->FireEvent(AuditEventsLib::AUDITEVENT_PO_CREATE,
																		 pContext->AccountID,2,idProp,"");
		
		//add any priceable items in the product offering's mPrcItemsToAdd
		AddPendingPriceableItems(apCtxt, apProdOff, idProp);

		// extended property code needs ID (but AddPendingPriceableItems can't have it)
		prodOff->ID = idProp;

		// run through extended properties for product offering
		MTPRODUCTCATALOGLib::IMTPropertyMetaDataSetPtr metaData = productCatalog->GetMetaData((MTPRODUCTCATALOGLib::MTPCEntityType) PCENTITY_TYPE_PRODUCT_OFFERING);
		metaData->UpsertExtendedProperties( reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(apCtxt), 
																				reinterpret_cast<MTPRODUCTCATALOGLib::IMTProperties*>(prodOff->GetProperties().GetInterfacePtr()),
																				VARIANT_FALSE);
		*apID = idProp;
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}

// ----------------------------------------------------------------
// Description:  Updates an existing product offering in the database
// Arguments:    apProdOff - the product offering to modify (identified by ID)
// ----------------------------------------------------------------
STDMETHODIMP CMTProductOfferingWriter::Update(IMTSessionContext* apCtxt, /*[in]*/ IMTProductOffering* apProdOff)
{
	MTAutoContext context(mpObjectContext);

	if (!apProdOff)
		return E_POINTER;

	try
	{
		_variant_t vtParam;

		//use comptr for convenience
		MTPRODUCTCATALOGEXECLib::IMTProductOfferingPtr prodOff = apProdOff;

		//check for existing name
		VerifyName(apCtxt, apProdOff);

		//check configuration if AvailabilityDate is being set
		CheckConfigurationIfSettingAvailabilityDate(apProdOff);


		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);


		MetraTech_Localization::ILocalizedEntityPtr displayDescLocalizationPtr(prodOff->DisplayDescriptions);
    	if (displayDescLocalizationPtr->GetID() <= 0)
		{
			prodOff->Description = displayDescLocalizationPtr->GetDefaultMapping();
		}

		//update base prop
		MTPRODUCTCATALOGEXECLib::IMTBasePropsWriterPtr baseWriter(__uuidof(MTBasePropsWriter));
		baseWriter->UpdateWithDisplayName(MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr(apCtxt),
																			prodOff->Name, prodOff->Description,
																			prodOff->DisplayName, prodOff->ID);

		//update PO
		rowset->SetQueryTag("UPDATE_PO");
		
		rowset->AddParam("%%ID_PO%%", prodOff->ID);

		vtParam = MTTypeConvert::BoolToString(prodOff->SelfSubscribable);
		rowset->AddParam("%%CAN_SUBSCRIBE%%", vtParam);
		
		vtParam = MTTypeConvert::BoolToString(prodOff->SelfUnsubscribable);
		rowset->AddParam("%%CAN_UNSUBSCRIBE%%", vtParam);

		vtParam = MTTypeConvert::BoolToString(prodOff->Hidden);
		rowset->AddParam("%%IS_HIDDEN%%", vtParam);

		rowset->AddParam("%%ID_NONSHARED_PL%%", prodOff->NonSharedPriceListID);
		
		rowset->Execute();
		
		// run through extended properties for product offering
		MTPRODUCTCATALOGLib::IMTProductCatalogPtr productCatalog(__uuidof(MTProductCatalog));
    productCatalog->SetSessionContext(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(apCtxt));
		MTPRODUCTCATALOGLib::IMTPropertyMetaDataSetPtr metaData = productCatalog->GetMetaData(MTPRODUCTCATALOGLib::PCENTITY_TYPE_PRODUCT_OFFERING);
		metaData->UpsertExtendedProperties( reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(apCtxt), 
																				reinterpret_cast<MTPRODUCTCATALOGLib::IMTProperties*>(prodOff->GetProperties().GetInterfacePtr()),
																				VARIANT_FALSE);

		//update EffectiveDate
		MTPRODUCTCATALOGEXECLib::IMTPCTimeSpanWriterPtr timeSpanWriter(__uuidof(MTPCTimeSpanWriter));
		timeSpanWriter->Update(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), prodOff->EffectiveDate);

		// check that the effective date is not outside any subscriptions
		rowset->Clear();
		rowset->SetQueryTag("__CHECK_SUBSCRIPTIONS_AGAINST_PO_EFFECTIVE_DATE__");
		rowset->AddParam("%%ID_PO%%", prodOff->ID);
		rowset->Execute();
		if((long)rowset->GetValue(L"n_start_date_violations") > 0)
		{
			MT_THROW_COM_ERROR(IID_IMTProductOfferingWriter, MTPCUSER_SUBS_EXIST_BEFORE_PO_EFF_START_DATE);
		}
		else if((long)rowset->GetValue(L"n_end_date_violations") > 0)
		{
			MT_THROW_COM_ERROR(IID_IMTProductOfferingWriter, MTPCUSER_SUBS_EXIST_AFTER_PO_EFF_END_DATE);
		}

		// propagate enddate change to subscribed users
		timeSpanWriter->PropagateEndDateChange(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), prodOff->ID, prodOff->EffectiveDate);

		//update AvailabilityDate
		timeSpanWriter->Update(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), prodOff->AvailabilityDate);

    //update localized display names
    MetraTech_Localization::ILocalizedEntityPtr displayNameLocalizationPtr(prodOff->DisplayNames);
    displayNameLocalizationPtr->Save();

    //update localized display descriptions
    if (displayDescLocalizationPtr->GetID() > 0)
    {
      displayDescLocalizationPtr->Save();
    }
	else
	{
		//Localized Display Names
		rowset->SetQueryTag("__GET_DISPLAYNAME_DESC_ID_FOR_PC_ITEM__");

		vtParam = prodOff->ID;
		rowset->AddParam("%%ID_PROP%%",vtParam);

		rowset->Execute();
		if((long)rowset->GetValue(L"n_desc") > 0)
		{
			displayDescLocalizationPtr->SaveWithID((long)rowset->GetValue(L"n_desc"));
		}
	}
    

    //refresh account type restriction mappings
    MTPRODUCTCATALOGEXECLib::IMTProductOfferingWriterPtr ThisPtr = this;
    ThisPtr->RemoveSubscribableAccountTypes(MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr(apCtxt), prodOff->ID);
    MetraTech_Accounts_Type::IAccountTypeManagerPtr mgr(__uuidof(MetraTech_Accounts_Type::AccountTypeManager));
    for(int index = 1; index <= prodOff->SubscribableAccountTypes->GetCount(); index++) 
    {
      _bstr_t acctypename = prodOff->SubscribableAccountTypes->GetItem(index);
      MTAccountTypeLib::IMTAccountTypePtr at = mgr->GetAccountTypeByName
        (reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext *>(apCtxt), acctypename);

      if(at->CanSubscribe == VARIANT_FALSE)
        MT_THROW_COM_ERROR(MTPCUSER_ACCOUNT_TYPE_NOT_SUBSCRIBABLE);

      AddSubscribableAccountTypeByName(prodOff->ID, acctypename);
    }

		MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr pContext(apCtxt);
		PCCache::GetAuditor()->FireEvent(1101,pContext->AccountID,2,prodOff->ID,"");

	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}


// ----------------------------------------------------------------
// Description:  Remove a new product offering from the database
// Arguments:    aID - the ID of the product offering to delete
// ----------------------------------------------------------------
STDMETHODIMP CMTProductOfferingWriter::Remove(IMTSessionContext* apCtxt, /*[in]*/ long aID)
{
	MTAutoContext context(mpObjectContext);

	try
	{

		MTPRODUCTCATALOGLib::IMTProductOfferingPtr prodOff;
		
		MTPRODUCTCATALOGEXECLib::IMTProductOfferingReaderPtr prodOffReader(__uuidof(MTProductOfferingReader));
		prodOff = prodOffReader->Find(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), aID);

		// Check if this product offering was ever subscribed to
		// If so, throw com error, since we can't delete it. If we try to, we will get a FK constraint error
		long n_sub_count = prodOff->GetCountOfAllSubscriptions();
		if (n_sub_count > 0)
			MT_THROW_COM_ERROR(IID_IMTProductOfferingWriter, MTPCUSER_CANNOT_DELETE_SUBSCRIBED_PO);

		// loop through each pi item 
		MTPRODUCTCATALOGLib::IMTCollectionPtr items = prodOff->GetPriceableItems();
		long count = items->Count;

		MTPRODUCTCATALOGEXECLib::IMTPriceableItemWriterPtr
		  priceableItemWriter(__uuidof(MTPriceableItemWriter));

		long piID;
		for (long i = 1; i <= count; i++)
		{
		  MTPRODUCTCATALOGLib::IMTPriceableItemPtr piInstance = items->GetItem(i);
		  piID = piInstance->GetID();

		  priceableItemWriter->Remove(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), piID);
		}

		// remove extended properties
		MTPRODUCTCATALOGLib::IMTProductCatalogPtr productCatalog( __uuidof(MTPRODUCTCATALOGLib::MTProductCatalog));

		MTPRODUCTCATALOGLib::IMTPropertyMetaDataSetPtr metaData = productCatalog->GetMetaData(MTPRODUCTCATALOGLib::PCENTITY_TYPE_PRODUCT_OFFERING);
		metaData->RemoveExtendedProperties(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(apCtxt), prodOff->GetProperties());

    //delete po account type restriction mappings
    MTPRODUCTCATALOGEXECLib::IMTProductOfferingWriterPtr ThisPtr = this;
    ThisPtr->RemoveSubscribableAccountTypes(MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr(apCtxt), aID);
    
		//delete po
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		rowset->SetQueryTag("DELETE_PO");
		rowset->AddParam("%%ID_PO%%", aID);
		rowset->Execute();
    
		// Delete the po nonshared price list
		MTPRODUCTCATALOGEXECLib::IMTPriceListWriterPtr priceListWriter(__uuidof(MTPriceListWriter));
		priceListWriter->Remove(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), prodOff->NonSharedPriceListID);
		
		//delete po base prop
		MTPRODUCTCATALOGEXECLib::IMTBasePropsWriterPtr baseWriter(__uuidof(MTBasePropsWriter));
		baseWriter->Delete(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), aID);
	
		//delete timespans
		MTPRODUCTCATALOGEXECLib::IMTPCTimeSpanWriterPtr timeSpanWriter(__uuidof(MTPCTimeSpanWriter));
		timeSpanWriter->Remove(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), prodOff->EffectiveDate->ID);
		timeSpanWriter->Remove(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), prodOff->AvailabilityDate->ID);

    

		//send event to audit log
    AuditEventsLib::MTAuditEvent event = AuditEventsLib::AUDITEVENT_UNKNOWN;
    event = AuditEventsLib::AUDITEVENT_PO_DELETE;
    char buffer[512];
    sprintf(buffer,"Product Offering Id: %d", aID);
    MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr pContext(apCtxt);
		PCCache::GetAuditor()->FireEvent(event,pContext->AccountID,2,-1,buffer);
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}

// helper to add any priceable items in the product offering's mPrcItemsToAdd
// can throw com_error
void CMTProductOfferingWriter::AddPendingPriceableItems(IMTSessionContext* apCtxt, IMTProductOffering* apProdOff, long aProdOfferringID)
{
	MTPRODUCTCATALOGEXECLib::IMTProductOfferingPtr prodOff = apProdOff; //use comptr for convenience

	// ASSERT that apProdOff does not have an ID (so that we will get the in memory PIs)
	ASSERT( prodOff->ID == PROPERTIES_BASE_NO_ID );

	//for all priceable item instances in list
	MTPRODUCTCATALOGEXECLib::IMTPriceableItemPtr prcItemInstance;
	
	MTPRODUCTCATALOGEXECLib::IMTCollectionPtr prcItems;
	prcItems = prodOff->GetPriceableItems();

	long count = prcItems->GetCount();

	for (long i = 1; i <= count; ++i) 	// collection indexes are 1-based
	{
		prcItemInstance = prcItems->GetItem(i);

		// add it to the po
		// use priceable item executant to create the instances
		MTPRODUCTCATALOGEXECLib::IMTPriceableItemWriterPtr writer(__uuidof(MTPRODUCTCATALOGEXECLib::MTPriceableItemWriter));
		writer->CreateInstance(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), aProdOfferringID, prcItemInstance);
	}
}


// check for existing name,
// throws _com_error if prod off with that name already exists for a different product offering
void CMTProductOfferingWriter::VerifyName(IMTSessionContext* apCtxt, IMTProductOffering* apProdOff)
{
	if (PCCache::IsBusinessRuleEnabled( PCCONFIGLib::MTPC_BUSINESS_RULE_ProdOff_NoDuplicateName ))
	{
		MTPRODUCTCATALOGEXECLib::IMTProductOfferingPtr prodOff = apProdOff;
	
		MTPRODUCTCATALOGEXECLib::IMTProductOfferingReaderPtr prodOffReader(__uuidof(MTProductOfferingReader));
		MTPRODUCTCATALOGEXECLib::IMTProductOfferingPtr existingProdOff;
		existingProdOff = prodOffReader->FindByName((MTPRODUCTCATALOGEXECLib::IMTSessionContext *) apCtxt, prodOff->Name);

		if (existingProdOff != NULL && existingProdOff->ID != prodOff->ID)
			MT_THROW_COM_ERROR(IID_IMTProductOfferingWriter, MTPCUSER_PROD_OFF_EXISTS, (const char*)prodOff->Name);
	}
}

// if AvailabilityDate is being set (was empty or NULL and is now not null)
// check product offering configuration
// throws _com_error if there are any configuration errors 
HRESULT CMTProductOfferingWriter::CheckConfigurationIfSettingAvailabilityDate(IMTProductOffering* apProdOff)
{
	if (PCCache::IsBusinessRuleEnabled(PCCONFIGLib::MTPC_BUSINESS_RULE_ProdOff_CheckConfiguration))
	{
		if (IsAvailabilityDateBeingSet(apProdOff))
		{
			MTPRODUCTCATALOGEXECLib::IMTProductOfferingPtr prodOff = apProdOff;

			MTPRODUCTCATALOGLib::IMTCollectionPtr errors;
			errors = prodOff->CheckConfiguration();

			long errorCount = errors->GetCount();

			// if there are config errors, concat them separated by '\n'
			// and throw a com_error
			if (errorCount > 0 )
			{
				bstr_t msgString;

				for (long errorIdx = 1; errorIdx <= errorCount; ++errorIdx) 	// collection indexes are 1-based
				{
					bstr_t errorMsg = errors->GetItem(errorIdx);

					//separate errors using '\n'
					msgString += L"\n";
					msgString += errorMsg;
				}

				ReturnComError(MTSourceInfo(__FILE__, __LINE__).CreateComError(MTPCUSER_PO_NOT_COMPLETELY_CONFIGURED, (char*)(msgString)));
			}
		}
	}
  return S_OK;
}

// Checks if product offering availability start date was empty/null and is now being set.
// can throw _com_error
bool CMTProductOfferingWriter::IsAvailabilityDateBeingSet(IMTProductOffering* apProdOff)
{
	MTPRODUCTCATALOGLib::IMTProductOfferingPtr prodOff = apProdOff;

	// check if PO has currently its date set at all
	if (prodOff->HasAvailabilityDateBeenSet() == VARIANT_FALSE)
	{
		PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "Availability start date is NOT being SET (is empty)");
		return false;
	}
	else
	{	// get availability date ID
		long availabilityDateID = prodOff->AvailabilityDate->ID;

		// if ID is -1, current date was not created, but is now non-empty/null,
		// so it is being set
		if (availabilityDateID == PROPERTIES_BASE_NO_ID)
		{
			PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "Availability start date is being SET (is not empty, PO is being created)");
			return true;
		}
		else
		{
			//look in db to get previous date
			MTPCDateType previousStartDateType = PCDATE_TYPE_NULL;
			{
				ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
				rowset->Init(CONFIG_DIR);

				rowset->SetQueryTag("__GET_EFF_DATE__");
				rowset->AddParam("%%ID_EFFDATE%%", availabilityDateID);
				rowset->Execute();

				variant_t val = rowset->GetValue("n_begintype");

				previousStartDateType = static_cast<MTPCDateType>(val.lVal);
			}

			// if previous date was empty/null (current one is non-empty/null)
			// date is being set
			if (previousStartDateType == PCDATE_TYPE_NO_DATE ||
				previousStartDateType == PCDATE_TYPE_NULL)
			{
				PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "Availability start date is being SET (is not-empty, was empty)");
				return true;
			}
			else
			{
				PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "Availability start date is NOT being SET (is not-empty, was not-empty");
				return false;
			}
		}
	}
}
STDMETHODIMP CMTProductOfferingWriter::AddSubscribableAccountType(IMTSessionContext* apCtxt, long poid, IMTAccountType* aType)
{
	MTAutoContext context(mpObjectContext);
  MTPRODUCTCATALOGEXECLib::IMTAccountTypePtr ptr = aType;
  //BP TODO: Check Auth? What Auth am I checking?
	try
	{
    if(ptr->CanSubscribe == VARIANT_FALSE)
        MT_THROW_COM_ERROR(MTPCUSER_ACCOUNT_TYPE_NOT_SUBSCRIBABLE);
		_variant_t vtParam;
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		//update t_charge_prop
		rowset->SetQueryTag("__ADD_SUBSCRIBABLE_ACCOUNT_TYPE__");

		rowset->AddParam("%%ID_PO%%",poid);
		rowset->AddParam("%%ID_TYPE%%", ptr->ID);
		rowset->Execute();

	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}

STDMETHODIMP CMTProductOfferingWriter::RemoveSubscribableAccountType(IMTSessionContext* apCtxt, long poid, IMTAccountType* aType)
{
	MTAutoContext context(mpObjectContext);
    MTPRODUCTCATALOGEXECLib::IMTAccountTypePtr ptr = aType;
  //BP TODO: Check Auth? What Auth am I checking?

	try
	{
		_variant_t vtParam;
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		//update t_charge_prop
		rowset->SetQueryTag("__REMOVE_SUBSCRIBABLE_ACCOUNT_TYPE__");

		rowset->AddParam("%%ID_PO%%",poid);
		rowset->AddParam("%%ID_TYPE%%", ptr->ID);
		rowset->Execute();

	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}

void CMTProductOfferingWriter::AddSubscribableAccountTypeByName(long poid, BSTR aName)
{
  _variant_t vtParam;
  ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
  rowset->Init(CONFIG_DIR);

  //update t_charge_prop
  rowset->SetQueryTag("__ADD_SUBSCRIBABLE_ACCOUNT_TYPE_BYNAME__");

  rowset->AddParam("%%ID_PO%%",poid);
  rowset->AddParam("%%NAME%%", aName);
  rowset->Execute();
  return;
}
/*

STDMETHODIMP CMTProductOfferingWriter::RemoveSubscribableAccountTypeByName(IMTSessionContext* apCtxt, long poid, BSTR aName)
{
	MTAutoContext context(mpObjectContext);

	try
	{
		_variant_t vtParam;
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		//update t_charge_prop
		rowset->SetQueryTag("__REMOVE_SUBSCRIBABLE_ACCOUNT_TYPE_BYNAME__");

		rowset->AddParam("%%ID_PO%%",poid);
		rowset->AddParam("%%NAME%%", aName);
		rowset->Execute();

	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}
*/
STDMETHODIMP CMTProductOfferingWriter::RemoveSubscribableAccountTypes(IMTSessionContext* apCtxt, long poid)
{
	MTAutoContext context(mpObjectContext);

	try
	{
		_variant_t vtParam;
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		//update t_charge_prop
		rowset->SetQueryTag("__REMOVE_SUBSCRIBABLE_ACCOUNT_TYPES__");

		rowset->AddParam("%%ID_PO%%",poid);
		rowset->Execute();

	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}
