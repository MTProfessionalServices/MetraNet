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
* $Header: ProductCatalog.cpp, 70, 10/11/2002 2:52:20 PM, Boris$
* 
***************************************************************************/

#include "StdAfx.h"

#include <comdef.h>
#include <metra.h>
#include <mtcomerr.h>
#include <mtprogids.h>

#include "MTProductCatalog.h"
#include "ProductCatalog.h"
#include "MTObjectCollection.h"
#include "PropertiesBase.h"
#include "optionalvariant.h"

using MTPRODUCTCATALOGLib::IMTPriceListPtr;

using MTPRODUCTCATALOGEXECLib::IMTPriceListReaderPtr;
using MTPRODUCTCATALOGEXECLib::IMTPriceListWriterPtr;
using MTPRODUCTCATALOGEXECLib::MTPriceListReader;
using MTPRODUCTCATALOGEXECLib::MTPriceListWriter;
using MTPRODUCTCATALOGEXECLib::MTCalendarReader;


/////////////////////////////////////////////////////////////////////////////
// CMTProductCatalog

STDMETHODIMP CMTProductCatalog::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTProductCatalog
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

CMTProductCatalog::CMTProductCatalog()
{
	mpUnkMarshaler = NULL;
}

HRESULT CMTProductCatalog::FinalConstruct()
{
	try
	{
		HRESULT hr = CoCreateFreeThreadedMarshaler(GetControllingUnknown(), &mpUnkMarshaler.p);
		if (FAILED(hr))
			throw _com_error(hr);

		// create session context
		// the product catalog object, as the main interface, owns the session context and passes it
		// to all subsequently created objects

		MTPRODUCTCATALOGLib::IMTSessionContextPtr ctxt(MTPROGID_MTSESSIONCONTEXT);

		MTPRODUCTCATALOGLib::IMTProductCatalogPtr thisPtr = this;
		thisPtr->SetSessionContext(ctxt);

	}	
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

void CMTProductCatalog::FinalRelease()
{
	mpUnkMarshaler.Release();
}


STDMETHODIMP CMTProductCatalog::GetProductOffering(long ID, IMTProductOffering ** apProdOff)
{
	if (!apProdOff)
		return E_POINTER;

  try
	{
	  // create reader instance
		MTPRODUCTCATALOGEXECLib::IMTProductOfferingReaderPtr ptrProdOffReader(__uuidof(MTPRODUCTCATALOGEXECLib::MTProductOfferingReader));

		*apProdOff = reinterpret_cast<IMTProductOffering*> (ptrProdOffReader->Find(GetSessionContextPtr(), ID).Detach());
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

STDMETHODIMP CMTProductCatalog::GetProductOfferingByName(BSTR aName, IMTProductOffering ** apProdOff)
{
	if (!apProdOff)
		return E_POINTER;

  try
	{
	  // create reader instance
		MTPRODUCTCATALOGEXECLib::IMTProductOfferingReaderPtr ptrProdOffReader(__uuidof(MTPRODUCTCATALOGEXECLib::MTProductOfferingReader));

		*apProdOff = reinterpret_cast<IMTProductOffering*> (ptrProdOffReader->FindByName(GetSessionContextPtr(), aName).Detach());
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}


STDMETHODIMP CMTProductCatalog::FindProductOfferingsAsRowset(VARIANT aFilter, IMTRowSet **apRowset)
{
	if (!(apRowset))
		return E_POINTER;

  try
	{
		// create reader instance and pass through
		MTPRODUCTCATALOGEXECLib::IMTProductOfferingReaderPtr ptrProdOffReader(__uuidof(MTPRODUCTCATALOGEXECLib::MTProductOfferingReader));
		MTPRODUCTCATALOGEXECLib::IMTRowSetPtr aRowset = ptrProdOffReader->FindAsRowset(GetSessionContextPtr(), aFilter);
		*apRowset	= reinterpret_cast<IMTRowSet*> (aRowset.Detach());
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}
	return S_OK;
}

STDMETHODIMP CMTProductCatalog::CreateProductOffering(IMTProductOffering **apProdOff)
{
	if (!apProdOff)
		return E_POINTER;
	
	try
	{
		MTPRODUCTCATALOGLib::IMTProductOfferingPtr prodOff(__uuidof(MTProductOffering));

		//pass the session context on to objects created from this one
		MTPRODUCTCATALOGLib::IMTProductCatalogPtr thisPtr = this;
		MTPRODUCTCATALOGLib::IMTSessionContextPtr ctxt = thisPtr->GetSessionContext();
		prodOff->SetSessionContext(ctxt);

		*apProdOff = reinterpret_cast<IMTProductOffering *>(prodOff.Detach());
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

STDMETHODIMP CMTProductCatalog::RemoveProductOffering(long aID)
{
	AuditEventsLib::MTAuditEvent deniedEvent = AuditEventsLib::AUDITEVENT_UNKNOWN;

  try
	{
		deniedEvent = AuditEventsLib::AUDITEVENT_PL_DELETE_DENIED;
		CHECKCAP(DELETE_PRODUCT_OFFERINGS_CAP);

		// create writer instance
		MTPRODUCTCATALOGEXECLib::IMTProductOfferingWriterPtr prodOffWriter(__uuidof(MTPRODUCTCATALOGEXECLib::MTProductOfferingWriter));
		// attempt delete
		prodOffWriter->Remove(GetSessionContextPtr(), aID);
	}
	catch (_com_error & err)
	{
		AuditAuthFailures(err, deniedEvent, GetSessionContextPtr()->AccountID, 
											AuditEventsLib::AUDITENTITY_TYPE_PRODCAT,
											aID);
		return LogAndReturnComError(PCCache::GetLogger(), err);
	}
	return S_OK;
}

STDMETHODIMP CMTProductCatalog::FindCountersAsRowset(VARIANT aFilter, IMTRowSet **apRowset)
{
	if (!apRowset)
		return E_POINTER;
	
  try
	{
	  // create reader instance
		MTPRODUCTCATALOGEXECLib::IMTCounterReaderPtr ptrCounterReader(__uuidof(MTPRODUCTCATALOGEXECLib::MTCounterReader));
		MTPRODUCTCATALOGEXECLib::IMTRowSetPtr aRowset = ptrCounterReader->FindAsRowset(GetSessionContextPtr(), aFilter);
		*apRowset = reinterpret_cast<IMTRowSet*>(aRowset.Detach());
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

STDMETHODIMP CMTProductCatalog::GetCounterType(long aDBID, IMTCounterType** apVal)
{
	if (!apVal)
		return E_POINTER;

  try
	{
	  // create reader instance
		MTPRODUCTCATALOGEXECLib::IMTCounterTypeReaderPtr ptrCounterTypeReader(__uuidof(MTPRODUCTCATALOGEXECLib::MTCounterTypeReader));

		*apVal = (IMTCounterType *) ptrCounterTypeReader->Find(GetSessionContextPtr(), aDBID).Detach();
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

STDMETHODIMP CMTProductCatalog::GetCounterTypeByName(BSTR aCounterTypeName, IMTCounterType** apVal)
{
	if (!apVal)
		return E_POINTER;
	
  try
	{
	  // create reader instance
		MTPRODUCTCATALOGEXECLib::IMTCounterTypeReaderPtr ptrCounterTypeReader(__uuidof(MTPRODUCTCATALOGEXECLib::MTCounterTypeReader));
		*apVal = (IMTCounterType *) ptrCounterTypeReader->FindByName(GetSessionContextPtr(), aCounterTypeName).Detach();
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}


	return S_OK;
}

STDMETHODIMP CMTProductCatalog::GetCounterTypes(IMTCollection** apVal)
{
	if (!apVal)
		return E_POINTER;
	
  try
	{
	  // create reader instance
		MTPRODUCTCATALOGEXECLib::IMTCounterTypeReaderPtr ptrCounterTypeReader(__uuidof(MTPRODUCTCATALOGEXECLib::MTCounterTypeReader));
		*apVal = (IMTCollection*) ptrCounterTypeReader->GetAllTypes(GetSessionContextPtr()).Detach();
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

STDMETHODIMP CMTProductCatalog::GetCounter(long aDBID, IMTCounter **apVal)
{
	if (!apVal)
		return E_POINTER;
	
  try
	{
	  // create reader instance
		MTPRODUCTCATALOGEXECLib::IMTCounterReaderPtr ptrCounterReader(__uuidof(MTPRODUCTCATALOGEXECLib::MTCounterReader));
		*apVal = (IMTCounter *) ptrCounterReader->Find(GetSessionContextPtr(), aDBID).Detach();
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

STDMETHODIMP CMTProductCatalog::GetCountersOfType(long aTypeDBID, IMTCollection **apVal)
{
	if (!apVal)
		return E_POINTER;
	
  try
	{
	  // create reader instance
		MTPRODUCTCATALOGEXECLib::IMTCounterReaderPtr ptrCounterReader(__uuidof(MTPRODUCTCATALOGEXECLib::MTCounterReader));
		*apVal = (IMTCollection*) ptrCounterReader->FindOfType(GetSessionContextPtr(), aTypeDBID).Detach();
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}
	return S_OK;
}

STDMETHODIMP CMTProductCatalog::GetParamTableDefinitionByName(BSTR name, IMTParamTableDefinition **table)
{
  try
	{
		// create instance of COM+ executant
		MTPRODUCTCATALOGEXECLib::IMTParamTableDefinitionReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTParamTableDefinitionReader));
		
		MTPRODUCTCATALOGEXECLib::IMTParamTableDefinitionPtr paramTable
			= reader->FindByName(GetSessionContextPtr(), name);
		*table = (IMTParamTableDefinition *) paramTable.Detach();
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}


	return S_OK;
}

STDMETHODIMP CMTProductCatalog::GetParamTableDefinition(long id, IMTParamTableDefinition **table)
{
  try
	{
		// create instance of COM+ executant
		MTPRODUCTCATALOGEXECLib::IMTParamTableDefinitionReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTParamTableDefinitionReader));
		
		MTPRODUCTCATALOGEXECLib::IMTParamTableDefinitionPtr paramTable
			= reader->FindByID(GetSessionContextPtr(), id);
		*table = (IMTParamTableDefinition *) paramTable.Detach();
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

STDMETHODIMP CMTProductCatalog::GetMetaData(MTPCEntityType aEntityType, IMTPropertyMetaDataSet **apMetaDataSet)
{
	if (!apMetaDataSet)
		return E_POINTER;

  try
	{
		MTPRODUCTCATALOGLib::IMTPropertyMetaDataSetPtr metaDataSetPtr;
		metaDataSetPtr = PCCache::GetMetaData( aEntityType );
		*apMetaDataSet = reinterpret_cast<IMTPropertyMetaDataSet*>(metaDataSetPtr.Detach());
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

STDMETHODIMP CMTProductCatalog::CreatePriceableItemType(IMTPriceableItemType **apType)
{
	if (!apType)
		return E_POINTER;
	
	try
	{
		MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr piType(__uuidof(MTPriceableItemType));

		//pass the session context on to objects created from this one
		MTPRODUCTCATALOGLib::IMTProductCatalogPtr thisPtr = this;
		MTPRODUCTCATALOGLib::IMTSessionContextPtr ctxt = thisPtr->GetSessionContext();
		piType->SetSessionContext(ctxt);

		*apType = reinterpret_cast<IMTPriceableItemType *>(piType.Detach());
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

STDMETHODIMP CMTProductCatalog::GetPriceableItemType(long aID, IMTPriceableItemType **apType)
{
	if (!apType)
		return E_POINTER;

  try
	{
	  // create reader instance
		MTPRODUCTCATALOGEXECLib::IMTPriceableItemTypeReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTPriceableItemTypeReader));

		*apType = reinterpret_cast<IMTPriceableItemType*> (reader->Find(GetSessionContextPtr(), aID).Detach());
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

STDMETHODIMP CMTProductCatalog::GetPriceableItemTypeByName(BSTR aName, IMTPriceableItemType **apType)
{
	ASSERT(apType);
	if(!apType) return E_POINTER;
  try {
	  // create reader instance
		MTPRODUCTCATALOGEXECLib::IMTPriceableItemTypeReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTPriceableItemTypeReader));

		*apType = reinterpret_cast<IMTPriceableItemType*> (reader->FindByName(GetSessionContextPtr(), aName).Detach());
	}	
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}



STDMETHODIMP CMTProductCatalog::GetPriceableItemTypes(VARIANT aFilter, IMTCollection **apColl)
{
	if (!apColl)
		return E_POINTER;

	*apColl = NULL;

  try
	{
	  // create reader instance
		MTPRODUCTCATALOGEXECLib::IMTPriceableItemTypeReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTPriceableItemTypeReader));
    //pass IS NULL condition to the query. I removed hardcoded "idparent IS NULL" from the query
    //so that it could be used for child PI types as well
    MTPRODUCTCATALOGEXECLib::IMTDataFilterPtr filter("MTSQLRowset.MTDataFilter");
    _variant_t varFilter;
    if(OptionalVariantConversion(aFilter,VT_DISPATCH,varFilter))
    {
     filter = varFilter;
    }
    else
    {
      varFilter = filter.GetInterfacePtr();
    }
    filter->AddIsNull("id_parent");
		*apColl = reinterpret_cast<IMTCollection*> (reader->FindByFilter(GetSessionContextPtr(), varFilter).Detach());
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

STDMETHODIMP CMTProductCatalog::RemovePriceableItemType(long aID)
{
  try
	{
		// TODO: we may want to remove all templates created from this type, first.

		// create writer instance
		MTPRODUCTCATALOGEXECLib::IMTPriceableItemTypeWriterPtr writer(__uuidof(MTPRODUCTCATALOGEXECLib::MTPriceableItemTypeWriter));

		writer->Remove(GetSessionContextPtr(), aID);
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}
	return S_OK;
}

STDMETHODIMP CMTProductCatalog::GetPriceableItem(long aID, IMTPriceableItem** apPrcItem)
{
	if (!apPrcItem)
		return E_POINTER;

  try
	{
	  // create reader instance
		MTPRODUCTCATALOGEXECLib::IMTPriceableItemReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTPriceableItemReader));

		*apPrcItem = reinterpret_cast<IMTPriceableItem*> (reader->Find(GetSessionContextPtr(), aID).Detach());
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

STDMETHODIMP CMTProductCatalog::GetPriceableItemByName(BSTR aName, IMTPriceableItem **apPI)
{
	if (!apPI)
		return E_POINTER;

  try
	{
	  // create reader instance
		MTPRODUCTCATALOGEXECLib::IMTPriceableItemReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTPriceableItemReader));

		*apPI = reinterpret_cast<IMTPriceableItem*> (reader->FindTemplateByName(GetSessionContextPtr(), aName).Detach());
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

STDMETHODIMP CMTProductCatalog::FindPriceableItemsAsRowset(VARIANT aFilter, IMTRowSet **apRowset)
{
	if (!apRowset)
		return E_POINTER;

  try
	{
		// create reader instance and pass through
		MTPRODUCTCATALOGEXECLib::IMTPriceableItemReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTPriceableItemReader));
		MTPRODUCTCATALOGEXECLib::IMTRowSetPtr aRowset = reader->FindTemplatesAsRowset(GetSessionContextPtr(), aFilter);
		*apRowset	= reinterpret_cast<IMTRowSet*> (aRowset.Detach());
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}
	return S_OK;
}

STDMETHODIMP CMTProductCatalog::GetPriceListByName(BSTR aName, IMTPriceList * * apPriceList)
{
	if (!apPriceList)
		return E_POINTER;

	try
	{
		// create reader instance
		IMTPriceListReaderPtr reader(__uuidof(MTPriceListReader));

		*apPriceList = reinterpret_cast<IMTPriceList*> (reader->FindByName(GetSessionContextPtr(), aName).Detach());
	}
	catch (_com_error & err)
	{ return LogAndReturnComError(PCCache::GetLogger(),err); }

	return S_OK;
}

STDMETHODIMP CMTProductCatalog::GetPriceList(long id, /*[out, retval]*/ IMTPriceList * * apPriceList)
{
	if (!apPriceList)
		return E_POINTER;

	try
	{
		// create reader instance
		IMTPriceListReaderPtr reader(__uuidof(MTPriceListReader));

		*apPriceList = reinterpret_cast<IMTPriceList*> (reader->Find(GetSessionContextPtr(), id).Detach());
	}
	catch (_com_error & err)
	{ return LogAndReturnComError(PCCache::GetLogger(),err); }

	return S_OK;
}

STDMETHODIMP CMTProductCatalog::RemovePriceList(long id)
{
	AuditEventsLib::MTAuditEvent deniedEvent = AuditEventsLib::AUDITEVENT_UNKNOWN;

	try
	{
		// Business Rule: delete override
		if (!PCCache::IsBusinessRuleEnabled(PCCONFIGLib::MTPC_BUSINESS_RULE_Rates_DeleteOverride))
			MT_THROW_COM_ERROR(IID_IMTProductCatalog, MTPCUSER_DOES_NOT_ALLOW_RATE_DELETE);

		deniedEvent = AuditEventsLib::AUDITEVENT_PL_DELETE_DENIED;
		CHECKCAP(DELETE_RATES_CAP);

		//pass the session context on to objects created from this one
		IMTPriceListWriterPtr plWriter(__uuidof(MTPriceListWriter));
		plWriter->Remove(GetSessionContextPtr(), id);
	}
	catch (_com_error & err)
	{
		AuditAuthFailures(err, deniedEvent, GetSessionContextPtr()->AccountID, 
											AuditEventsLib::AUDITENTITY_TYPE_PRODCAT,
											id);
		return LogAndReturnComError(PCCache::GetLogger(),err); 
	}
	return S_OK;
}

STDMETHODIMP CMTProductCatalog::CreatePriceList(/*[out, retval]*/ IMTPriceList * * apPriceList)
{
	try
	{
		IMTPriceListPtr pricelist(__uuidof(MTPriceList));
		
		//pass the session context on to objects created from this one
		MTPRODUCTCATALOGLib::IMTProductCatalogPtr thisPtr = this;
		MTPRODUCTCATALOGLib::IMTSessionContextPtr ctxt = thisPtr->GetSessionContext();
		pricelist->SetSessionContext(ctxt);

		*apPriceList = (IMTPriceList *) pricelist.Detach();
	}
	catch (_com_error & err)
	{ return LogAndReturnComError(PCCache::GetLogger(),err); }

	return S_OK;
}

STDMETHODIMP CMTProductCatalog::FindPriceListsAsRowset(VARIANT aFilter, IMTRowSet **apRowset)
{
	if (!apRowset)
		return E_POINTER;

  try
	{
		// create reader instance and pass through
		IMTPriceListReaderPtr plReader(__uuidof(MTPriceListReader));
		MTPRODUCTCATALOGEXECLib::IMTRowSetPtr aRowset = plReader->FindAsRowset(GetSessionContextPtr(), PROPERTIES_BASE_NO_ID, PROPERTIES_BASE_NO_ID, aFilter);
		*apRowset	= reinterpret_cast<IMTRowSet*> (aRowset.Detach());
	}
	catch (_com_error & err)
	{ return LogAndReturnComError(PCCache::GetLogger(),err); }

	return S_OK;
}

// ----------------------------------------------------------------
// Name:          FindPriceListsForMappingAsRowset
// Arguments:     aParamTblDefID - parameter table definition to use when checking rates
//                aPrcItemTmplID - priceable item template to use when checking rates
//                aFilter - optional filter
//                apRowset - resulting rowset, with pricelist columns and column 'rateschedules'
// Return Value:  
// Errors Raised: 
// Description:   column 'rateschedules' contains the number of rateschedules
//                for that price list and passed in ParamTblDef, PrcItemTmpl
//                column 'rateschedules' is NULL if there aren't any appropriate rateschedules
// ----------------------------------------------------------------
STDMETHODIMP CMTProductCatalog::FindPriceListsForMappingAsRowset(long aParamTblDefID, long aPrcItemTmplID, VARIANT aFilter, IMTRowSet** apRowset)
{
	if (!apRowset)
		return E_POINTER;

  try
	{
		// create reader instance and pass through
		IMTPriceListReaderPtr plReader(__uuidof(MTPriceListReader));
		MTPRODUCTCATALOGEXECLib::IMTRowSetPtr aRowset = plReader->FindAsRowset(GetSessionContextPtr(), aParamTblDefID, aPrcItemTmplID, aFilter);
		*apRowset	= reinterpret_cast<IMTRowSet*> (aRowset.Detach());
	}
	catch (_com_error & err)
	{ return LogAndReturnComError(PCCache::GetLogger(),err); }

	return S_OK;
}

STDMETHODIMP CMTProductCatalog::CreateCounter(long aTypeID, IMTCounter **apCounter)
{
	HRESULT hr(S_OK);
	if(!apCounter)
		return E_POINTER;
	try
	{
		MTCOUNTERLib::IMTCounterTypePtr CounterType(__uuidof(MTCOUNTERLib::MTCounterType));
		MTCOUNTERLib::IMTCounterPtr Counter(__uuidof(MTCOUNTERLib::MTCounter));

		//TODO: pass the session context on once Counters are ready for it!!
		//MTPRODUCTCATALOGLib::IMTProductCatalogPtr thisPtr = this;
		//MTPRODUCTCATALOGLib::IMTSessionContextPtr ctxt = thisPtr->GetSessionContext();
		//CounterType->SetSessionContext(ctxt);
		//Counter->SetSessionContext(ctxt);

		GetCounterType(aTypeID, (IMTCounterType**) &CounterType);
		Counter = CounterType->CreateCounter();
		(*apCounter) = (IMTCounter*) Counter.Detach();
	}
	catch(_com_error& e)
	{
		return LogAndReturnComError(PCCache::GetLogger(),e);
	}

	return hr;
}


STDMETHODIMP CMTProductCatalog::GetAccount(long accountID,IMTPCAccount** ppAccount)
{
	ASSERT(ppAccount);
	if(!ppAccount) return E_POINTER;
	
	try {

		// step 1: create the account object
		MTPRODUCTCATALOGLib::IMTPCAccountPtr account(__uuidof(MTPRODUCTCATALOGLib::MTPCAccount));

		// step 1a: pass the session context on to objects created from this one
		MTPRODUCTCATALOGLib::IMTProductCatalogPtr thisPtr = this;
		MTPRODUCTCATALOGLib::IMTSessionContextPtr ctxt = thisPtr->GetSessionContext();
		account->SetSessionContext(ctxt);

		// step 2: populate the account ID
		account->PutAccountID(accountID);
		// step 3: return the object
		*ppAccount = reinterpret_cast<IMTPCAccount*>(account.Detach());
	}
	catch(_com_error& e)
	{
		return LogAndReturnComError(PCCache::GetLogger(),e);
	}
	return S_OK;
}

STDMETHODIMP CMTProductCatalog::GetCounterPropertyDefinition(long aDBID, IMTCounterPropertyDefinition **apVal)
{
	if (!apVal)
		return E_POINTER;
	
  try
	{
	  // create reader instance
		MTPRODUCTCATALOGEXECLib::IMTCounterPropertyDefinitionReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTCounterPropertyDefinitionReader));
		*apVal = (IMTCounterPropertyDefinition *) reader->Find(GetSessionContextPtr(), aDBID).Detach();
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}
	return S_OK;
}

STDMETHODIMP CMTProductCatalog::BulkSubscriptionChange(long aOldPO_id, long aNewPO_id, VARIANT vtDate,VARIANT_BOOL bNextBillingCycle)
{
  try
	{
		MTPRODUCTCATALOGEXECLib::IMTSubscriptionWriterPtr writer(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionWriter));
		writer->BulkSubscriptionChange(GetSessionContextPtr(), aOldPO_id,aNewPO_id,vtDate,bNextBillingCycle);
		

		MTPRODUCTCATALOGLib::IMTProductCatalogPtr thisPtr = this;
		MTPRODUCTCATALOGLib::IMTProductOfferingPtr prodOff;
		prodOff = thisPtr->GetProductOffering(aOldPO_id);
		

		MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr pContext(GetSessionContextPtr());
		PCCache::GetAuditor()->FireEvent(1500,pContext->AccountID,2,aNewPO_id,prodOff->GetName());

	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}
	return S_OK;
}


STDMETHODIMP CMTProductCatalog::RateAllAggregateCharges(long aUsageIntervalID, long aSessionSetSize)
{
	return Rate(aUsageIntervalID, NULL, true, aSessionSetSize);
}

// DEPRECATED
STDMETHODIMP CMTProductCatalog::RateAllAggregateChargesForAccount(long aUsageIntervalID, long aAccountID)
{
	return Rate(aUsageIntervalID, aAccountID, true, 1000);
}

// DEPRECATED
STDMETHODIMP CMTProductCatalog::RateAllAggregateChargesForAccountAsynch(long aUsageIntervalID, long aAccountID)
{
	return Rate(aUsageIntervalID, aAccountID, false, 1000);
}

STDMETHODIMP CMTProductCatalog::GetPriceableItemInstancesByKind(MTPCEntityType aKind, /*[out, retval]*/ IMTCollection** apInstances)
{
	HRESULT hr(S_OK);
	
	if (!apInstances)
		return E_POINTER;

	(*apInstances) = NULL;
	
  try
	{
	  // create reader instance
		MTPRODUCTCATALOGEXECLib::IMTPriceableItemTypeReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTPriceableItemTypeReader));
		(*apInstances) = (IMTCollection*)reader->FindInstancesByKind( GetSessionContextPtr(), ( MTPRODUCTCATALOGEXECLib::MTPCEntityType)aKind).Detach();
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}
	return hr;
}
 

STDMETHODIMP CMTProductCatalog::CreateCalendar(IMTCalendar **apCalendar)
{
	if (!apCalendar)
		return E_POINTER;
	
	try
	{
		MTPRODUCTCATALOGLib::IMTCalendarPtr calendar(__uuidof(MTCalendar));

		//pass the session context on to objects created from this one
		MTPRODUCTCATALOGLib::IMTProductCatalogPtr thisPtr = this;
		MTPRODUCTCATALOGLib::IMTSessionContextPtr ctxt = thisPtr->GetSessionContext();
		calendar->SetSessionContext(ctxt);

		*apCalendar = reinterpret_cast<IMTCalendar *>(calendar.Detach());
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

STDMETHODIMP CMTProductCatalog::GetCalendarsAsRowset(IMTRowSet **apRowset)
{
	if (!apRowset)
		return E_POINTER;

	try
	{
		MTPRODUCTCATALOGEXECLib::IMTCalendarReaderPtr pReader(__uuidof(MTCalendarReader));
		MTPRODUCTCATALOGEXECLib::IMTRowSetPtr aRowset = pReader->GetCalendarsAsRowset(GetSessionContextPtr());
		*apRowset	= reinterpret_cast<IMTRowSet*> (aRowset.Detach());
	}
	catch (_com_error & err)
	{ 
		return LogAndReturnComError(PCCache::GetLogger(),err); 
	}

	return S_OK;	
}

STDMETHODIMP CMTProductCatalog::GetCalendar(long aID, IMTCalendar **apCalendar)
{
	if (!apCalendar)
		return E_POINTER;

	try
	{
		MTPRODUCTCATALOGEXECLib::IMTCalendarReaderPtr pReader(__uuidof(MTCalendarReader));
		MTPRODUCTCATALOGLib::IMTCalendarPtr pCalendar = pReader->GetCalendar(GetSessionContextPtr(), aID);
		*apCalendar = reinterpret_cast<IMTCalendar*>(pCalendar.Detach());
	}
	catch (_com_error & err)
	{ 
		return LogAndReturnComError(PCCache::GetLogger(),err); 
	}

	return S_OK;
}

STDMETHODIMP CMTProductCatalog::GetCalendarByName(BSTR aName, IMTCalendar **apCalendar)
{
	if (!apCalendar)
		return E_POINTER;

	try
	{
		MTPRODUCTCATALOGEXECLib::IMTCalendarReaderPtr pReader(__uuidof(MTCalendarReader));
		MTPRODUCTCATALOGLib::IMTCalendarPtr pCalendar = pReader->GetCalendarByName(GetSessionContextPtr(), aName);
		*apCalendar = reinterpret_cast<IMTCalendar*>(pCalendar.Detach());
	}
	catch (_com_error & err)
	{ 
		return LogAndReturnComError(PCCache::GetLogger(),err); 
	}

	return S_OK;
}


/// NON COM - INTERNAL USE ONLY
// iterates over all aggregate charge priceable item templates who are not children
// calls MTAggregateCharge::Rate(aUsageIntervalID)
HRESULT CMTProductCatalog::Rate(long aUsageIntervalID,
																long aAccountID,
																bool aWaitForCommit,
																long aSessionSetSize)
{
	try {
		MTPRODUCTCATALOGEXECLib::IMTPriceableItemTypeReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTPriceableItemTypeReader));

		//get all templates of PCENTITY_TYPE_AGGREGATE_CHARGE kind
		MTObjectCollection<IMTPriceableItem> CollTemplates;
		CollTemplates =  (IMTCollection*)reader->FindTemplatesByKind
			(GetSessionContextPtr(), ( MTPRODUCTCATALOGEXECLib::MTPCEntityType)PCENTITY_TYPE_AGGREGATE_CHARGE).GetInterfacePtr();

		long lNumTemplates;
		CollTemplates.Count(&lNumTemplates);
		for (int i = 1; i <= lNumTemplates; ++i) {
			//casts each template to IMTAggregateCharge*
			MTPRODUCTCATALOGLib::IMTAggregateChargePtr aggregateCharge;
			MTPRODUCTCATALOGLib::IMTPriceableItemPtr pi;
			CollTemplates.Item(i, (IMTPriceableItem**) &pi);
			aggregateCharge = reinterpret_cast<IMTAggregateCharge*> (pi.GetInterfacePtr());
			
			//rates only parents (parents are responsible for calling Rate on children)
			if (aggregateCharge->GetParent() == NULL) 
			{
				if(aAccountID) 
				{
					if (aWaitForCommit)
						aggregateCharge->RateAccount(aUsageIntervalID, aAccountID);
					else
						aggregateCharge->RateAccountAsynch(aUsageIntervalID, aAccountID);
				} 
				else 
					aggregateCharge->Rate(aUsageIntervalID, aSessionSetSize);
			}
		}	
	}
	catch (_com_error & err)
	{	return LogAndReturnComError(PCCache::GetLogger(),err);}

	return S_OK;
}


STDMETHODIMP CMTProductCatalog::RemoveCounter(long aCounterID)
{
	HRESULT hr(S_OK);
	try
	{
		MTPRODUCTCATALOGEXECLib::IMTCounterWriterPtr writer
			(__uuidof(MTPRODUCTCATALOGEXECLib::MTCounterWriter));
		writer->Remove(GetSessionContextPtr(), aCounterID);
	}
	catch (_com_error & e)
	{ 
		return LogAndReturnComError(PCCache::GetLogger(),e); 
	}
	
	return hr;
}

STDMETHODIMP CMTProductCatalog::ClearCache()
{
	PCCache::Refresh();

	return S_OK;
}

STDMETHODIMP CMTProductCatalog::GetPricelistChaining(MTPC_PRICELIST_CHAIN_RULE* apChainRule)
{
	(*apChainRule) = static_cast<MTPC_PRICELIST_CHAIN_RULE>(PCCache::GetPLChaining());
	return S_OK;
}

STDMETHODIMP CMTProductCatalog::IsBusinessRuleEnabled(MTPC_BUSINESS_RULE aBusRule, VARIANT_BOOL* apEnabledFlag)
{
	(*apEnabledFlag) = PCCache::IsBusinessRuleEnabled(static_cast<PCCONFIGLib::MTPC_BUSINESS_RULE>(aBusRule));
	return S_OK;
}

STDMETHODIMP CMTProductCatalog::SetSessionContextAccountID(long aAccountID)
{
  try
	{
		//get the session context of this product catalog
		MTPRODUCTCATALOGLib::IMTProductCatalogPtr thisPtr = this;
		MTPRODUCTCATALOGLib::IMTSessionContextPtr ctxt = thisPtr->GetSessionContext();
		
		//set account ID of session context
		ctxt->AccountID = aAccountID;

	}
	catch (_com_error & err)
	{ return LogAndReturnComError(PCCache::GetLogger(),err); }

	return S_OK;
}

STDMETHODIMP CMTProductCatalog::CreateGroupSubscription(IMTGroupSubscription **ppGroupSub)
{
	ASSERT(ppGroupSub);
	if(!ppGroupSub) return E_POINTER;
	
	AuditEventsLib::MTAuditEvent deniedEvent = AuditEventsLib::AUDITEVENT_UNKNOWN;
	try {
    // check for the create group subscription capability
		deniedEvent = AuditEventsLib::AUDITEVENT_SUB_CREATE_DENIED;
    CHECKCAP(CREATE_GROUPSUB_CAP);

		MTPRODUCTCATALOGLib::IMTGroupSubscriptionPtr groupSubPtr(__uuidof(MTGroupSubscription));

		//pass the session context on to objects created from this one
		MTPRODUCTCATALOGLib::IMTProductCatalogPtr thisPtr = this;
		MTPRODUCTCATALOGLib::IMTSessionContextPtr ctxt = thisPtr->GetSessionContext();
		groupSubPtr->SetSessionContext(ctxt);

		*ppGroupSub = reinterpret_cast<IMTGroupSubscription *>(groupSubPtr.Detach());
	}
	catch(_com_error& err) {
		AuditAuthFailures(err, deniedEvent, GetSessionContextPtr()->AccountID, 
											AuditEventsLib::AUDITENTITY_TYPE_ACCOUNT,
											-1);

		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

STDMETHODIMP CMTProductCatalog::DeleteGroupSubscription(long aGroupID)
{
  // TODO: Implement proper auth here - probably need (yet) another capability
  AuditEventsLib::MTAuditEvent event;
	try 
  {
    event = AuditEventsLib::AUDITEVENT_GSUB_DELETE_DENIED;
    CHECKCAP(DELETESUB_CAP);
    MTPRODUCTCATALOGLib::IMTProductCatalogPtr thisPtr = this;
    MTPRODUCTCATALOGLib::IMTSubscriptionBasePtr basePtr = thisPtr->GetGroupSubscriptionByID(aGroupID);

	  MTPRODUCTCATALOGEXECLib::IMTSubscriptionWriterPtr subWriter(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionWriter));
    subWriter->DeleteGroupSubscription(GetSessionContextPtr(),
      reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSubscriptionBase*>(basePtr.GetInterfacePtr()));
  }
	catch (_com_error & err)
	{ 
    // TODO : Fix auth failure type
		AuditAuthFailures(err, event, GetSessionContextPtr()->AccountID, 
											AuditEventsLib::AUDITENTITY_TYPE_GROUPSUB,
											aGroupID);
		return LogAndReturnComError(PCCache::GetLogger(),err);
  }
  return S_OK;
}

STDMETHODIMP CMTProductCatalog::GetGroupSubscriptionsAsRowset(DATE RefDate,VARIANT aFilter,
																															IMTSQLRowset **ppRowset)
{
	ASSERT(ppRowset);
	if(!ppRowset) return E_POINTER;
	try {

		MTPRODUCTCATALOGEXECLib::IMTSubscriptionReaderPtr 
			subReader(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionReader));
		MTPRODUCTCATALOGEXECLib::IMTRowSetPtr aRowset = 
			subReader->GetGroupSubscriptionsAsRowset(GetSessionContextPtr(),RefDate, aFilter);
		*ppRowset	= reinterpret_cast<IMTSQLRowset*> (aRowset.Detach());

	}
	catch(_com_error& err) {
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

STDMETHODIMP CMTProductCatalog::GetGroupSubscriptionByName(DATE RefDate,
																													 BSTR name,
																													 IMTGroupSubscription **ppGroupSub)
{
	ASSERT(ppGroupSub);
	if(!ppGroupSub) return E_POINTER;

	try {
		MTPRODUCTCATALOGEXECLib::IMTSubscriptionReaderPtr 
			subReader(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionReader));
		MTPRODUCTCATALOGLib::IMTGroupSubscriptionPtr aGroupSub = 
			subReader->GetGroupSubscriptionByName(GetSessionContextPtr(),RefDate, name);
		*ppGroupSub = reinterpret_cast<IMTGroupSubscription*>(aGroupSub.Detach());

	}
	catch(_com_error& err) {
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

STDMETHODIMP CMTProductCatalog::GetGroupSubscriptionByID(long aGroupSubID, 
																												 IMTGroupSubscription **ppSub)
{
	// TODO: Add your implementation code here
	ASSERT(ppSub);
	if(!ppSub) return E_POINTER;

	try {
		MTPRODUCTCATALOGEXECLib::IMTSubscriptionReaderPtr 
			subReader(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionReader));
		MTPRODUCTCATALOGLib::IMTGroupSubscriptionPtr aGroupSub = 
			subReader->GetGroupSubscriptionByID(GetSessionContextPtr(),aGroupSubID);
		*ppSub = reinterpret_cast<IMTGroupSubscription*>(aGroupSub.Detach());
	}
	catch(_com_error& err) {
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

STDMETHODIMP CMTProductCatalog::GetGroupSubscriptionByCorporateAccount(long aCorporateAccount, IMTSQLRowset **ppRowset)
{
	try {
		MTPRODUCTCATALOGEXECLib::IMTSubscriptionReaderPtr 
			subReader(__uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionReader));
		MTPRODUCTCATALOGEXECLib::IMTRowSetPtr aRowset = 	
			subReader->GetGroupSubscriptionByCorporateAccount(aCorporateAccount);
		*ppRowset = reinterpret_cast<IMTSQLRowset*>(aRowset.Detach());
	}
	catch(_com_error& err) {
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}
	return S_OK;
}

STDMETHODIMP CMTProductCatalog::FindAvailableProductOfferingsAsRowset(VARIANT aFilter, VARIANT RefDate,
                                                                      IMTSQLRowset **ppRowset)
{
	try {
	  // create reader instance
		MTPRODUCTCATALOGEXECLib::IMTProductOfferingReaderPtr ptrProdOffReader(__uuidof(MTPRODUCTCATALOGEXECLib::MTProductOfferingReader));
		*ppRowset = reinterpret_cast<IMTSQLRowset*> 
      (ptrProdOffReader->FindAvailableProductOfferingsAsRowset(GetSessionContextPtr(),aFilter,RefDate).Detach());

  }
	catch(_com_error& err) {
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}
	return S_OK;
}

STDMETHODIMP CMTProductCatalog::FindAvailableProductOfferingsForGroupSubscriptionAsRowset(long corpAccID, VARIANT aFilter, VARIANT RefDate,
                                                                      IMTSQLRowset **ppRowset)
{
	try {
	  // create reader instance
		MTPRODUCTCATALOGEXECLib::IMTProductOfferingReaderPtr ptrProdOffReader(__uuidof(MTPRODUCTCATALOGEXECLib::MTProductOfferingReader));
		*ppRowset = reinterpret_cast<IMTSQLRowset*> 
      (ptrProdOffReader->FindAvailableProductOfferingsForGroupSubscriptionAsRowset(GetSessionContextPtr(),corpAccID,aFilter,RefDate).Detach());

  }
	catch(_com_error& err) {
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}
	return S_OK;
}

STDMETHODIMP CMTProductCatalog::OverrideBusinessRule(MTPC_BUSINESS_RULE aBusRule,VARIANT_BOOL aVal)
{
  PCCache::OverrideBusinessRule(aBusRule,aVal);
  return S_OK;
}


STDMETHODIMP CMTProductCatalog::SubscribeBatch(long aProductOffering,
                                               IMTPCTimeSpan* pTimeSpan,
                                               IMTCollection *pCol,
                                               IMTProgress *pProgress,
                                               VARIANT_BOOL *pDateModified,
                                               VARIANT transaction,
                                               IMTRowSet **ppRowset)
{
  // NOTE: This method does not do failure auditing because everything in
  // the transaction is rolled back in case of a one failure

	try {
    // check capability to create subscriptions
    CHECKCAP(CREATESUB_CAP);

    GUID subGUID = __uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionWriter);
    MTPRODUCTCATALOGEXECLib::IMTSubscriptionWriterPtr SubWriter;

    _variant_t trans;
    if(OptionalVariantConversion(transaction,VT_UNKNOWN,trans)) {
      PIPELINETRANSACTIONLib::IMTTransactionPtr pTrans(__uuidof(PIPELINETRANSACTIONLib::CMTTransaction));
      pTrans->SetTransaction(trans,VARIANT_FALSE);
      IDispatchPtr pDisp = pTrans->CreateObjectWithTransactionByCLSID(&subGUID);
      SubWriter = pDisp; // QI
    }
    else {
      SubWriter.CreateInstance(subGUID);
    }

    ROWSETLib::IMTSQLRowsetPtr errorRs(__uuidof(ROWSETLib::MTSQLRowset));

    SubWriter->SubscribeBatch(GetSessionContextPtr(),
      aProductOffering,
      reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTPCTimeSpan *>(pTimeSpan),
      reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTCollection *>(pCol),
      reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTProgress *>(pProgress),pDateModified,
      reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSQLRowset*>(errorRs.GetInterfacePtr()));

    ROWSETLib::IMTRowSetPtr rs = errorRs; // QI
    *ppRowset = reinterpret_cast<IMTRowSet*>(rs.Detach());
  }
	catch(_com_error& err) {
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}
	return S_OK;
}

STDMETHODIMP CMTProductCatalog::FindCounterParametersAsRowset(VARIANT aFilter, IMTRowSet **apRowset)
{
  if (!apRowset)
		return E_POINTER;

  try
	{
		// create reader instance and pass through
    MTPRODUCTCATALOGEXECLib::IMTCounterParamReaderPtr cpReader
      (__uuidof(MTPRODUCTCATALOGEXECLib::MTCounterParamReader));
		MTPRODUCTCATALOGEXECLib::IMTRowSetPtr aRowset = cpReader->FindSharedAsRowset(GetSessionContextPtr(), aFilter);
		*apRowset	= reinterpret_cast<IMTRowSet*> (aRowset.Detach());
	}
	catch (_com_error & err)
	{ return LogAndReturnComError(PCCache::GetLogger(),err); }

	return S_OK;
}

STDMETHODIMP CMTProductCatalog::GetCounterParameter(long aDBID, IMTCounterParameter **apParam)
{
	if (!apParam)
		return E_POINTER;
  (*apParam) = NULL;

  try
	{
	  // create reader instance
		MTPRODUCTCATALOGEXECLib::IMTCounterParamReaderPtr ptrCounterParamReader(__uuidof(MTPRODUCTCATALOGEXECLib::MTCounterParamReader));
    *apParam = (IMTCounterParameter *) ptrCounterParamReader->Find(GetSessionContextPtr(), aDBID).Detach();
	}
	catch (_com_error & err)
	{
		return LogAndReturnComError(PCCache::GetLogger(),err);
	}

	return S_OK;
}

STDMETHODIMP CMTProductCatalog::SubscribeToGroups(IMTCollection* pCol,
                                                  IMTProgress*   pProgress,
                                                  VARIANT_BOOL*  pDateModified,
                                                  VARIANT        transaction,
                                                  IMTRowSet**    ppRowset)
{
  // NOTE: This method does not do failure auditing because everything in
  // the transaction is rolled back in case of one failure

  try
  {
    // check capability to create subscriptions
    CHECKCAP(CREATESUB_CAP);

    GUID subGUID = __uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionWriter);
    MTPRODUCTCATALOGEXECLib::IMTSubscriptionWriterPtr SubWriter;

    _variant_t trans;
    if(OptionalVariantConversion(transaction,VT_UNKNOWN,trans))
    {
      PIPELINETRANSACTIONLib::IMTTransactionPtr pTrans(__uuidof(PIPELINETRANSACTIONLib::CMTTransaction));
      pTrans->SetTransaction(trans,VARIANT_FALSE);
      IDispatchPtr pDisp = pTrans->CreateObjectWithTransactionByCLSID(&subGUID);
      SubWriter = pDisp; // QI
    }
    else
    {
      SubWriter.CreateInstance(subGUID);
    }

    ROWSETLib::IMTSQLRowsetPtr errorRs(__uuidof(ROWSETLib::MTSQLRowset));

    SubWriter->SubscribeToGroups(GetSessionContextPtr(),
                                 reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTCollection*>(pCol),
                                 reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTProgress*>(pProgress),
                                 pDateModified,
                                 reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSQLRowset*>(errorRs.GetInterfacePtr()));

    ROWSETLib::IMTRowSetPtr rs = errorRs; // QI
    *ppRowset = reinterpret_cast<IMTRowSet*>(rs.Detach());
  }
  catch(_com_error& err)
  {
    return LogAndReturnComError(PCCache::GetLogger(),err);
  }

  return S_OK;
}

STDMETHODIMP CMTProductCatalog::SubscribeAccounts(IMTCollection* pCol,
                                                  IMTProgress*   pProgress,
                                                  VARIANT_BOOL*  pDateModified,
                                                  VARIANT        transaction,
                                                  IMTRowSet**    ppRowset)
{
  // NOTE: This method does not do failure auditing because everything in
  // the transaction is rolled back in case of one failure

  HRESULT hr = S_OK;

  try
  {
    // check capability to create subscriptions
    bool bCreateSubNotChecked = true;
    bool bSelfSubNotChecked   = true;
    long curAccountID = GetSecurityContext()->AccountID;
    long size;
    pCol->get_Count(&size);
    for(long i = 1; i <= size; i++) 
    {
	    _variant_t var;

	    hr = pCol->get_Item(i, &var);
	    if (FAILED(hr))
		    return hr;

      MTPRODUCTCATALOGLib::IMTSubInfoPtr memberPtr = var;

      var.Clear();

      if(!(memberPtr->IsGroupSub))
      {
        if (memberPtr->AccountID == curAccountID)
        {
          if (bSelfSubNotChecked)
          {
            // Only need to do this once.
            bSelfSubNotChecked = false;
            CHECKCAP(SELF_SUBSCRIBE);
          }
        }
        else
        {
          if (bCreateSubNotChecked)
          {
            // Only need to do this once.
            bCreateSubNotChecked = false;
            CHECKCAP(CREATESUB_CAP);
          }
        }

        if ((!bSelfSubNotChecked)
         && (!bCreateSubNotChecked))
        {
          // We know we can do anything so we are done!
          break;
        }
      }
    }

    GUID subGUID = __uuidof(MTPRODUCTCATALOGEXECLib::MTSubscriptionWriter);
    MTPRODUCTCATALOGEXECLib::IMTSubscriptionWriterPtr SubWriter;

    _variant_t trans;
    if(OptionalVariantConversion(transaction,VT_UNKNOWN,trans))
    {
      PIPELINETRANSACTIONLib::IMTTransactionPtr pTrans(__uuidof(PIPELINETRANSACTIONLib::CMTTransaction));
      pTrans->SetTransaction(trans,VARIANT_FALSE);
      IDispatchPtr pDisp = pTrans->CreateObjectWithTransactionByCLSID(&subGUID);
      SubWriter = pDisp; // QI
    }
    else
    {
      SubWriter.CreateInstance(subGUID);
    }

    ROWSETLib::IMTSQLRowsetPtr errorRs(__uuidof(ROWSETLib::MTSQLRowset));

    SubWriter->SubscribeAccounts(GetSessionContextPtr(),
                                 reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTCollection*>(pCol),
                                 reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTProgress*>(pProgress),
                                 pDateModified,
                                 reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSQLRowset*>(errorRs.GetInterfacePtr()));

    ROWSETLib::IMTRowSetPtr rs = errorRs; // QI
    *ppRowset = reinterpret_cast<IMTRowSet*>(rs.Detach());
  }
  catch(_com_error& err)
  {
    return LogAndReturnComError(PCCache::GetLogger(),err);
  }

  return S_OK;
}
