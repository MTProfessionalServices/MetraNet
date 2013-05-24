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
* $Header: c:\development35\ProductCatalog\MTProductCatalogExec\MTPriceableItemTypeWriter.cpp, 30, 11/12/2002 2:24:28 PM, David Blair$
* 
***************************************************************************/

#include "StdAfx.h"

#include "MTProductCatalogExec.h"
#include "MTPriceableItemTypeWriter.h"
#include <pcexecincludes.h>
#import <MetraTech.Pipeline.tlb> inject_statement("using namespace mscorlib; using ROWSETLib::IMTSQLRowsetPtr; using ROWSETLib::IMTSQLRowset;") no_function_mapping
#import <MetraTech.Localization.tlb> inject_statement("using namespace mscorlib;") no_function_mapping
#import <MetraTech.Adjustments.tlb> inject_statement("using namespace mscorlib; using namespace MetraTech_Pipeline; using namespace MetraTech_Localization;")//rename ("EOF", "RowsetEOF") no_function_mapping


/////////////////////////////////////////////////////////////////////////////
// CMTPriceableItemTypeWriter

/******************************************* error interface ***/
STDMETHODIMP CMTPriceableItemTypeWriter::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTPriceableItemTypeWriter
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

CMTPriceableItemTypeWriter::CMTPriceableItemTypeWriter()
{
	mpObjectContext = NULL;
}

HRESULT CMTPriceableItemTypeWriter::Activate()
{
	HRESULT hr = GetObjectContext(&mpObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTPriceableItemTypeWriter::CanBePooled()
{
	return FALSE;
} 

void CMTPriceableItemTypeWriter::Deactivate()
{
	mpObjectContext.Release();
} 


STDMETHODIMP CMTPriceableItemTypeWriter::Create(IMTSessionContext* apCtxt, 
																								/*[in]*/ IMTPriceableItemType *apType,
																								/*[out, retval]*/ long *apID)
{
	MTAutoContext context(mpObjectContext);

	if (!apType || !apID)
		return E_POINTER;

	//init out var
	*apID = 0;
	
	try
	{
		_variant_t vtParam;
		MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr prcItemType = apType; //use comptr for convenience

		//check for existing name
		VerifyName(apCtxt, apType);


		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		//insert into base prop
		MTPRODUCTCATALOGEXECLib::IMTBasePropsWriterPtr baseWriter(__uuidof(MTBasePropsWriter));
		long idProp = baseWriter->Create( reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), 
																			(long)prcItemType->Kind,
																			prcItemType->Name,
																			prcItemType->Description);
		//insert into pi
		rowset->SetQueryTag("__ADD_PI__");

		vtParam = idProp;
		rowset->AddParam("%%ID_PI%%",vtParam);
		
		long parentID = prcItemType->ParentID;
		if (parentID == PROPERTIES_BASE_NO_ID)		
			vtParam = "NULL";
		else
			vtParam = parentID;
		rowset->AddParam("%%ID_PARENT%%", vtParam);

		vtParam = prcItemType->ServiceDefinition;
		rowset->AddParam("%%SERVICEDEF%%", vtParam);

		vtParam = prcItemType->ProductView;
		if(_bstr_t(vtParam).length() == 0) {
			return Error("Product view must be specified");
		}
		rowset->AddParam("%%PRODUCTVIEW%%", vtParam);

		rowset->AddParam(L"%%CONSTRAIN_CYCLE%%", MTTypeConvert::BoolToString(prcItemType->ConstrainSubscriberCycle));

		rowset->Execute();

    prcItemType->ID = idProp;
    GENERICCOLLECTIONLib::IMTCollectionPtr adjustments = prcItemType->AdjustmentTypes;
    int count = adjustments->GetCount();
    for (int i = 1; i <= count; i++)
    {
      MetraTech_Adjustments::IAdjustmentTypePtr ajt = adjustments->GetItem(i);
			ajt->PriceableItemTypeID = prcItemType->ID;
      ajt->Save();
    }

		*apID = idProp;

	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}

STDMETHODIMP CMTPriceableItemTypeWriter::Update(IMTSessionContext* apCtxt, IMTPriceableItemType *apType)
{
	MTAutoContext context(mpObjectContext);
	if (!apType)
		return E_POINTER;

	try
	{
		_variant_t vtParam;
		MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr prcItemType = apType; //use comptr for convenience

		//check for existing name
		VerifyName(apCtxt, apType);


		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);

		MTPRODUCTCATALOGEXECLib::IMTBasePropsWriterPtr baseWriter(__uuidof(MTBasePropsWriter));
		baseWriter->Update(MTPRODUCTCATALOGEXECLib::IMTSessionContextPtr(apCtxt),
											 prcItemType->Name, prcItemType->Description,
											 prcItemType->ID);

		rowset->SetQueryTag(L"UPDATE_PI");
		rowset->AddParam(L"%%ID_PI%%", prcItemType->ID);

		long parentID = prcItemType->ParentID;
		if (parentID == PROPERTIES_BASE_NO_ID)		
			vtParam = "NULL";
		else
			vtParam = parentID;
		rowset->AddParam(L"%%ID_PARENT%%", vtParam);

		rowset->AddParam(L"%%SERVICEDEF%%", prcItemType->ServiceDefinition);
		rowset->AddParam(L"%%PRODUCTVIEW%%", prcItemType->ProductView);
		rowset->AddParam(L"%%CONSTRAIN_CYCLE%%", MTTypeConvert::BoolToString(prcItemType->ConstrainSubscriberCycle));

		rowset->Execute();

    //update adjustment types
    GENERICCOLLECTIONLib::IMTCollectionPtr adjustments = prcItemType->AdjustmentTypes;
    int count = adjustments->GetCount();
    for (int i = 1; i <= count; i++)
    {
      MetraTech_Adjustments::IAdjustmentTypePtr ajt = adjustments->GetItem(i);
      ajt->Save();
    }

	}
	catch (_com_error & err)
	{ return ReturnComError(err); }

	context.Complete();
	return S_OK;
}

STDMETHODIMP CMTPriceableItemTypeWriter::Remove(IMTSessionContext* apCtxt, long aID)
{
	MTAutoContext context(mpObjectContext);

	try
	{
		PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTPriceableItemTypeWriter::Remove(%d)", aID);

		/////////////////////////////
		// find priceable item type by aID
		MTPRODUCTCATALOGEXECLib::IMTPriceableItemTypeReaderPtr piReader( __uuidof(MTPRODUCTCATALOGEXECLib::MTPriceableItemTypeReader));
		MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr prcItemType;
		prcItemType = piReader->Find(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), aID); 

		if (prcItemType == NULL)
			MT_THROW_COM_ERROR(MTPC_OBJECT_NO_STATE);

		PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTPriceableItemTypeWriter::Remove(%d) checks, if there are any templates", aID);

		/////////////////////////////
		// check, if there are any templates created 
		if (PCCache::IsBusinessRuleEnabled( PCCONFIGLib::MTPC_BUSINESS_RULE_PIType_NoRemoveIfTemplate ))
		{
			MTPRODUCTCATALOGEXECLib::IMTCollectionPtr piTemplates;
			piTemplates = prcItemType->GetTemplates();
			
			int count = piTemplates->Count;
			if(count != 0)
			{
				PCCache::GetLogger().LogVarArgs(LOG_ERROR, "CMTPriceableItemTypeWriter::Remove(%d): Template has %d templates", aID, count);
				MT_THROW_COM_ERROR(IID_IMTPriceableItemTypeWriter, MTPCUSER_PRC_ITEM_TYPE_HAS_TEMPLATES, (const char*)prcItemType->Name, count);
			}
		}

		/////////////////////////////
		// remove the children 
		MTPRODUCTCATALOGEXECLib::IMTCollectionPtr childPITypes;
		childPITypes = prcItemType->GetChildren();
		
		int count = childPITypes->Count;
		PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTPriceableItemTypeWriter::Remove(%d) removes %d child items", aID, count);
		for( int i = 1; i <= count; i++ )
		{
			MTPRODUCTCATALOGEXECLib::IMTPriceableItemTypePtr childPIType = childPITypes->Item[i];
			
			// remove instance from DB (this also recursively removes childInstances for children of childPI)
			MTPRODUCTCATALOGEXECLib::IMTPriceableItemTypeWriterPtr writer = this;
			writer->Remove(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), childPIType->ID);
		}

		/////////////////////////////
		// delete parameter table definition maps
		MTPRODUCTCATALOGLib::IMTCollectionPtr paramTableDefs;
		paramTableDefs = prcItemType->GetParamTableDefinitions();

		// loop over all param table defs
		MTPRODUCTCATALOGLib::IMTParamTableDefinitionPtr paramTableDef;
		count = paramTableDefs->GetCount();

		PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTPriceableItemTypeWriter::Remove(%d) removes %d param table definitions", aID, count);

		for (i = 1; i <= count; ++i) // collection indexes are 1-based
		{
			paramTableDef = paramTableDefs->GetItem(i);
			RemoveParamTableDefinition(apCtxt, aID, paramTableDef->ID);
		}

		/////////////////////////////
		// delete counter property definitions
		MTPRODUCTCATALOGEXECLib::IMTCollectionPtr counterPropertyDefinitions = prcItemType->GetCounterPropertyDefinitions();

		int iCPDCount = counterPropertyDefinitions->Count;

		PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTPriceableItemTypeWriter::Remove(%d) removes %d CPDs", aID, iCPDCount);

		// now iterate through counters and save them.
		for(i = 1; i <= iCPDCount; ++i)
		{
			// get CPD
			MTPRODUCTCATALOGLib::IMTCounterPropertyDefinitionPtr cpd = counterPropertyDefinitions->GetItem(i);
			long lCPDID = cpd->ID;
			prcItemType->RemoveCounterPropertyDefinition(lCPDID);
		}

		/////////////////////////////
		// delete charges
		MTPRODUCTCATALOGEXECLib::IMTCollectionPtr charges = prcItemType->GetCharges();

		int iChargeCount = charges->Count;

		PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTPriceableItemTypeWriter::Remove(%d) removes %d Charges", aID, iChargeCount);

		// now iterate through charges and delete them.
		for(i = 1; i <= iChargeCount; ++i)
		{
			// get Charge
			MTPRODUCTCATALOGLib::IMTChargePtr charge = charges->GetItem(i);
			long lChargeID = charge->ID;
			prcItemType->RemoveCharge(lChargeID);
		}

    //same for adjustments
    GENERICCOLLECTIONLib::IMTCollectionPtr adjustments = prcItemType->AdjustmentTypes;
    MetraTech_Adjustments::IAdjustmentTypeWriterPtr writer(__uuidof(MetraTech_Adjustments::AdjustmentTypeWriter));
    int ajcount = adjustments->GetCount();
    for (int i = 1; i <= ajcount; i++)
    {
      MetraTech_Adjustments::IAdjustmentTypePtr ajt = adjustments->GetItem(i);
      writer->Remove(
        reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(prcItemType->GetSessionContext().GetInterfacePtr()),
        ajt);
    }

		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);

		PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTPriceableItemTypeWriter::Remove(%d) removes t_pi record", aID);

		//delete pi
		rowset->SetQueryTag("DELETE_PI");
		rowset->AddParam("%%ID_PI%%", aID);
		rowset->Execute();

		PCCache::GetLogger().LogVarArgs(LOG_DEBUG, "CMTPriceableItemTypeWriter::Remove(%d) removes t_base_props record", aID);

		//delete pi base prop
		MTPRODUCTCATALOGEXECLib::IMTBasePropsWriterPtr baseWriter(__uuidof(MTBasePropsWriter));
		baseWriter->Delete(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt),
											 aID);
	}
	catch (_com_error & err)
	{
		PCCache::GetLogger().LogVarArgs(LOG_ERROR, "CMTPriceableItemTypeWriter::Remove() caught error 0x%08h", err.Error());
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}

STDMETHODIMP CMTPriceableItemTypeWriter::AddParamTableDefinition(IMTSessionContext* apCtxt, long aPrcItemTypeID, long aParamTblDefID)
{
	MTAutoContext context(mpObjectContext);

	try
	{
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		//insert into base prop
		rowset->SetQueryTag("_ADD_PIMAP__");

		rowset->AddParam("%%ID_PI%%", aPrcItemTypeID);
		rowset->AddParam("%%ID_PT%%", aParamTblDefID);
		rowset->Execute();

    // Also set up any parameter table mappings for pi instance (with null pricelist).
    rowset->SetQueryTag("_ADD_PIMAP_FOR_INSTANCES__");
		rowset->AddParam("%%ID_PI%%", aPrcItemTypeID);
		rowset->AddParam("%%ID_PT%%", aParamTblDefID);
		rowset->Execute();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}

STDMETHODIMP CMTPriceableItemTypeWriter::RemoveParamTableDefinition(IMTSessionContext* apCtxt, long aPrcItemTypeID, long aParamTblDefID)
{
	MTAutoContext context(mpObjectContext);

	try
	{
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		//insert into base prop
		rowset->SetQueryTag("__DELETE_PIMAP__");

		rowset->AddParam("%%ID_PI%%", aPrcItemTypeID);
		rowset->AddParam("%%ID_PT%%", aParamTblDefID);
		rowset->Execute();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}

// check for existing name,
// throws _com_error if prc item type with that name already exists
void CMTPriceableItemTypeWriter::VerifyName(IMTSessionContext* apCtxt, IMTPriceableItemType* apType)
{
	if (PCCache::IsBusinessRuleEnabled( PCCONFIGLib::MTPC_BUSINESS_RULE_PIType_NoDuplicateName ))
	{
		MTPRODUCTCATALOGEXECLib::IMTPriceableItemTypePtr type = apType;

		MTPRODUCTCATALOGEXECLib::IMTPriceableItemTypeReaderPtr reader(__uuidof(MTPriceableItemTypeReader));
		MTPRODUCTCATALOGEXECLib::IMTPriceableItemTypePtr exisitingType;
		exisitingType = reader->FindByName((MTPRODUCTCATALOGEXECLib::IMTSessionContext *) apCtxt, type->Name);

		if (exisitingType != NULL && exisitingType->ID != type->ID)
			MT_THROW_COM_ERROR(IID_IMTPriceableItemTypeWriter, MTPCUSER_PRC_ITEM_TYPE_EXISTS, (const char*)type->Name);
	}
}

STDMETHODIMP CMTPriceableItemTypeWriter::AddCharge(IMTSessionContext *apCtxt, long aPrcItemTypeID, long aChargeID)
{
	// TODO: Add your implementation code here

	return S_OK;
}

STDMETHODIMP CMTPriceableItemTypeWriter::RemoveCharge(IMTSessionContext *apCtxt, long aPrcItemTypeID, long aChargeID)
{
	// TODO: Add your implementation code here

	return S_OK;
}
