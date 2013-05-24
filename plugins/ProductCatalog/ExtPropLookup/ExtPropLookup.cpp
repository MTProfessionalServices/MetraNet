/**************************************************************************
 * @doc SIMPLE
 *
 * Copyright 1999 by MetraTech Corporation
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
 * Created by: Derek Young
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include <PlugInSkeleton.h>
//#include <MTDec.h>
#include <mtprogids.h>
#include <propids.h>
#include <RowsetDefs.h>

#include <DBMiscUtils.h>
#import <MTProductCatalog.tlb> rename("EOF", "EOFX")

using MTPRODUCTCATALOGLib::IMTProductCatalogPtr;
using MTPRODUCTCATALOGLib::IMTPropertyMetaDataSetPtr;
using MTPRODUCTCATALOGLib::IMTPropertyMetaDataPtr;
using MTPRODUCTCATALOGLib::MTPCEntityType;


using MTPipelineLib::IMTConfigPropSetPtr;
using MTPipelineLib::IMTConfigPropPtr;

#define CONFIG_DIR L"queries\\ProductCatalog"

// generate using uuidgen
CLSID CLSID_ExtPropLookup = { /* fd612fb8-4c6d-4dee-b773-a6b6176f69c4 */
    0xfd612fb8,
    0x4c6d,
    0x4dee,
    {0xb7, 0x73, 0xa6, 0xb6, 0x17, 0x6f, 0x69, 0xc4}
  };


class ATL_NO_VTABLE ExtPropLookupPlugIn
	: public MTPipelinePlugIn<ExtPropLookupPlugIn, &CLSID_ExtPropLookup>
{
protected:
	// Initialize the processor, looking up any necessary property IDs.
	// The processor can also use this time to do any other necessary initialization.
	// NOTE: This method can be called any number of times in order to
	//  refresh the initialization of the processor.
	virtual HRESULT PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																	MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																	MTPipelineLib::IMTNameIDPtr aNameID,
                                  MTPipelineLib::IMTSystemContextPtr aSysContext);

	// Shutdown the processor.  The processor can release any resources
	// it no longer needs.
	virtual HRESULT PlugInShutdown();

	virtual HRESULT PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession);

private:
	MTPipelineLib::IMTLogPtr mLogger;
	MTPipelineLib::IMTNameIDPtr mNameID;
	IMTProductCatalogPtr mCatalog;
	IMTPropertyMetaDataSetPtr mMetaData;
};


PLUGIN_INFO(CLSID_ExtPropLookup, ExtPropLookupPlugIn,
						"MetraPipeline.ExtPropLookup.1", "MetraPipeline.ExtPropLookup", "Free")

/////////////////////////////////////////////////////////////////////////////
//PlugInConfigure
/////////////////////////////////////////////////////////////////////////////

#ifdef PROCEDURE
#undef PROCEDURE
#endif
#define PROCEDURE "MTTotalConfCharge::PlugInConfigure"
HRESULT ExtPropLookupPlugIn::PlugInConfigure(MTPipelineLib::IMTLogPtr aLogger,
																				MTPipelineLib::IMTConfigPropSetPtr aPropSet,
																				MTPipelineLib::IMTNameIDPtr aNameID,
                                        MTPipelineLib::IMTSystemContextPtr aSysContext)
{
	mLogger = aLogger;
	mNameID = aNameID;

	// NOTE: this has to be done very early
	PipelinePropIDs::Init();

	long kind = aPropSet->NextLongWithName("kind");

	HRESULT hr = mCatalog.CreateInstance("MetraTech.MTProductCatalog");
	if (FAILED(hr))
		return Error(L"Unable to create product catalog object", IID_IMTPipelinePlugIn, hr);
		
	mMetaData = mCatalog->GetMetaData(static_cast<MTPCEntityType>(kind));

	return S_OK;
}


/////////////////////////////////////////////////////////////////////////////
//PlugInProcessSession
/////////////////////////////////////////////////////////////////////////////

HRESULT ExtPropLookupPlugIn::PlugInProcessSession(MTPipelineLib::IMTSessionPtr aSession)
{
	long idCode;

	if (aSession->PropertyExists(PipelinePropIDs::PriceableItemInstanceIDCode(), MTPipelineLib::SESS_PROP_TYPE_LONG))
		idCode = aSession->GetLongProperty(PipelinePropIDs::PriceableItemInstanceIDCode());
	
	else if (aSession->PropertyExists(PipelinePropIDs::PriceableItemTemplateIDCode(), MTPipelineLib::SESS_PROP_TYPE_LONG))
		idCode = aSession->GetLongProperty(PipelinePropIDs::PriceableItemTemplateIDCode());
	
	else if (aSession->PropertyExists(PipelinePropIDs::ProductOfferingIDCode(), MTPipelineLib::SESS_PROP_TYPE_LONG))
		idCode = aSession->GetLongProperty(PipelinePropIDs::ProductOfferingIDCode());
	
	else
	{
		mLogger->LogString(MTPipelineLib::PLUGIN_LOG_DEBUG, "Nothing to do: PI instance ID, PI template ID and PO ID not in the session");
		return S_OK;
	}

	BSTR pSelectList, pJoinList;

	mMetaData->GetPropertySQL(idCode, L"t_base_props", VARIANT_FALSE, &pSelectList, &pJoinList);
	
	_bstr_t bstrSelectList(pSelectList,false), bstrJoinList(pJoinList,false);
	
	// if there is nothing to select, do nothing
	if (bstrSelectList.length() == 0)
		return S_OK;

	MTPipelineLib::IMTSQLRowsetPtr rowset(MTPROGID_SQLROWSET);
	rowset->Init(CONFIG_DIR);

	rowset->SetQueryTag("__GET_EXTENDED_PROPERTIES__");
	rowset->AddParam("%%ID_PROP%%", idCode);
	rowset->AddParam("%%EXTENDED_SELECT%%", bstrSelectList);
	rowset->AddParam("%%EXTENDED_JOIN%%", bstrJoinList);
	rowset->Execute();
	
	if(rowset->GetRowsetEOF().boolVal == VARIANT_TRUE)
		return S_OK;

	long count = mMetaData->GetCount();
	
	for (long i = 1; i < count; i++) 
	{
		IMTPropertyMetaDataPtr propMeta = mMetaData->GetItem(i);
		
		if (propMeta->GetExtended() == VARIANT_TRUE) 
		{		
			_bstr_t name = propMeta->GetName();
			long propid = mNameID->GetNameID((const char *)name);
			
			_variant_t value = rowset->GetValue(propMeta->GetDBAliasName());
		    if(value.vt == VT_NULL)	
				continue;

			MTPRODUCTCATALOGLib::PropValType type;
			propMeta->get_DataType(&type);
			
			switch (type)
			{
			case PROP_TYPE_STRING:
				aSession->SetBSTRProperty(propid, (_bstr_t)value);
				break;
			case PROP_TYPE_INTEGER:
				aSession->SetLongProperty(propid, (long)value);
				break;
			case PROP_TYPE_BIGINTEGER:
				aSession->SetLongLongProperty(propid, (__int64) value);
				break;
			case PROP_TYPE_DOUBLE:
				aSession->SetDoubleProperty(propid, (double)value);
				break;
			case PROP_TYPE_TIME:
				aSession->SetTimeProperty(propid, (long)value);
				break;
			case PROP_TYPE_DATETIME:
				aSession->SetDateTimeProperty(propid, (long)value);
				break;
			case PROP_TYPE_BOOLEAN:
				aSession->SetBoolProperty(propid, ((bool) value) ? VARIANT_TRUE : VARIANT_FALSE);
				break;
			}
		}
	}

	return S_OK;
}


/////////////////////////////////////////////////////////////////////////////
//PlugInShutdown
/////////////////////////////////////////////////////////////////////////////

HRESULT ExtPropLookupPlugIn::PlugInShutdown()
{
	return S_OK;
}
