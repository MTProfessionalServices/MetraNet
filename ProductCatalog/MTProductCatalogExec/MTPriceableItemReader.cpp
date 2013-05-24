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
* $Header: MTPriceableItemReader.cpp, 47, 11/20/2002 5:01:03 PM, Boris$
* 
***************************************************************************/

#include "StdAfx.h"

#include "MTProductCatalogExec.h"
#include "MTPriceableItemReader.h"
#include "pcexecincludes.h"
#import <MetraTech.Pipeline.tlb> inject_statement("using namespace mscorlib; using ROWSETLib::IMTSQLRowsetPtr; using ROWSETLib::IMTSQLRowset;") no_function_mapping
#import <MetraTech.Localization.tlb> inject_statement("using namespace mscorlib;") no_function_mapping
#import <MetraTech.Adjustments.tlb> inject_statement("using namespace mscorlib; using namespace MetraTech_Pipeline; using namespace MetraTech_Localization;")//rename ("EOF", "RowsetEOF") no_function_mapping



/////////////////////////////////////////////////////////////////////////////
// CMTPriceableItemReader

STDMETHODIMP CMTPriceableItemReader::InterfaceSupportsErrorInfo(REFIID riid)
{
  static const IID* arr[] = 
  {
    &IID_IMTPriceableItemReader
  };
  for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
  {
    if (InlineIsEqualGUID(*arr[i],riid))
      return S_OK;
  }
  return S_FALSE;
}

CMTPriceableItemReader::CMTPriceableItemReader()
{
  mpObjectContext = NULL;
}


HRESULT CMTPriceableItemReader::Activate()
{
  HRESULT hr = GetObjectContext(&mpObjectContext);
  if (SUCCEEDED(hr))
    return S_OK;
  return hr;
} 

BOOL CMTPriceableItemReader::CanBePooled()
{
  return FALSE;
} 

void CMTPriceableItemReader::Deactivate()
{
  mpObjectContext.Release();
} 

// returns the PI template or PI instance with given ID
STDMETHODIMP CMTPriceableItemReader::Find(IMTSessionContext* apCtxt, long aID, IMTPriceableItem **apPrcItem)
{
  MTAutoContext context(mpObjectContext);

  if (!apPrcItem)
    return E_POINTER;

  //init out var
  *apPrcItem = NULL;

  HRESULT hr = S_OK;
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

    rowset->SetQueryTag("__GET_PI_TMPL_OR_INST__");
    rowset->AddParam("%%ID_PI%%", aID);
    rowset->AddParam("%%ID_LANG%%", languageID);
    rowset->Execute();

    //test if found
    if(rowset->GetRowsetEOF().boolVal == VARIANT_TRUE)
      MT_THROW_COM_ERROR(IID_IMTPriceableItemReader, MTPC_ITEM_NOT_FOUND_BY_ID, 0, aID);

    PopulatePriceableItem(apCtxt, rowset, apPrcItem);

  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}

// returns the PI template with given name
STDMETHODIMP CMTPriceableItemReader::FindTemplateByName(IMTSessionContext* apCtxt, BSTR aName, IMTPriceableItem **apPI)
{
  MTAutoContext context(mpObjectContext);

  if (!apPI)
    return E_POINTER;

  //init out var
  *apPI = NULL;

  HRESULT hr = S_OK;
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

    rowset->SetQueryTag("__GET_PI_TMPL_BY_NAME__");
    rowset->AddParam("%%NAME%%", aName);
    rowset->AddParam("%%ID_LANG%%", languageID);
    rowset->Execute();

    //if item not found just return NULL
    if(rowset->GetRowsetEOF().boolVal == VARIANT_FALSE)
      PopulatePriceableItem(apCtxt, rowset, apPI);
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}

STDMETHODIMP CMTPriceableItemReader::FindInstanceByName(IMTSessionContext* apCtxt, BSTR aName, long aProductOfferingID, IMTPriceableItem ** apPrcItem)
{
  MTAutoContext context(mpObjectContext);

  if (!apPrcItem)
    return E_POINTER;

  //init out var
  *apPrcItem = NULL;

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

    rowset->SetQueryTag("__GET_PI_INST_BY_NAME__");
    rowset->AddParam("%%NAME%%", aName);
    rowset->AddParam("%%ID_PO%%", aProductOfferingID);
    rowset->AddParam("%%ID_LANG%%", languageID);
    rowset->Execute();

    //if item not found just return NULL
    if(rowset->GetRowsetEOF().boolVal == VARIANT_FALSE)
      PopulatePriceableItem(apCtxt, rowset, apPrcItem);
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}


void CMTPriceableItemReader::PopulatePriceableItem(IMTSessionContext* apCtxt, ROWSETLib::IMTSQLRowsetPtr rowset, IMTPriceableItem * * apPI)
{
  //determine kind
  _variant_t val;
  val = rowset->GetValue("n_kind");
  MTPCEntityType kind = static_cast<MTPCEntityType>((long)val);

  //construct the appropriate kind
  CLSID clsid;
  switch(kind)
  {	case PCENTITY_TYPE_USAGE:
  clsid = __uuidof(MTUsageCharge);
  break;
  case PCENTITY_TYPE_RECURRING:
  case PCENTITY_TYPE_RECURRING_UNIT_DEPENDENT:
    clsid = __uuidof(MTRecurringCharge);
    break;
  case PCENTITY_TYPE_NON_RECURRING:
    clsid = __uuidof(MTNonRecurringCharge);
    break;
  case PCENTITY_TYPE_DISCOUNT:
    clsid = __uuidof(MTDiscount);
    break;
  case PCENTITY_TYPE_AGGREGATE_CHARGE:
    clsid = __uuidof(MTAggregateCharge);
    break;
  default:
    MT_THROW_COM_ERROR(IID_IMTPriceableItemReader, MTPC_INVALID_PRICEABLE_ITEM_KIND, kind);
  }

  MTPRODUCTCATALOGLib::IMTPriceableItemPtr prcItem(clsid);

  //set the session context (every product catalog object needs one)
  prcItem->SetSessionContext(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(apCtxt));

  //set base props
  val = rowset->GetValue("id_prop");
  prcItem->ID = (long)val;

  //TODO!! use ID to string
  val = rowset->GetValue("nm_name");
  prcItem->Name = MTMiscUtil::GetString(val);

  val = rowset->GetValue("nm_display_name");
  prcItem->DisplayName = MTMiscUtil::GetString(val);

  val = rowset->GetValue("n_display_name");
  MetraTech_Localization::ILocalizedEntityPtr displayNameLocalizationPtr(prcItem->DisplayNames);
  displayNameLocalizationPtr->ID=val;

  val = rowset->GetValue("n_desc");
  MetraTech_Localization::ILocalizedEntityPtr displayDescLocalizationPtr(prcItem->DisplayDescriptions);
  displayDescLocalizationPtr->ID=val;

  val = rowset->GetValue("nm_desc");
  prcItem->Description = MTMiscUtil::GetString(val);

  val = rowset->GetValue("id_pi_type");
  long idPrcItemType = (long)val;

  val = rowset->GetValue("id_pi_parent");
  if (val.vt != VT_NULL)
    prcItem->ParentID = (long)val;

  val = rowset->GetValue("id_pi_template");
  if (val.vt != VT_NULL)
    prcItem->TemplateID = (long)val;

  val = rowset->GetValue("id_po");
  if (val.vt != VT_NULL)
    prcItem->ProductOfferingID = (long)val;

  // load extended properties
  // unfortunately, this has to be done in a separate query from the one
  // that determines the kind, 
  // since the kind specifies which meta data to use
  LoadExtendedProperties(reinterpret_cast<IMTPriceableItem*>(prcItem.GetInterfacePtr()));


  //load the type object
  MTPRODUCTCATALOGEXECLib::IMTPriceableItemTypeReaderPtr typeReader(__uuidof(MTPriceableItemTypeReader));
  MTPRODUCTCATALOGEXECLib::IMTPriceableItemTypePtr prcItemType;

  prcItemType = typeReader->Find(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), idPrcItemType);

  prcItem->PriceableItemType = reinterpret_cast<MTPRODUCTCATALOGLib::IMTPriceableItemType*>(prcItemType.GetInterfacePtr());


  //TODO: find adjustment templates or instances for this PI
  MetraTech_Adjustments::IAdjustmentReaderPtr adjReaderPtr(__uuidof(MetraTech_Adjustments::AdjustmentReader));
	prcItem->SetAdjustments(reinterpret_cast<MTPRODUCTCATALOGLib::IMTCollection*>(adjReaderPtr->GetAdjustments
    (
      reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(apCtxt),
      reinterpret_cast<MTPRODUCTCATALOGLib::IMTPriceableItem*>(prcItem.GetInterfacePtr())).GetInterfacePtr())
     );

  // call priceable-item-type-specific readers to populate extra properties
  switch(long(prcItem->Kind))
  {
  case PCENTITY_TYPE_NON_RECURRING:
    {
      MTPRODUCTCATALOGEXECLib::IMTNonRecurringChargeReaderPtr Reader( __uuidof(MTPRODUCTCATALOGEXECLib::MTNonRecurringChargeReader));
      MTPRODUCTCATALOGEXECLib::IMTNonRecurringChargePtr item(prcItem);
      Reader->PopulateNRCProperties(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), item.GetInterfacePtr());
    }
    break;
  case PCENTITY_TYPE_DISCOUNT:
    {
      MTPRODUCTCATALOGEXECLib::IMTDiscountReaderPtr Reader( __uuidof(MTPRODUCTCATALOGEXECLib::MTDiscountReader));
      MTPRODUCTCATALOGEXECLib::IMTDiscountPtr item(prcItem);
      Reader->PopulateDiscountProperties(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), item.GetInterfacePtr());
    }
    break;
  case PCENTITY_TYPE_RECURRING:
  case PCENTITY_TYPE_RECURRING_UNIT_DEPENDENT:
    {
      MTPRODUCTCATALOGEXECLib::IMTRecurringChargeReaderPtr Reader( __uuidof(MTPRODUCTCATALOGEXECLib::MTRecurringChargeReader));
      MTPRODUCTCATALOGEXECLib::IMTRecurringChargePtr item(prcItem);
      Reader->PopulateProperties(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), item.GetInterfacePtr());
    }
    break;
  case PCENTITY_TYPE_AGGREGATE_CHARGE:
    {
      MTPRODUCTCATALOGEXECLib::IMTAggregateChargeReaderPtr Reader( __uuidof(MTPRODUCTCATALOGEXECLib::MTAggregateChargeReader));
      MTPRODUCTCATALOGEXECLib::IMTAggregateChargePtr item(prcItem);
      Reader->Populate(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), item.GetInterfacePtr());
    }
    break;
  default:
    ;
  }

  *apPI = reinterpret_cast<IMTPriceableItem *>(prcItem.Detach());
}

// load extended properties of apPrcItem 
// uses the ID of apPrcItem and fills in the extended properties
// throws com_errors on error
void CMTPriceableItemReader::LoadExtendedProperties(IMTPriceableItem* apPrcItem)
{
  MTPRODUCTCATALOGLib::IMTPriceableItemPtr prcItem = apPrcItem;

  BSTR pSelectList,pJoinList;
  MTPRODUCTCATALOGLib::IMTProductCatalogPtr productCatalog(__uuidof(MTProductCatalog));
  MTPRODUCTCATALOGLib::IMTPropertyMetaDataSetPtr metaData = productCatalog->GetMetaData(prcItem->Kind);

  metaData->GetPropertySQL(prcItem->ID, L"t_base_props", VARIANT_FALSE, // VARIANT_FALSE means all extended properties
    &pSelectList,&pJoinList);

  // attach to BSTRs and OWN them (_bstr_t will deallocate memory)
  _bstr_t selectlist(pSelectList,false),joinlist(pJoinList,false);

  if (selectlist.length() == 0)
    // if there is nothing to select, do nothing
    return;

  ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
  rowset->Init(CONFIG_DIR);

  rowset->SetQueryTag("__GET_EXTENDED_PROPERTIES__");
  rowset->AddParam("%%ID_PROP%%", prcItem->ID);
  rowset->AddParam("%%EXTENDED_SELECT%%",selectlist);
  rowset->AddParam("%%EXTENDED_JOIN%%",pJoinList);
  rowset->Execute();

  if(rowset->GetRowsetEOF().boolVal == VARIANT_FALSE)
  {
    metaData->PopulateProperties(	prcItem->GetProperties(), 
      reinterpret_cast< MTPRODUCTCATALOGLib::IMTRowSet *>(rowset.GetInterfacePtr()) );
  }
}




STDMETHODIMP CMTPriceableItemReader::FindTemplatesAsRowset(IMTSessionContext* apCtxt, VARIANT aFilter, ::IMTSQLRowset **apRowset)
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


    _bstr_t filters;

    // TODO: check filter for kind and pick correct entity type!!
    MTPRODUCTCATALOGLib::IMTProductCatalogPtr pc(__uuidof(MTProductCatalog));
    MTPRODUCTCATALOGLib::IMTDataFilterPtr aDataFilter = 
      pc->GetMetaData(MTPRODUCTCATALOGLib::PCENTITY_TYPE_USAGE)->TranslateFilter(aFilter);

    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);

    rowset->SetQueryTag("__GET_FILTERED_PI_TEMPLATES__");
    rowset->AddParam("%%COLUMNS%%", ""); //todo!!
    rowset->AddParam("%%JOINS%%", ""); //todo!!
    rowset->AddParam("%%FILTERS%%", filters);
    rowset->AddParam("%%ID_LANG%%", languageID);
    rowset->Execute();

    // apply filter... XXX replace ADO filter with customized SQL
    // for better performance
    if(aDataFilter != NULL) {
      rowset->PutRefFilter(reinterpret_cast<ROWSETLib::IMTDataFilter*>(aDataFilter.GetInterfacePtr()));
    }

    *apRowset = reinterpret_cast<::IMTSQLRowset*>(rowset.Detach());
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}

STDMETHODIMP CMTPriceableItemReader::FindInstances(IMTSessionContext* apCtxt, long aProdOffID, IMTCollection **apPrcItemInstances)
{
  MTAutoContext context(mpObjectContext);

  if (!apPrcItemInstances)
    return E_POINTER;

  *apPrcItemInstances = NULL;

  try
  {
    MTObjectCollection<IMTPriceableItem> coll;

    if (!apCtxt)
      return E_POINTER;

    long languageID;
    HRESULT hr = apCtxt->get_LanguageID(&languageID);
    if (FAILED(hr))
      return hr;

    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);

    rowset->SetQueryTag("__GET_PI_INSTANCES_ON_PO__");
    rowset->AddParam("%%ID_PO%%", aProdOffID);
    rowset->AddParam("%%ID_LANG%%", languageID);
    rowset->Execute();

    // call CMTPriceableItemReader::Find() for each ID
    // If performance is critical, we can do one of these solutions:
    // (A) modify initial query to return all fields of a priceable item and populate PI from one row
    // (B) only fill in ID of priceable item and load other properties on demand


    while(rowset->GetRowsetEOF().boolVal == VARIANT_FALSE)
    {
      _variant_t val;
      val = rowset->GetValue("id_prop");
      long prcItemID = val.lVal;

      IMTPriceableItem* prcItem = NULL;
      HRESULT hr = Find(apCtxt, prcItemID, &prcItem);
      if(FAILED(hr))
        return hr;

      coll.Add( prcItem );
      prcItem->Release();
      rowset->MoveNext();
    }

    coll.CopyTo(apPrcItemInstances);
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}


STDMETHODIMP CMTPriceableItemReader::FindInstancesAsRowset(IMTSessionContext* apCtxt, long aProdOffID, ::IMTSQLRowset **apRowset)
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

    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);

    rowset->SetQueryTag("__GET_PI_INSTANCES_ON_PO__");
    rowset->AddParam("%%ID_PO%%", aProdOffID);
    rowset->AddParam("%%ID_LANG%%", languageID);
    rowset->Execute();

    *apRowset = reinterpret_cast<::IMTSQLRowset*>(rowset.Detach());
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}

STDMETHODIMP CMTPriceableItemReader::FindInstancesOfType(IMTSessionContext* apCtxt, long aProdOffID, long aPITypeID, IMTCollection **apPrcItemInstances)
{
  MTAutoContext context(mpObjectContext);

  if (!apPrcItemInstances)
    return E_POINTER;

  *apPrcItemInstances = NULL;

  try
  {
    MTObjectCollection<IMTPriceableItem> coll;

    if (!apCtxt)
      return E_POINTER;

    long languageID;
    HRESULT hr = apCtxt->get_LanguageID(&languageID);
    if (FAILED(hr))
      return hr;

    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);

    rowset->SetQueryTag("__GET_PI_INSTANCES_ON_PO_OF_TYPE__");
    rowset->AddParam("%%ID_PO%%", aProdOffID);
    rowset->AddParam("%%ID_LANG%%", languageID);
    rowset->AddParam("%%ID_PI%%", aPITypeID);
    rowset->Execute();

    // call CMTPriceableItemReader::Find() for each ID
    // If performance is critical, we can do one of these solutions:
    // (A) modify initial query to return all fields of a priceable item and populate PI from one row
    // (B) only fill in ID of priceable item and load other properties on demand


    while(rowset->GetRowsetEOF().boolVal == VARIANT_FALSE)
    {
      _variant_t val;
      val = rowset->GetValue("id_prop");
      long prcItemID = val.lVal;

      IMTPriceableItem* prcItem = NULL;
      HRESULT hr = Find(apCtxt, prcItemID, &prcItem);
      if(FAILED(hr))
        return hr;

      coll.Add( prcItem );
      prcItem->Release();
      rowset->MoveNext();
    }

    coll.CopyTo(apPrcItemInstances);
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}

STDMETHODIMP CMTPriceableItemReader::FindPriceListMappingsAsRowset(IMTSessionContext* apCtxt, long aPrcItemInstanceID, VARIANT_BOOL aIncludeICB, ::IMTSQLRowset **apRowset)
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

    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);

    if (aIncludeICB == VARIANT_TRUE)
      rowset->SetQueryTag("__GET_PRC_LST_MAPPINGS__");
    else
      rowset->SetQueryTag("__GET_NON_ICB_PRC_LST_MAPPINGS__");

    rowset->AddParam("%%ID_PI%%", aPrcItemInstanceID);
    rowset->AddParam("%%ID_LANG%%", languageID);
    rowset->Execute();

    *apRowset = reinterpret_cast<::IMTSQLRowset*>(rowset.Detach());
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}

STDMETHODIMP CMTPriceableItemReader::FindChildTemplates(IMTSessionContext* apCtxt, long aPrcItemTmplID, IMTCollection **apChildTemplates)
{
  MTAutoContext context(mpObjectContext);

  if (!apChildTemplates)
    return E_POINTER;

  *apChildTemplates = NULL; //init out var

  try
  {
    MTObjectCollection<IMTPriceableItem> coll;

    if (!apCtxt)
      return E_POINTER;

    long languageID;
    HRESULT hr = apCtxt->get_LanguageID(&languageID);
    if (FAILED(hr))
      return hr;

    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);

    rowset->SetQueryTag("__GET_PI_TMPL_CHILDREN__");
    rowset->AddParam("%%ID_PARENT%%", aPrcItemTmplID);
    rowset->AddParam("%%ID_LANG%%", languageID);
    rowset->Execute();

    // the objects are loaded one by one
    // not the most efficient but more maintanable
    // - this can be changed if it turns out to be performance critical

    MTPRODUCTCATALOGLib::IMTPriceableItemPtr childTmpl;
    MTPRODUCTCATALOGEXECLib::IMTPriceableItemReaderPtr reader = this;

    while(rowset->GetRowsetEOF().boolVal == VARIANT_FALSE)
    {
      _variant_t val;
      val = rowset->GetValue("id_template");
      long childID = val.lVal;

      childTmpl = reader->Find(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), childID);

      coll.Add( reinterpret_cast<IMTPriceableItem*>( childTmpl.GetInterfacePtr() ) );
      rowset->MoveNext();
    }

    coll.CopyTo(apChildTemplates);
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}

STDMETHODIMP CMTPriceableItemReader::FindChildTemplatesAsRowset(IMTSessionContext* apCtxt, long aPrcItemTmplID, ::IMTSQLRowset **apRowset)
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

    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);

    rowset->SetQueryTag("__GET_PI_TMPL_CHILDREN__");
    rowset->AddParam("%%ID_PARENT%%", aPrcItemTmplID);
    rowset->AddParam("%%ID_LANG%%", languageID);
    rowset->Execute();

    *apRowset = reinterpret_cast<::IMTSQLRowset*>(rowset.Detach());
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}


STDMETHODIMP CMTPriceableItemReader::FindChildInstances(IMTSessionContext* apCtxt, long aPrcItemInstID, IMTCollection **apChildInstances)
{
  MTAutoContext context(mpObjectContext);

  if (!apChildInstances)
    return E_POINTER;

  *apChildInstances = NULL; //init out var

  try
  {
    if (!apCtxt)
      return E_POINTER;

    long languageID;
    HRESULT hr = apCtxt->get_LanguageID(&languageID);
    if (FAILED(hr))
      return hr;

    MTObjectCollection<IMTPriceableItem> coll;

    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);

    rowset->SetQueryTag("__GET_PI_INST_CHILDREN__");
    rowset->AddParam("%%ID_PARENT%%", aPrcItemInstID);
    rowset->AddParam("%%ID_LANG%%", languageID);
    rowset->Execute();

    // the objects are loaded one by one
    // not the most efficient but more maintanable
    // - this can be changed if it turns out to be performance critical

    MTPRODUCTCATALOGLib::IMTPriceableItemPtr childInst;
    MTPRODUCTCATALOGEXECLib::IMTPriceableItemReaderPtr reader = this;

    while(rowset->GetRowsetEOF().boolVal == VARIANT_FALSE)
    {
      _variant_t val;
      val = rowset->GetValue("id_pi_instance");
      long childID = val.lVal;

      childInst = reader->Find(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), childID);

      coll.Add( reinterpret_cast<IMTPriceableItem*>( childInst.GetInterfacePtr() ) );
      rowset->MoveNext();
    }

    coll.CopyTo(apChildInstances);
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}

STDMETHODIMP CMTPriceableItemReader::FindChildInstancesAsRowset(IMTSessionContext* apCtxt, long aPrcItemInstID, ::IMTSQLRowset **apRowset)
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

    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);

    rowset->SetQueryTag("__GET_PI_INST_CHILDREN__");
    rowset->AddParam("%%ID_PARENT%%", aPrcItemInstID);
    rowset->AddParam("%%ID_LANG%%", languageID);
    rowset->Execute();

    *apRowset = reinterpret_cast<::IMTSQLRowset*>(rowset.Detach());
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}

STDMETHODIMP CMTPriceableItemReader::FindChild(IMTSessionContext* apCtxt, long aParentID, long aChildID, IMTPriceableItem **apPrcItem)
{
  MTAutoContext context(mpObjectContext);

  if (!apPrcItem)
    return E_POINTER;

  //init out var
  *apPrcItem = NULL;

  HRESULT hr = S_OK;
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

    rowset->SetQueryTag("__GET_PI_CHILD_TMPL_OR_INST__");
    rowset->AddParam("%%ID_PARENT%%", aParentID);
    rowset->AddParam("%%ID_CHILD%%", aChildID);
    rowset->AddParam("%%ID_LANG%%", languageID);
    rowset->Execute();

    //test if found
    if(rowset->GetRowsetEOF().boolVal == VARIANT_TRUE)
      MT_THROW_COM_ERROR(IID_IMTPriceableItemReader, MTPC_ITEM_NOT_FOUND);

    PopulatePriceableItem(apCtxt, rowset, apPrcItem);
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}

STDMETHODIMP CMTPriceableItemReader::FindInstancesOfTemplate(IMTSessionContext* apCtxt, long aPITemplateID, IMTCollection **apInstances)
{
  MTAutoContext context(mpObjectContext);

  if (!apInstances)
    return E_POINTER;

  *apInstances = NULL;

  try
  {
    if (!apCtxt)
      return E_POINTER;

    long languageID;
    HRESULT hr = apCtxt->get_LanguageID(&languageID);
    if (FAILED(hr))
      return hr;

    MTObjectCollection<IMTPriceableItem> coll;

    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);

    rowset->SetQueryTag("__GET_PI_INSTANCES_ON_PI_TEMPLATE__");
    rowset->AddParam("%%ID_PI_TEMPLATE%%", aPITemplateID);
    rowset->AddParam(L"%%ID_LANG%%", languageID);
    rowset->Execute();

    // call CMTPriceableItemReader::Find() for each ID
    // If performance is critical, we can do one of these solutions:
    // (A) modify initial query to return all fields of a priceable item and populate PI from one row
    // (B) only fill in ID of priceable item and load other properties on demand

    while(rowset->GetRowsetEOF().boolVal == VARIANT_FALSE)
    {
      _variant_t val;
      val = rowset->GetValue("id_prop");
      long prcItemID = val.lVal;

      IMTPriceableItem* prcItem = NULL;
      HRESULT hr = Find(apCtxt, prcItemID, &prcItem);
      if(FAILED(hr))
        return hr;

      coll.Add( prcItem );
      prcItem->Release();
      rowset->MoveNext();
    }

    coll.CopyTo(apInstances);
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}

STDMETHODIMP CMTPriceableItemReader::FindTemplateByInstanceAsRowset(IMTSessionContext* apCtxt, long aPrcItemInstID, ::IMTSQLRowset **apRowset)
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

    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);

    rowset->SetQueryTag("__GET_PI_TEMPLATE_OF_PI_INSTANCE__");
    rowset->AddParam("%%ID_PI_INSTANCE%%", aPrcItemInstID);
    rowset->AddParam("%%ID_LANG%%", languageID);
    rowset->Execute();

    *apRowset = reinterpret_cast<::IMTSQLRowset*>(rowset.Detach());
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}

