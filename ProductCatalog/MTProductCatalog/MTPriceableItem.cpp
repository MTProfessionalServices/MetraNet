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
* $Header: c:\development35\ProductCatalog\MTProductCatalog\MTPriceableItem.cpp, 49, 11/13/2002 7:15:00 PM, David Blair$
* 
***************************************************************************/

#include "StdAfx.h"
#include <mtprogids.h>
#include <comdef.h>
#include <mtcomerr.h>

#pragma warning(disable: 4297)  // disable warning "function assumed not to throw an exception but does"

#include "MTProductCatalog.h"
#include "MTPriceableItem.h"

using MTPRODUCTCATALOGLib::IMTPriceListMappingPtr;
using MTPRODUCTCATALOGLib::IMTPriceListPtr;
using MTPRODUCTCATALOGLib::IMTProductOfferingPtr;
using MTPRODUCTCATALOGLib::IMTParamTableDefinitionPtr;
using MTPRODUCTCATALOGLib::IMTRateSchedulePtr;

#import <MetraTech.Localization.tlb>

/////////////////////////////////////////////////////////////////////////////
// CMTPriceableItem

CMTPriceableItem::CMTPriceableItem()
{
	mpTemplate = NULL;
	mCreateChildren = VARIANT_FALSE;
    PCCache::GetLogger().LogVarArgs(LOG_TRACE, "CMTPriceableItem::CMTPriceableItem() Created Instance [%p]", this);
}

CMTPriceableItem::~CMTPriceableItem()
{
    PCCache::GetLogger().LogVarArgs(LOG_TRACE, "CMTPriceableItem::~CMTPriceableItem() Destroying Instance [%p]", this);
    long lCnt = 0;
    HRESULT hr = mAdjustments.Count(&lCnt);
    if(S_OK == hr && 0 != lCnt)
    {
		// Added to remove memory leak reported in ESR-4503
        while(lCnt != 0)
        {
			// Must remove to clear reference count
            mAdjustments.Remove(1); 
            hr = mAdjustments.Count(&lCnt);
        }
        mAdjustments.Clear();
        mAdjustments = NULL;
    }
}


STDMETHODIMP CMTPriceableItem::get_ID(long *pVal)
{
	return GetPropertyValue("ID", pVal);
}
STDMETHODIMP CMTPriceableItem::put_ID(long newVal)
{
	return PutPropertyValue("ID", newVal);
}

STDMETHODIMP CMTPriceableItem::get_Kind(MTPCEntityType *pVal)
{
	return GetPropertyValue("Kind", reinterpret_cast<long*>(pVal));
}

STDMETHODIMP CMTPriceableItem::put_Kind(MTPCEntityType newVal)
{
	return PutPropertyValue("Kind", static_cast<long>(newVal));
}

STDMETHODIMP CMTPriceableItem::get_Name(BSTR *pVal)
{
	return GetPropertyValue("Name", pVal);
}

STDMETHODIMP CMTPriceableItem::put_Name(BSTR newVal)
{
	return PutPropertyValue("Name", newVal);
}

STDMETHODIMP CMTPriceableItem::get_DisplayName(BSTR *pVal)
{
	return GetPropertyValue("DisplayName", pVal);
}

STDMETHODIMP CMTPriceableItem::put_DisplayName(BSTR newVal)
{
	return PutPropertyValue("DisplayName", newVal);
}

STDMETHODIMP CMTPriceableItem::get_DisplayNames(IDispatch **pVal)
{
  //Here we delay the construction of the nested Localization object until it is actually needed.
  HRESULT hr;
  hr=GetPropertyObject( "DisplayNames", reinterpret_cast<IDispatch**>(pVal) );
  if (FAILED(hr))
  {
   	MetraTech_Localization::ILocalizedEntityPtr displayNameLocalizationPtr(__uuidof(MetraTech_Localization::LocalizedEntity));
		PutPropertyObject("DisplayNames", displayNameLocalizationPtr);
    hr=GetPropertyObject( "DisplayNames", reinterpret_cast<IDispatch**>(pVal) );
  }
  
  return hr;
}

STDMETHODIMP CMTPriceableItem::get_DisplayDescriptions(IDispatch **pVal)
{
  //Here we delay the construction of the nested Localization object until it is actually needed.
  HRESULT hr;
  hr=GetPropertyObject( "DisplayDescriptions", reinterpret_cast<IDispatch**>(pVal) );
  if (FAILED(hr))
  {
   	MetraTech_Localization::ILocalizedEntityPtr displayDescLocalizationPtr(__uuidof(MetraTech_Localization::LocalizedEntity));
		PutPropertyObject("DisplayDescriptions", displayDescLocalizationPtr);
    hr=GetPropertyObject( "DisplayDescriptions", reinterpret_cast<IDispatch**>(pVal) );
  }
  
  return hr;
}

STDMETHODIMP CMTPriceableItem::get_Description(BSTR *pVal)
{
	return GetPropertyValue("Description", pVal);
}

STDMETHODIMP CMTPriceableItem::put_Description(BSTR newVal)
{
	return PutPropertyValue("Description", newVal);
}

STDMETHODIMP CMTPriceableItem::get_PriceableItemType(IMTPriceableItemType **pVal)
{
	return GetPropertyObject( "PriceableItemType", reinterpret_cast<IDispatch**>(pVal) );
}

STDMETHODIMP CMTPriceableItem::put_PriceableItemType(IMTPriceableItemType* newVal)
{
	return PutPropertyObject( "PriceableItemType", newVal );
}

STDMETHODIMP CMTPriceableItem::get_ParentID(long *pVal)
{
	return GetPropertyValue("ParentID", pVal);
}

STDMETHODIMP CMTPriceableItem::put_ParentID(long newVal)
{
	return PutPropertyValue("ParentID", newVal);
}

STDMETHODIMP CMTPriceableItem::get_TemplateID(long *pVal)
{
	//if we have a in-mem template use that one
	if (mpTemplate != NULL)
		return mpTemplate->get_ID( pVal);
	else	
		return GetPropertyValue("TemplateID", pVal);
}

STDMETHODIMP CMTPriceableItem::put_TemplateID(long newVal)
{
	//make sure to not use the in memory template
	// to avoid inconsistencey between GetTemplate() and get_TemplateID();
	mpTemplate = NULL;
	
	return PutPropertyValue("TemplateID", newVal);
}

STDMETHODIMP CMTPriceableItem::get_ProductOfferingID(long *pVal)
{
	return GetPropertyValue("ProductOfferingID", pVal);
}

STDMETHODIMP CMTPriceableItem::put_ProductOfferingID(long newVal)
{
	return PutPropertyValue("ProductOfferingID", newVal);
}

STDMETHODIMP CMTPriceableItem::get_CreateChildren(VARIANT_BOOL *pVal)
{
	//non-persistent property, not exposed in MTProperties collection	
	if (!pVal)
		return E_POINTER;
	
	*pVal = mCreateChildren;
	return S_OK;
}

STDMETHODIMP CMTPriceableItem::put_CreateChildren(VARIANT_BOOL newVal)
{
	//non-persistent property, not exposed in MTProperties collection	
	mCreateChildren = newVal;
	return S_OK;
}

STDMETHODIMP CMTPriceableItem::Save(IMTPriceableItem* apPrcItemThis)
{
  try
	{
		//validate properties based on their meta data (required, length, ...)
		//throws _com_error on failure
		ValidateProperties();

		// create instance of COM+ executant
		MTPRODUCTCATALOGEXECLib::IMTPriceableItemWriterPtr writer(__uuidof(MTPRODUCTCATALOGEXECLib::MTPriceableItemWriter));
		
		// note "this" CMTPriceableItem does not inherit from IMTPriceableItem
		// so we habe to pass the IMTPriceableItem in
		MTPRODUCTCATALOGEXECLib::IMTPriceableItemPtr prcItemThis = apPrcItemThis;

		if (HasID())  //created
			writer->Update(GetSessionContextPtr(), prcItemThis);
		else					// not yet created
		{ 
			VARIANT_BOOL isTemplate;
			IsTemplate(&isTemplate);
			
			if (isTemplate == VARIANT_TRUE)
			{
				put_ID( writer->CreateTemplate(GetSessionContextPtr(), prcItemThis) );
			}
			else
			{	MT_THROW_COM_ERROR( IID_IMTPriceableItem, "You cannot create a priceable item instances by calling CMTPriceableItem::Save()."
			                                              "Priceable item instances are created by adding the template to a product offering.");
			}
		}
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(), err);
	}

	return S_OK;
}

//returns NULL if priceableItem has no parent
STDMETHODIMP CMTPriceableItem::GetParent(IMTPriceableItem** apParentPrcItem)
{
	if (!apParentPrcItem)
		return E_POINTER;

	*apParentPrcItem = NULL;

  try
	{
		long parentID = PROPERTIES_BASE_NO_ID;
		HRESULT hr = get_ParentID(&parentID);
		if(FAILED(hr))
			return hr;

		if (parentID != PROPERTIES_BASE_NO_ID)
		{
			// create reader instance
			MTPRODUCTCATALOGEXECLib::IMTPriceableItemReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTPriceableItemReader));
			*apParentPrcItem = reinterpret_cast<IMTPriceableItem*> (reader->Find(GetSessionContextPtr(), parentID).Detach());
		}
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

STDMETHODIMP CMTPriceableItem::GetChildren(IMTCollection** apChildren)
{
	if (!apChildren)
		return E_POINTER;

	*apChildren = NULL;

  try
	{
	  // create reader instance
		MTPRODUCTCATALOGEXECLib::IMTPriceableItemReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTPriceableItemReader));

		VARIANT_BOOL isTemplate;
		IsTemplate(&isTemplate);

		if (isTemplate == VARIANT_TRUE)
			*apChildren = reinterpret_cast<IMTCollection*> (reader->FindChildTemplates(GetSessionContextPtr(), GetID()).Detach());
		else
			*apChildren = reinterpret_cast<IMTCollection*> (reader->FindChildInstances(GetSessionContextPtr(), GetID()).Detach());
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

STDMETHODIMP CMTPriceableItem::GetChildrenAsRowset(IMTRowSet** apRowset)
{
	if (!apRowset)
		return E_POINTER;

	*apRowset = NULL;

  try
	{
	  // create reader instance
		MTPRODUCTCATALOGEXECLib::IMTPriceableItemReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTPriceableItemReader));
		MTPRODUCTCATALOGEXECLib::IMTRowSetPtr rowset;
		
		VARIANT_BOOL isTemplate;
		IsTemplate(&isTemplate);

		if (isTemplate == VARIANT_TRUE)
			rowset = reader->FindChildTemplatesAsRowset(GetSessionContextPtr(), GetID());
		else
			rowset = reader->FindChildInstancesAsRowset(GetSessionContextPtr(), GetID());

		*apRowset	= reinterpret_cast<IMTRowSet*> (rowset.Detach());
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

//gets child with given ID, if there is no child with that ID returns error
STDMETHODIMP CMTPriceableItem::GetChild(long aID, IMTPriceableItem** apPrcItem)
{
	if (!apPrcItem)
		return E_POINTER;

	*apPrcItem = NULL;

  try
	{
		MTPRODUCTCATALOGEXECLib::IMTPriceableItemReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTPriceableItemReader));
		*apPrcItem = reinterpret_cast<IMTPriceableItem*> (reader->FindChild(GetSessionContextPtr(), GetID(), aID).Detach());
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}


STDMETHODIMP CMTPriceableItem::GetPriceListMappingsAsRowset(/*[out, retval]*/ IMTRowSet **apRowset)
{
	//return Non-ICB and ICB pricelist mappings
	return DoGetPriceListMappingsAsRowset(VARIANT_TRUE, apRowset);
}

STDMETHODIMP CMTPriceableItem::GetNonICBPriceListMappingsAsRowset(/*[out, retval]*/ IMTRowSet **apRowset)
{
	//return Non-ICB pricelist mappings only
	return DoGetPriceListMappingsAsRowset(VARIANT_FALSE, apRowset);
}

STDMETHODIMP CMTPriceableItem::DoGetPriceListMappingsAsRowset(VARIANT_BOOL aIncludeICB, IMTRowSet **apRowset)
{
	if (!apRowset)
		return E_POINTER;

  try
	{
		// create reader instance and pass through
		MTPRODUCTCATALOGEXECLib::IMTPriceableItemReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTPriceableItemReader));
		MTPRODUCTCATALOGEXECLib::IMTRowSetPtr aRowset = reader->FindPriceListMappingsAsRowset(GetSessionContextPtr(), GetID(), aIncludeICB);
		*apRowset	= reinterpret_cast<IMTRowSet*> (aRowset.Detach());
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}
	return S_OK;
}


STDMETHODIMP CMTPriceableItem::GetPriceListMapping(/*[in]*/ long aParamTblDefID, /*[out, retval]*/ IMTPriceListMapping** apPrcLstMap)
{
	if (!apPrcLstMap)
		return E_POINTER;

  try
	{
	  // create reader instance
		MTPRODUCTCATALOGEXECLib::IMTPriceListMappingReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTPriceListMappingReader));

		*apPrcLstMap = reinterpret_cast<IMTPriceListMapping*> (reader->FindByInstance(GetSessionContextPtr(), GetID(), aParamTblDefID).Detach());
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

STDMETHODIMP CMTPriceableItem::SetPriceListMapping(/*[in]*/ long aParamTblDefID, /*[in]*/ long aPrcLstID)
{
  try
	{
		// create instance of COM+ executant
		MTPRODUCTCATALOGEXECLib::IMTPriceableItemWriterPtr writer(__uuidof(MTPRODUCTCATALOGEXECLib::MTPriceableItemWriter));
		writer->SetPriceListMapping(GetSessionContextPtr(), GetID(), aParamTblDefID, aPrcLstID);
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

/*
STDMETHODIMP SetAllPriceListMappings( long aPrcLstID)
{
  try
	{
		// create instance of COM+ executant
		MTPRODUCTCATALOGEXECLib::IMTPriceableItemWriterPtr writer(__uuidof(MTPRODUCTCATALOGEXECLib::MTPriceableItemWriter));
		writer->SetAllPriceListMappings(GetSessionContextPtr(), GetID(), aPrcLstID);
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}
*/

//returns VARIANT_TRUE if this is a pricable item template
//returns VARIANT_FALSE if this is a pricable item instance
STDMETHODIMP CMTPriceableItem::IsTemplate(VARIANT_BOOL* apIsTemplate)
{
	if (!apIsTemplate)
		return E_POINTER;
	else
		*apIsTemplate = VARIANT_FALSE;

	//this is a template if neither templateID nor mpTemplate has been set
	//only instances have the templateID (or mpTemplate) set
	if (mpTemplate == NULL)
	{
		long templateID;
		HRESULT hr = get_TemplateID(&templateID);

		if(FAILED(hr))
			return hr;

		if (templateID == PROPERTIES_BASE_NO_ID)
			*apIsTemplate = VARIANT_TRUE;
	}
		
	return S_OK;
}

// for instances: returns the the template that this instance is based on
// for templates: returns NULL
STDMETHODIMP CMTPriceableItem::GetTemplate(/*[out, retval]*/ IMTPriceableItem** apPrcItemTemplate)
{
	if (!apPrcItemTemplate)
		return E_POINTER;
	
	*apPrcItemTemplate = NULL;

  try
	{
		VARIANT_BOOL isTemplate;
		IsTemplate( &isTemplate );
		
		if( isTemplate == VARIANT_TRUE )
		{	
			// for templates: return NULL
			*apPrcItemTemplate = NULL;
		}
		else
		{
			// for instances:

			// if we have a in-memory template use that one
			// otherwise load it from DB

			if (mpTemplate == NULL) 
			{
				// create reader instance
				MTPRODUCTCATALOGEXECLib::IMTPriceableItemReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTPriceableItemReader));

				long templateID;
				get_TemplateID(&templateID);
				*apPrcItemTemplate = reinterpret_cast<IMTPriceableItem*> (reader->Find(GetSessionContextPtr(), templateID).Detach());
			}
			else	//not yet created
			{
				mpTemplate.CopyTo(apPrcItemTemplate);
			}
		}
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

// helper to store the template (in case the template has not been created yet)
STDMETHODIMP CMTPriceableItem::SetTemplate(/*[in]*/ IMTPriceableItem* apPrcItemTemplate)
{
	
	mpTemplate = apPrcItemTemplate;
	
	//also set the ID to be consistent
	long templateID = -1;
	HRESULT hr = apPrcItemTemplate->get_ID(&templateID);
	if (FAILED(hr))
		return hr;

	PutPropertyValue("TemplateID", templateID); //can't call put_TemplateID since that releases mpTemplate

	return S_OK;
}

// for templates: creates an instance based on this template
// for instances: ERROR
STDMETHODIMP CMTPriceableItem::CreateInstance(IMTPriceableItem* apPrcItemThis, IMTPriceableItem** apPrcItemInstance)
{
	if (!apPrcItemInstance)
		return E_POINTER;

	*apPrcItemInstance = NULL;
	
	try
	{
		MTPRODUCTCATALOGLib::IMTPriceableItemPtr prcItemTmplThis = apPrcItemThis;

		//only valid for templates
		if( prcItemTmplThis->IsTemplate() == VARIANT_FALSE)
		{
			MT_THROW_COM_ERROR(IID_IMTPriceableItem, "CreateInstance can only be called on templates");
		}
		
		//create a priceable item of the same kind as this template
		MTPCEntityType kind;
		get_Kind(&kind);
		
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
				MT_THROW_COM_ERROR(IID_IMTPriceableItem, MTPC_INVALID_PRICEABLE_ITEM_KIND, kind);
		}

		MTPRODUCTCATALOGLib::IMTPriceableItemPtr prcItemInstance(clsid);

		//pass the session context on to objects created from this one
		MTPRODUCTCATALOGLib::IMTSessionContextPtr ctxt = prcItemTmplThis->GetSessionContext();
		prcItemInstance->SetSessionContext(ctxt);

		// set template
		// note: template does not have to be created in db yet
		//        (in which case, the template will be created when the instance gets created)
		prcItemInstance->SetTemplate(prcItemTmplThis);

		//copy all members from template to instance		
		prcItemTmplThis->CopyTo(prcItemInstance);

		// if this templates has children (usage charge only)
		// the child instances will be created when parent instance is inserted into DB
		// (otherwise we'd need to store childrenToCreate in the pi instance object)

		*apPrcItemInstance = reinterpret_cast<IMTPriceableItem*>(prcItemInstance.Detach());
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

// copies this instance or template to another instance or template
// does a deep copy (includes derived type objects)
STDMETHODIMP CMTPriceableItem::CopyTo(IMTPriceableItem* apPrcItemThis, IMTPriceableItem* apTarget)
{
	if (!apTarget)
		return E_POINTER;

	try
	{
		MTPRODUCTCATALOGLib::IMTPriceableItemPtr sourcePrcItem = apPrcItemThis;
		MTPRODUCTCATALOGLib::IMTPriceableItemPtr targetPrcItem = apTarget;
		MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr sourceType = sourcePrcItem->PriceableItemType;

		// copy names and description, type
		targetPrcItem->Name = sourcePrcItem->Name;
		targetPrcItem->DisplayName = sourcePrcItem->DisplayName;
		targetPrcItem->Description = sourcePrcItem->Description;
		targetPrcItem->PriceableItemType = sourceType;

    // usually copying the kind from template to instance wouldn't be necessary but it is at the moment
    // for UDRCs (both kind=20 and 25 are handled by MTRecurringCharge)
    targetPrcItem->Kind = sourcePrcItem->Kind;

		//copy extended properties
		CopyExtendedProperties(reinterpret_cast<IMTProperties*>(targetPrcItem->Properties.GetInterfacePtr()));

		//copy the non base members for any derived class
    CopyNonBaseMembersTo(reinterpret_cast<IMTPriceableItem*>(targetPrcItem.GetInterfacePtr()));

    //create adjustment instances and set it on the newly created PI instance
    //for every adjustment template
    CopyAdjustmentsTo(
      reinterpret_cast<IMTPriceableItem*>(sourcePrcItem.GetInterfacePtr()),
      reinterpret_cast<IMTPriceableItem*>(targetPrcItem.GetInterfacePtr()));

		//for instances set pricelist mappings
		if( sourcePrcItem->IsTemplate() == VARIANT_FALSE &&
				targetPrcItem->IsTemplate() == VARIANT_FALSE)
		{
			// copy all pricelist mappings
			HRESULT hr = CopyPriceListMappingsTo(
				(IMTPriceableItem *) sourcePrcItem.GetInterfacePtr(),
				(IMTPriceableItem *) targetPrcItem.GetInterfacePtr());

			if (FAILED(hr))
				return hr;
		}

		// recursively copy the children.  To do this we have to match the
		// children by template ID.
		// NOTE: this only works if the target has already been saved in the database.
		long id = targetPrcItem->GetID();
		if (id != -1)
		{
			// it's been saved so we need to copy the children
			MTPRODUCTCATALOGLib::IMTCollectionPtr sourceChildren = sourcePrcItem->GetChildren();
			MTPRODUCTCATALOGLib::IMTCollectionPtr targetChildren = targetPrcItem->GetChildren();

			ASSERT(sourceChildren->GetCount() == targetChildren->GetCount());

			// for each child of the source
			for (long i = 1; i <= sourceChildren->GetCount(); i++)
			{
				MTPRODUCTCATALOGLib::IMTPriceableItemPtr sourceChild = sourceChildren->GetItem(i);

				// find the template ID
				long sourceTemplateID = -1;
				if (sourceChild->IsTemplate() == VARIANT_TRUE)
					sourceTemplateID = sourceChild->GetID();
				else
					sourceTemplateID = sourceChild->GetTemplate()->GetID();

				ASSERT(sourceTemplateID != -1);

				MTPRODUCTCATALOGLib::IMTPriceableItemPtr targetChild;
				// find the matching child in the target list
				for (long j = 1; j <= targetChildren->GetCount(); j++)
				{
					MTPRODUCTCATALOGLib::IMTPriceableItemPtr testChild = targetChildren->GetItem(j);

					// find the template ID
					long testTemplateID = -1;
					if (testChild->IsTemplate() == VARIANT_TRUE)
						testTemplateID = testChild->GetID();
					else
						testTemplateID = testChild->GetTemplate()->GetID();
					ASSERT(testTemplateID != -1);

					if (testTemplateID == sourceTemplateID)
					{
						// we have a match
						targetChild = testChild;
						break;
					}
				}

				if (targetChild == NULL)
				{
					// no matching child!  this shouldn't happen
					MT_THROW_COM_ERROR(IID_IMTPriceableItem, MTPC_ITEM_NOT_FOUND);
				}

				// NOTE: we have to save the child because that's the only way we can
				// copy pricelist mappings!  mappings only exist on instances
				// so we only save if this priceable item is an instance
				if (targetChild->IsTemplate() == VARIANT_FALSE)
					targetChild->Save();

				// copy the child
				sourceChild->CopyTo(targetChild);
			}
		}
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}


HRESULT CMTPriceableItem::CopyPriceListMappingsTo(IMTPriceableItem* apPrcItemThis, IMTPriceableItem* apTarget)
{
	if (!apTarget)
		return E_POINTER;

	try
	{
		MTPRODUCTCATALOGLib::IMTPriceableItemPtr sourcePrcItem = apPrcItemThis;
		MTPRODUCTCATALOGLib::IMTPriceableItemPtr targetPrcItem = apTarget;
		MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr sourceType = sourcePrcItem->PriceableItemType;
		MTPRODUCTCATALOGLib::IMTProductOfferingPtr sourcePo = sourcePrcItem->GetProductOffering();
		MTPRODUCTCATALOGLib::IMTProductOfferingPtr targetPo = targetPrcItem->GetProductOffering();

		// do one more test - this error should never happen because we check in CopyTo
		if( sourcePrcItem->IsTemplate() == VARIANT_TRUE ||
				targetPrcItem->IsTemplate() == VARIANT_TRUE)
			//return Error("Source and targets priceable item must be instances to copy price list mappings");
		{
			ASSERT(0);
			return E_FAIL;
		}

		MTPRODUCTCATALOGLib::IMTRowSetPtr rowset = sourcePrcItem->GetNonICBPriceListMappingsAsRowset();

		while (rowset->GetRowsetEOF().boolVal == VARIANT_FALSE)
		{
			_variant_t paramtable = rowset->GetValue("id_paramtable");
			_variant_t pricelist = rowset->GetValue("id_pricelist");
			_variant_t canICB = rowset->GetValue("b_canICB");

			if (V_VT(&pricelist) != VT_NULL)
			{
				if (pricelist.lVal == sourcePo->NonSharedPriceListID)
				{
					// This param table is mapped to the non-shared pl on the source PO. 
					// ... so we need to create copies of the rate schedules and associate them.
					// for each rs in this pt/pi combination... .
					// This action constitutes the "Deep Copy"
					IMTPriceListMappingPtr thisPlmPtr = sourcePrcItem->GetPriceListMapping(paramtable.lVal);
					MTPRODUCTCATALOGLib::IMTRowSetPtr rsRowsetPtr = thisPlmPtr->FindRateSchedulesAsRowset();
					while (rsRowsetPtr->GetRowsetEOF().boolVal == VARIANT_FALSE)
					{
						IMTParamTableDefinitionPtr thisPtPtr = thisPlmPtr->GetParameterTable();
						IMTRateSchedulePtr currentRSPtr = thisPtPtr->GetRateSchedule(rsRowsetPtr->GetValue("id_sched"));
						IMTRateSchedulePtr rsCopyPtr = currentRSPtr->CreateCopy();
						rsCopyPtr->PriceListID = targetPo->NonSharedPriceListID;
						rsCopyPtr->SaveWithRules();
						rsRowsetPtr->MoveNext();
					}
				}
				else
				{
					// TODO: is this the best way to copy the pricelist mapping?
					// there is a pricelist mapping
					targetPrcItem->SetPriceListMapping((long) paramtable, (long) pricelist);
					// have to copy the ICB flag as well
					MTPRODUCTCATALOGLib::IMTPriceListMappingPtr mapping =
						targetPrcItem->GetPriceListMapping((long) paramtable);

					mapping->PriceListID = pricelist.lVal;
					mapping->ParamTableDefinitionID = paramtable.lVal;
					mapping->PutCanICB((_bstr_t) canICB == _bstr_t(L"Y"));
					mapping->Save();
				}
			}

			rowset->MoveNext();
		}
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

STDMETHODIMP CMTPriceableItem::CanBeModified(VARIANT_BOOL *pVal)
{
	*pVal = VARIANT_TRUE;

	return S_OK;
}

STDMETHODIMP CMTPriceableItem::CheckConfiguration(IMTPriceableItem* apPrcItemThis, IMTCollection ** apErrors)
{
	try
	{
		//create a new collection
		GENERICCOLLECTIONLib::IMTCollectionPtr errors(__uuidof(GENERICCOLLECTIONLib::MTCollection));
		
		CheckConfigurationForBase(apPrcItemThis, reinterpret_cast<IMTCollection*>(errors.GetInterfacePtr()));
		CheckConfigurationForDerived(reinterpret_cast<IMTCollection*>(errors.GetInterfacePtr()));
		
		*apErrors = reinterpret_cast<IMTCollection*>(errors.Detach());
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(), err);
	}

	return S_OK;
}

// check configuration,
// add any errors as strings to apErrors
// can throw _com_error
void CMTPriceableItem::CheckConfigurationForBase(IMTPriceableItem* apPrcItemThis, IMTCollection* apErrors)
{
	MTPRODUCTCATALOGLib::IMTCollectionPtr errors = apErrors;

	MTPRODUCTCATALOGLib::IMTPriceableItemPtr prcItemThis = apPrcItemThis;

	PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "checking configuration for '%s'", (const char*)prcItemThis->Name);

	MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr prcItemType;
	prcItemType = prcItemThis->PriceableItemType;

	//get collection of param tables
	MTPRODUCTCATALOGLib::IMTCollectionPtr paramTableDefs;
	paramTableDefs = prcItemType->GetParamTableDefinitions();

	MTPRODUCTCATALOGLib::IMTParamTableDefinitionPtr paramTableDef;
	MTPRODUCTCATALOGLib::IMTPriceListMappingPtr prcLstMapping;

	// loop over all param table defs
	long count = paramTableDefs->GetCount();
	for (long i = 1; i <= count; ++i) // collection indexes are 1-based
	{
		paramTableDef = paramTableDefs->GetItem(i);

		// Only force the param table to be configured if it is being used.
		if(!IsParameterTableInUse(reinterpret_cast<IMTParamTableDefinition*>(paramTableDef.GetInterfacePtr()))) continue;

		prcLstMapping = prcItemThis->GetPriceListMapping(paramTableDef->ID);

		//check price list mapping for price list
		long prcListID = prcLstMapping->PriceListID;
		if (prcListID == PROPERTIES_BASE_NO_ID)
		{	
			Message message(MTPCUSER_PRC_ITEM_HAS_NO_PRICE_LIST);
			string msgString;
			message.FormatErrorMessage(msgString, TRUE,
																	(const char*)prcItemThis->Name,
																	(const char*)paramTableDef->Name);

			errors->Add(msgString.c_str());
		}
		else
		{
			//check price list mapping for any rate schedules
			ROWSETLib::IMTSQLRowsetPtr rowset;
			
			rowset = prcLstMapping->FindRateSchedulesAsRowset();
			int NumRecords = rowset->GetRecordCount();
			if (NumRecords == 0)
			{	
				Message message(MTPCUSER_PRC_ITEM_HAS_NO_RATES);
				string msgString;
				message.FormatErrorMessage(msgString, TRUE,
																		(const char*)prcItemThis->Name,
																		(const char*)paramTableDef->Name);

				errors->Add(msgString.c_str());
			}
		}
	}
}

// for templates: returns NULL
// for instances: returns the product offering that this instance is part of
STDMETHODIMP CMTPriceableItem::GetProductOffering(IMTProductOffering** apProdOff)
{
	if (!apProdOff)
		return E_POINTER;

	*apProdOff = NULL;

	try
	{
		VARIANT_BOOL isTemplate;
		IsTemplate( &isTemplate );
		
		if( isTemplate == VARIANT_TRUE )
		{	
			// for templates: return NULL
			*apProdOff = NULL;
		}
		else
		{
			// for instances load it from DB

			// create reader instance
			MTPRODUCTCATALOGEXECLib::IMTProductOfferingReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTProductOfferingReader));

			long prodOffID;
			get_ProductOfferingID(&prodOffID);
			*apProdOff = reinterpret_cast<IMTProductOffering*> (reader->Find(GetSessionContextPtr(), prodOffID).Detach());
		}
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}


// for templates: returns all instances of this template
// for instances: ERROR
STDMETHODIMP CMTPriceableItem::GetInstances(IMTCollection** apInstances)
{
	VARIANT_BOOL bIsTemplate;
	if (!apInstances)
		return E_POINTER;

	*apInstances = NULL;

	HRESULT hr = IsTemplate(&bIsTemplate);

	if(FAILED(hr))
		return hr;

	//only valid for templates
	if(bIsTemplate == VARIANT_FALSE)
	{
		MT_THROW_COM_ERROR(IID_IMTPriceableItem, "GetInstances can only be called on templates");
	}
	
	try
	{
		
		MTPRODUCTCATALOGEXECLib::IMTPriceableItemReaderPtr reader
			(__uuidof(MTPRODUCTCATALOGEXECLib::MTPriceableItemReader));
		GENERICCOLLECTIONLib::IMTCollectionPtr Coll(__uuidof(GENERICCOLLECTIONLib::MTCollection));
		//coll = 
		*apInstances = 
			reinterpret_cast<IMTCollection*>( reader->FindInstancesOfTemplate(GetSessionContextPtr(), GetID()).Detach() );
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

STDMETHODIMP CMTPriceableItem::CreateAdjustment(IMTPriceableItem* apPrcItemThis, long aAdjTypeID, IDispatch** apAdjustment)
{
  if (!apAdjustment)
		return E_POINTER;
  (*apAdjustment) = NULL;

  try
	{
    //creates either a template or instance of an adjustment
    //"templateness" or "instanceness" of an adjustment object is determined by
    //association with owner priceable item
    MTPRODUCTCATALOGLib::IMTPriceableItemPtr ThisPtr = apPrcItemThis;
    MTPRODUCTCATALOGLib::IMTSessionContextPtr ctxt = ThisPtr->GetSessionContext();
    MetraTech_Adjustments::IAdjustmentTypeReaderPtr adjTypeReaderPtr
      (__uuidof(MetraTech_Adjustments::AdjustmentTypeReader));
    MetraTech_Adjustments::IAdjustmentPtr newAJ = NULL;
    if(ThisPtr->IsTemplate() == VARIANT_TRUE)
    {
      newAJ = adjTypeReaderPtr->FindAdjustmentType(
        reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext *>(GetSessionContextPtr().GetInterfacePtr()),
        aAdjTypeID)->CreateAdjustmentTemplate
      (reinterpret_cast<MTPRODUCTCATALOGLib::IMTPriceableItem*>(ThisPtr.GetInterfacePtr()));
    }
    else
    {
       newAJ = adjTypeReaderPtr->FindAdjustmentType(
        reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext *>(GetSessionContextPtr().GetInterfacePtr()),
        aAdjTypeID)->CreateAdjustmentInstance
      (reinterpret_cast<MTPRODUCTCATALOGLib::IMTPriceableItem*>(ThisPtr.GetInterfacePtr()));
    }
    //only one template/instance per adjustment type
    mAdjustments.Add(reinterpret_cast<MetraTech_Adjustments::IAdjustment*>(newAJ.GetInterfacePtr()));
    *apAdjustment = newAJ.GetInterfacePtr();
    (*apAdjustment)->AddRef();
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

  return S_OK;
}

STDMETHODIMP CMTPriceableItem::RemoveAdjustment(IMTPriceableItem* apPrcItemThis, long aAdjID)
{
  try
	{
    MetraTech_Adjustments::IAdjustmentWriterPtr ajwriter(__uuidof(MetraTech_Adjustments::AdjustmentWriter));
    MTPRODUCTCATALOGLib::IMTPriceableItemPtr prcItemTmplThis = apPrcItemThis;
    GENERICCOLLECTIONLib::IMTCollectionPtr adjustments = prcItemTmplThis->GetAdjustments();
    MTPRODUCTCATALOGLib::IMTSessionContextPtr ctxt = prcItemTmplThis->GetSessionContext();

    long numaj = adjustments->GetCount();
    for (int i = 1; i <= numaj; i++)
    {
      MetraTech_Adjustments::IAdjustmentPtr ajPtr = adjustments->GetItem(i);
      if(ajPtr->ID == aAdjID)
      {
        ajwriter->Remove(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(ctxt.GetInterfacePtr()), ajPtr);
        mAdjustments.Remove(i);
        return S_OK;
      }
    }	
  }
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

  return S_OK;
}

STDMETHODIMP CMTPriceableItem::RemoveAdjustmentOfType(IMTPriceableItem* apPrcItemThis, long aAdjTypeID)
{
  try
	{
    MetraTech_Adjustments::IAdjustmentWriterPtr ajwriter(__uuidof(MetraTech_Adjustments::AdjustmentWriter));
    MTPRODUCTCATALOGLib::IMTPriceableItemPtr prcItemTmplThis = apPrcItemThis;
    GENERICCOLLECTIONLib::IMTCollectionPtr adjustments = prcItemTmplThis->GetAdjustments();
    MTPRODUCTCATALOGLib::IMTSessionContextPtr ctxt = prcItemTmplThis->GetSessionContext();
    long numaj = adjustments->GetCount();
    for (int i = 1; i <= numaj; i++)
    {
      MetraTech_Adjustments::IAdjustmentPtr ajPtr = adjustments->GetItem(i);
      if(ajPtr->AdjustmentType->ID == aAdjTypeID)
      {
        mAdjustments.Remove(i);
			  ajwriter->Remove(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(ctxt.GetInterfacePtr()), ajPtr);
        return S_OK;
      }
    }	
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

  return S_OK;
}



STDMETHODIMP CMTPriceableItem::GetAdjustments(IMTCollection** apAdjustments)
{
  if (!apAdjustments)
		return E_POINTER;
  (*apAdjustments) = NULL;

  try
	{
    return mAdjustments.CopyTo(apAdjustments );
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

  return S_OK;
}

STDMETHODIMP CMTPriceableItem::SetAdjustments(IMTCollection* apAdjustments)
{
  try {
    mAdjustments = apAdjustments;
  }
  catch (_com_error & err) {
		return LogAndReturnComError(PCCache::GetLogger(),err);
  }
  return S_OK;
}

// ----------------------------------------------------------------
// Name:          CopyNonBaseMembersTo
// Arguments:     apPrcItemTarget - PI template or instanc
//                
// Errors Raised: _com_error
// Description:   copy the members that are not in the base class
//                this method can be called for templates or instances
// ----------------------------------------------------------------
void CMTPriceableItem::CopyAdjustmentsTo
    ( IMTPriceableItem* apPrcItemThis, 
      IMTPriceableItem* apPrcItemTarget)
{
 
	MTPRODUCTCATALOGLib::IMTPriceableItemPtr ThisPtr = apPrcItemThis;
  MTPRODUCTCATALOGLib::IMTPriceableItemPtr target = apPrcItemTarget;
	MTPRODUCTCATALOGEXECLib::IMTCollectionPtr adjustments = ThisPtr->GetAdjustments();
   
  
	int iAJCount = adjustments->Count;
	for(int i = 1; i <= iAJCount; ++i)
	{
		 MetraTech_Adjustments::IAdjustmentPtr srcAjPtr = adjustments->GetItem(i);
     ASSERT(srcAjPtr->AdjustmentType != NULL);
     MetraTech_Adjustments::IAdjustmentPtr 
       targetAjPtr = target->CreateAdjustment(srcAjPtr->AdjustmentType->ID);
     targetAjPtr->Name = srcAjPtr->Name;
     targetAjPtr->DisplayName = srcAjPtr->DisplayName;
     targetAjPtr->Description = srcAjPtr->Description;
     targetAjPtr->SetApplicableReasonCodes(srcAjPtr->GetApplicableReasonCodes().GetInterfacePtr());
	}
}

// ----------------------------------------------------------------
// Name:          GetAvailableAdjustmentTypesAsRowset
// Arguments:     apRowset - The rowset of adjustment types
//                
// Errors Raised: _com_error
// Description:   Get list of all adjustment types on the PI type of this
//                template or instance that is not yet configured.
// ----------------------------------------------------------------
STDMETHODIMP CMTPriceableItem::GetAvailableAdjustmentTypesAsRowset(IMTPriceableItem* apPrcItemThis, IMTRowSet** apRowset)
{
	try
	{
		MTPRODUCTCATALOGLib::IMTPriceableItemPtr ThisPtr = apPrcItemThis;
    MetraTech_Adjustments::IAdjustmentReaderPtr adjReaderPtr
      (__uuidof(MetraTech_Adjustments::AdjustmentReader));

		*apRowset = reinterpret_cast<IMTRowSet*>(adjReaderPtr->GetAvailableAdjustmentTypesAsRowset(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext *>(GetSessionContextPtr().GetInterfacePtr()), ThisPtr->ID, ThisPtr->IsTemplate()).Detach());
	}
  catch (_com_error & err) {
		return LogAndReturnComError(PCCache::GetLogger(),err);
  }
	
	return S_OK;
}
