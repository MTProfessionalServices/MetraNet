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
* $Header: MTPriceableItemTypeReader.cpp, 34, 11/20/2002 5:01:04 PM, Boris$
* 
***************************************************************************/

#include "StdAfx.h"

#include "MTProductCatalogExec.h"
#include "MTPriceableItemTypeReader.h"
#include <pcexecincludes.h>
#include <optionalvariant.h>
#import <MetraTech.Pipeline.tlb> inject_statement("using namespace mscorlib; using ROWSETLib::IMTSQLRowsetPtr; using ROWSETLib::IMTSQLRowset;") no_function_mapping
#import <MetraTech.Localization.tlb> inject_statement("using namespace mscorlib;") no_function_mapping
#import <MetraTech.Adjustments.tlb> inject_statement("using namespace mscorlib; using namespace MetraTech_Pipeline; using namespace MetraTech_Localization;")//rename ("EOF", "RowsetEOF") no_function_mapping


/////////////////////////////////////////////////////////////////////////////
// CMTPriceableItemTypeReader

/******************************************* error interface ***/
STDMETHODIMP CMTPriceableItemTypeReader::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTPriceableItemTypeReader
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (::InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

CMTPriceableItemTypeReader::CMTPriceableItemTypeReader()
{
	mpObjectContext = NULL;
}


HRESULT CMTPriceableItemTypeReader::Activate()
{
	HRESULT hr = GetObjectContext(&mpObjectContext);
	if (SUCCEEDED(hr))
		return S_OK;
	return hr;
} 

BOOL CMTPriceableItemTypeReader::CanBePooled()
{
	return FALSE;
} 

void CMTPriceableItemTypeReader::Deactivate()
{
	mpObjectContext.Release();
} 

void CMTPriceableItemTypeReader::PopulateByRowset(IMTSessionContext* apCtxt, 
																									ROWSETLib::IMTSQLRowsetPtr rowset,
																									IMTPriceableItemType** apType,
																									long aID)
{
	_variant_t val;
	MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr prcItemType(__uuidof(MTPriceableItemType));
  
	//set the session context
	prcItemType->SetSessionContext(reinterpret_cast<MTPRODUCTCATALOGLib::IMTSessionContext*>(apCtxt));

	if(aID != 0) {
		prcItemType->ID = aID;
	}
	else {
		prcItemType->ID = rowset->GetValue("id_pi");
	}

  val = rowset->GetValue("id_parent");
  if (val.vt != VT_NULL)
    prcItemType->ParentID = (long)val;

	val = rowset->GetValue("n_kind");
	prcItemType->Kind = static_cast<MTPRODUCTCATALOGLib::MTPCEntityType>((long)rowset->GetValue("n_kind"));

	//TODO!! use ID to string
	val = rowset->GetValue("nm_name");
	prcItemType->Name = MTMiscUtil::GetString(val);

	val = rowset->GetValue("nm_desc");
	prcItemType->Description = MTMiscUtil::GetString(val);

	val = rowset->GetValue("nm_servicedef");
	prcItemType->ServiceDefinition = MTMiscUtil::GetString(val);

	val = rowset->GetValue("nm_productview");
	prcItemType->ProductView = MTMiscUtil::GetString(val);

	_bstr_t strVal = rowset->GetValue("b_constrain_cycle");
	prcItemType->ConstrainSubscriberCycle = MTTypeConvert::StringToBool(strVal);
  
	*apType = reinterpret_cast<IMTPriceableItemType *>(prcItemType.Detach());
}


STDMETHODIMP CMTPriceableItemTypeReader::Find(IMTSessionContext* apCtxt, 
																							/*[in]*/ long aID,
																							/*[out, retval]*/ IMTPriceableItemType** apType)
{
	MTAutoContext context(mpObjectContext);

	if (!apType)
		return E_POINTER;

	//init out var
	*apType = NULL;

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
		
		rowset->SetQueryTag("__GET_PI__");
		rowset->AddParam("%%ID_PI%%", aID);
		rowset->AddParam("%%ID_LANG%%", languageID);
		rowset->Execute();

		if((bool) rowset->GetRowsetEOF())
		{
			//not found
		}
		else
		{
			// populate and set return object
			PopulateByRowset(apCtxt,rowset,apType,aID);
		}
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}

STDMETHODIMP CMTPriceableItemTypeReader::FindByName(IMTSessionContext* apCtxt, BSTR aName, IMTPriceableItemType **apType)
{
	MTAutoContext context(mpObjectContext);

	try {
		if (!apCtxt)
			return E_POINTER;

		long languageID;
		HRESULT hr = apCtxt->get_LanguageID(&languageID);
		if (FAILED(hr))
			return hr;

		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		rowset->SetQueryTag("__GET_PI_BY_NAME__");
		rowset->AddParam("%%NAME%%", aName);
		rowset->AddParam("%%ID_LANG%%", languageID);
		rowset->Execute();

		if((bool) rowset->GetRowsetEOF())
		{
			*apType = NULL;
		}
		else
		{
			// populate and set return object
			PopulateByRowset(apCtxt,rowset,apType);
		}
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	context.Complete();
	return S_OK;
}

STDMETHODIMP CMTPriceableItemTypeReader::FindByFilter(IMTSessionContext* apCtxt, VARIANT aFilter, IMTCollection **apColl)
{
	MTAutoContext context(mpObjectContext);

	if (!apColl)
		return E_POINTER;

	*apColl = NULL;

	try
	{
		if (!apCtxt)
			return E_POINTER;
    _bstr_t bstrFilterString = " ";
    _variant_t vFilter;
    MTPRODUCTCATALOGEXECLib::IMTDataFilterPtr filter = NULL;
    if(OptionalVariantConversion(aFilter,VT_DISPATCH,vFilter))
    {
      filter = vFilter;
      if(filter != NULL)
      {
        bstrFilterString = " AND ";
        bstrFilterString += filter->FilterString;
      }
    }
		long languageID;
		HRESULT hr = apCtxt->get_LanguageID(&languageID);
		if (FAILED(hr))
			return hr;

		MTObjectCollection<IMTPriceableItemType> coll;
		
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		rowset->SetQueryTag("__GET_FILTERED_PIS__");
		rowset->AddParam("%%FILTERS%%", bstrFilterString, VARIANT_TRUE); //TODO filter!!
		rowset->AddParam("%%COLUMNS%%", "");
		rowset->AddParam("%%JOINS%%", "");
		rowset->AddParam("%%ID_LANG%%", languageID);
		rowset->Execute();

		// call CMTPriceableItemTypeReader::Find() for each ID
		// If performance is critical, we can do one of these solutions:
		// (A) modify initial query to return all fields of a priceable item type and populate PI from one row
		// (B) only fill in ID of priceable item type and load other properties on demand

		MTPRODUCTCATALOGEXECLib::IMTPriceableItemTypeReaderPtr reader = this;
		
		while(rowset->GetRowsetEOF().boolVal == VARIANT_FALSE)
		{
			_variant_t val;
			val = rowset->GetValue("id_prop");
			long prcItemTypeID = val.lVal;

			MTPRODUCTCATALOGEXECLib::IMTPriceableItemTypePtr prcItemType;
			prcItemType = reader->Find(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), prcItemTypeID);

			coll.Add( reinterpret_cast<IMTPriceableItemType*>(prcItemType.GetInterfacePtr()) );
			rowset->MoveNext();
		}

		coll.CopyTo(apColl);
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}

STDMETHODIMP CMTPriceableItemTypeReader::FindParamTableDefinitions(IMTSessionContext* apCtxt, long aID, IMTCollection **apParamTblDefs)
{
	MTAutoContext context(mpObjectContext);

	if (!apParamTblDefs)
		return E_POINTER;
	else
		*apParamTblDefs = NULL; //init out var

	try
	{
		if (!apCtxt)
			return E_POINTER;

		long languageID;
		HRESULT hr = apCtxt->get_LanguageID(&languageID);
		if (FAILED(hr))
			return hr;

		MTObjectCollection<IMTParamTableDefinition> coll;
		
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		rowset->SetQueryTag("GET_PIPT_MAPPINGS");
		rowset->AddParam("%%ID_PI%%", aID);
		rowset->AddParam("%%ID_LANG%%", languageID);
		rowset->Execute();

		// the paramTblDef objects are loaded using existing ParamTablDefReader
		// not the most efficient but more maintanable
		// - this can be changed if it turns out to be performance critical
		
		MTPRODUCTCATALOGEXECLib::IMTParamTableDefinitionReaderPtr paramTblReader(__uuidof(MTParamTableDefinitionReader));
		MTPRODUCTCATALOGLib::IMTParamTableDefinitionPtr paramTblDef;

		while(rowset->GetRowsetEOF().boolVal == VARIANT_FALSE)
		{
			_variant_t val;
			val = rowset->GetValue("id_pt");
			long paramTblDefID = val.lVal;

			paramTblDef = paramTblReader->FindByID(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), paramTblDefID);

			coll.Add( reinterpret_cast<IMTParamTableDefinition*>( paramTblDef.GetInterfacePtr() ) );
			rowset->MoveNext();
		}

		coll.CopyTo(apParamTblDefs);
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}

STDMETHODIMP CMTPriceableItemTypeReader::FindParamTableDefinitionsAsRowset(IMTSessionContext* apCtxt, long aPrcItemTypeID, ::IMTSQLRowset **apRowset)
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
		
		rowset->SetQueryTag("GET_PIPT_MAPPINGS");
		rowset->AddParam("%%ID_PI%%", aPrcItemTypeID);
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


STDMETHODIMP CMTPriceableItemTypeReader::FindChildren(IMTSessionContext* apCtxt, long aPrcItemTypeID, IMTCollection **apChildTypes)
{
	MTAutoContext context(mpObjectContext);

	if (!apChildTypes)
		return E_POINTER;

	*apChildTypes = NULL; //init out var

	try
	{
		MTObjectCollection<IMTPriceableItemType> coll;
		
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		rowset->SetQueryTag("__GET_PI_CHILDREN__");
		rowset->AddParam("%%ID_PARENT%%", aPrcItemTypeID);
		rowset->Execute();

		// the type objects are loaded one by one
		// not the most efficient but more maintanable
		// - this can be changed if it turns out to be performance critical
		
		MTPRODUCTCATALOGLib::IMTPriceableItemTypePtr childType;
		MTPRODUCTCATALOGEXECLib::IMTPriceableItemTypeReaderPtr reader = this;

		while(rowset->GetRowsetEOF().boolVal == VARIANT_FALSE)
		{
			_variant_t val;
			val = rowset->GetValue("id_pi");
			long childID = val.lVal;

			childType = reader->Find(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), childID);

			coll.Add( reinterpret_cast<IMTPriceableItemType*>( childType.GetInterfacePtr() ) );
			rowset->MoveNext();
		}

		coll.CopyTo(apChildTypes);
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}


STDMETHODIMP CMTPriceableItemTypeReader::FindTemplates(IMTSessionContext* apCtxt, long aPITypeDBID, IMTCollection **apColl)
{
	HRESULT hr(S_OK);
	MTAutoContext context(mpObjectContext);

	if (!apColl)
		return E_POINTER;

	try
	{
		MTObjectCollection<IMTPriceableItem> coll;
		
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		rowset->SetQueryTag("__GET_PI_TEMPLATES_BY_TYPE__");
		rowset->AddParam("%%ID_PI%%", aPITypeDBID);
		rowset->Execute();

		MTPRODUCTCATALOGLib::IMTPriceableItemPtr PITemplate;
		MTPRODUCTCATALOGEXECLib::IMTPriceableItemReaderPtr 
			reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTPriceableItemReader));

		while(rowset->GetRowsetEOF().boolVal == VARIANT_FALSE)
		{
			_variant_t val;
			val = rowset->GetValue("id_template");
			long templateID = val.lVal;

			PITemplate = reader->Find(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), templateID);
			coll.Add( reinterpret_cast<IMTPriceableItem*>( PITemplate.GetInterfacePtr() ) );
			rowset->MoveNext();
		}

		coll.CopyTo(apColl);
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;

}

STDMETHODIMP CMTPriceableItemTypeReader::FindInstancesByKind(IMTSessionContext* apCtxt, MTPCEntityType aKind, IMTCollection **apInstances)
{
	HRESULT hr(S_OK);
	MTAutoContext context(mpObjectContext);

	if (!apInstances)
		return E_POINTER;

	try
	{
		MTObjectCollection<IMTPriceableItem> coll;
		
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		rowset->SetQueryTag("__GET_PI_INSTANCES_BY_KIND__");
		rowset->AddParam("%%KIND%%", (long)aKind);
		rowset->Execute();

		MTPRODUCTCATALOGLib::IMTPriceableItemPtr PIInstancePtr;
		MTPRODUCTCATALOGEXECLib::IMTPriceableItemReaderPtr 
			reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTPriceableItemReader));

		while(rowset->GetRowsetEOF().boolVal == VARIANT_FALSE)
		{
			_variant_t val;
			val = rowset->GetValue("id_instance");
			long lInstanceID = val.lVal;

			PIInstancePtr = reader->Find(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), lInstanceID);
			coll.Add( reinterpret_cast<IMTPriceableItem*>( PIInstancePtr.GetInterfacePtr() ) );
			rowset->MoveNext();
		}

		coll.CopyTo(apInstances);
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return hr;
}


STDMETHODIMP CMTPriceableItemTypeReader::FindTemplatesByKind(IMTSessionContext* apCtxt, MTPCEntityType aKind, IMTCollection **apTemplates)
{
	HRESULT hr(S_OK);
	MTAutoContext context(mpObjectContext);

	if (!apTemplates)
		return E_POINTER;

	try
	{
		MTObjectCollection<IMTPriceableItem> coll;
		
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		rowset->SetQueryTag("__GET_PI_TEMPLATES_BY_KIND__");
		rowset->AddParam("%%KIND%%", (long)aKind);
		rowset->Execute();

		MTPRODUCTCATALOGLib::IMTPriceableItemPtr PITemplatePtr;
		MTPRODUCTCATALOGEXECLib::IMTPriceableItemReaderPtr 
			reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTPriceableItemReader));

		while(rowset->GetRowsetEOF().boolVal == VARIANT_FALSE)
		{
			_variant_t val;
			val = rowset->GetValue("id_template");
			long lTemplateID = val.lVal;

			PITemplatePtr = reader->Find(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), lTemplateID);
			coll.Add( reinterpret_cast<IMTPriceableItem*>( PITemplatePtr.GetInterfacePtr() ) );
			rowset->MoveNext();
		}

		coll.CopyTo(apTemplates);
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return hr;
}

STDMETHODIMP CMTPriceableItemTypeReader::FindCharges(IMTSessionContext *apCtxt, long aPrcItemTypeID, IMTCollection **apColl)
{
	HRESULT hr(S_OK);
	MTAutoContext context(mpObjectContext);

	if (!apColl)
		return E_POINTER;

	try
	{
		MTObjectCollection<IMTCharge> coll;
		
		ROWSETLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
		rowset->Init(CONFIG_DIR);
		
		rowset->SetQueryTag("__GET_CHILD_CHARGES__");
		rowset->AddParam("%%ID_PI%%", aPrcItemTypeID);
		rowset->Execute();

		MTPRODUCTCATALOGEXECLib::IMTChargeReaderPtr 
			reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTChargeReader));

		while(rowset->GetRowsetEOF().boolVal == VARIANT_FALSE)
		{
			MTPRODUCTCATALOGEXECLib::IMTChargePtr Charge = 
				reader->Load(reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSessionContext*>(apCtxt), 
										 reinterpret_cast<MTPRODUCTCATALOGEXECLib::IMTSQLRowset*>(rowset.GetInterfacePtr()));
			coll.Add( reinterpret_cast<IMTCharge*>( Charge.GetInterfacePtr() ) );
			rowset->MoveNext();
		}

		coll.CopyTo(apColl);
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	context.Complete();
	return S_OK;
}
