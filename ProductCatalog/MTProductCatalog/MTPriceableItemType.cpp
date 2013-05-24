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
* $Header: c:\development35\ProductCatalog\MTProductCatalog\MTPriceableItemType.cpp, 42, 11/12/2002 2:24:01 PM, David Blair$
* 
***************************************************************************/

#include "StdAfx.h"

#include <metra.h>
#include <comdef.h>
#include <mtcomerr.h>

#include "MTProductCatalog.h"
#include "MTPriceableItemType.h"

#import <MTProductView.tlb> rename ("EOF", "EOFX")

/////////////////////////////////////////////////////////////////////////////
// CMTPriceableItemType

/******************************************* error interface ***/
STDMETHODIMP CMTPriceableItemType::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTPriceableItemType,
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
CMTPriceableItemType::CMTPriceableItemType()
{
	mUnkMarshalerPtr = NULL;
}

HRESULT CMTPriceableItemType::FinalConstruct()
{
	try
	{
		HRESULT hr = CoCreateFreeThreadedMarshaler(GetControllingUnknown(), &mUnkMarshalerPtr.p);
		if (FAILED(hr))
			throw _com_error(hr);

		LoadPropertiesMetaData( PCENTITY_TYPE_PRICEABLE_ITEM_TYPE );
	}	
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

void CMTPriceableItemType::FinalRelease()
{
	mUnkMarshalerPtr.Release();
}

/********************************** IMTPriceableItemType ***/
STDMETHODIMP CMTPriceableItemType::get_ID(long *pVal)
{
	return GetPropertyValue("ID", pVal);
}

STDMETHODIMP CMTPriceableItemType::put_ID(long newVal)
{
	return PutPropertyValue("ID", newVal);
}

STDMETHODIMP CMTPriceableItemType::get_Kind(MTPCEntityType *pVal)
{
	return GetPropertyValue("Kind", reinterpret_cast<long*>(pVal));
}

STDMETHODIMP CMTPriceableItemType::put_Kind(MTPCEntityType newVal)
{
	return PutPropertyValue("Kind", static_cast<long>(newVal));
}

STDMETHODIMP CMTPriceableItemType::get_Name(BSTR *pVal)
{
	return GetPropertyValue("Name", pVal);
}

STDMETHODIMP CMTPriceableItemType::put_Name(BSTR newVal)
{
	return PutPropertyValue("Name", newVal);
}

STDMETHODIMP CMTPriceableItemType::get_Description(BSTR *pVal)
{
	return GetPropertyValue("Description", pVal);
}

STDMETHODIMP CMTPriceableItemType::put_Description(BSTR newVal)
{
	return PutPropertyValue("Description", newVal);
}

STDMETHODIMP CMTPriceableItemType::get_ServiceDefinition(BSTR *pVal)
{
	return GetPropertyValue("ServiceDefinition", pVal);
}

STDMETHODIMP CMTPriceableItemType::put_ServiceDefinition(BSTR newVal)
{
	return PutPropertyValue("ServiceDefinition", newVal);
}

STDMETHODIMP CMTPriceableItemType::get_ProductView(BSTR *pVal)
{
	return GetPropertyValue("ProductView", pVal);
}

STDMETHODIMP CMTPriceableItemType::put_ProductView(BSTR newVal)
{
	return PutPropertyValue("ProductView", newVal);
}

STDMETHODIMP CMTPriceableItemType::get_ParentID(long *pVal)
{
	return GetPropertyValue("ParentID", pVal);
}

STDMETHODIMP CMTPriceableItemType::put_ParentID(long newVal)
{
	return PutPropertyValue("ParentID", newVal);
}

STDMETHODIMP CMTPriceableItemType::get_ConstrainSubscriberCycle(VARIANT_BOOL *pVal)
{
	return GetPropertyValue("ConstrainSubscriberCycle", pVal);
}

STDMETHODIMP CMTPriceableItemType::put_ConstrainSubscriberCycle(VARIANT_BOOL newVal)
{
	return PutPropertyValue("ConstrainSubscriberCycle", newVal);
}


STDMETHODIMP CMTPriceableItemType::Save()
{
  try
	{
		//validate properties based on their meta data (required, length, ...)
		//throws _com_error on failure
		ValidateProperties();

		// create instance of COM+ executant
		MTPRODUCTCATALOGEXECLib::IMTPriceableItemTypeWriterPtr writer(__uuidof(MTPRODUCTCATALOGEXECLib::MTPriceableItemTypeWriter));
		
		// just cast "this"
		MTPRODUCTCATALOGEXECLib::IMTPriceableItemType* piType = reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTPriceableItemType *>(this);

		if (HasID())  //created
			writer->Update(GetSessionContextPtr(), piType);
		else					// not yet created
			put_ID( writer->Create(GetSessionContextPtr(), piType) );
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(), err);
	}

	return S_OK;
}

STDMETHODIMP CMTPriceableItemType::CreateTemplate(VARIANT aCreateChildren, IMTPriceableItem **apPrcItemTmpl)
{
	if (!apPrcItemTmpl)
		return E_POINTER;
	else
		*apPrcItemTmpl = NULL;
	
	try
	{
		//create a priceable item of the same kind as this type
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
				MT_THROW_COM_ERROR(IID_IMTPriceableItemType, MTPC_INVALID_PRICEABLE_ITEM_KIND, kind);
		}

		MTPRODUCTCATALOGLib::IMTPriceableItemPtr prcItem;
		HRESULT hr = prcItem.CreateInstance(clsid);
		if (FAILED(hr))
			return hr;

		//pass the session context on to objects created from this one
		MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr thisPtr = this;
		MTPRODUCTCATALOGLib::IMTSessionContextPtr ctxt = thisPtr->GetSessionContext();
		prcItem->SetSessionContext(ctxt);


		MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr prcItemType = this;

		// copy default names and description from type
		prcItem->Name = prcItemType->Name;
		prcItem->DisplayName = prcItemType->Name;  //type has no display name, use name to start with
		prcItem->Description = prcItemType->Description;

		// set type
		// add a reference to this priceable Item type
		prcItem->PriceableItemType = prcItemType;
		
		// Special handling of UDRC
		if (kind == PCENTITY_TYPE_RECURRING_UNIT_DEPENDENT)
		{
			//For the moment, MTRecurringCharge handles two different types ('kinds')
			prcItem->Kind = (MTPRODUCTCATALOGLib::MTPCEntityType)kind;
		}

		// set CreateChildren flag (true by default).
		// If flag is set and this type has children (usage charge only)
		// the child templates types will be created when parent template is inserted into DB
		// (alternatively child templates could be created now and stored in a new childrenToCreate collection of the pi template object)
		prcItem->CreateChildren = VARIANT_TRUE;
		
		_variant_t vtCreateChildren = aCreateChildren;
		if (vtCreateChildren != vtMissing)
		{	
			bool bCreateChildren = vtCreateChildren;
			if (!bCreateChildren)
				prcItem->CreateChildren = VARIANT_FALSE;
		}


		*apPrcItemTmpl = reinterpret_cast<IMTPriceableItem*>(prcItem.Detach());
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

STDMETHODIMP CMTPriceableItemType::RemoveTemplate(long aID)
{
	try
	{
		// TODO: we may want to remove all instances, created from this template, first.

		// create writer instance
		MTPRODUCTCATALOGEXECLib::IMTPriceableItemWriterPtr writer(__uuidof(MTPRODUCTCATALOGEXECLib::MTPriceableItemWriter));
		
		// remove priceable item from the database
		writer->Remove(GetSessionContextPtr(), aID);
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}
	
	return S_OK;
}


STDMETHODIMP CMTPriceableItemType::GetParent(IMTPriceableItemType** apType)
{
	if (!apType)
		return E_POINTER;
	
	*apType = NULL;

  try
	{
	  // create reader instance
		MTPRODUCTCATALOGEXECLib::IMTPriceableItemTypeReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTPriceableItemTypeReader));

		long parentID;
		get_ParentID(&parentID);
		if (parentID == PROPERTIES_BASE_NO_ID)
			*apType = NULL; //this object has no parent
		else
			*apType = reinterpret_cast<IMTPriceableItemType*> (reader->Find(GetSessionContextPtr(), parentID).Detach());
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

STDMETHODIMP CMTPriceableItemType::CreateChild(IMTPriceableItemType** apType)
{
	try
	{
		if(!HasID())
		{	MT_THROW_COM_ERROR(IID_IMTPriceableItemType, MTPC_OBJECT_NO_STATE);
		}

		//create a new type object
		MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr child(__uuidof(MTPRODUCTCATALOGLib::MTPriceableItemType));

		//pass the session context on to objects created from this one
		MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr thisPtr = this;
		MTPRODUCTCATALOGLib::IMTSessionContextPtr ctxt = thisPtr->GetSessionContext();
		child->SetSessionContext(ctxt);

		//set its parent and Kind
		MTPCEntityType kind;
		get_Kind(&kind);
		child->Kind = (MTPRODUCTCATALOGLib::MTPCEntityType)kind;
		child->ParentID = GetID();

		*apType = reinterpret_cast<IMTPriceableItemType *>(child.Detach());
	}
	catch (_com_error & err)
	{ return LogAndReturnComError(PCCache::GetLogger(),err); }

	return S_OK;
}

STDMETHODIMP CMTPriceableItemType::RemoveChild(long aID)
{
	try
	{
		// find the child
		/////////////////////////////
		// remove the children 
		MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr prcItemType(this);
		MTPRODUCTCATALOGEXECLib::IMTCollectionPtr childPITypes;
		childPITypes = prcItemType->GetChildren();
		int count = childPITypes->Count;

		// find index of particular child in the collection
		for(int i = 1; i <= count ; i++)
		{
			MTPRODUCTCATALOGEXECLib::IMTPriceableItemTypePtr childPIType = childPITypes->Item[i];

			if(childPIType->ID == aID)
				break;
		}

		// child type does not belong to this type
		if(i > count)
		{
			MT_THROW_COM_ERROR(MTPC_CHILD_ITEM_TYPE_NOT_FOUND_BY_ID, aID);
		}

		// create instance of COM+ executant
		MTPRODUCTCATALOGEXECLib::IMTPriceableItemTypeWriterPtr writer(__uuidof(MTPRODUCTCATALOGEXECLib::MTPriceableItemTypeWriter));
		writer->Remove(GetSessionContextPtr(), aID);

		// remove object from collection
		childPITypes->Remove(i);
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

STDMETHODIMP CMTPriceableItemType::GetChildren(IMTCollection** apChildren)
{
	if (!apChildren)
		return E_POINTER;
	else
		*apChildren = NULL;
		
	try
	{
		if(!HasID())
		{	MT_THROW_COM_ERROR(IID_IMTPriceableItemType, MTPC_OBJECT_NO_STATE);
		}

		// read from DB
		MTPRODUCTCATALOGEXECLib::IMTPriceableItemTypeReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTPriceableItemTypeReader));
			
		MTPRODUCTCATALOGEXECLib::IMTCollectionPtr children;
		children = reader->FindChildren(GetSessionContextPtr(), GetID());

		*apChildren	= reinterpret_cast<IMTCollection*>(children.Detach());
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

STDMETHODIMP CMTPriceableItemType::GetChild(long aID, IMTPriceableItemType** apType)
{
	if (!apType)
		return E_POINTER;
	
	*apType = NULL;

  try
	{
	  // create reader instance
		MTPRODUCTCATALOGEXECLib::IMTPriceableItemTypeReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTPriceableItemTypeReader));

		// return the priceable item type with that ID
		// TODO!!: only return type if it is a child of this type
		*apType = reinterpret_cast<IMTPriceableItemType*> (reader->Find(GetSessionContextPtr(), aID).Detach());
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

STDMETHODIMP CMTPriceableItemType::AddParamTableDefinition(long aParamTblDefID)
{
  try
	{
		if(!HasID())
		{	MT_THROW_COM_ERROR(IID_IMTPriceableItemType, MTPC_OBJECT_NO_STATE);
		}

		// create instance of COM+ executant
		MTPRODUCTCATALOGEXECLib::IMTPriceableItemTypeWriterPtr writer(__uuidof(MTPRODUCTCATALOGEXECLib::MTPriceableItemTypeWriter));
		
		writer->AddParamTableDefinition(GetSessionContextPtr(), GetID(), aParamTblDefID);
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

STDMETHODIMP CMTPriceableItemType::RemoveParamTableDefinition(long aParamTblDefID)
{
	try
	{
		if(!HasID())
		{	MT_THROW_COM_ERROR(IID_IMTPriceableItemType, MTPC_OBJECT_NO_STATE);
		}
		
		// create instance of COM+ executant
		MTPRODUCTCATALOGEXECLib::IMTPriceableItemTypeWriterPtr writer(__uuidof(MTPRODUCTCATALOGEXECLib::MTPriceableItemTypeWriter));
		
		writer->RemoveParamTableDefinition(GetSessionContextPtr(), GetID(), aParamTblDefID);
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

STDMETHODIMP CMTPriceableItemType::GetParamTableDefinitions(IMTCollection** apParamTblDefs)
{
	if (!apParamTblDefs)
		return E_POINTER;
	else
		*apParamTblDefs = NULL;

  try
	{
		if(!HasID())
		{	MT_THROW_COM_ERROR(IID_IMTPriceableItemType, MTPC_OBJECT_NO_STATE);
		}

		// create instance of COM+ executant
		MTPRODUCTCATALOGEXECLib::IMTPriceableItemTypeReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTPriceableItemTypeReader));
		
		// call it
		MTPRODUCTCATALOGEXECLib::IMTCollectionPtr coll;
		coll = reader->FindParamTableDefinitions(GetSessionContextPtr(), GetID());
		
		*apParamTblDefs = reinterpret_cast<IMTCollection*>(coll.Detach());
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

STDMETHODIMP CMTPriceableItemType::CreateCounterPropertyDefinition(IMTCounterPropertyDefinition **apCPD)
{
	HRESULT hr(S_OK);
	MTPRODUCTCATALOGLib::IMTCounterPropertyDefinitionPtr cpd;
	
	try
	{

		hr = cpd.CreateInstance(__uuidof(MTCounterPropertyDefinition));
		if (FAILED(hr))
			return hr;
	
		//pass the session context on to objects created from this one
		MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr thisPtr = this;
		MTPRODUCTCATALOGLib::IMTSessionContextPtr ctxt = thisPtr->GetSessionContext();
		cpd->SetSessionContext(ctxt);
		
		cpd->PutPITypeID(GetID());
		(*apCPD) = reinterpret_cast<IMTCounterPropertyDefinition*>(cpd.Detach());
}
	catch(_com_error& e)
	{
		return LogAndReturnComError(PCCache::GetLogger(),e);
	}

	return hr;
}

STDMETHODIMP CMTPriceableItemType::GetCounterPropertyDefinitions(IMTCollection **apColl)
{
	HRESULT hr(S_OK);
	try
	{
		// create instance of COM+ executant
		MTPRODUCTCATALOGEXECLib::IMTCounterPropertyDefinitionReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTCounterPropertyDefinitionReader));
		// call it
		MTPRODUCTCATALOGEXECLib::IMTCollectionPtr coll;
		coll = reader->FindByPIType(GetSessionContextPtr(), GetID());
		*apColl = reinterpret_cast<IMTCollection*>(coll.Detach());
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}
	return hr;
}

STDMETHODIMP CMTPriceableItemType::RemoveCounterPropertyDefinition(long aID)
{
	HRESULT hr(S_OK);
	try
	{
		// create instance of COM+ executant
		MTPRODUCTCATALOGEXECLib::IMTCounterPropertyDefinitionWriterPtr writer(__uuidof(MTPRODUCTCATALOGEXECLib::MTCounterPropertyDefinitionWriter));
		writer->Remove(GetSessionContextPtr(), aID);
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}
	return hr;
}

STDMETHODIMP CMTPriceableItemType::FindCounterPropertyDefinitionsAsRowset(VARIANT aFilter, IMTRowSet **apRowset)
{
	HRESULT hr(S_OK);
	if (!apRowset)
		return E_POINTER;

  try
	{
		// create instance of COM+ executant
		MTPRODUCTCATALOGEXECLib::IMTCounterPropertyDefinitionReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::IMTCounterPropertyDefinitionReader));
		MTPRODUCTCATALOGEXECLib::IMTRowSetPtr aRowset = reader->FindAsRowset(GetSessionContextPtr(), _variant_t( GetID()));
		//TODO: implement filters, but for now just set it as id
		*apRowset	= reinterpret_cast<IMTRowSet*> (aRowset.Detach());
	}
	catch (_com_error & err)
	{ return LogAndReturnComError(PCCache::GetLogger(),err); }

	return hr;
}

STDMETHODIMP CMTPriceableItemType::GetParamTableDefinitionsAsRowset(IMTRowSet **apRowset)
{
	HRESULT hr(S_OK);
	if (!apRowset)
		return E_POINTER;

  try
	{
		// create instance of COM+ executant
		MTPRODUCTCATALOGEXECLib::IMTPriceableItemTypeReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTPriceableItemTypeReader));
		MTPRODUCTCATALOGEXECLib::IMTRowSetPtr aRowset = reader->FindParamTableDefinitionsAsRowset(GetSessionContextPtr(), GetID());
		*apRowset	= reinterpret_cast<IMTRowSet*> (aRowset.Detach());
	}
	catch (_com_error & err)
	{ return LogAndReturnComError(PCCache::GetLogger(),err); }

	return hr;
}

STDMETHODIMP CMTPriceableItemType::GetTemplates(IMTCollection** apTemplates)
{
	if (!apTemplates)
		return E_POINTER;
	try
	{
		if(!HasID())
		{	
			MT_THROW_COM_ERROR(IID_IMTPriceableItemType, MTPC_OBJECT_NO_STATE);
		}

		// read from DB
		MTPRODUCTCATALOGEXECLib::IMTPriceableItemTypeReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTPriceableItemTypeReader));
			
		MTPRODUCTCATALOGEXECLib::IMTCollectionPtr templates;
		templates = reader->FindTemplates(GetSessionContextPtr(), GetID());

		*apTemplates	= reinterpret_cast<IMTCollection*>(templates.Detach());
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

STDMETHODIMP CMTPriceableItemType::GetProductOfferings(IMTCollection** apProdOffs)
{
	if (!apProdOffs)
		return E_POINTER;

	*apProdOffs = NULL;
	
	try
	{
		MTPRODUCTCATALOGEXECLib::IMTProductOfferingReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTProductOfferingReader));

		MTPRODUCTCATALOGEXECLib::IMTCollectionPtr productOfferings;
		productOfferings = reader->FindForPrcItemType(GetSessionContextPtr(), GetID());

		*apProdOffs	= reinterpret_cast<IMTCollection*>(productOfferings.Detach());
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

STDMETHODIMP CMTPriceableItemType::CreateCharge(IMTCharge** apCharge)
{
	HRESULT hr(S_OK);
	
	try
	{

		if(!HasID())
		{	MT_THROW_COM_ERROR(IID_IMTPriceableItemType, MTPC_OBJECT_NO_STATE);
		}

		MTPRODUCTCATALOGLib::IMTChargePtr charge(__uuidof(MTPRODUCTCATALOGLib::MTCharge));

		//pass the session context on to objects created from this one
		MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr thisPtr = this;
		MTPRODUCTCATALOGLib::IMTSessionContextPtr ctxt = thisPtr->GetSessionContext();
		charge->SetSessionContext(ctxt);
		
		charge->PITypeID = GetID();
		(*apCharge) = reinterpret_cast<IMTCharge*>(charge.Detach());

	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

STDMETHODIMP CMTPriceableItemType::RemoveCharge(long aChargeID)
{
	try
	{
		if(!HasID())
		{	MT_THROW_COM_ERROR(IID_IMTPriceableItemType, MTPC_OBJECT_NO_STATE);
		}
		
		// create instance of COM+ executant
		MTPRODUCTCATALOGEXECLib::IMTChargeWriterPtr writer(__uuidof(MTPRODUCTCATALOGEXECLib::MTChargeWriter));
		
		writer->Remove(GetSessionContextPtr(), aChargeID);
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

STDMETHODIMP CMTPriceableItemType::GetCharges(IMTCollection** apCharges)
{
	if (!apCharges)
		return E_POINTER;
	else
		*apCharges = NULL;

  try
	{
		if(!HasID())
		{	MT_THROW_COM_ERROR(IID_IMTPriceableItemType, MTPC_OBJECT_NO_STATE);
		}

		// create instance of COM+ executant
		MTPRODUCTCATALOGEXECLib::IMTPriceableItemTypeReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTPriceableItemTypeReader));
		
		// call it
		MTPRODUCTCATALOGEXECLib::IMTCollectionPtr coll;
		coll = reader->FindCharges(GetSessionContextPtr(), GetID());
		
		*apCharges = reinterpret_cast<IMTCollection*>(coll.Detach());
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}


STDMETHODIMP CMTPriceableItemType::GetProductViewObject(IProductView** apPV)
{
	if (!apPV)
		return E_POINTER;
	else
		*apPV = NULL;

  try {
		MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr This(this);
		MTPRODUCTVIEWLib::IProductViewCatalogPtr PVcatalog(__uuidof(MTPRODUCTVIEWLib::ProductViewCatalog));
		PVcatalog->SessionContext = reinterpret_cast<MTPRODUCTVIEWLib::IMTSessionContext*>(GetSessionContextPtr().GetInterfacePtr());
		*apPV = reinterpret_cast<IProductView*> (PVcatalog->GetProductViewByName(This->ProductView).Detach());
  }
  catch (_com_error & err) {
		return LogAndReturnComError(PCCache::GetLogger(),err);
  }
  return S_OK;
}



STDMETHODIMP CMTPriceableItemType::get_AdjustmentTypes(IMTCollection **pVal)
{
  try {
    long count;
    mAdjustmentTypeCol.Count(&count);
    if(count < 1) {
      // fetch the collection of adjustment types
      //MetraTech_Adjustments::IAdjustmentCatalogPtr adjCatalogPtr(__uuidof(MetraTech_Adjustments::AdjustmentCatalog));
      //adjCatalogPtr->Initialize(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext *>(GetSessionContextPtr().GetInterfacePtr()));
      MetraTech_Adjustments::IAdjustmentTypeReaderPtr adjTypeReaderPtr(__uuidof(MetraTech_Adjustments::AdjustmentTypeReader));

      long id;
      GetPropertyValue("ID",&id);
      mAdjustmentTypeCol = 
        (IMTCollection*)adjTypeReaderPtr->GetAdjustmentTypesForPIType(
        reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext *>(GetSessionContextPtr().GetInterfacePtr()),
        id).GetInterfacePtr();
    }
    return mAdjustmentTypeCol.CopyTo(pVal);
  }
  catch (_com_error & err) {
		return LogAndReturnComError(PCCache::GetLogger(),err);
  }
  return S_OK;
}

STDMETHODIMP CMTPriceableItemType::put_AdjustmentTypes(IMTCollection *newVal)
{
  try {
    mAdjustmentTypeCol = newVal;
  }
  catch (_com_error & err) {
		return LogAndReturnComError(PCCache::GetLogger(),err);
  }
  return S_OK;
}
STDMETHODIMP CMTPriceableItemType::CreateAdjustmentType(IDispatch** apAdjustmentType)
{
  if (!apAdjustmentType)
		return E_POINTER;
  (*apAdjustmentType) = NULL;

  try
	{
    MetraTech_Adjustments::IAdjustmentTypePtr outPtr(__uuidof(MetraTech_Adjustments::AdjustmentType));
		if (HasID())
		{
			outPtr->PriceableItemTypeID = GetID();
		}
		else
		{
			outPtr->PriceableItemTypeID = -1;
		}
    mAdjustmentTypeCol.Add(outPtr.GetInterfacePtr());
    *apAdjustmentType = outPtr.Detach();
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

  return S_OK;
}
