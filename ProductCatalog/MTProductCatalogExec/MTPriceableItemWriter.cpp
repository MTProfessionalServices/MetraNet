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
#include "MTPriceableItemWriter.h"
#include "pcexecincludes.h"
#import <MetraTech.Pipeline.tlb> inject_statement("using namespace mscorlib; using ROWSETLib::IMTSQLRowsetPtr; using ROWSETLib::IMTSQLRowset;") no_function_mapping
#import <MetraTech.Localization.tlb> inject_statement("using namespace mscorlib;") no_function_mapping
#import <MetraTech.Adjustments.tlb> inject_statement("using namespace mscorlib; using namespace MetraTech_Pipeline; using namespace MetraTech_Localization;")//rename ("EOF", "RowsetEOF") no_function_mapping


/////////////////////////////////////////////////////////////////////////////
// CMTPriceableItemWriter

/******************************************* error interface ***/
STDMETHODIMP CMTPriceableItemWriter::InterfaceSupportsErrorInfo(REFIID riid)
{
  static const IID* arr[] = 
  {
    &IID_IMTPriceableItemWriter
  };
  for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
  {
    if (::InlineIsEqualGUID(*arr[i],riid))
      return S_OK;
  }
  return S_FALSE;
}

CMTPriceableItemWriter::CMTPriceableItemWriter()
{
  mpObjectContext = NULL;
}

HRESULT CMTPriceableItemWriter::Activate()
{
  HRESULT hr = GetObjectContext(&mpObjectContext);
  if (SUCCEEDED(hr))
    return S_OK;
  return hr;
} 

BOOL CMTPriceableItemWriter::CanBePooled()
{
  return FALSE;
} 

void CMTPriceableItemWriter::Deactivate()
{
  mpObjectContext.Release();
} 


STDMETHODIMP CMTPriceableItemWriter::CreateTemplate(IMTSessionContext* apCtxt, IMTPriceableItem *apPrcItemTmpl, long *apID)
{
  MTAutoContext context(mpObjectContext);

  if (!apPrcItemTmpl || !apID)
    return E_POINTER;

  //init out var
  *apID = 0;
  
  try
  {
    _variant_t vtParam;

    MTPRODUCTCATALOGLib::IMTPriceableItemPtr prcItem = apPrcItemTmpl; //use comptr for convenience

    //check for existing name
    VerifyName(apCtxt, apPrcItemTmpl);


    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);
    
    //insert into base prop
    MTPRODUCTCATALOGEXECLib::IMTBasePropsWriterPtr baseWriter(__uuidof(MTBasePropsWriter));
    long idProp = baseWriter->CreateWithDisplayName( reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt),
                                                      (long)prcItem->Kind,
                                                      prcItem->Name,
                                                      prcItem->Description,
                                                      prcItem->DisplayName);

    //set ID in prcItem, since it will be used in writers of derived classes
    prcItem->ID = idProp;

    //get the type
    MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr prcItemType;
    prcItemType = prcItem->PriceableItemType;

    //insert into t_pi_template
    rowset->SetQueryTag("__ADD_PI_TMPL__");
    rowset->AddParam("%%ID_TMPL%%", idProp);
    
    long parentID = prcItem->ParentID;
    if (parentID == PROPERTIES_BASE_NO_ID)    
      vtParam = "NULL";
    else
      vtParam = parentID;
    rowset->AddParam("%%ID_TMPL_PARENT%%", vtParam);
    rowset->AddParam("%%ID_PI%%", prcItemType->ID);

    rowset->Execute();

    // call priceable-item-type-specific writers to create extra properties
    switch(long(prcItem->Kind))
    {
    case PCENTITY_TYPE_NON_RECURRING:
      {
        MTPRODUCTCATALOGEXECLib::IMTNonRecurringChargeWriterPtr writer( __uuidof(MTPRODUCTCATALOGEXECLib::MTNonRecurringChargeWriter));
        MTPRODUCTCATALOGEXECLib::IMTNonRecurringChargePtr item(prcItem);
        writer->CreateProperties(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), item.GetInterfacePtr());
      }
      break;
    case PCENTITY_TYPE_DISCOUNT:
      {
        MTPRODUCTCATALOGEXECLib::IMTDiscountWriterPtr writer( __uuidof(MTPRODUCTCATALOGEXECLib::MTDiscountWriter));
        MTPRODUCTCATALOGEXECLib::IMTDiscountPtr item(prcItem);
        writer->CreateDiscountProperties(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), item.GetInterfacePtr());
      }
      break;
    case PCENTITY_TYPE_RECURRING:
    case PCENTITY_TYPE_RECURRING_UNIT_DEPENDENT:
      {
        MTPRODUCTCATALOGEXECLib::IMTRecurringChargeWriterPtr writer( __uuidof(MTPRODUCTCATALOGEXECLib::MTRecurringChargeWriter));
        MTPRODUCTCATALOGEXECLib::IMTRecurringChargePtr item(prcItem);
        writer->CreateProperties(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), item.GetInterfacePtr());
      }
      break;
    case PCENTITY_TYPE_AGGREGATE_CHARGE:
      {
        MTPRODUCTCATALOGEXECLib::IMTAggregateChargeWriterPtr writer( __uuidof(MTPRODUCTCATALOGEXECLib::MTAggregateChargeWriter));
        MTPRODUCTCATALOGEXECLib::IMTAggregateChargePtr item(prcItem);
        writer->Create(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), item.GetInterfacePtr());
      }
      break;
    default:
      ;
    }

    // save extended properties of this priceable item
    MTPRODUCTCATALOGLib::IMTProductCatalogPtr productCatalog(__uuidof(MTProductCatalog));
    MTPRODUCTCATALOGLib::IMTPropertyMetaDataSetPtr metaData = productCatalog->GetMetaData(prcItem->Kind);
    metaData->UpsertExtendedProperties(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(apCtxt), prcItem->GetProperties(), VARIANT_FALSE);

    if (prcItem->CreateChildren)
    {
      //recursively create child templates for all children of type
      CreateChildTemplates( reinterpret_cast<IMTPriceableItem*> (prcItem.GetInterfacePtr()) );
    }

    //Create adjustment templates
    MetraTech_Adjustments::IAdjustmentWriterPtr ajwriter(__uuidof(MetraTech_Adjustments::AdjustmentWriter));
    GENERICCOLLECTIONLib::IMTCollectionPtr adjustments = prcItem->GetAdjustments();
    long numaj = adjustments->GetCount();
    for (int i = 1; i <= numaj; i++)
    {
      MetraTech_Adjustments::IAdjustmentPtr ajPtr = adjustments->GetItem(i);
	  
	  ajPtr->PriceableItem = prcItem;

			ajwriter->Create((MTPRODUCTCATALOGLib::IMTSessionContext*)apCtxt, ajPtr);
    }

    //Localized Display Names
    rowset->SetQueryTag("__GET_DISPLAYNAME_DESC_ID_FOR_PC_ITEM__");

    vtParam = idProp;
    rowset->AddParam("%%ID_PROP%%",vtParam);

    rowset->Execute();
    if((long)rowset->GetValue(L"n_display_name") > 0)
    {
	    MetraTech_Localization::ILocalizedEntityPtr displayNameLocalizationPtr(prcItem->DisplayNames);
      displayNameLocalizationPtr->SaveWithID((long)rowset->GetValue(L"n_display_name"));
    }
    else
    {
      //Error
    }

    if((long)rowset->GetValue(L"n_desc") > 0)
    {
	    MetraTech_Localization::ILocalizedEntityPtr displayDescLocalizationPtr(prcItem->DisplayDescriptions);
      displayDescLocalizationPtr->SaveWithID((long)rowset->GetValue(L"n_desc"));
    }
    else
    {
      //Error
    }

    MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr pContext(apCtxt);
    PCCache::GetAuditor()->FireEvent(1200,pContext->AccountID,2,prcItem->ID,"");

    *apID = idProp;
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}

// helper for CreateTemplate
// recursively create child templates for all children of type
void CMTPriceableItemWriter::CreateChildTemplates(IMTPriceableItem* apPrcItemTmpl )
{
    MTPRODUCTCATALOGLib::IMTPriceableItemPtr prcItemTmpl = apPrcItemTmpl;
    MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr prcItemType;
    prcItemType = prcItemTmpl->PriceableItemType;

    // for all children of type
    MTPRODUCTCATALOGLib::IMTCollectionPtr childTypes;
    childTypes  = prcItemType->GetChildren();
    
    long count = childTypes->Count;
    for( int i = 1; i <= count; i++ )
    {
      MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr childType = childTypes->Item[i];
      
      //create template from type
      MTPRODUCTCATALOGLib::IMTPriceableItemPtr childTmpl;;
      childTmpl = childType->CreateTemplate(VARIANT_TRUE); //VARIANT_TRUE means keep recursing
      childTmpl->ParentID = prcItemTmpl->ID;

      //write template to DB (this also recursively creates childTemplates for children of childTempl)
      childTmpl->Save();
    }
}

STDMETHODIMP CMTPriceableItemWriter::CreateInstance(IMTSessionContext* apCtxt, long aProdOffID, IMTPriceableItem *apPrcItemInst, long *apPrcItemInstID)
{
  MTAutoContext context(mpObjectContext);

  try
  {
    if (!apPrcItemInst || !apPrcItemInstID)
      return E_POINTER;

    //init out var
    *apPrcItemInstID = 0;

    
    _variant_t vtParam;
    MTPRODUCTCATALOGLib::IMTPriceableItemPtr prcItemInstance = apPrcItemInst;

    // ProductOfferingID could have been set before calling method, 
    // but ProductOfferingID was added later to PI, and I did not want to change interface
    prcItemInstance->ProductOfferingID = aProdOffID;

    PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "adding priceable item '%s' to product offering with ID %d",
                                       (char*)prcItemInstance->GetName(),
                                       aProdOffID);

    //if template has not been created yet, do it now
    MTPRODUCTCATALOGLib::IMTPriceableItemPtr prcItemTemplate = prcItemInstance->GetTemplate();

    if (prcItemTemplate->ID == PROPERTIES_BASE_NO_ID) //not yet created
    {
      prcItemTemplate->Save();
      prcItemInstance->TemplateID = prcItemTemplate->ID;
    }

    //verify: only one template is allowed per product offering
    if (PCCache::IsBusinessRuleEnabled( PCCONFIGLib::MTPC_BUSINESS_RULE_ProdOff_NoDuplicateUsageTemplate ) ||
        PCCache::IsBusinessRuleEnabled( PCCONFIGLib::MTPC_BUSINESS_RULE_ProdOff_NoDuplicateTemplate))
    {

      MTPRODUCTCATALOGEXECLib::IMTProductOfferingReaderPtr poReader(__uuidof(MTPRODUCTCATALOGEXECLib::MTProductOfferingReader));
      VARIANT_BOOL hasTemplate = poReader->HasPriceableItemTemplate(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), aProdOffID, prcItemInstance->TemplateID);
        
      if( hasTemplate == VARIANT_TRUE )
      {
        if( prcItemTemplate->Kind == PCENTITY_TYPE_USAGE ||
            prcItemTemplate->Kind == PCENTITY_TYPE_AGGREGATE_CHARGE )
        {
          if (PCCache::IsBusinessRuleEnabled( PCCONFIGLib::MTPC_BUSINESS_RULE_ProdOff_NoDuplicateUsageTemplate ))
            MT_THROW_COM_ERROR(IID_IMTPriceableItemWriter, MTPCUSER_USAGE_CHARGE_ALREADY_IN_PRODOFF, (char*)prcItemInstance->GetName());
        }
        else
        { if (PCCache::IsBusinessRuleEnabled( PCCONFIGLib::MTPC_BUSINESS_RULE_ProdOff_NoDuplicateTemplate ))
            MT_THROW_COM_ERROR(IID_IMTPriceableItemWriter, MTPCUSER_TEMPLATE_ALREADY_IN_PRODOFF, (char*)prcItemInstance->GetName());
        }
      }
    }

		// check for UDRC with duplicate unit name
		if(prcItemTemplate->PriceableItemType->Kind == PCENTITY_TYPE_RECURRING_UNIT_DEPENDENT)
		{
			MTPRODUCTCATALOGEXECLib::IMTRecurringChargePtr rc(prcItemTemplate.GetInterfacePtr());
      MTPRODUCTCATALOGEXECLib::IMTProductOfferingReaderPtr poReader(__uuidof(MTPRODUCTCATALOGEXECLib::MTProductOfferingReader));
      _bstr_t piname = poReader->FindRecurringChargeWithUnitName(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), aProdOffID, rc->UnitName);
			if(piname != _bstr_t(L""))
			{
				MT_THROW_COM_ERROR(MTPCUSER_UDRC_DUPLICATE_UNIT_NAME_IN_PO,
													 (const char *)rc->UnitName);
			}
		}

    //check for existing name
    VerifyName(apCtxt, apPrcItemInst);


    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);
    
    //---insert into base prop---
    MTPRODUCTCATALOGEXECLib::IMTBasePropsWriterPtr baseWriter(__uuidof(MTBasePropsWriter));
    long idProp = baseWriter->CreateWithDisplayName( reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt),
                                                      (long)prcItemInstance->Kind,
                                                      prcItemInstance->Name,
                                                      prcItemInstance->Description,
                                                      prcItemInstance->DisplayName);

    //set ID in prcItem, since it will be used in writers of derived classes
    prcItemInstance->ID = idProp;


    //insert a null plm entry to be able to identify PI without param tables
    InsertPriceListMapping( -1, aProdOffID, reinterpret_cast<IMTPriceableItem*>(prcItemInstance.GetInterfacePtr()));

    //--- for each param table add a pl mapping --
    
    //get the type
    MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr prcItemType;
    prcItemType = prcItemInstance->PriceableItemType;

    //get collection of param tables
    MTPRODUCTCATALOGLib::IMTCollectionPtr paramTableDefs;
    paramTableDefs = prcItemType->GetParamTableDefinitions();

    // loop over all param table defs
    MTPRODUCTCATALOGLib::IMTParamTableDefinitionPtr paramTableDef;

    long count = paramTableDefs->GetCount();

    for (long i = 1; i <= count; ++i) // collection indexes are 1-based
    {
      paramTableDef = paramTableDefs->GetItem(i);
      InsertPriceListMapping( paramTableDef->ID, aProdOffID, reinterpret_cast<IMTPriceableItem*>(prcItemInstance.GetInterfacePtr()));
    }

    // call priceable-item-type-specific writers to create extra properties
    switch(long(prcItemInstance->Kind))
    {
    case PCENTITY_TYPE_NON_RECURRING:
      {
        MTPRODUCTCATALOGEXECLib::IMTNonRecurringChargeWriterPtr writer( __uuidof(MTPRODUCTCATALOGEXECLib::MTNonRecurringChargeWriter));
        MTPRODUCTCATALOGEXECLib::IMTNonRecurringChargePtr item(prcItemInstance);
        writer->CreateProperties(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), item.GetInterfacePtr());
      }
      break;
    case PCENTITY_TYPE_DISCOUNT:
      {
        MTPRODUCTCATALOGEXECLib::IMTDiscountWriterPtr writer( __uuidof(MTPRODUCTCATALOGEXECLib::MTDiscountWriter));
        MTPRODUCTCATALOGEXECLib::IMTDiscountPtr item(prcItemInstance);
        writer->CreateDiscountProperties(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), item.GetInterfacePtr());
      }
      break;
    case PCENTITY_TYPE_RECURRING:
    case PCENTITY_TYPE_RECURRING_UNIT_DEPENDENT:
      {
        MTPRODUCTCATALOGEXECLib::IMTRecurringChargeWriterPtr writer( __uuidof(MTPRODUCTCATALOGEXECLib::MTRecurringChargeWriter));
        MTPRODUCTCATALOGEXECLib::IMTRecurringChargePtr item(prcItemInstance);
        writer->CreateProperties(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), item.GetInterfacePtr());
      }
      break;
    case PCENTITY_TYPE_AGGREGATE_CHARGE:
      {
        MTPRODUCTCATALOGEXECLib::IMTAggregateChargeWriterPtr writer( __uuidof(MTPRODUCTCATALOGEXECLib::MTAggregateChargeWriter));
        MTPRODUCTCATALOGEXECLib::IMTAggregateChargePtr item(prcItemInstance);
        writer->Create(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), item.GetInterfacePtr());
      }
      break;
    default:
      ;
    }

    // save extended properties of this priceable item
    MTPRODUCTCATALOGLib::IMTProductCatalogPtr productCatalog(__uuidof(MTProductCatalog));
    MTPRODUCTCATALOGLib::IMTPropertyMetaDataSetPtr metaData = productCatalog->GetMetaData(prcItemInstance->Kind);
    metaData->UpsertExtendedProperties(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(apCtxt), prcItemInstance->GetProperties(), VARIANT_FALSE);

    //Create adjustment instances
    MetraTech_Adjustments::IAdjustmentWriterPtr ajwriter(__uuidof(MetraTech_Adjustments::AdjustmentWriter));
    GENERICCOLLECTIONLib::IMTCollectionPtr adjustments = prcItemInstance->GetAdjustments();
    long numaj = adjustments->GetCount();
    for (int i = 1; i <= numaj; i++)
    {
      MetraTech_Adjustments::IAdjustmentPtr ajPtr = adjustments->GetItem(i);
	  ajPtr->PriceableItem = prcItemInstance;
			ajwriter->Create((MTPRODUCTCATALOGLib::IMTSessionContext*)apCtxt, ajPtr);
    }

    //Localized Display Names
    rowset->SetQueryTag("__GET_DISPLAYNAME_DESC_ID_FOR_PC_ITEM__");

    vtParam = idProp;
    rowset->AddParam("%%ID_PROP%%",vtParam);

    rowset->Execute();
    if((long)rowset->GetValue(L"n_display_name") > 0)
    {
      MetraTech_Localization::ILocalizedEntityPtr templateDisplayNameLocalizationPtr(prcItemTemplate->DisplayNames);
      MetraTech_Localization::ILocalizedEntityPtr displayNameLocalizationPtr(prcItemInstance->DisplayNames);
      displayNameLocalizationPtr->Copy(templateDisplayNameLocalizationPtr);
      displayNameLocalizationPtr->SaveWithID((long)rowset->GetValue(L"n_display_name"));
    }
    else
    {
      //Error
    }

    if((long)rowset->GetValue(L"n_desc") > 0)
    {
      MetraTech_Localization::ILocalizedEntityPtr templateDescLocalizationPtr(prcItemTemplate->DisplayDescriptions);
      MetraTech_Localization::ILocalizedEntityPtr displayDescLocalizationPtr(prcItemInstance->DisplayDescriptions);
      displayDescLocalizationPtr->Copy(templateDescLocalizationPtr);
      displayDescLocalizationPtr->SaveWithID((long)rowset->GetValue(L"n_desc"));
    }
    else
    {
      //Error
    }

    //recursively create child instances for all children of template
    CreateChildInstances( apCtxt, aProdOffID, reinterpret_cast<IMTPriceableItem*> (prcItemInstance.GetInterfacePtr()) );

    *apPrcItemInstID = idProp;

    MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr pContext(apCtxt);
    PCCache::GetAuditor()->FireEvent(1102,pContext->AccountID,2, aProdOffID,prcItemInstance->GetName());
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  context.Complete();


  return S_OK;
}

// helper for CreateInstance
// recursively create child instances for all children of type
void CMTPriceableItemWriter::CreateChildInstances(IMTSessionContext* apCtxt, long aProdOffID, IMTPriceableItem* apPrcItemInst )
{
    MTPRODUCTCATALOGEXECLib::IMTPriceableItemPtr prcItemInst = apPrcItemInst;
    MTPRODUCTCATALOGEXECLib::IMTPriceableItemPtr prcItemTmpl;
    prcItemTmpl = prcItemInst->GetTemplate();

    // for all children of tmpl
    MTPRODUCTCATALOGEXECLib::IMTCollectionPtr childTmpls;
    childTmpls  = prcItemTmpl->GetChildren();
    
    long count = childTmpls->Count;
    for( int i = 1; i <= count; i++ )
    {
      MTPRODUCTCATALOGEXECLib::IMTPriceableItemPtr childTmpl = childTmpls->Item[i];
      
      //create instance from template
      MTPRODUCTCATALOGEXECLib::IMTPriceableItemPtr childInst;;
      childInst = childTmpl->CreateInstance();
      childInst->ParentID = prcItemInst->ID;

      //write instance to DB (this also recursively creates childInstances for children of childTempl)
      MTPRODUCTCATALOGEXECLib::IMTPriceableItemWriterPtr writer = this;
      writer->CreateInstance(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), aProdOffID, childInst);
    }
}


void CMTPriceableItemWriter::InsertPriceListMapping( long aParamTableDefID,
                                                     long aProdOffID,
                                                     IMTPriceableItem* apPrcItemInst)
{
  _variant_t vtParam;
  MTPRODUCTCATALOGLib::IMTPriceableItemPtr prcItemInstance = apPrcItemInst;

  //get the type
  MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr prcItemType;
  prcItemType = prcItemInstance->PriceableItemType;


  ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
  rowset->Init(CONFIG_DIR);

  // insert into t_pl_map
  rowset->SetQueryTag("_ADD_PO_PIMAPPING__");

  if (aParamTableDefID == PROPERTIES_BASE_NO_ID)    
    vtParam = "NULL";
  else
    vtParam = aParamTableDefID;

  rowset->AddParam("%%ID_PT%%", vtParam);
  rowset->AddParam("%%ID_PI_TYPE%%", prcItemType->ID);
  rowset->AddParam("%%ID_PI_TEMPLATE%%", prcItemInstance->TemplateID);
  rowset->AddParam("%%ID_PI_INSTANCE%%", prcItemInstance->ID);

  long parentID = prcItemInstance->ParentID;
  if (parentID == PROPERTIES_BASE_NO_ID)    
    vtParam = "NULL";
  else
    vtParam = parentID;
  rowset->AddParam("%%ID_PI_INSTANCE_PARENT%%", vtParam);

  rowset->AddParam("%%ID_PO%%", aProdOffID);
  rowset->AddParam("%%ID_PL%%", "NULL");
  rowset->AddParam("%%CANICB%%", "N");

  rowset->Execute();
}


STDMETHODIMP CMTPriceableItemWriter::Update(IMTSessionContext* apCtxt, IMTPriceableItem *apPrcItem)
{
  MTAutoContext context(mpObjectContext);
  _variant_t vtParam;

  try 
  {
    if (!apPrcItem)
      return E_POINTER;

    MTPRODUCTCATALOGLib::IMTPriceableItemPtr prcItem = apPrcItem; //use comptr for convenience

    //check for existing name
    VerifyName(apCtxt, apPrcItem);

    //check if cycle has changed and if change is OK
    CheckValidCycleChange(apCtxt, apPrcItem);

    MTPRODUCTCATALOGEXECLib::IMTPriceableItemReaderPtr reader(__uuidof(MTPriceableItemReader));
    MTPRODUCTCATALOGEXECLib::IMTPriceableItemPtr originalPrcItem;
    originalPrcItem = reader->Find((MTPRODUCTCATALOGEXECLib::IMTSessionContext *)apCtxt, prcItem->ID);

    string oldName = originalPrcItem->Name;
    string oldDescription = originalPrcItem->Description;
    string  oldDisplayName = originalPrcItem->DisplayName;

    // update pricable item properties
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);

    MTPRODUCTCATALOGEXECLib::IMTBasePropsWriterPtr baseWriter(__uuidof(MTBasePropsWriter));
    baseWriter->UpdateWithDisplayName(MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr(apCtxt),
                                      prcItem->Name, prcItem->Description,
                                      prcItem->DisplayName, prcItem->ID);

    //CR 5635: PriceableItem hook has to call Save on templates multiple times.
    //It's an easiest way to support N-deep parent-children relationships
    //for compound priceable item. A more complex way would be to build a tree
    //while parsing PI type files and only call Save() on the top-most element.
    rowset->Clear();
    rowset->SetQueryTag("__UPDATE_PI_TMPL__");
    rowset->AddParam("%%ID_TMPL%%", prcItem->ID);
    
    long parentID = prcItem->ParentID;
    if (parentID == PROPERTIES_BASE_NO_ID)    
      vtParam = "NULL";
    else
      vtParam = parentID;
    rowset->AddParam("%%ID_TMPL_PARENT%%", vtParam);
    rowset->AddParam("%%ID_PI%%", prcItem->PriceableItemType->ID);
    rowset->Execute();


    //
    // call priceable-item-type-specific writers to Update extra properties
    switch(long(prcItem->Kind))
    {
    case PCENTITY_TYPE_NON_RECURRING:
      {
        MTPRODUCTCATALOGEXECLib::IMTNonRecurringChargeWriterPtr writer( __uuidof(MTPRODUCTCATALOGEXECLib::MTNonRecurringChargeWriter));
        MTPRODUCTCATALOGEXECLib::IMTNonRecurringChargePtr item(prcItem);
        writer->UpdateProperties(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), item.GetInterfacePtr());
      }
      break;
    case PCENTITY_TYPE_DISCOUNT:
      {
        MTPRODUCTCATALOGEXECLib::IMTDiscountWriterPtr writer( __uuidof(MTPRODUCTCATALOGEXECLib::MTDiscountWriter));
        MTPRODUCTCATALOGEXECLib::IMTDiscountPtr item(prcItem);
        writer->UpdateDiscountProperties(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), item.GetInterfacePtr());
      }
      break;
    case PCENTITY_TYPE_RECURRING:
    case PCENTITY_TYPE_RECURRING_UNIT_DEPENDENT:
      {
        MTPRODUCTCATALOGEXECLib::IMTRecurringChargeWriterPtr writer( __uuidof(MTPRODUCTCATALOGEXECLib::MTRecurringChargeWriter));
        MTPRODUCTCATALOGEXECLib::IMTRecurringChargePtr item(prcItem);
        writer->UpdateProperties(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), item.GetInterfacePtr());
      }
      break;
    case PCENTITY_TYPE_AGGREGATE_CHARGE:
      {
        MTPRODUCTCATALOGEXECLib::IMTAggregateChargeWriterPtr writer( __uuidof(MTPRODUCTCATALOGEXECLib::MTAggregateChargeWriter));
        MTPRODUCTCATALOGEXECLib::IMTAggregateChargePtr item(prcItem);
        writer->Update(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), item.GetInterfacePtr());
      }
      break;
    default:
      ;
    }

    // save extended properties of this priceable item
    // if this is a template:
    //     write all extended properties of this template
    //     and propagate changes of non-overridable properties to all instance 
    // if this is an instance:
    //     only write overridable properties
    //     (to avoid writing of outdated data - in case of an almost simultaneous change to the template)
    
    MTPRODUCTCATALOGLib::IMTProductCatalogPtr productCatalog(__uuidof(MTProductCatalog));
    MTPRODUCTCATALOGLib::IMTPropertyMetaDataSetPtr metaData = productCatalog->GetMetaData(prcItem->Kind);

    if (prcItem->IsTemplate() == VARIANT_TRUE)
    {
      metaData->UpsertExtendedProperties(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(apCtxt), prcItem->GetProperties(), VARIANT_FALSE); //VARIANT_FALSE means all extended props
      metaData->PropagateExtendedProperties(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(apCtxt), prcItem->GetProperties());
    }
    else
    {
      metaData->UpsertExtendedProperties(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(apCtxt), prcItem->GetProperties(), VARIANT_TRUE); //VARIANT_TRUE means OverrideableOnly
    }

    //Update adjustment templates or instances
    MetraTech_Adjustments::IAdjustmentWriterPtr ajwriter(__uuidof(MetraTech_Adjustments::AdjustmentWriter));
    GENERICCOLLECTIONLib::IMTCollectionPtr adjustments = prcItem->GetAdjustments();
    long numaj = adjustments->GetCount();
    for (int i = 1; i <= numaj; i++)
    {
      MetraTech_Adjustments::IAdjustmentPtr ajPtr = adjustments->GetItem(i);
      ASSERT(ajPtr != NULL);
      if(ajPtr->ID > 0)
			  ajwriter->Update((MTPRODUCTCATALOGLib::IMTSessionContext*)apCtxt, ajPtr);
      else
		  ajPtr->PriceableItem = prcItem;
        ajwriter->Create((MTPRODUCTCATALOGLib::IMTSessionContext*)apCtxt, ajPtr);
    }

    //Localized Display Names
    rowset->SetQueryTag("__GET_DISPLAYNAME_DESC_ID_FOR_PC_ITEM__");

    vtParam = prcItem->ID;
    rowset->AddParam("%%ID_PROP%%",vtParam);

    rowset->Execute();
    if((long)rowset->GetValue(L"n_display_name") > 0)
    {
	    MetraTech_Localization::ILocalizedEntityPtr displayNameLocalizationPtr(prcItem->DisplayNames);
      displayNameLocalizationPtr->SaveWithID((long)rowset->GetValue(L"n_display_name"));
    }
    else
    {
      //Error
    }

    if((long)rowset->GetValue(L"n_desc") > 0)
    {
	    MetraTech_Localization::ILocalizedEntityPtr displayDescLocalizationPtr(prcItem->DisplayDescriptions);
      displayDescLocalizationPtr->SaveWithID((long)rowset->GetValue(L"n_desc"));
    }
    else
    {
      //Error
    }
    if (prcItem->IsTemplate() == VARIANT_TRUE)
    {
      MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr pContext(apCtxt);
      PCCache::GetAuditor()->FireEvent(1201,pContext->AccountID,2,prcItem->ID,"");
    }
    else
    {
      MTPRODUCTCATALOGEXECLib::IMTPriceableItemReaderPtr reader(__uuidof(MTPriceableItemReader));
      MTPRODUCTCATALOGEXECLib::IMTPriceableItemPtr newPrcItem;
      newPrcItem = reader->Find((MTPRODUCTCATALOGEXECLib::IMTSessionContext *)apCtxt, prcItem->ID);

      string newName = newPrcItem->Name;
      string newDescription = newPrcItem->Description;
      string  newDisplayName = newPrcItem->DisplayName;
      MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr pContext(apCtxt);
      string changes = newName + " changed. ";
      if (oldName != newName){
        changes += "Name was " + oldName + ", now " + newName + ". ";
      }
      if (oldDescription != newDescription){
        changes += "Description was " + oldDescription + ", now " + newDescription + ". ";
      }
      if (oldDisplayName != newDisplayName){
        changes += "Display name was " + oldDisplayName + ", now " + newDisplayName + ". ";
      }
      PCCache::GetAuditor()->FireEvent(AuditEventsLib::AUDITEVENT_PO_UPDATEPI,pContext->AccountID,2,prcItem->GetProductOfferingID(),changes.c_str());

    }
  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}

STDMETHODIMP CMTPriceableItemWriter::Remove(IMTSessionContext* apCtxt, long aID)
{
  MTAutoContext context(mpObjectContext);

  try 
  {
    PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTPriceableItemWriter::Remove(%d)", aID);

    /////////////////////////////
    // find priceable item by aID
    MTPRODUCTCATALOGEXECLib::IMTPriceableItemReaderPtr piReader( __uuidof(MTPRODUCTCATALOGEXECLib::MTPriceableItemReader));
    MTPRODUCTCATALOGLib::IMTPriceableItemPtr prcItem;
    prcItem = piReader->Find(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), aID); 

    if (prcItem == NULL)
      MT_THROW_COM_ERROR(MTPC_OBJECT_NO_STATE);

    if(prcItem->CanBeModified() != VARIANT_TRUE)
      MT_THROW_COM_ERROR(MTPCUSER_PI_CAN_NOT_BE_MODIFIED);

    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);

    //Remove adjustment templates or instances
    MetraTech_Adjustments::IAdjustmentWriterPtr ajwriter(__uuidof(MetraTech_Adjustments::AdjustmentWriter));
    GENERICCOLLECTIONLib::IMTCollectionPtr adjustments = prcItem->GetAdjustments();
    long numaj = adjustments->GetCount();
    for (int i = 1; i <= numaj; i++)
    {
      MetraTech_Adjustments::IAdjustmentPtr ajPtr = adjustments->GetItem(i);
			ajwriter->Remove((MTPRODUCTCATALOGLib::IMTSessionContext*)apCtxt, ajPtr);
    }

    if (prcItem->IsTemplate() == VARIANT_TRUE)
    {
      /////////////////////////////
      // if this is a template, remove its instances...
      PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTPriceableItemWriter::Remove(%d) removes a pi template", aID);

      // TODO: find 'em and remove 'em

      /////////////////////////////
      // if this is a template, remove its entry from t_pi_template, 
      rowset->SetQueryTag("__DELETE_PI_TEMPLATE_BY_ID__");
      rowset->AddParam("%%ID_TEMPLATE%%", aID);
      rowset->Execute();
    }
    else
    {
      /////////////////////////////
      // remove instance from the product offering
      PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTPriceableItemWriter::Remove(%d) removes a pi instance", aID);
      rowset->SetQueryTag("__DELETE_PI_INSTANCE_FROM_THE_PO__");
      rowset->AddParam("%%ID_INSTANCE%%", aID);
      rowset->Execute();
    }

    


    /////////////////////////////
    // remove the children 
    MTPRODUCTCATALOGEXECLib::IMTCollectionPtr childTmpls;
    childTmpls  = prcItem->GetChildren();
    
    long count = childTmpls->Count;
    PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTPriceableItemWriter::Remove(%d) removes %d child items", aID, count);
    for( int i = 1; i <= count; i++ )
    {
      MTPRODUCTCATALOGEXECLib::IMTPriceableItemPtr childPI = childTmpls->Item[i];
      
      // remove instance from DB (this also recursively removes childInstances for children of childPI)
      MTPRODUCTCATALOGEXECLib::IMTPriceableItemWriterPtr writer = this;
      writer->Remove(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), childPI->ID);
    }

    /////////////////////////////
    // call priceable-item-type-specific writers to remove extra properties
    switch(long(prcItem->Kind))
    {
    case PCENTITY_TYPE_NON_RECURRING:
      {
        MTPRODUCTCATALOGEXECLib::IMTNonRecurringChargeWriterPtr writer( __uuidof(MTPRODUCTCATALOGEXECLib::MTNonRecurringChargeWriter));
        writer->RemoveProperties(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), aID);
      }
      break;
    case PCENTITY_TYPE_DISCOUNT:
      {
        MTPRODUCTCATALOGEXECLib::IMTDiscountWriterPtr writer( __uuidof(MTPRODUCTCATALOGEXECLib::MTDiscountWriter));
        writer->RemoveDiscountProperties(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), aID);
      }
      break;
    case PCENTITY_TYPE_RECURRING:
    case PCENTITY_TYPE_RECURRING_UNIT_DEPENDENT:
      {
        MTPRODUCTCATALOGEXECLib::IMTRecurringChargeWriterPtr writer( __uuidof(MTPRODUCTCATALOGEXECLib::MTRecurringChargeWriter));
        writer->RemoveProperties(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), aID);
      }
      break;
    case PCENTITY_TYPE_AGGREGATE_CHARGE:
      {
        MTPRODUCTCATALOGEXECLib::IMTAggregateChargeWriterPtr writer( __uuidof(MTPRODUCTCATALOGEXECLib::MTAggregateChargeWriter));
        writer->Remove(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), aID);
      }
      break;
    default:
      ;
    }

    /////////////////////////////
    // remove extended properties of this priceable item
    PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTPriceableItemWriter::Remove(%d) removes extended properties", aID);

    MTPRODUCTCATALOGLib::IMTProductCatalogPtr productCatalog(__uuidof(MTProductCatalog));
    MTPRODUCTCATALOGLib::IMTPropertyMetaDataSetPtr metaData = productCatalog->GetMetaData(prcItem->Kind);
    metaData->RemoveExtendedProperties(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(apCtxt), prcItem->GetProperties());

    /////////////////////////////
    // remove entry from t_base_props
    PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTPriceableItemWriter::Remove(%d) removes base properties", aID);
    MTPRODUCTCATALOGEXECLib::IMTBasePropsWriterPtr baseWriter(__uuidof(MTBasePropsWriter));
    baseWriter->Delete(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt),
                       aID);

    if (prcItem->IsTemplate() == VARIANT_TRUE)
    {
      //MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr pContext(apCtxt);
      //PCCache::GetAuditor()->FireEvent(1202,pContext->AccountID,2, aProdOffID,prcItemInstance->GetName());
    }
    else
    {
      
      MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr pContext(apCtxt);
      PCCache::GetAuditor()->FireEvent(1103,pContext->AccountID,2,prcItem->GetProductOfferingID(),prcItem->GetName());
    }

  }
  catch (_com_error & err)
  {
    PCCache::GetLogger().LogVarArgs(LOG_ERROR, "CMTPriceableItemWriter::Remove() caught error 0x%08h", err.Error());
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}

STDMETHODIMP CMTPriceableItemWriter::SetPriceListMapping(IMTSessionContext* apCtxt, long aPrcItemInstanceID, long aParamTblDefID, long aPrcLstID)
{
  MTAutoContext context(mpObjectContext);

  try
  {
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init(CONFIG_DIR);
    
    rowset->SetQueryTag("__SET_PRC_LST_MAPPING__");

    rowset->AddParam("%%ID_PI%%", aPrcItemInstanceID);
    rowset->AddParam("%%ID_PTD%%", aParamTblDefID);
    rowset->AddParam("%%ID_PL%%", aPrcLstID);

    rowset->Execute();

  }
  catch (_com_error & err)
  {
    return ReturnComError(err);
  }

  context.Complete();
  return S_OK;
}
/*
STDMETHODIMP CMTPriceableItemWriter::CreateOrSetAllPriceListMappings(IMTSessionContext* apCtxt, IMTPriceableItem* apPrcItemInst, long aPrcLstID)
{

}
*/

// check name of priceable item 
// throws _com_error if prc item with that name already exists
void CMTPriceableItemWriter::VerifyName(IMTSessionContext* apCtxt, IMTPriceableItem* apPrcItem)
{
  MTPRODUCTCATALOGEXECLib::IMTPriceableItemPtr prcItem = apPrcItem;
  MTPRODUCTCATALOGEXECLib::IMTPriceableItemReaderPtr reader(__uuidof(MTPriceableItemReader));

  if (prcItem->IsTemplate() == VARIANT_TRUE)
  {
    if (PCCache::IsBusinessRuleEnabled( PCCONFIGLib::MTPC_BUSINESS_RULE_PITempl_NoDuplicateName ))
    { 
      MTPRODUCTCATALOGEXECLib::IMTPriceableItemPtr existingPrcItem;
      existingPrcItem = reader->FindTemplateByName((MTPRODUCTCATALOGEXECLib::IMTSessionContext *) apCtxt, prcItem->Name);

      if (existingPrcItem != NULL && existingPrcItem->ID != prcItem->ID)
        MT_THROW_COM_ERROR(IID_IMTPriceableItemWriter, MTPCUSER_PRC_ITEM_TEMPLATE_EXISTS, (const char*)prcItem->Name);
    }
  }
  else
  {
    if (PCCache::IsBusinessRuleEnabled( PCCONFIGLib::MTPC_BUSINESS_RULE_ProdOff_NoDuplicateInstanceName ))
    { 
      MTPRODUCTCATALOGEXECLib::IMTPriceableItemPtr existingPrcItem;
      existingPrcItem = reader->FindInstanceByName((MTPRODUCTCATALOGEXECLib::IMTSessionContext *) apCtxt, prcItem->Name, prcItem->ProductOfferingID);

      if (existingPrcItem != NULL && existingPrcItem->ID != prcItem->ID)
        MT_THROW_COM_ERROR(IID_IMTPriceableItemWriter, MTPCUSER_PRC_ITEM_INSTANCE_EXISTS, (const char*)prcItem->Name);
    }
  }
}

//checks if a change to a cycle can be applied
//  check cycle of other PIs within same POs 
//  check cycle of all subscriptions to POs
//  check cycle requirements of group subscriptions to POs
void CMTPriceableItemWriter::CheckValidCycleChange(IMTSessionContext* apCtxt, IMTPriceableItem* apPrcItem)
{
  MTPRODUCTCATALOGEXECLib::IMTPriceableItemPtr prcItem = apPrcItem;
  
  //check busrule enabeled
  if (PCCache::IsBusinessRuleEnabled( PCCONFIGLib::MTPC_BUSINESS_RULE_PI_CheckCycleChange ))
  {
    //check if prc item has cycle
    if(prcItem->Properties->Exist("Cycle"))
    {
      MTPRODUCTCATALOGEXECLib::IMTPropertyPtr newCycleProp = prcItem->Properties->GetItem("Cycle");
      MTPRODUCTCATALOGEXECLib::IMTPCCyclePtr newCycle = newCycleProp->Value;

      // check if cycle was modified
      MTPRODUCTCATALOGEXECLib::IMTPriceableItemReaderPtr reader(__uuidof(MTPriceableItemReader));
      MTPRODUCTCATALOGEXECLib::IMTPriceableItemPtr originalPrcItem;
      originalPrcItem = reader->Find((MTPRODUCTCATALOGEXECLib::IMTSessionContext *)apCtxt, prcItem->ID);
      
      MTPRODUCTCATALOGEXECLib::IMTPropertyPtr orgCycleProp = originalPrcItem->Properties->GetItem("Cycle");
      MTPRODUCTCATALOGEXECLib::IMTPCCyclePtr originalCycle = orgCycleProp->Value;


      //before comparing cycles make sure CycleID is correct
      //(this could eventually be done in Equals, but tracking state of that cycle object is pretty complex)
      newCycle->ComputeCycleIDFromProperties();

      if (!newCycle->Equals(originalCycle))
      {
        PCCache::GetLogger().LogThis(LOG_DEBUG, "Cycle has been modified. Check affected product offerings");

        // call CheckValidCycle for each affected PO
        MTPRODUCTCATALOGEXECLib::IMTProductOfferingPtr prodOff;
        
        if (prcItem->IsTemplate() == VARIANT_TRUE)
        {
          // for a modified template see if cycle is propagated
          if (newCycleProp->Overrideable == VARIANT_FALSE)
          {
            // and if so check all affected POs
            MTPRODUCTCATALOGEXECLib::IMTCollectionPtr instances = prcItem->GetInstances();
            for(int i = 1; i <= instances->Count; i++)
            {
              MTPRODUCTCATALOGEXECLib::IMTPriceableItemPtr instance = instances->GetItem(i);
              MTPRODUCTCATALOGEXECLib::IMTProductOfferingPtr prodOff;
          
              prodOff = instance->GetProductOffering();
              ASSERT(prodOff != NULL);
              prodOff->CheckValidCycle(newCycle, instance);
            }
          }
        }
        else
        {
          //for a modified instance check it's productoffering
          prodOff = prcItem->GetProductOffering();
          ASSERT(prodOff != NULL);
          prodOff->CheckValidCycle(newCycle, prcItem);
        }
      }
    }
  }
}
