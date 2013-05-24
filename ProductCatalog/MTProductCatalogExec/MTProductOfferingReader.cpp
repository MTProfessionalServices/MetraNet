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
* $Header: MTProductOfferingReader.cpp, 41, 11/13/2002 6:09:25 PM, Fabricio Pettena$
* 
***************************************************************************/


#include "StdAfx.h"

#include "MTProductCatalogExec.h"
#include "MTProductOfferingReader.h"
#include <pcexecincludes.h>
#include <optionalvariant.h>
#include <mttime.h>
#include <formatdbvalue.h>

#import <MetraTech.Localization.tlb>

/////////////////////////////////////////////////////////////////////////////
// CMTProductOfferingReader

/******************************************* error interface ***/
STDMETHODIMP CMTProductOfferingReader::InterfaceSupportsErrorInfo(REFIID riid)
{
  static const IID* arr[] = 
  {
    &IID_IMTProductOfferingReader
  };
  for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
  {
    if (::InlineIsEqualGUID(*arr[i],riid))
      return S_OK;
  }
  return S_FALSE;
}


CMTProductOfferingReader::CMTProductOfferingReader()
{
  mpObjectContext = NULL;
}


HRESULT CMTProductOfferingReader::Activate()
{
  HRESULT hr = GetObjectContext(&mpObjectContext);
  if (SUCCEEDED(hr))
    return S_OK;
  return hr;
} 

BOOL CMTProductOfferingReader::CanBePooled()
{
  return FALSE;
} 

void CMTProductOfferingReader::Deactivate()
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

STDMETHODIMP CMTProductOfferingReader::Find(IMTSessionContext* apCtxt, long aID, IMTProductOffering ** apProdOff)
{
  MTAutoContext context(mpObjectContext);

  if (!apProdOff)
    return E_POINTER;

  //init out var
  *apProdOff = NULL;

  try
  {
    if (!apCtxt)
      return E_POINTER;

    long languageID;
    HRESULT hr = apCtxt->get_LanguageID(&languageID);
    if (FAILED(hr))
      return hr;

    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);

    BSTR pSelectList,pJoinList;
    MTPRODUCTCATALOGLib::IMTProductCatalogPtr aProductCatalog(__uuidof(MTProductCatalog));
    aProductCatalog->GetMetaData(MTPRODUCTCATALOGLib::PCENTITY_TYPE_PRODUCT_OFFERING)->
      GetPropertySQL(aID, L"t_po", VARIANT_FALSE, // VARIANT_FALSE means all extended properties
                     &pSelectList,&pJoinList);

    // attach to BSTRs and OWN them (_bstr_t will deallocate memory)
    _bstr_t selectlist(pSelectList,false),joinlist(pJoinList,false);
    
    rowset->SetQueryTag("GET_PO");
    rowset->AddParam("%%ID_PO%%", aID);
    rowset->AddParam("%%EXTENDED_SELECT%%",selectlist);
    rowset->AddParam("%%EXTENDED_JOIN%%",joinlist);
    rowset->AddParam("%%ID_LANG%%", languageID);
    rowset->Execute();

    if((bool) rowset->GetRowsetEOF())
    {
      MT_THROW_COM_ERROR(MTPC_ITEM_NOT_FOUND_BY_ID, MTPRODUCTCATALOGLib::PCENTITY_TYPE_PRODUCT_OFFERING, aID);
    }
    else
    {
      MTPRODUCTCATALOGLib::IMTProductOfferingPtr prodOff(__uuidof(MTProductOffering));
      prodOff->SetSessionContext(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(apCtxt));

      PopulateByRowset(aID,rowset,prodOff);
      
      *apProdOff = reinterpret_cast<IMTProductOffering *>(prodOff.Detach());
    }
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}

STDMETHODIMP CMTProductOfferingReader::FindWithNonSharedPriceList(IMTSessionContext* apCtxt, long pricelistID, IMTProductOffering ** apProdOff)
{
	MTAutoContext context(mpObjectContext);

	if (!apProdOff)
		return E_POINTER;

	//init out var
	*apProdOff = NULL;

	try
	{
		if (!apCtxt)
			return E_POINTER;

		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		rowset->SetQueryTag("__GET_PO_ID_FOR_NONSHARED_PL__");
		rowset->AddParam("%%ID_PL%%", pricelistID);
		rowset->Execute();

		if((bool) rowset->GetRowsetEOF())
		{
			*apProdOff = NULL;
		}
		else
		{
			_variant_t poID = rowset->GetValue(0L);
			MTPRODUCTCATALOGLib::IMTProductCatalogPtr aProductCatalog(__uuidof(MTProductCatalog));
			MTPRODUCTCATALOGLib::IMTProductOfferingPtr prodOff = aProductCatalog->GetProductOffering(poID.lVal);
			prodOff->SetSessionContext(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(apCtxt));
			*apProdOff = reinterpret_cast<IMTProductOffering *>(prodOff.Detach());
		}
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}


STDMETHODIMP CMTProductOfferingReader::FindByName(IMTSessionContext* apCtxt, BSTR aName, IMTProductOffering ** apProdOff)
{
  MTAutoContext context(mpObjectContext);

  if (!apProdOff)
    return E_POINTER;

  //init out var
  *apProdOff = NULL;

  try
  {
    if (!apCtxt)
      return E_POINTER;

    long languageID;
    HRESULT hr = apCtxt->get_LanguageID(&languageID);
    if (FAILED(hr))
      return hr;

    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);

    BSTR pSelectList,pJoinList;
    MTPRODUCTCATALOGLib::IMTProductCatalogPtr aProductCatalog(__uuidof(MTProductCatalog));
    aProductCatalog->GetMetaData(MTPRODUCTCATALOGLib::PCENTITY_TYPE_PRODUCT_OFFERING)->
      GetPropertySQL("id_po" , L"t_po", VARIANT_FALSE, // VARIANT_FALSE means all extended properties
                     &pSelectList,&pJoinList);

    // attach to BSTRs and OWN them (_bstr_t will deallocate memory)
    _bstr_t selectlist(pSelectList,false),joinlist(pJoinList,false);
    
    rowset->SetQueryTag("GET_PO_BY_NAME");
    rowset->AddParam("%%NAME%%", aName);
    rowset->AddParam("%%EXTENDED_SELECT%%",selectlist);
    rowset->AddParam("%%EXTENDED_JOIN%%",joinlist);
    rowset->AddParam("%%ID_LANG%%", languageID);
    rowset->Execute();

    if((bool) rowset->GetRowsetEOF())
    {
      //not found, no error, just return NULL
      *apProdOff = NULL;
    }
    else
    {
      MTPRODUCTCATALOGLib::IMTProductOfferingPtr prodOff(__uuidof(MTProductOffering));
      prodOff->SetSessionContext(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(apCtxt));

      long ID = rowset->GetValue("id_po");
      PopulateByRowset(ID,rowset,prodOff);
      
      *apProdOff = reinterpret_cast<IMTProductOffering *>(prodOff.Detach());
    }
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

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

void CMTProductOfferingReader::PopulateByRowset(long aID,
                                                ROWSETLib::IMTSQLRowsetPtr rowset,
                                                MTPRODUCTCATALOGLib::IMTProductOfferingPtr prodOff)
{
    _variant_t val;
    prodOff->ID = aID;

    //TODO!! use ID to string
    val = rowset->GetValue("nm_name");
    prodOff->Name = MTMiscUtil::GetString(val);

    val = rowset->GetValue("nm_desc");
    prodOff->Description = MTMiscUtil::GetString(val);

    val = rowset->GetValue("nm_display_name");
    prodOff->DisplayName = MTMiscUtil::GetString(val);

    val = rowset->GetValue("n_display_name");
  	MetraTech_Localization::ILocalizedEntityPtr displayNameLocalizationPtr(prodOff->DisplayNames);
    displayNameLocalizationPtr->ID=val;

    val = rowset->GetValue("n_desc");
  	MetraTech_Localization::ILocalizedEntityPtr displayDescLocalizationPtr(prodOff->DisplayDescriptions);
    displayDescLocalizationPtr->ID=val;

    _bstr_t strVal = rowset->GetValue("b_user_subscribe");
    prodOff->SelfSubscribable = MTTypeConvert::StringToBool(strVal);

    strVal = rowset->GetValue("b_user_unsubscribe").bstrVal;
    prodOff->SelfUnsubscribable = MTTypeConvert::StringToBool(strVal);

    strVal = rowset->GetValue("b_hidden").bstrVal;
    prodOff->Hidden = MTTypeConvert::StringToBool(strVal);

    // Nonshared pricelist
    val = rowset->GetValue("id_nonshared_pl");
    prodOff->NonSharedPriceListID = val;

		//load EffectiveDate
		val = rowset->GetValue("id_eff_date");
		prodOff->EffectiveDate->ID = val;

    val = rowset->GetValue("te_n_begintype");
    prodOff->EffectiveDate->StartDateType = static_cast<MTPRODUCTCATALOGLib::MTPCDateType>(val.lVal);

    val = rowset->GetValue("te_dt_start");
    if (V_VT(&val) == VT_NULL)
      prodOff->EffectiveDate->StartDate = 0.0;
    else
      prodOff->EffectiveDate->StartDate = val;

    val = rowset->GetValue("te_n_beginoffset");
    prodOff->EffectiveDate->StartOffset = val;

    val = rowset->GetValue("te_n_endtype");
    prodOff->EffectiveDate->EndDateType = static_cast<MTPRODUCTCATALOGLib::MTPCDateType>(val.lVal);

    val = rowset->GetValue("te_dt_end");
    if (V_VT(&val) == VT_NULL)
      prodOff->EffectiveDate->EndDate = 0.0;
    else
      prodOff->EffectiveDate->EndDate = val;

    val = rowset->GetValue("te_n_endoffset");
    prodOff->EffectiveDate->EndOffset = val;

    //load AvailabilityDate

    val = rowset->GetValue("id_avail");
    prodOff->AvailabilityDate->ID = val;

    val = rowset->GetValue("ta_n_begintype");
    prodOff->AvailabilityDate->StartDateType = static_cast<MTPRODUCTCATALOGLib::MTPCDateType>(val.lVal);

    val = rowset->GetValue("ta_dt_start");
    if (V_VT(&val) == VT_NULL)
      prodOff->AvailabilityDate->StartDate = 0.0;
    else
      prodOff->AvailabilityDate->StartDate = val;

    val = rowset->GetValue("ta_n_beginoffset");
    prodOff->AvailabilityDate->StartOffset = val;

    val = rowset->GetValue("ta_n_endtype");
    prodOff->AvailabilityDate->EndDateType = static_cast<MTPRODUCTCATALOGLib::MTPCDateType>(val.lVal);

    val = rowset->GetValue("ta_dt_end");
    if (V_VT(&val) == VT_NULL)
      prodOff->AvailabilityDate->EndDate = 0.0;
    else
      prodOff->AvailabilityDate->EndDate = val;

    val = rowset->GetValue("ta_n_endoffset");
    prodOff->AvailabilityDate->EndOffset = val;

    //Run another query to populate subscribable account types
    MTPRODUCTCATALOGEXECLib::IMTProductOfferingReaderPtr ThisPtr = this;
    MTPRODUCTCATALOGEXECLib::IMTSQLRowsetPtr atrs = 
      ThisPtr->GetSubscribableAccountTypesAsRowset(NULL, prodOff->ID);
    while(atrs->GetRowsetEOF().boolVal == VARIANT_FALSE) 
    {
      _variant_t atname = atrs->GetValue("AccountTypeName");
      prodOff->SubscribableAccountTypes->Add(atname);
      atrs->MoveNext();
    }


    MTPRODUCTCATALOGLib::IMTRowSetPtr aTempRowset = rowset;
    MTPRODUCTCATALOGLib::IMTProductCatalogPtr(__uuidof(MTProductCatalog))
    ->GetMetaData(MTPRODUCTCATALOGLib::PCENTITY_TYPE_PRODUCT_OFFERING)->PopulateProperties(
    prodOff->GetProperties(),
    reinterpret_cast<MTPRODUCTCATALOGLib::IMTRowSet*>(aTempRowset.GetInterfacePtr()));
}


// ----------------------------------------------------------------
// Name:      
// Arguments:     
//                
// Return Value:  
// Errors Raised: 
// Description:   
// ----------------------------------------------------------------
_COM_SMARTPTR_TYPEDEF(IDispatch,__uuidof(IDispatch));

STDMETHODIMP CMTProductOfferingReader::FindAsRowset(IMTSessionContext* apCtxt, VARIANT aFilter, IMTSQLRowset **apRowset)
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
    MTPRODUCTCATALOGLib::IMTPropertyMetaDataSetPtr metaData = pc->GetMetaData(MTPRODUCTCATALOGLib::PCENTITY_TYPE_PRODUCT_OFFERING);

    _bstr_t filters = "";
    _variant_t vtFilter(aFilter);
    MTPRODUCTCATALOGLib::IMTDataFilterPtr aDataFilter = metaData->TranslateFilter(aFilter);

    /* this is the code to support SummaryView properties:

    BSTR pSelectList,pJoinList;
    metaData->GetPropertySQL("id_po", "t_po", VARIANT_TRUE, // VARIANT_TRUE means summary view properties only
                             &pSelectList, &pJoinList);

	try
	{
		if (!apCtxt)
			return E_POINTER;

		long languageID;
		HRESULT hr = apCtxt->get_LanguageID(&languageID);
		if (FAILED(hr))
			return hr;

		MTPRODUCTCATALOGLib::IMTProductCatalogPtr pc(__uuidof(MTProductCatalog));
		MTPRODUCTCATALOGLib::IMTPropertyMetaDataSetPtr metaData = pc->GetMetaData(MTPRODUCTCATALOGLib::PCENTITY_TYPE_PRODUCT_OFFERING);

		_bstr_t filters = "";
		_variant_t vtFilter(aFilter);
		MTPRODUCTCATALOGLib::IMTDataFilterPtr aDataFilter = metaData->TranslateFilter(aFilter);

		/* this is the code to support SummaryView properties:

		BSTR pSelectList,pJoinList;
		metaData->GetPropertySQL("id_po", "t_po", VARIANT_TRUE, // VARIANT_TRUE means summary view properties only
			                       &pSelectList, &pJoinList);

		// attach to BSTRs and OWN them (_bstr_t will deallocate memory)
		_bstr_t selectlist(pSelectList,false), joinlist(pJoinList,false);

		*/
		_bstr_t selectlist, joinlist; //delete this line when reenabling SummaryView properties

		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		rowset->SetQueryTag("GET_FILTERED_POS");
		rowset->AddParam("%%COLUMNS%%", selectlist);
		rowset->AddParam("%%JOINS%%", joinlist);
		rowset->AddParam("%%FILTERS%%", filters);
		rowset->AddParam(L"%%ID_LANG%%", languageID);
		rowset->Execute();

		// apply filter... XXX replace ADO filter with customized SQL
		// for better performance
		if(aDataFilter != NULL) {
			rowset->PutRefFilter(reinterpret_cast<ROWSETLib::IMTDataFilter*>(aDataFilter.GetInterfacePtr()));
		}

		*apRowset = reinterpret_cast<IMTSQLRowset*>(rowset.Detach());
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

  context.Complete();
  return S_OK;
}

// ----------------------------------------------------------------
// Name:  FindSubscribablePoByAccID     
// Arguments:    accountID,rowset
//                
// Return Value:  S_OK, E_FAIL
// Errors Raised: 
// Description:   Finds all of the the product offerings that the account
// can subscribe to.  The query basically disregards existing subscriptions,
// conflicting product offerings, and product offerings that are not currently
// available for subscription
// ----------------------------------------------------------------


STDMETHODIMP CMTProductOfferingReader::FindSubscribablePoByAccID(IMTSessionContext* apCtxt,
                                                                 long accID,
                                                                 VARIANT aRefDate,
                                                                 IMTSQLRowset **ppRowset)
{
  MTAutoContext context(mpObjectContext);

  try {
    if (!apCtxt)
      return E_POINTER;

    // Get the language ID off the session context so we can join to get nm_display_name correctly.
    // we do not want to use the nm_display_name that is on t_base_props
    long languageID;
    HRESULT hr = apCtxt->get_LanguageID(&languageID);
    if (FAILED(hr))
      return hr;

    BSTR pSelectList,pJoinList;
	_bstr_t sCURRENCYFILTER1, sCURRENCYFILTER2;
    sCURRENCYFILTER1=" pl1.nm_currency_code = tav.c_currency ";
    sCURRENCYFILTER2=" tmp.payercurrency = t_pricelist.nm_currency_code ";

      if(PCCache::IsBusinessRuleEnabled( PCCONFIGLib::MTPC_BUSINESS_RULE_ProdOff_AllowAccountPOCurrencyMismatch))
      {
        //If ProdOff_AllowAccountPOCurrencyMismatch business rule is enabled then set the currency filters accordingly
    
	  sCURRENCYFILTER1=" 1=1";
      sCURRENCYFILTER2=" 1=1";
      }

    
	MTPRODUCTCATALOGLib::IMTProductCatalogPtr aProductCatalog(__uuidof(MTProductCatalog));
    aProductCatalog->GetMetaData(MTPRODUCTCATALOGLib::PCENTITY_TYPE_PRODUCT_OFFERING)->
      GetPropertySQL("t_po.id_po", L"t_po",VARIANT_FALSE, &pSelectList,&pJoinList);

    // attach to BSTRs and OWN them (_bstr_t will deallocate memory)
    _bstr_t selectlist(pSelectList,false),joinlist(pJoinList,false);

    //set refdate
    _variant_t vtRefDate;
    wstring strRefDate;
    if(!OptionalVariantConversion(aRefDate,VT_DATE,vtRefDate))
    {
      vtRefDate = GetMTOLETime();
    }
    FormatValueForDB(vtRefDate,FALSE,strRefDate);

    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);
    rowset->SetQueryTag("__FIND_SUBSCRIBABLE_PO__");
    rowset->AddParam("%%ACC_ID%%",accID);
		rowset->AddParam("%%ID_LANG%%",languageID);
    rowset->AddParam("%%COLUMNS%%",selectlist);
    rowset->AddParam("%%JOINS%%",joinlist);
    rowset->AddParam("%%REFDATE%%",strRefDate.c_str(),VARIANT_TRUE);
    rowset->AddParam("%%CURRENCYFILTER1%%",sCURRENCYFILTER1);
    rowset->AddParam("%%CURRENCYFILTER2%%",sCURRENCYFILTER2);

    rowset->Execute();

    *ppRowset = reinterpret_cast<IMTSQLRowset*>(rowset.Detach()); 

  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}

STDMETHODIMP CMTProductOfferingReader::FindSubscribablePoByAccIDasCollection(IMTSessionContext* apCtxt,
                                                                             long accID,
                                                                             VARIANT aRefDate,
                                                                             IMTCollection **ppCol)
{
  ASSERT(ppCol);
  if(!ppCol) return E_POINTER;

  MTAutoContext context(mpObjectContext);
  MTObjectCollection<IMTProductOffering> coll;

  try {
    // step 1: Get a rowset full of all subscribable product offerings
    ROWSETLib::IMTSQLRowset* pRowset;
    if(SUCCEEDED(FindSubscribablePoByAccID(apCtxt, accID, aRefDate, reinterpret_cast<IMTSQLRowset**>(&pRowset)))) {
      // attach smart pointer
      ROWSETLib::IMTSQLRowsetPtr rowset(pRowset,false); // don't addref

      // step 2: iterate the list
      while(rowset->GetRowsetEOF().boolVal == VARIANT_FALSE) {
        
        // create product offering
        MTPRODUCTCATALOGLib::IMTProductOfferingPtr prodOff(__uuidof(MTProductOffering));
        prodOff->SetSessionContext(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(apCtxt));

        // get the product offering ID from the rowset
        long aProdOfferingID = rowset->GetValue("id_po");

        // step 3: populate the product offering
        PopulateByRowset(aProdOfferingID,rowset,prodOff);

        // step 4: add to the collection
        coll.Add( (IMTProductOffering*) prodOff.GetInterfacePtr());
        rowset->MoveNext();
      }
    }
    else {
      return Error("Failed to find subscribable product offerings");
    }
    // step 5: return the collection
    coll.CopyTo(ppCol);

  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }
  context.Complete();
  return S_OK;
}

STDMETHODIMP CMTProductOfferingReader::HasPriceableItemTemplate(IMTSessionContext* apCtxt, long aProdOffID, long aPrcItemTmplID, VARIANT_BOOL* apHasTmpl)
{
  MTAutoContext context(mpObjectContext);

  if (!apHasTmpl)
    return E_POINTER;

  //init out var
  *apHasTmpl = VARIANT_FALSE;

  try
  {
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);

    rowset->SetQueryTag("__FIND_PI_TEMPLATE_IN_PO__");
    rowset->AddParam("%%ID_PO%%", aProdOffID);
    rowset->AddParam("%%ID_TEMPL%%", aPrcItemTmplID);
    rowset->Execute();

    if((bool) rowset->GetRowsetEOF())
    {
      *apHasTmpl = VARIANT_FALSE;
    }
    else
    {
      *apHasTmpl = VARIANT_TRUE;
    }
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}

STDMETHODIMP CMTProductOfferingReader::GetCurrencyCode(IMTSessionContext* apCtxt, long aProdOffID, BSTR *apCurrency)
{
  MTAutoContext context(mpObjectContext);

  if (!apCurrency)
    return E_POINTER;

  try
  {
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);

    rowset->SetQueryTag("__GET_CURRENCY_OF_PO__");
    rowset->AddParam("%%ID_PO%%", aProdOffID);
    rowset->Execute();

    _bstr_t currency = ""; //if no row returned, return "" currency (meaning not yet determined)

    if (!rowset->GetRowsetEOF().boolVal)
    {
      if(PCCache::IsBusinessRuleEnabled( PCCONFIGLib::MTPC_BUSINESS_RULE_ProdOff_CheckCurrency ) && rowset->GetRecordCount() > 1)
      {
        //If more then one row returned, then this is an error if
        //MTPC_BUSINESS_RULE_ProdOff_CheckCurrency business rule is enabled:
        //Pricelists with different currencies were associated with this product offering.
        //This is a part of CR 5923 fix.
        context.Complete();
        MT_THROW_COM_ERROR(IID_IMTProductOfferingReader, MTPC_PRICELISTS_WITH_DIFFERENT_CURRENCIES,  aProdOffID);
      }
    
      currency = rowset->GetValue("nm_currency_code");
    }

    *apCurrency = currency.copy();
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}

STDMETHODIMP CMTProductOfferingReader::FindForPrcItemType(IMTSessionContext* apCtxt, long aPrcItemTypeID, IMTCollection **apProdOffs)
{
  MTAutoContext context(mpObjectContext);

  if (!apProdOffs)
    return E_POINTER;

  *apProdOffs = NULL;

  try
  {
    MTObjectCollection<IMTProductOffering> coll;
    
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);
    
    rowset->SetQueryTag("__GET_POS_FOR_PI_TYPE__");
    rowset->AddParam("%%ID_PI_TYPE%%", aPrcItemTypeID);
    rowset->Execute();

    // call CMTProductOfferingReader::Find() for each ID
    MTPRODUCTCATALOGEXECLib::IMTProductOfferingReaderPtr thisPtr = this;

    while(rowset->GetRowsetEOF().boolVal == VARIANT_FALSE)
    {
      long prodOffID = rowset->GetValue("id_po").lVal;

      MTPRODUCTCATALOGEXECLib::IMTProductOfferingPtr prodOff;
      prodOff = thisPtr ->Find((MTPRODUCTCATALOGEXECLib::IMTSessionContext *)apCtxt, prodOffID);

      coll.Add(reinterpret_cast<IMTProductOffering*>(prodOff.GetInterfacePtr()));
      rowset->MoveNext();
    }

    coll.CopyTo(apProdOffs);
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}

STDMETHODIMP CMTProductOfferingReader::FindAvailableProductOfferingsAsRowset(IMTSessionContext *apCTX,
                                                                             VARIANT aFilter,
                                                                             VARIANT aRefDate,
                                                                             IMTSQLRowset **ppRowset)
{
  MTAutoContext context(mpObjectContext);
  try {
    _variant_t vtRefDate;

    if(!OptionalVariantConversion(aRefDate,VT_DATE,vtRefDate)) {
      vtRefDate = GetMTOLETime();
    }
    long languageID;
    HRESULT hr = apCTX->get_LanguageID(&languageID);
    if (FAILED(hr))
      return hr;

    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);
    rowset->SetQueryTag("__FIND_AVAILABLE_PRODUCTOFFERINGS__");
    wstring dateStr;
    FormatValueForDB(vtRefDate,FALSE,dateStr);
    rowset->AddParam("%%REFDATE%%",dateStr.c_str(),VARIANT_TRUE);
    rowset->AddParam("%%ID_LANG%%",languageID);
    rowset->ExecuteDisconnected();
    *ppRowset = reinterpret_cast<IMTSQLRowset*>(rowset.Detach());
  }
  catch (_com_error & err) {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}
                                       
STDMETHODIMP CMTProductOfferingReader::FindAvailableProductOfferingsForGroupSubscriptionAsRowset(IMTSessionContext* apCTX,
                                                                                                 long corpAccID,
                                                                                                 VARIANT aFilter,
                                                                                                 VARIANT aRefDate,
                                                                                                 IMTSQLRowset** ppRowset)
{
  MTAutoContext context(mpObjectContext);
  try {
    _variant_t vtRefDate;

    if(!OptionalVariantConversion(aRefDate, VT_DATE, vtRefDate)) {
      vtRefDate = GetMTOLETime();
    }
    long languageID;
    HRESULT hr = apCTX->get_LanguageID(&languageID);
    if (FAILED(hr))
      return hr;

   	_bstr_t sCURRENCYFILTER3;
    sCURRENCYFILTER3=" tavi.c_currency = tpl.nm_currency_code ";

		if(PCCache::IsBusinessRuleEnabled( PCCONFIGLib::MTPC_BUSINESS_RULE_ProdOff_AllowAccountPOCurrencyMismatch))
      {
        //If ProdOff_AllowAccountPOCurrencyMismatch business rule is enabled then set the currency filters accordingly
    
	  sCURRENCYFILTER3=" 1=1 ";
      }

    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);
    rowset->SetQueryTag("__FIND_AVAILABLE_PRODUCTOFFERINGS_FOR_GROUPSUBSCRIPTION__");
    wstring dateStr;
    FormatValueForDB(vtRefDate, FALSE, dateStr);
    rowset->AddParam("%%REFDATE%%", dateStr.c_str(), VARIANT_TRUE);
    rowset->AddParam("%%ID_LANG%%", languageID);
    rowset->AddParam("%%CORPORATEACCOUNT%%", corpAccID);
    rowset->AddParam("%%CURRENCYFILTER3%%",sCURRENCYFILTER3);
    rowset->ExecuteDisconnected();
    *ppRowset = reinterpret_cast<IMTSQLRowset*>(rowset.Detach());
  }
  catch (_com_error & err){
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}
      

STDMETHODIMP CMTProductOfferingReader::GetConstrainedCycleType(IMTSessionContext* apCTX,
                                                               long poID,
                                                               MTUsageCycleType *pCycleType)
{
  MTAutoContext context(mpObjectContext);
  try {
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);
    rowset->SetQueryTag("__FIND_CONSTRAINED_CYCLE_TYPE__");
    rowset->AddParam("%%ID_PO%%",poID);
    rowset->Execute();
    if(rowset->GetRecordCount() > 0) {
      *pCycleType = static_cast<MTUsageCycleType>((long)rowset->GetValue("id_cycle_type"));
    }
    else {
      *pCycleType = NO_CYCLE;
    }
 
  }
  catch (_com_error & err) {
    return ReturnComError(err);
  }
  context.Complete();
  return S_OK;
}

STDMETHODIMP CMTProductOfferingReader::FindRecurringChargeWithUnitName(IMTSessionContext* apCtxt, 
																																			 long aProdOffID, 
																																			 BSTR aUnitName, 
																																			 BSTR* apChargeName)
{
  MTAutoContext context(mpObjectContext);
  try {
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);
    rowset->SetQueryTag("__FIND_UDRC_WITH_UNIT_NAME__");
    rowset->AddParam("%%ID_PO%%",aProdOffID);
    rowset->AddParam("%%NM_UNIT_NAME%%",aUnitName);
    rowset->Execute();
    if(rowset->GetRecordCount() > 0) {
      *apChargeName = _bstr_t(rowset->GetValue("nm_display_name")).copy();
    }
    else {
      *apChargeName = _bstr_t(L"").copy();
    }
 
  }
  catch (_com_error & err) {
    return ReturnComError(err);
  }
  context.Complete();
  return S_OK;
}

STDMETHODIMP CMTProductOfferingReader::GetNumberOfCycleRelativePrcItems(IMTSessionContext* apCtxt, 
																																				long poID, 
																																				long * apDiscounts,
																																				long * apAggregates,
																																				long * apRCs)
{
  MTAutoContext context(mpObjectContext);
	try
	{
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);
    rowset->SetQueryTag("__GET_NUMBER_OF_CYCLE_RELATIVE_PI__");
    rowset->AddParam("%%ID_PO%%",poID);
    rowset->Execute();
		if(rowset->GetRecordCount() > 0)
		{
			*apDiscounts = (long) rowset->GetValue(L"NumDiscounts");
			*apAggregates = (long) rowset->GetValue(L"NumAggregates");
			*apRCs = (long) rowset->GetValue(L"NumRCs");
		}
		else
		{
			*apDiscounts = 0;
			*apAggregates = 0;
			*apRCs = 0;
		}
	}
	catch (_com_error & err) 
	{
    return ReturnComError(err);
  }
  context.Complete();
	return S_OK;
}

STDMETHODIMP CMTProductOfferingReader::GetDiscountDistribution(IMTSessionContext* apCtxt, 
																															 long poID, 
																															 long * apNumDistributedDiscounts,
																															 long * apNumUndistributedDiscounts)
{
  MTAutoContext context(mpObjectContext);
	try
	{
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);
    rowset->SetQueryTag("__GET_DISCOUNT_DISTRIBUTION_COUNTS__");
    rowset->AddParam("%%ID_PO%%",poID);
    rowset->Execute();
		if(rowset->GetRecordCount() > 0)
		{
			*apNumDistributedDiscounts = (long) rowset->GetValue(L"NumDistributedDiscounts");
			*apNumUndistributedDiscounts = (long) rowset->GetValue(L"NumUndistributedDiscounts");
		}
		else
		{
			*apNumDistributedDiscounts = 0;
			*apNumUndistributedDiscounts = 0;
		}
	}
	catch (_com_error & err) 
	{
    return ReturnComError(err);
  }
  context.Complete();
	return S_OK;
}

STDMETHODIMP CMTProductOfferingReader::GetSubscribableAccountTypesAsRowset(IMTSessionContext* apCtxt,
                                                                           long poID,
                                                                           IMTSQLRowset **apRowset)
{
  MTAutoContext context(mpObjectContext);
	try
	{
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);
    rowset->SetQueryTag("__GET_SUBSCRIBABLE_ACCOUNT_TYPES__");
    rowset->AddParam("%%ID_PO%%",poID);
    rowset->Execute();
		*apRowset = reinterpret_cast<IMTSQLRowset*>(rowset.Detach());
		
	}
	catch (_com_error & err) 
	{
    return ReturnComError(err);
  }
  context.Complete();
	return S_OK;
}

