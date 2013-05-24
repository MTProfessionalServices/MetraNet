/**************************************************************************
 * Copyright 1998 by MetraTech Corporation
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
 * NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech Corporation MAKES NO
 * REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
 * PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
 * DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
 * COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech Corporation,
 * and USER agrees to preserve the same.
 *
 * Created by: Ralf Boeck
 *
 * $Date: 11/13/2002 6:09:23 PM$
 * $Author: Fabricio Pettena$
 * $Revision: 57$
 ***************************************************************************/
#include "StdAfx.h"

#include <metra.h>
#include <mtprogids.h>
#include <comdef.h>
#include <mtcomerr.h>
#include <mtglobal_msg.h>
#include <vector>

#include "MTProductCatalog.h"
#include "MTProductOffering.h"

#define CYCLE_PROPERTY "Cycle"

using MTPRODUCTCATALOGLib::IMTProductOfferingPtr;
using MTPRODUCTCATALOGLib::IMTPriceableItemPtr;
using MTPRODUCTCATALOGLib::IMTCollectionPtr;
using MTPRODUCTCATALOGLib::IMTPriceListMappingPtr;

#import <MetraTech.Localization.tlb>
#import <IMTAccountType.tlb> rename ("EOF", "RowsetEOF")
#import <MetraTech.Accounts.Type.tlb>  inject_statement("using namespace mscorlib;") inject_statement("using namespace MTAccountTypeLib;") inject_statement("using MTAccountTypeLib::IMTAccountTypePtr;")

/////////////////////////////////////////////////////////////////////////////
// CMTProductOffering

/******************************************* error interface ***/
STDMETHODIMP CMTProductOffering::InterfaceSupportsErrorInfo(REFIID riid)
{
  static const IID* arr[] = 
  {
    &IID_IMTProductOffering,
    &IID_IMTPCBase
  };
  for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
  {
    if (::InlineIsEqualGUID(*arr[i],riid))
      return S_OK;
  }
  return S_FALSE;
}

/********************************** construction/destruction ***/
CMTProductOffering::CMTProductOffering()
{
  mUnkMarshalerPtr = NULL;
}

HRESULT CMTProductOffering::FinalConstruct()
{
  try
  {
    HRESULT hr = CoCreateFreeThreadedMarshaler(GetControllingUnknown(), &mUnkMarshalerPtr.p);
    if (FAILED(hr))
      throw _com_error(hr);

    LoadPropertiesMetaData( PCENTITY_TYPE_PRODUCT_OFFERING );

    //construct nested objects
    //(note: session context of nested objects needs to be set in CMTProductOffering::SetSessionContext())
    MTPRODUCTCATALOGLib::IMTPCTimeSpanPtr effectiveDatePtr(__uuidof(MTPCTimeSpan));
    // effective dates are always absolute, initially: no start date, infinite end date
    effectiveDatePtr->Init(MTPRODUCTCATALOGLib::PCDATE_TYPE_ABSOLUTE, MTPRODUCTCATALOGLib::PCDATE_TYPE_NO_DATE,   
                           MTPRODUCTCATALOGLib::PCDATE_TYPE_ABSOLUTE, MTPRODUCTCATALOGLib::PCDATE_TYPE_NULL );
    PutPropertyObject("EffectiveDate", effectiveDatePtr);

    MTPRODUCTCATALOGLib::IMTPCTimeSpanPtr availabilityDatePtr(__uuidof(MTPCTimeSpan));
    // availability dates are always absolute, initially: no start date, infinite end date
    availabilityDatePtr->Init(MTPRODUCTCATALOGLib::PCDATE_TYPE_ABSOLUTE, MTPRODUCTCATALOGLib::PCDATE_TYPE_NO_DATE,
                              MTPRODUCTCATALOGLib::PCDATE_TYPE_ABSOLUTE, MTPRODUCTCATALOGLib::PCDATE_TYPE_NULL );
    PutPropertyObject("AvailabilityDate", availabilityDatePtr);

    //Localized display names
    MetraTech_Localization::ILocalizedEntityPtr displayNameLocalizationPtr(__uuidof(MetraTech_Localization::LocalizedEntity));
    PutPropertyObject("DisplayNames", displayNameLocalizationPtr);

    MetraTech_Localization::ILocalizedEntityPtr displayDescriptionLocalizationPtr(__uuidof(MetraTech_Localization::LocalizedEntity));
    PutPropertyObject("DisplayDescriptions", displayDescriptionLocalizationPtr);

    //put dummy collection for Subscribable Account Types
    GENERICCOLLECTIONLib::IMTCollectionExPtr accounttypes(__uuidof(GENERICCOLLECTIONLib::MTCollectionEx));
    PutPropertyObject("SubscribableAccountTypes", accounttypes);
    

    // Set the default currency code to USD
    nonsharedPLCurrency = L"USD"; // TODO: Do not hardcode!
    PutPropertyValue("Hidden", VARIANT_FALSE);
  } 
  catch (_com_error & err)
  {
    return LogAndReturnComError(PCCache::GetLogger(),err);
  }

  return S_OK;
}

void CMTProductOffering::FinalRelease()
{
  mUnkMarshalerPtr.Release();
}

/********************************** IMTProductOffering ***/

// ----------------------------------------------------------------
// Description: Return product offering's ID
// Return Value: product offering's ID
// ----------------------------------------------------------------
STDMETHODIMP CMTProductOffering::get_ID(long *pVal)
{
  return GetPropertyValue("ID", pVal);
}

STDMETHODIMP CMTProductOffering::put_ID(/*[in]*/ long newVal)
{
  return PutPropertyValue("ID", newVal);
}

// ----------------------------------------------------------------
// Description: Return product offering's name, localized
// Return Value: product offering's Name
// ----------------------------------------------------------------
STDMETHODIMP CMTProductOffering::get_Name(BSTR *pVal)
{
  return GetPropertyValue("Name", pVal);
}

// ----------------------------------------------------------------
// Description:  Set product offering's localized name
// Arguments:    newVal - new name
// ----------------------------------------------------------------
STDMETHODIMP CMTProductOffering::put_Name(BSTR newVal)
{
  return PutPropertyValue("Name", newVal);
}

STDMETHODIMP CMTProductOffering::get_DisplayName(BSTR *pVal)
{
  return GetPropertyValue("DisplayName", pVal);
}

STDMETHODIMP CMTProductOffering::put_DisplayName(BSTR newVal)
{
  return PutPropertyValue("DisplayName", newVal);
}

STDMETHODIMP CMTProductOffering::get_DisplayNames(IDispatch **pVal)
{
	return GetPropertyObject( "DisplayNames", reinterpret_cast<IDispatch**>(pVal) );
}

STDMETHODIMP CMTProductOffering::get_DisplayDescriptions(IDispatch **pVal)
{
	return GetPropertyObject( "DisplayDescriptions", reinterpret_cast<IDispatch**>(pVal) );
}

STDMETHODIMP CMTProductOffering::get_Description(BSTR *pVal)
{
  return GetPropertyValue("Description", pVal);
}

STDMETHODIMP CMTProductOffering::put_Description(BSTR newVal)
{
  return PutPropertyValue("Description", newVal);
}

STDMETHODIMP CMTProductOffering::get_SelfSubscribable(VARIANT_BOOL *pVal)
{
  return GetPropertyValue("SelfSubscribable", pVal);
}

STDMETHODIMP CMTProductOffering::put_SelfSubscribable(VARIANT_BOOL newVal)
{
  return PutPropertyValue("SelfSubscribable", newVal);
}


STDMETHODIMP CMTProductOffering::get_SelfUnsubscribable(VARIANT_BOOL *pVal)
{
  return GetPropertyValue("SelfUnsubscribable", pVal);
}

STDMETHODIMP CMTProductOffering::put_SelfUnsubscribable(VARIANT_BOOL newVal)
{
  return PutPropertyValue("SelfUnsubscribable", newVal);
}

STDMETHODIMP CMTProductOffering::get_EffectiveDate(IMTPCTimeSpan **pVal)
{
  return GetPropertyObject( "EffectiveDate", reinterpret_cast<IDispatch**>(pVal) );
}

STDMETHODIMP CMTProductOffering::get_AvailabilityDate(IMTPCTimeSpan **pVal)
{
  return GetPropertyObject( "AvailabilityDate", reinterpret_cast<IDispatch**>(pVal) );
}

STDMETHODIMP CMTProductOffering::get_NonSharedPriceListID(long *pVal)
{
  return GetPropertyValue("NonSharedPriceListID", pVal);
}

STDMETHODIMP CMTProductOffering::put_NonSharedPriceListID(long newVal)
{
  return PutPropertyValue("NonSharedPriceListID", newVal);
}

STDMETHODIMP CMTProductOffering::get_Hidden(VARIANT_BOOL *pVal)
{
  return GetPropertyValue("Hidden", pVal);
}

STDMETHODIMP CMTProductOffering::put_Hidden(VARIANT_BOOL newVal)
{
  return PutPropertyValue("Hidden", newVal);
}


STDMETHODIMP CMTProductOffering::get_SubscribableAccountTypes(IMTCollection **pVal)
{
   return GetPropertyObject( "SubscribableAccountTypes", reinterpret_cast<IDispatch**>(pVal) );
}



// ----------------------------------------------------------------
// Description: Saves modification to this PO to database.
// ----------------------------------------------------------------
STDMETHODIMP CMTProductOffering::Save()
{

  try
  {
    // validate (throws error on failure)
    Validate();

    // create instance of COM+ executant
    MTPRODUCTCATALOGEXECLib::IMTProductOfferingWriterPtr prodOffWriter(__uuidof(MTPRODUCTCATALOGEXECLib::MTProductOfferingWriter));
    
    // just cast "this"
    MTPRODUCTCATALOGEXECLib::IMTProductOffering* prodOff = reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTProductOffering *>(this);
		MTPRODUCTCATALOGLib::IMTProductOfferingPtr thisPoPtr = this;

    if (HasID())  //created
    {
      prodOffWriter->Update(GetSessionContextPtr(), prodOff);
    }
    else          // not yet created
    { // save ID
      put_ID(prodOffWriter->Create(GetSessionContextPtr(), prodOff) );
      // TODO!! flush collection of priceable items to add

			// By default, make sure that all pricelist mappings reference the current internal pricelist.
			IMTCollectionPtr piColl = thisPoPtr->GetPriceableItems();
			for (int i = 1; i <= piColl->Count; i++)
			{
				IMTPriceableItemPtr currentPI = piColl->GetItem(i);
				MapToNonSharedPL(reinterpret_cast<IMTPriceableItem*> (currentPI.GetInterfacePtr()));
			}
    }
  }
  catch (_com_error & err)
  {
    return LogAndReturnComError(PCCache::GetLogger(), err);
  }

  return S_OK;
}

// ----------------------------------------------------------------
// Description: Check a few basic validations before we would save modification to this PO to database.
//    This is for approvals to call
// ----------------------------------------------------------------
STDMETHODIMP CMTProductOffering::CheckCanSave()
{

  try
  {
    // validate (throws error on failure)
    Validate();

    // create instance of COM+ executant
    MTPRODUCTCATALOGEXECLib::IMTProductOfferingWriterPtr prodOffWriter(__uuidof(MTPRODUCTCATALOGEXECLib::MTProductOfferingWriter));
    
    // just cast "this"
    MTPRODUCTCATALOGEXECLib::IMTProductOffering* prodOff = reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTProductOffering *>(this);
		MTPRODUCTCATALOGLib::IMTProductOfferingPtr thisPoPtr = this;

    if (HasID())  //created
    {
      prodOffWriter->CheckConfigurationIfSettingAvailabilityDate(prodOff);
    }
  }
  catch (_com_error & err)
  {
    return LogAndReturnComError(PCCache::GetLogger(), err);
  }

  return S_OK;
}

STDMETHODIMP CMTProductOffering::AddPriceableItem(IMTPriceableItem* apPrcItemTmpl, IMTPriceableItem **apPrcItemInstance)
{
  if (!apPrcItemInstance)
    return E_POINTER;
  else
    *apPrcItemInstance = NULL;
  
  try
  {
    MTPRODUCTCATALOGEXECLib::IMTPriceableItemPtr prcItemTemplate = apPrcItemTmpl;

    // verify PO can be modified
    VARIANT_BOOL bCanBeModified = VARIANT_TRUE;
    HRESULT hr = CanBeModified(NULL, &bCanBeModified);
    if(FAILED(hr))
      MT_THROW_COM_ERROR(hr);

    if(bCanBeModified != VARIANT_TRUE)
      MT_THROW_COM_ERROR(MTPCUSER_PO_CAN_NOT_BE_MODIFIED);

    // verify compatible cycle    
    if(prcItemTemplate->Properties->Exist(CYCLE_PROPERTY))
    {
      MTPRODUCTCATALOGLib::IMTPropertyPtr prop = prcItemTemplate->Properties->GetItem(CYCLE_PROPERTY);
      MTPRODUCTCATALOGLib::IMTPCCyclePtr piCycle = prop->Value;
    
      if(FindPrcItemWithIncompatibleCycle(piCycle) != NULL)
        MT_THROW_COM_ERROR(MTPCUSER_BILLING_RELATIVE_CYCLE_CONFLICT);
    }

    //create instance from template
    MTPRODUCTCATALOGEXECLib::IMTPriceableItemPtr prcItemInstance = prcItemTemplate->CreateInstance();

    // if po has not yet been created add pi instance to in-memory collection
    // and insert pi instance in DB when po is saved
    // if po has already yet been created insert pi instance in DB now

    if (HasID()) //created
    {
      // create instance of COM+ executant
      MTPRODUCTCATALOGEXECLib::IMTPriceableItemWriterPtr writer(__uuidof(MTPRODUCTCATALOGEXECLib::MTPriceableItemWriter));
      writer->CreateInstance(GetSessionContextPtr(), GetID(), prcItemInstance);

			// We will also make sure that, by default, this priceable item is mapped to the internal pricelist
 			MapToNonSharedPL(reinterpret_cast<IMTPriceableItem*>(prcItemInstance.GetInterfacePtr()));

			*apPrcItemInstance = reinterpret_cast<IMTPriceableItem*>(prcItemInstance.Detach());
    }
    else //not yet created
    {
			// for UDRC, verify that there is no unit name conflict
			if(prcItemTemplate->PriceableItemType->Kind == PCENTITY_TYPE_RECURRING_UNIT_DEPENDENT)
			{
				long count;
				mPrcItemsToAdd.Count(&count);
				MTPRODUCTCATALOGLib::IMTRecurringChargePtr rc(prcItemTemplate.GetInterfacePtr());
				for(long i=1; i<=count; i++)
				{
					IMTPriceableItem* prcItem = NULL;
        
					hr = mPrcItemsToAdd.Item(i, &prcItem);
					if (FAILED(hr))
            return hr;
        
					MTPRODUCTCATALOGLib::IMTPriceableItemPtr prcItemPtr;
					prcItemPtr.Attach(reinterpret_cast<MTPRODUCTCATALOGLib::IMTPriceableItem*>(prcItem));
					if(prcItemPtr->PriceableItemType->Kind == PCENTITY_TYPE_RECURRING_UNIT_DEPENDENT)
					{
						MTPRODUCTCATALOGLib::IMTRecurringChargePtr rc2(prcItemPtr.GetInterfacePtr());
						if(rc->UnitName == rc2->UnitName)
						{
							MT_THROW_COM_ERROR(MTPCUSER_UDRC_DUPLICATE_UNIT_NAME_IN_PO, 
																 (const char *)rc->UnitName);
																 
						}
					}
				}
			}

      HRESULT hr = mPrcItemsToAdd.Add(reinterpret_cast<IMTPriceableItem*>(prcItemInstance.GetInterfacePtr()));
      if (FAILED(hr))
        return hr;

			*apPrcItemInstance = reinterpret_cast<IMTPriceableItem*>(prcItemInstance.Detach());
    }
  }
  catch (_com_error & err)
  {
    return LogAndReturnComError(PCCache::GetLogger(), err);
  }

  return S_OK;
}

STDMETHODIMP CMTProductOffering::RemovePriceableItem(long aPrcItemInstanceID)
{
  try
  {
    // verify PO can be modified
    VARIANT_BOOL bCanBeModified = VARIANT_TRUE;
    HRESULT hr = CanBeModified(NULL, &bCanBeModified);
    if(FAILED(hr))
      MT_THROW_COM_ERROR(hr);

    if(bCanBeModified != VARIANT_TRUE)
      MT_THROW_COM_ERROR(MTPCUSER_PO_CAN_NOT_BE_MODIFIED);

    // create writer instance
    MTPRODUCTCATALOGEXECLib::IMTPriceableItemWriterPtr writer(__uuidof(MTPRODUCTCATALOGEXECLib::MTPriceableItemWriter));
    
    // remove priceable item from the database
    writer->Remove(GetSessionContextPtr(), aPrcItemInstanceID);
  }
  catch (_com_error & err)
  {
    return LogAndReturnComError(PCCache::GetLogger(),err);
  }
  
  return S_OK;
}

STDMETHODIMP CMTProductOffering::GetPriceableItem(long aPrcItemInstanceID, IMTPriceableItem **apPrcItemInstance)
{
  if (!apPrcItemInstance)
    return E_POINTER;
  
  *apPrcItemInstance = NULL;

  try
  {
    // create reader instance
    MTPRODUCTCATALOGEXECLib::IMTPriceableItemReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTPriceableItemReader));

    // return the priceable item with that ID
    // TODO!!: only return PI if it is in the Prod Off
    *apPrcItemInstance = reinterpret_cast<IMTPriceableItem*> (reader->Find(GetSessionContextPtr(), aPrcItemInstanceID).Detach());
  }
  catch (_com_error & err)
  {
    return LogAndReturnComError(PCCache::GetLogger(),err);
  }

  return S_OK;
}

STDMETHODIMP CMTProductOffering::GetPriceableItemByName(BSTR aName, IMTPriceableItem **apPrcItemInstance)
{
  if (!apPrcItemInstance)
    return E_POINTER;
  
  *apPrcItemInstance = NULL;

  try
  {
    // create reader instance
    MTPRODUCTCATALOGEXECLib::IMTPriceableItemReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTPriceableItemReader));
    *apPrcItemInstance = reinterpret_cast<IMTPriceableItem*> (reader->FindInstanceByName(GetSessionContextPtr(), aName, GetID()).Detach());
  }
  catch (_com_error & err)
  {
    return LogAndReturnComError(PCCache::GetLogger(),err);
  }

  return S_OK;
}

STDMETHODIMP CMTProductOffering::GetPriceableItems(IMTCollection** apPrcItemInstances)
{
  if (!apPrcItemInstances)
    return E_POINTER;
  else
    *apPrcItemInstances = NULL;
    
  try
  {
    if (HasID()) //created
    {
      // read from DB
      MTPRODUCTCATALOGEXECLib::IMTPriceableItemReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTPriceableItemReader));
      
      MTPRODUCTCATALOGEXECLib::IMTCollectionPtr prcItems =
                    reader->FindInstances(GetSessionContextPtr(), GetID());
      *apPrcItemInstances = reinterpret_cast<IMTCollection*>(prcItems.Detach());
    }
    else
    {
      //not yet created, return in memory ones
      return mPrcItemsToAdd.CopyTo( apPrcItemInstances );
    }
  }
  catch (_com_error & err)
  {
    return LogAndReturnComError(PCCache::GetLogger(),err);
  }

  return S_OK;
}

STDMETHODIMP CMTProductOffering::GetPriceableItemsAsRowset(IMTRowSet** apRowset)
{
  if (!apRowset)
    return E_POINTER;
  else
    *apRowset = NULL;

  try
  {

    if (HasID()) //created
    {
      // create reader instance and pass through
      MTPRODUCTCATALOGEXECLib::IMTPriceableItemReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTPriceableItemReader));
      MTPRODUCTCATALOGEXECLib::IMTRowSetPtr aRowset = reader->FindInstancesAsRowset(GetSessionContextPtr(), GetID());
      *apRowset = reinterpret_cast<IMTRowSet*> (aRowset.Detach());
    }
    else
    {
      //not yet created, return disconnected rowset 

      ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
      rowset->InitDisconnected();

      //TODO: use correct columns!!
      rowset->AddColumnDefinition( "id_prop", "int32", 10);
      rowset->AddColumnDefinition( "nm_name", "string", 256);
      rowset->AddColumnDefinition( "nm_desc", "string", 256);
      rowset->AddColumnDefinition( "nm_internal", "string", 256);

      rowset->OpenDisconnected();

      //for all priceable item instances in list
      MTPRODUCTCATALOGLib::IMTPriceableItemPtr prcItemPtr;

      long count = 0;
      HRESULT hr = mPrcItemsToAdd.Count(&count);
      if (FAILED(hr)) return hr;

      for (long i = 1; i <= count; ++i)   // collection indexes are 1-based
      {
        IMTPriceableItem* prcItem = NULL;
        
        hr = mPrcItemsToAdd.Item( i, &prcItem);
        if (FAILED(hr)) return hr;
        
        prcItemPtr.Attach(reinterpret_cast<MTPRODUCTCATALOGLib::IMTPriceableItem*>(prcItem));
      
        rowset->AddRow();
        rowset->AddColumnData( "id_prop", prcItemPtr->ID );
        rowset->AddColumnData( "nm_name", prcItemPtr->Name );
        rowset->AddColumnData( "nm_desc", prcItemPtr->Description );
        rowset->AddColumnData( "nm_internal", prcItemPtr->Name );

      }
      ROWSETLib::IMTRowSetPtr aTempRowset = rowset; //QI
      *apRowset = reinterpret_cast<IMTRowSet*> (aTempRowset.Detach());
    }
  }
  catch (_com_error & err)
  {
    return LogAndReturnComError(PCCache::GetLogger(),err);
  }
  return S_OK;
}

STDMETHODIMP CMTProductOffering::GetPriceableItemsOfType(long aPITypeID, IMTCollection** apPrcItemInstances)
{
  if (!apPrcItemInstances)
    return E_POINTER;
  else
    *apPrcItemInstances = NULL;
    
  try
  {
    if (HasID()) //created
    {
      // read from DB
      MTPRODUCTCATALOGEXECLib::IMTPriceableItemReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTPriceableItemReader));
      
      MTPRODUCTCATALOGEXECLib::IMTCollectionPtr prcItems;
      prcItems = reader->FindInstancesOfType(GetSessionContextPtr(), GetID(), aPITypeID);

      *apPrcItemInstances = reinterpret_cast<IMTCollection*>(prcItems.Detach());
    }
    else
    {
			// TODO: FIXFIX filter out by pi type
      //not yet created, return in memory ones
      return mPrcItemsToAdd.CopyTo( apPrcItemInstances );
    }
  }
  catch (_com_error & err)
  {
    return LogAndReturnComError(PCCache::GetLogger(),err);
  }

  return S_OK;
}


// checks if PO can be modified
// if optional apErrors is provided, it will contain a collection of errors
STDMETHODIMP CMTProductOffering::CanBeModified(/*[out, optional]*/VARIANT* apErrors,
                                               /*[out, retval]*/ VARIANT_BOOL *apCanBeModifed)
{
  if (!apCanBeModifed)
    return E_POINTER;
  
  *apCanBeModifed = VARIANT_TRUE;

  try
  {
    //create an errors collection if errors are returned
    GENERICCOLLECTIONLib::IMTCollectionPtr errors;
    if (apErrors != NULL &&
        _variant_t(*apErrors) != vtMissing)
    {
      HRESULT hr = errors.CreateInstance(__uuidof(GENERICCOLLECTIONLib::MTCollection));
      if (FAILED(hr))
        MT_THROW_COM_ERROR(hr);

      //set out var
      _variant_t varErrors = errors.GetInterfacePtr();
      *apErrors = varErrors.Detach();
    }

    if (PCCache::IsBusinessRuleEnabled( PCCONFIGLib::MTPC_BUSINESS_RULE_ProdOff_CheckModification ))
    {
      // check availability date
      // this rule is not really neccessary any more, but kept in for backward compatibility
      // and in case we ever wanted to enable different rules for CanBeModified
      if (PCCache::IsBusinessRuleEnabled( PCCONFIGLib::MTPC_BUSINESS_RULE_ProdOff_NoModificationIfAvailable ))
      {
        VARIANT_BOOL hasAvailabilityDateBeenSet = VARIANT_FALSE;
        HasAvailabilityDateBeenSet(&hasAvailabilityDateBeenSet);
        
        if (hasAvailabilityDateBeenSet)
        {
          *apCanBeModifed = VARIANT_FALSE;
          
          //add error string if errors are returned
          if (errors != NULL)
          {
            Message message(MTPCUSER_PO_CAN_NOT_BE_MODIFIED);
            string msgText;
            message.GetErrorMessage(msgText,TRUE);
            errors->Add(msgText.c_str());
          }
        }
      }
    }
  }
  catch (_com_error & err)
  {
    return LogAndReturnComError(PCCache::GetLogger(),err);
  }
  return S_OK;
}

//validates state of object, throws user error if invalid
void CMTProductOffering::Validate()
{
  MTPRODUCTCATALOGLib::IMTProductOfferingPtr prodOff = this;

  //validate properties based on their meta data (required, length, ...)
  //throws _com_error on failure
  ValidateProperties();

  if (PCCache::IsBusinessRuleEnabled( PCCONFIGLib::MTPC_BUSINESS_RULE_ProdOff_CheckDates ))
  {
    // validate effective date
    MTPRODUCTCATALOGLib::IMTPCTimeSpanPtr effectiveDate = prodOff->EffectiveDate;
    if (effectiveDate->IsEndBeforeStart() == VARIANT_TRUE)
      MT_THROW_COM_ERROR(MTPCUSER_EFFECTIVE_END_BEFORE_START);

    // validate availability date
    MTPRODUCTCATALOGLib::IMTPCTimeSpanPtr availDate = prodOff->AvailabilityDate;
    if (availDate->IsEndBeforeStart() == VARIANT_TRUE)
      MT_THROW_COM_ERROR(MTPCUSER_AVAILABLE_END_BEFORE_START);
  }
}

STDMETHODIMP CMTProductOffering::CreateCopy(BSTR aNewName, VARIANT aNewCurrency, IMTProductOffering** apProdOff)
{
  if (!apProdOff)
    return E_POINTER;

  *apProdOff = NULL;

  try
  {
    MTPRODUCTCATALOGLib::IMTProductOfferingPtr thisProdOff = this;

    if (PCCache::GetLogger().IsOkToLog(LOG_DEBUG))
      PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "Creating copy of product offering: %s", (const char*)thisProdOff->Name);

    //construct a new product offering
    MTPRODUCTCATALOGLib::IMTProductOfferingPtr newProdOff(__uuidof(MTPRODUCTCATALOGLib::MTProductOffering));

    //pass the session context on to objects created from this one
    MTPRODUCTCATALOGLib::IMTSessionContextPtr ctxt = thisProdOff->GetSessionContext();
    newProdOff->SetSessionContext(ctxt);

    // assign the new name
    newProdOff->Name = aNewName;

    //copy all properties except dates
    newProdOff->DisplayName = thisProdOff->DisplayName;
    newProdOff->Description = thisProdOff->Description;
    newProdOff->SelfSubscribable = thisProdOff->SelfSubscribable;
    newProdOff->SelfUnsubscribable = thisProdOff->SelfUnsubscribable;

		// Determine if a different currency was specified, and if the new Product Offering can use it
		_variant_t vtNewCurrency;
		if ((OptionalVariantConversion(aNewCurrency, VT_BSTR, vtNewCurrency))
			&& (_bstr_t(vtNewCurrency.bstrVal) != _bstr_t(thisProdOff->GetCurrencyCode())))
		{
			// The new currency is different from the source one.
			// Then we need to check a couple of business rules.
			// First, is there any shared mapping on the source PO? If so, the new PO can't have a different currency.
			if (thisProdOff->GetCountOfPriceListMappings(MTPRODUCTCATALOGLib::MAPPING_NORMAL) > 0)
			{
				MT_THROW_COM_ERROR(MTPCUSER_CANNOT_SET_NEWPO_CURRENCY_SHARED_MAPPINGS, (char*) thisProdOff->GetCurrencyCode());
			}
			// If we got here, than all mappings are non-shared. Now check if there are any rate schedules on the non-shared PL.
			else if (thisProdOff->GetNonSharedPriceList()->GetRateScheduleCount() > 0)
			{
				MT_THROW_COM_ERROR(MTPCUSER_CANNOT_SET_NEWPO_CURRENCY_HAS_RATESCHEDULES, (char*) thisProdOff->GetCurrencyCode());
			}
			// Otherwise, we can safely set the new currency
			else
			{
				newProdOff->SetCurrencyCode(vtNewCurrency.bstrVal);
			}
		}
		else
		{
			newProdOff->SetCurrencyCode(thisProdOff->GetCurrencyCode());
		}

    //copy extended props
    CopyExtendedProperties(reinterpret_cast<IMTProperties*>(newProdOff->Properties.GetInterfacePtr()));

    //copy localized displaynames
    MetraTech_Localization::ILocalizedEntityPtr newDisplayNameLocalizationPtr(newProdOff->DisplayNames);
    MetraTech_Localization::ILocalizedEntityPtr thisDisplayNameLocalizationPtr(thisProdOff->DisplayNames);
    newDisplayNameLocalizationPtr->Copy(thisDisplayNameLocalizationPtr);

    //copy localized displaydescriptions
    MetraTech_Localization::ILocalizedEntityPtr newDisplayDescriptionLocalizationPtr(newProdOff->DisplayDescriptions);
    MetraTech_Localization::ILocalizedEntityPtr thisDisplayDescriptionLocalizationPtr(thisProdOff->DisplayDescriptions);
    newDisplayDescriptionLocalizationPtr->Copy(thisDisplayDescriptionLocalizationPtr);

    newProdOff->Save();

    MTPRODUCTCATALOGLib::IMTCollectionPtr items = thisProdOff->GetPriceableItems();
    long count = items->Count;

    for (long i = 1; i <= count; i++)
    {
      MTPRODUCTCATALOGLib::IMTPriceableItemPtr piInstance = items->GetItem(i);
      MTPRODUCTCATALOGLib::IMTPriceableItemPtr piTemplate = piInstance->GetTemplate();

      if (PCCache::GetLogger().IsOkToLog(LOG_DEBUG))
        PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "  Adding: %s", (const char*)piInstance->Name);

      MTPRODUCTCATALOGLib::IMTPriceableItemPtr newPiInstance = newProdOff->AddPriceableItem(piTemplate);

      // NOTE: we have to save it before we use CopyTo because CopyTo
      // will copy the price list mappings.  This can only be done if the
      // priceable item exists in the database.
      newPiInstance->Save();

      //copy instance (all properties, including cycle, counters, ...)
      piInstance->CopyTo(newPiInstance);

      // CR 10258: Eventually we need to revisit this, but for now, we need to call save again
      // so the properties set by the method above get commited to the db.
      newPiInstance->Save();
    }

    //copy account type restrictions
    GENERICCOLLECTIONLib::IMTCollectionExPtr acctypes = thisProdOff->SubscribableAccountTypes;
    GENERICCOLLECTIONLib::IMTCollectionExPtr exptr = newProdOff->SubscribableAccountTypes;
    count = acctypes->Count;
    exptr->Clear();
    for (long i = 1; i <= count; i++)
    {
      _variant_t accTypeName = acctypes->GetItem(i);
      newProdOff->SubscribableAccountTypes->Add(accTypeName);
    }

    // copy shared properties
    ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
    rowset->Init("queries\\PCWS");
    rowset->SetQueryTag("__COPY_SPECIFICATION_CHARACTERISTIC__");
    rowset->AddParam("%%ID_OLD_ENTITY%%", thisProdOff->ID);
    rowset->AddParam("%%ID_NEW_ENTITY%%", newProdOff->ID);
    rowset->Execute();

    *apProdOff = reinterpret_cast<IMTProductOffering*>( newProdOff.Detach() );
  }
  catch (_com_error & err)
  {
    return LogAndReturnComError(PCCache::GetLogger(), err);
  }
  return S_OK;
}

STDMETHODIMP CMTProductOffering::CheckConfiguration(IMTCollection ** apErrors)
{
  try
  {
    //create a new collection
    GENERICCOLLECTIONLib::IMTCollectionPtr errors(__uuidof(GENERICCOLLECTIONLib::MTCollection));

    if( PCCache::IsBusinessRuleEnabled(PCCONFIGLib::MTPC_BUSINESS_RULE_ProdOff_CheckConfiguration))
    {
      MTPRODUCTCATALOGLib::IMTProductOfferingPtr thisPtr(this);

      //for all priceable items: check its configuration
    
      MTPRODUCTCATALOGLib::IMTCollectionPtr prcItems;
      prcItems = thisPtr->GetPriceableItems();
      long count = prcItems->GetCount();
      if (count < 1){
        Message message(MTPCUSER_PO_HAS_NO_PRC);
        string msgString;
        message.FormatErrorMessage(msgString, TRUE,
          (const char*)thisPtr->Name);

        errors->Add(msgString.c_str());
      } else {
        for (long i = 1; i <= count; ++i)   // collection indexes are 1-based
        {
          MTPRODUCTCATALOGLib::IMTPriceableItemPtr prcItem;
          prcItem = prcItems->GetItem(i);

          CheckConfigurationForPIAndChildren(prcItem, errors);
        }
      }

      *apErrors = reinterpret_cast<IMTCollection*>(errors.Detach());
    }
  }
  catch (_com_error & err)
  {
    return LogAndReturnComError(PCCache::GetLogger(), err);
  }

  return S_OK;
}


//recursively check configuration for a prc item
void CMTProductOffering::CheckConfigurationForPIAndChildren(MTPRODUCTCATALOGLib::IMTPriceableItemPtr aPrcItem,
                                                            MTPRODUCTCATALOGLib::IMTCollectionPtr aErrors)
{
  MTPRODUCTCATALOGLib::IMTCollectionPtr prcItemErrors;
  prcItemErrors = aPrcItem->CheckConfiguration();

  //add any prcItemErrors
  long errorCount = prcItemErrors->GetCount();

  for (long errorIdx = 1; errorIdx <= errorCount; ++errorIdx)   // collection indexes are 1-based
  {
    _variant_t error = prcItemErrors->GetItem(errorIdx);
    aErrors->Add(error);
  }

  //check any children
  MTPRODUCTCATALOGLib::IMTCollectionPtr children;
  children = aPrcItem->GetChildren();
  long childCount = children->GetCount();
  for (long childIdx = 1; childIdx <= childCount; ++childIdx)   // collection indexes are 1-based
  {
    MTPRODUCTCATALOGLib::IMTPriceableItemPtr child;
    child = children->GetItem(childIdx);
    CheckConfigurationForPIAndChildren(child, aErrors);
  }
}

STDMETHODIMP CMTProductOffering::GetCountOfActiveSubscriptions(long *apSubCount)
{
  if (!apSubCount)
    return E_POINTER;
  
  *apSubCount = 0;

  try
  {
    // create reader instance
    MTPRODUCTCATALOGEXECLib::IMTSubscriptionReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionReader));

    *apSubCount = reader->GetCountOfActiveSubscriptionsByPO(GetSessionContextPtr(), GetID());
  }
  catch (_com_error & err)
  {
    return LogAndReturnComError(PCCache::GetLogger(),err);
  }

  return S_OK;
}

STDMETHODIMP CMTProductOffering::GetCountOfAllSubscriptions(long *apSubCount)
{
  if (!apSubCount)
    return E_POINTER;
  
  *apSubCount = 0;

  try
  {
    // create reader instance
    MTPRODUCTCATALOGEXECLib::IMTSubscriptionReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionReader));

    *apSubCount = reader->GetCountOfAllSubscriptionsByPO(GetSessionContextPtr(), GetID());
  }
  catch (_com_error & err)
  {
    return LogAndReturnComError(PCCache::GetLogger(),err);
  }

  return S_OK;
}


// checks the passed in cycle to make sure it is compatible with other
// cycle constraints (BCR Constrained or EBCR) already on the PO
// i.e, trying to add a Weekly BCR RC to a PO with a Monthly BCR Discount should fail.
// returns the first instance found that has a cycle incompatible with the passed in cycle
// otherwise NULL if none found
MTPRODUCTCATALOGLib::IMTPriceableItemPtr
    CMTProductOffering::FindPrcItemWithIncompatibleCycle(MTPRODUCTCATALOGLib::IMTPCCyclePtr aCycle,
                                                         MTPRODUCTCATALOGLib::IMTPriceableItemPtr aInstanceToIgnore /*=NULL*/)
{
	// Fixed and BCR unconstrained cycles need no checking since
	// they don't mandate a specific billing cycle
	if ((aCycle->Mode == CYCLE_MODE_FIXED) || (aCycle->Mode == CYCLE_MODE_BCR))
		return NULL;

	// this leaves only BCR Constrained and EBCR cycles that need validation

    // iterate through all PIs in this PO, and compare their
    // billing-relative cycle types (if any) with stored one
    MTPRODUCTCATALOGLib::IMTProductOfferingPtr po(this);
    MTPRODUCTCATALOGEXECLib::IMTCollectionPtr priceableItems = po->GetPriceableItems();
    int piCount = priceableItems->Count;
    int i;

    for(i = 1; i <= piCount; ++i)
    {
      MTPRODUCTCATALOGLib::IMTPriceableItemPtr curPI = priceableItems->GetItem(i);
      
      //skip the prcItemInstanceToIgnore if provided
		if (aInstanceToIgnore != NULL && curPI->ID == aInstanceToIgnore->ID)
        continue;

      // find out if new PI has a cycle, and it is billing-relative.
      // if it is, then look at its type
      if(curPI->Properties->Exist(CYCLE_PROPERTY))
      {
        MTPRODUCTCATALOGLib::IMTPropertyPtr curCycleProp = curPI->Properties->Item[CYCLE_PROPERTY];
        ASSERT(curCycleProp != NULL);
        MTPRODUCTCATALOGLib::IMTPCCyclePtr curCycle = curCycleProp->Value;
        ASSERT(curCycle != NULL);

			if(curCycle->IsMutuallyExclusive(aCycle))
          {
            //found incompatible PI
            return curPI;
          }
        }
      }

  //no incompatible PI found
  return NULL;
}


// returns the currency code of this product offering, or "" if not yet determined.
// The currency is determined by the currency of the price list used in the first price list mapping.
// All price list mappings within a product offering must use price lists of the same currency.
STDMETHODIMP CMTProductOffering::GetCurrencyCode(BSTR* apCurrency)
{
  if (!apCurrency)
    return E_POINTER;
  
  try
  {
		if (HasID())
		{
			MTPRODUCTCATALOGEXECLib::IMTProductOfferingReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTProductOfferingReader));
			_bstr_t currency = reader->GetCurrencyCode(GetSessionContextPtr(), GetID());
			*apCurrency = currency.copy();
		}
		else
		{
			*apCurrency = nonsharedPLCurrency.copy();
		}
  }
  catch (_com_error & err)
  {
    return LogAndReturnComError(PCCache::GetLogger(),err);
  }

  return S_OK;
}

// Sets the in-memmory currency code
// No effect if the Product Offering has been saved
// When PO.Save is called, this value will be used to configure the non-shared price list
STDMETHODIMP CMTProductOffering::SetCurrencyCode(BSTR aCurrency)
{
	// Todo: decide if we want this method to change the 
	// currency code on the db if the PO has been saved.
	if (!HasID())
	{
		nonsharedPLCurrency = aCurrency;
	}
  return S_OK;
}

void CMTProductOffering::OnSetSessionContext(IMTSessionContext* apSessionContext)
{
  // session context for nested objects can't be set inside the constructor
  // (since this object does not have a session context at the time it constructs its nested objects)
  // so set session context of derived objects now
  // caller will catch any exceptions
  MTPRODUCTCATALOGLib::IMTProductOfferingPtr thisPtr = this;

  thisPtr->EffectiveDate->SetSessionContext(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(apSessionContext));
  thisPtr->AvailabilityDate->SetSessionContext(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(apSessionContext));
}

// returns true if the availability start date is not empty
STDMETHODIMP CMTProductOffering::HasAvailabilityDateBeenSet(VARIANT_BOOL *apHasBeenSet)
{
  if (!apHasBeenSet)
    return E_POINTER;

  *apHasBeenSet = VARIANT_FALSE;

  try
  {
    MTPRODUCTCATALOGLib::IMTProductOfferingPtr thisPtr = this;

    //normalize date to make sure type is set correctly
    thisPtr->AvailabilityDate->Normalize();

    MTPRODUCTCATALOGLib::MTPCDateType startDateType = thisPtr->AvailabilityDate->StartDateType;

    if (startDateType != PCDATE_TYPE_NO_DATE &&
      startDateType != PCDATE_TYPE_NULL)
    {
      *apHasBeenSet = VARIANT_TRUE;;
    }
  }
  catch (_com_error & err)
  {
    return LogAndReturnComError(PCCache::GetLogger(),err);
  }

  return S_OK;
}


// specifies how distribution needs to be configured for a subscription based on this product offering
// returns DISTRIBUTION_REQUIREMENT_TYPE_NONE     if PO has no discount
//         DISTRIBUTION_REQUIREMENT_TYPE_ACCOUNT  if PO has at least one discount without distribution counter
//         DISTRIBUTION_REQUIREMENT_TYPE_ACCOUNT_OR_PROPORTIONAL  if PO has discounts, all of which have distribution counter
STDMETHODIMP CMTProductOffering::GetDistributionRequirement(MTDistributionRequirementType* apDistrReq)
{
  if (!apDistrReq)
    return E_POINTER;
  
  try
  {
    //set out var
    *apDistrReq = DISTRIBUTION_REQUIREMENT_TYPE_UNKNOWN;

		// Recall that if a discount is going to be proportionally distributed, then we need
		// to select the counter that will be used for distribution (e.g. the source or target counter).
		// As a result, not all discounts support proportional distribution (e.g. an unconditional flat discount/rebate cannot
		// be distributed "proportionally").  If the offering contains any discounts that do not
		// support proportional distribution, the offering itself will not support proportional distribution.
		MTPRODUCTCATALOGEXECLib::IMTProductOfferingReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTProductOfferingReader));
		long nDistributedDiscounts;
		long nUndistributedDiscounts;
		reader->GetDiscountDistribution(GetSessionContextPtr(), GetID(), &nDistributedDiscounts, &nUndistributedDiscounts);

    bool bHasDiscount = (nDistributedDiscounts + nUndistributedDiscounts) > 0;
    bool bHasDiscountWithoutDistribution = nUndistributedDiscounts > 0;
    
    //figure out the requirement
    if (bHasDiscount)
    {
      if (bHasDiscountWithoutDistribution)
        *apDistrReq = DISTRIBUTION_REQUIREMENT_TYPE_ACCOUNT;
      else
        *apDistrReq = DISTRIBUTION_REQUIREMENT_TYPE_ACCOUNT_OR_PROPORTIONAL;
    }
    else
      *apDistrReq = DISTRIBUTION_REQUIREMENT_TYPE_NONE;
  }
  catch (_com_error & err)
  {
    return LogAndReturnComError(PCCache::GetLogger(),err);
  }

  return S_OK;
}

STDMETHODIMP CMTProductOffering::GetConstrainedCycleType(MTUsageCycleType *pCycleType)
{
  try
  {
    *pCycleType = NO_CYCLE;
    MTPRODUCTCATALOGEXECLib::IMTProductOfferingReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTProductOfferingReader));
    return reader->raw_GetConstrainedCycleType(GetSessionContextPtr(), GetID(),
      (MTPRODUCTCATALOGEXECLib::MTUsageCycleType*)pCycleType);
  }
  catch (_com_error & err)
  {
    return LogAndReturnComError(PCCache::GetLogger(),err);
  }
  return S_OK;
}

STDMETHODIMP CMTProductOffering::GroupSubscriptionRequiresCycle(VARIANT_BOOL *pVal)
{
  ASSERT(pVal);
  if(!pVal) return E_POINTER;

  *pVal = VARIANT_FALSE;
  try {
		// A group subscription requires a cycle if there are any discounts
		// or aggregate charges that are billing cycle relative.
		// TODO: Should this also include per-subscription RCs?
		MTPRODUCTCATALOGEXECLib::IMTProductOfferingReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTProductOfferingReader));
		long nDiscounts;
		long nAggregates;
		long nRCs;
		reader->GetNumberOfCycleRelativePrcItems(GetSessionContextPtr(), GetID(), &nDiscounts, &nAggregates, &nRCs);

		*pVal = (nDiscounts + nAggregates) > 0 ? VARIANT_TRUE : VARIANT_FALSE;
  }
  catch(_com_error & err)
  {
    return LogAndReturnComError(PCCache::GetLogger(),err);
  }
  return S_OK;
}

STDMETHODIMP CMTProductOffering::CheckValidCycle(IMTPCCycle* apCycle, IMTPriceableItem* apInstanceToIgnore)
{
  if(!apCycle)
    return E_POINTER;

  try
  {
    MTPRODUCTCATALOGLib::IMTProductOfferingPtr thisPtr = this;
    MTPRODUCTCATALOGLib::IMTPCCyclePtr cycle = apCycle;
    
    // checks for conflicting cycle constraints from other PIs of this PO
    MTPRODUCTCATALOGLib::IMTPriceableItemPtr incompatiblePrcItem;
    incompatiblePrcItem = FindPrcItemWithIncompatibleCycle(apCycle, apInstanceToIgnore);
    if (incompatiblePrcItem != NULL)
    {
      //"Cycle conflicts with cycle of PI %s in PO %s"
      MT_THROW_COM_ERROR(MTPCUSER_CYCLE_CONFLICTS_WITH_OTHER_PRC_ITEM,
                          (char*) incompatiblePrcItem->Name,
                          (char*) thisPtr->Name);
    }

    // checks against cycle of account subscriptions to this PO
      MTPRODUCTCATALOGEXECLib::IMTSubscriptionReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionReader));
      long numConflictingAccounts;
		numConflictingAccounts = reader->GetCountOfSubscribersWithCycleConflicts(GetSessionContextPtr(),
																																						 thisPtr->ID,
																																						 (MTPRODUCTCATALOGEXECLib::IMTPCCycle *) apCycle);

      if (numConflictingAccounts > 0)
      {
        //Cycle conflicts with cycle of %1!d! subscriber(s) to [TEXT_KEYTERM_PRODUCT_OFFERING] '%2!s!'
        MT_THROW_COM_ERROR(MTPCUSER_CYCLE_CONFLICTS_WITH_ACCOUNT,
                           numConflictingAccounts,
                           (char*) thisPtr->Name);
      }

    // checks against cycles of group subscriptions to this PO
      ROWSETLib::IMTRowSetPtr groupSubRowset;
		groupSubRowset = reader->GetGroupSubscriptionsWithCycleConflictsAsRowset(GetSessionContextPtr(),
                                              thisPtr->ID,
																																						 cycle->CycleTypeID);
        
      if( groupSubRowset->RecordCount > 0 )
      { 
			// builds up string of conflicting groupSubs
        _bstr_t groupSubs;
        while(groupSubRowset->GetRowsetEOF().boolVal == VARIANT_FALSE)
        { 
          if (groupSubs.length() > 0)
            groupSubs += L", ";
          groupSubs += MTMiscUtil::GetString(groupSubRowset->GetValue("tx_name"));

          groupSubRowset->MoveNext();
        }

        //Cycle conflicts with cycle of the following [TEXT_KEYTERM_GROUP_SUBSCRIPTIONS] to [TEXT_KEYTERM_PRODUCT_OFFERING] '%1!s!':%n'%2!s!'
        MT_THROW_COM_ERROR(MTPCUSER_CYCLE_CONFLICTS_WITH_GROUP_SUB,
                           (char*) thisPtr->Name,
                           (char*) groupSubs);
      }
    }
  catch(_com_error & err)
  {
    return LogAndReturnComError(PCCache::GetLogger(),err);
  }

  return S_OK;
}

STDMETHODIMP CMTProductOffering::MapToNonSharedPL(IMTPriceableItem* apPi)
{    
  try
  {
    IMTProductOfferingPtr thisProdOff = this;
		IMTPriceableItemPtr currentPi = apPi; // making it easier to work with the Pi

    // First retrieve rowset that contains information about each parameter table included in this priceable item
		// Then either update the pricelist mapping or create a new one if necessary.
    ROWSETLib::IMTSQLRowsetPtr rowset = currentPi->GetNonICBPriceListMappingsAsRowset();

    // Loop through price list mapping collection and prepare a list of items to save.
    while(rowset->GetRowsetEOF().boolVal == VARIANT_FALSE)
    {
			//id_paramtable   tpt_nm_name   id_pricelist   tpl_nm_name   b_canICB   nm_display_name
			IMTPriceListMappingPtr plmap = currentPi->GetPriceListMapping(rowset->GetValue("id_paramtable"));
			plmap->PriceableItemID = currentPi->ID;
			plmap->ParamTableDefinitionID = rowset->GetValue("id_paramtable");
			plmap->PriceListID = thisProdOff->NonSharedPriceListID;
			if (plmap->CanICB != VARIANT_TRUE) // Necessary to handle the case where the value is not set initially
				plmap->CanICB = VARIANT_FALSE;
			plmap->MappingType = (MTPRODUCTCATALOGLib::MTPriceListMappingType) MAPPING_PO_PRICELIST;
      plmap->Save();
			rowset->MoveNext();
		}

		// Recurse for each contained pi child
		IMTCollectionPtr childrenColl = currentPi->GetChildren();
		for (int i = 1; i <= childrenColl->Count; i++)
		{
			IMTPriceableItemPtr currentChild = childrenColl->GetItem(i);
			MapToNonSharedPL(reinterpret_cast<IMTPriceableItem*> (currentChild.GetInterfacePtr()));
		}
  }
  catch (_com_error & err)
  {
    return LogAndReturnComError(PCCache::GetLogger(), err);
  }
  return S_OK;
}

STDMETHODIMP CMTProductOffering::GetCountOfPriceListMappings(MTPriceListMappingType aType, long *apCount)
{
  if (!apCount)
    return E_POINTER;
  
  *apCount = 0;

  try
  {
    // create reader instance
		MTPRODUCTCATALOGEXECLib::IMTPriceListMappingReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTPriceListMappingReader));
    MTPRODUCTCATALOGEXECLib::IMTProductOfferingPtr thisPtr = this;

		*apCount = reader->GetCountOfTypeByPO(GetSessionContextPtr(), thisPtr->ID, thisPtr->NonSharedPriceListID, (MTPRODUCTCATALOGEXECLib::MTPriceListMappingType) aType);
  }
  catch (_com_error & err)
  {
    return LogAndReturnComError(PCCache::GetLogger(),err);
  }

  return S_OK;
}

STDMETHODIMP CMTProductOffering::GetNonSharedPriceList(IMTPriceList** apPriceList)
{
  if (!apPriceList)
    return E_POINTER;
  
  *apPriceList = NULL;

  try
  {
    // create reader instance
		MTPRODUCTCATALOGLib::IMTProductCatalogPtr prodcat(__uuidof(MTPRODUCTCATALOGLib::MTProductCatalog));
		MTPRODUCTCATALOGEXECLib::IMTProductOfferingPtr thisPtr = this;
    MTPRODUCTCATALOGEXECLib::IMTPriceListPtr plPtr = prodcat->GetPriceList(thisPtr->NonSharedPriceListID);

		*apPriceList = reinterpret_cast<IMTPriceList*> (plPtr.Detach());
  }
  catch (_com_error & err)
  {
    return LogAndReturnComError(PCCache::GetLogger(),err);
  }

  return S_OK;
}
STDMETHODIMP CMTProductOffering::GetSubscribableAccountTypesAsRowset(IMTRowSet** apRowset)
{
  if (!apRowset)
    return E_POINTER;
  else
    *apRowset = NULL;

  try
  {

    if (HasID()) //created
    {
      MTPRODUCTCATALOGEXECLib::IMTProductOfferingReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTProductOfferingReader));
      MTPRODUCTCATALOGEXECLib::IMTRowSetPtr aRowset = reader->GetSubscribableAccountTypesAsRowset(GetSessionContextPtr(), GetID());
      *apRowset = reinterpret_cast<IMTRowSet*> (aRowset.Detach());
      //BP TODO: Initialize "SubscribableAccountTypes" collection?
    }
    else
    {
      //BP TODO: Error out?
      *apRowset = NULL;
    }
  }
  catch (_com_error & err)
  {
    return LogAndReturnComError(PCCache::GetLogger(),err);
  }
  return S_OK;
}

STDMETHODIMP CMTProductOffering::AddSubscribableAccountType(int aTypeID)
{
  try
  {

    if (HasID()) //created
    {
      MetraTech_Accounts_Type::IAccountTypeManagerPtr mgr(__uuidof(MetraTech_Accounts_Type::AccountTypeManager));
      MTAccountTypeLib::IMTAccountTypePtr at = mgr->GetAccountTypeByID
        (reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext *>(GetSessionContextPtr().GetInterfacePtr()), aTypeID);
      MTPRODUCTCATALOGEXECLib::IMTProductOfferingWriterPtr writer(__uuidof(MTPRODUCTCATALOGEXECLib::MTProductOfferingWriter));
      writer->AddSubscribableAccountType(GetSessionContextPtr(), 
      GetID(), 
      reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTAccountType *>(at.GetInterfacePtr()));
      //add it to properties collection
      _bstr_t name = at->Name;
      MTPRODUCTCATALOGLib::IMTProductOfferingPtr ThisPtr = this;
      ThisPtr->SubscribableAccountTypes->Add(at->Name);

    }
    else
    {
      //BP TODO: Error out
      return S_OK;
    }
  }
  catch (_com_error & err)
  {
    return LogAndReturnComError(PCCache::GetLogger(),err);
  }
  return S_OK;
}

STDMETHODIMP CMTProductOffering::RemoveSubscribableAccountType(int aTypeID)
{
  try
  {

    if (HasID()) //created
    {
      MetraTech_Accounts_Type::IAccountTypeManagerPtr mgr(__uuidof(MetraTech_Accounts_Type::AccountTypeManager));
      MTAccountTypeLib::IMTAccountTypePtr at = mgr->GetAccountTypeByID
        (reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext *>(GetSessionContextPtr().GetInterfacePtr()), aTypeID);
      MTPRODUCTCATALOGEXECLib::IMTProductOfferingWriterPtr writer(__uuidof(MTPRODUCTCATALOGEXECLib::MTProductOfferingWriter));
      writer->RemoveSubscribableAccountType(GetSessionContextPtr(), 
        GetID(), 
        reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTAccountType *>(at.GetInterfacePtr()));
      //remove it from properties collection
      MTPRODUCTCATALOGLib::IMTProductOfferingPtr ThisPtr = this;
      for(int index = 1; index <= ThisPtr->SubscribableAccountTypes->GetCount(); index++) 
      {
		    _bstr_t acctypename = ThisPtr->SubscribableAccountTypes->GetItem(index);
        //BP: maybe we can just store IMTAccountType objects instead of names.
        MTAccountTypeLib::IMTAccountTypePtr at = mgr->GetAccountTypeByName
        (reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext *>(GetSessionContextPtr().GetInterfacePtr()), acctypename);
		    if(at->ID == aTypeID) 
        {
          ThisPtr->SubscribableAccountTypes->Remove(index);
        }
			  return S_OK;
		  }
    }
    else
    {
      //BP TODO: Error out
      return S_OK;
    }
  }
  catch (_com_error & err)
  {
    return LogAndReturnComError(PCCache::GetLogger(),err);
  }
  return S_OK;
}
