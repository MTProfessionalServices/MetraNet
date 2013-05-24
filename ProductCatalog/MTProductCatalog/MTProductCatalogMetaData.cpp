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
* $Header: c:\mainline\development\ProductCatalog\MTProductCatalog\MTProductCatalogMetaData.cpp, 38, 11/13/2002 6:09:22 PM, Fabricio Pettena$
* 
***************************************************************************/

// MTProductCatalogMetaData.cpp : Implementation of CMTProductCatalogMetaData
#include "StdAfx.h"

#include <metra.h>
#include <mtprogids.h>
#include <comdef.h>
#include <mtcomerr.h>
#include <mtglobal_msg.h>
#include <PropertiesBase.h>

#include "MTProductCatalog.h"
#include "MTProductCatalogMetaData.h"


/////////////////////////////////////////////////////////////////////////////
// CMTProductCatalogMetaData

/******************************************* error interface ***/
STDMETHODIMP CMTProductCatalogMetaData::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IMTProductCatalogMetaData
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

/********************************** construction/destruction ***/
CMTProductCatalogMetaData::CMTProductCatalogMetaData()
{
	mpUnkMarshaler = NULL;

	mAttrMetaDataSet = NULL;

	for( int i = 0; i < METADATASET_SIZE; i++ )
	{	mPropMetaDataSet[i] = NULL;
	}
}

HRESULT CMTProductCatalogMetaData::FinalConstruct()
{
	try
	{
		HRESULT hr = CoCreateFreeThreadedMarshaler(GetControllingUnknown(), &mpUnkMarshaler.p);
		if (FAILED(hr))
			throw _com_error(hr);
	}	
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}

	return S_OK;
}

void CMTProductCatalogMetaData::FinalRelease()
{
	//release 
	for( int i = 0; i < METADATASET_SIZE; i++ )
	{	mPropMetaDataSet[i] = NULL;
	}

	mAttrMetaDataSet = NULL;
	
	mpUnkMarshaler.Release();
}

/********************************** IMTProductCatalogMetaData ***/

// if aReturnErrors is TRUE, any encountered error will stop processing, and the error will be returned
// if aReturnErrors is FALSE, encountered meta data errors will be logged only and processing continues
STDMETHODIMP CMTProductCatalogMetaData::Load(VARIANT_BOOL aReturnErrors)
{
	try
	{
		// eventually, all load functions should take an aReturnErrors arg and implement errorhandling accordingly.
		// currently only LoadPropertyMetaData implements it (for CR6360)
		LoadAttributeMetaData();
		LoadPropertyMetaData(aReturnErrors);
		LoadAttributeValues();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	return S_OK;
}

STDMETHODIMP CMTProductCatalogMetaData::GetPropertyMetaDataSet(MTPCEntityType aEntityType, IMTPropertyMetaDataSet **apMetaDataSet)
{
	if (!apMetaDataSet)
		return E_POINTER;

	*apMetaDataSet = NULL;

	try
	{
		int idx = EntityTypeToIndex(aEntityType);

		*apMetaDataSet = reinterpret_cast<IMTPropertyMetaDataSet*>(mPropMetaDataSet[idx].GetInterfacePtr());
		(*apMetaDataSet)->AddRef();
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	return S_OK;
}

STDMETHODIMP CMTProductCatalogMetaData::GetAttributeMetaDataSet(IMTAttributeMetaDataSet **apMetaDataSet)
{
	if (!apMetaDataSet)
		return E_POINTER;
		
	*apMetaDataSet = reinterpret_cast<IMTAttributeMetaDataSet*>(mAttrMetaDataSet.GetInterfacePtr());
	(*apMetaDataSet)->AddRef();

	return S_OK;
}

STDMETHODIMP CMTProductCatalogMetaData::SetAttributeValue(MTPCEntityType aEntityType, BSTR aPropertyName, BSTR aAttributeName, BSTR aValue)
{
	try
	{
		MetaDataSetIndexType idx = EntityTypeToIndex(aEntityType);
		SetAttributeValueByIdx (idx, aPropertyName, aAttributeName, aValue);
	}
	catch (_com_error & err)
	{
		return ReturnComError(err);
	}
	return S_OK;
}


//can throw _com_error
void CMTProductCatalogMetaData::SetAttributeValueByIdx(MetaDataSetIndexType aIdx, const _bstr_t& aPropertyName, const _bstr_t& aAttributeName, const _bstr_t& aValue)
{
	MTPRODUCTCATALOGLib::IMTPropertyMetaDataPtr propMeta;
	propMeta = mPropMetaDataSet[aIdx]->Item[aPropertyName];

	MTPRODUCTCATALOGLib::IMTAttributePtr attribute;
	attribute = propMeta->Attributes->Item[aAttributeName];

	attribute->Value = aValue;
}

//helper to add a PropertyMetaData object to mPropMetaDataSet
// can throw com error
void CMTProductCatalogMetaData::AddPropMetaData(
					MetaDataSetIndexType aIdx,
					char* aPropertyName,
					char* aTableAndColumn,       //format: "table.column" or "column"
					MTPRODUCTCATALOGLib::PropValType aDataType,
					int aFlags,                  //bitfield of PropertyFlags
					_variant_t aDefaultValue,
          int stringLength/*= _variant_t()*/)
{
	MTPRODUCTCATALOGLib::IMTPropertyMetaDataPtr	metaDataPtr;

	//construct metadata set when needed
	if (mPropMetaDataSet[aIdx] == NULL )
	{ mPropMetaDataSet[aIdx].CreateInstance(__uuidof(MTPropertyMetaDataSet));
	}

	metaDataPtr = mPropMetaDataSet[aIdx]->CreateMetaData(aPropertyName);

	//set datatype, DefaultValue, EnumType, EnumSpace
	metaDataPtr->InitDefault((MTPRODUCTCATALOGLib::PropValType)aDataType, aDefaultValue);

	//extract tableName and ColumnName from aColumnName
	string tableAndColumn = aTableAndColumn;
	unsigned long pos = tableAndColumn.find('.');
	if (pos == string::npos)
	{	metaDataPtr->DBTableName = "";
		metaDataPtr->DBColumnName = aTableAndColumn;
	}
	else
	{	metaDataPtr->DBTableName = tableAndColumn.substr(0, pos).c_str();
		metaDataPtr->DBColumnName = tableAndColumn.substr(pos+1, tableAndColumn.size() - pos -1).c_str();
	}

	metaDataPtr->DataType = static_cast<MTPRODUCTCATALOGLib::PropValType>(aDataType);
	
	if (aDataType == PROP_TYPE_STRING)
		metaDataPtr->Length = stringLength;
	else
		metaDataPtr->Length = 0; //do we need length for no string types?

	if(aFlags & REQUIRED )
		metaDataPtr->Required = VARIANT_TRUE;
	else
		metaDataPtr->Required = VARIANT_FALSE;

	metaDataPtr->Extended = VARIANT_FALSE;
	metaDataPtr->PropertyGroup = "";
	metaDataPtr->Attributes = CreateDefaultAttributes();

	/* OVERRIDEABLE now will be loaded from attribute_values.xml file
	if(aFlags & OVERRIDEABLE )
		SetAttributeValueByIdx(aIdx, aPropertyName, "overrideable", "true");
	else
		SetAttributeValueByIdx(aIdx, aPropertyName, "overrideable", "false");
	*/
}

//creates a new MTAttributes object with the default values and returns it
MTPRODUCTCATALOGLib::IMTAttributesPtr CMTProductCatalogMetaData::CreateDefaultAttributes()
{
	MTPRODUCTCATALOGLib::IMTAttributesPtr attributes(__uuidof(MTAttributes));
	MTPRODUCTCATALOGLib::IMTAttributeMetaDataPtr metaData;

	//add all AttrMetaData objects of the global AttributeMetaDataSet
	long lCount = mAttrMetaDataSet->Count;
	
	for (long i = 1; i <= lCount; ++i) 	// collection indexes are 1-based
	{
		metaData = mAttrMetaDataSet->Item[i];
		attributes->Add(metaData);
	}

	return attributes;
}

//loads the global set of AttributeMetaData
//can throw _com_error
void CMTProductCatalogMetaData::LoadAttributeMetaData()
{
	MTPRODUCTCATALOGEXECLib::IMTAttributeMetaDataSetReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTAttributeMetaDataSetReader));
	mAttrMetaDataSet = reader->Load();
}

//load attribute values for core properties from attribute_values.xml files
void CMTProductCatalogMetaData::LoadAttributeValues()
{
	MTPRODUCTCATALOGEXECLib::IMTProductCatalogMetaDataPtr thisPtr = this;

	MTPRODUCTCATALOGEXECLib::IMTPropertyMetaDataSetReaderPtr reader(__uuidof(MTPRODUCTCATALOGEXECLib::MTPropertyMetaDataSetReader));
	reader->LoadAttributeValues( thisPtr );
}

void CMTProductCatalogMetaData::LoadExtendedPropertyTable(MetaDataSetIndexType aCacheType,
																													MTPRODUCTCATALOGLib::MTPCEntityType aEntityType,
																													VARIANT_BOOL aReturnErrors)
{
	MTPRODUCTCATALOGEXECLib::IMTPropertyMetaDataSetReaderPtr aMetaReaderPtr(__uuidof(MTPRODUCTCATALOGEXECLib::MTPropertyMetaDataSetReader));
	MTPRODUCTCATALOGLib::IMTPropertyMetaDataSetPtr propMeta = aMetaReaderPtr->Find(
		(MTPRODUCTCATALOGEXECLib::MTPCEntityType)aEntityType,
		(MTPRODUCTCATALOGEXECLib::IMTAttributeMetaDataSet *)mAttrMetaDataSet.GetInterfacePtr(),
		aReturnErrors);

	if(propMeta != NULL) {
		mPropMetaDataSet[aCacheType] = propMeta;
	}
}


//translate MTPCEntityType to MetaDataSetIndexType
CMTProductCatalogMetaData::MetaDataSetIndexType CMTProductCatalogMetaData::EntityTypeToIndex(MTPCEntityType aEntityType)
{
	switch (aEntityType)
	{
		case PCENTITY_TYPE_PRICEABLE_ITEM_TYPE:		    return METADATASET_PRICEABLE_ITEM_TYPE;
		case PCENTITY_TYPE_USAGE:									    return METADATASET_USAGE;
		case PCENTITY_TYPE_AGGREGATE_CHARGE:			    return METADATASET_AGGREGATE_CHARGE;
		case PCENTITY_TYPE_RECURRING:							    return METADATASET_RECURRING;
		case PCENTITY_TYPE_RECURRING_UNIT_DEPENDENT:  return METADATASET_RECURRING;
		case PCENTITY_TYPE_NON_RECURRING:					    return METADATASET_NON_RECURRING;
		case PCENTITY_TYPE_DISCOUNT:							    return METADATASET_DISCOUNT;
		case PCENTITY_TYPE_PRODUCT_OFFERING:			    return METADATASET_PRODUCT_OFFERING;
		case PCENTITY_TYPE_TIME_SPAN:							    return METADATASET_TIME_SPAN;
		case PCENTITY_TYPE_PARAM_TABLE_DEF:				    return METADATASET_PARAM_TABLE_DEF;
		case PCENTITY_TYPE_CONDITION_META_DATA:		    return METADATASET_CONDITION_META_DATA;
		case PCENTITY_TYPE_ACTION_META_DATA:			    return METADATASET_ACTION_META_DATA;
		case PCENTITY_TYPE_RATE_SCHEDULE:					    return METADATASET_RATE_SCHEDULE;
		case PCENTITY_TYPE_PRICE_LIST:						    return METADATASET_PRICE_LIST;
		case PCENTITY_TYPE_CYCLE:									    return METADATASET_CYCLE;
		case PCENTITY_TYPE_PRICE_LIST_MAP:				    return METADATASET_PRICE_LIST_MAP;
		case PCENTITY_TYPE_SUBSCRIPTION:					    return METADATASET_SUBSCRIPTION;
		case PCENTITY_TYPE_COUNTER:								    return METADATASET_COUNTER;
		case PCENTITY_TYPE_COUNTER_META_DATA:			    return METADATASET_COUNTER_META_DATA;
		case PCENTITY_TYPE_COUNTER_PARAM:					    return METADATASET_COUNTER_PARAM;
		case PCENTITY_TYPE_COUNTER_PROPERTY_DEF:	    return METADATASET_COUNTER_PROPERTY_DEF;
		case PCENTITY_TYPE_CALENDAR:							    return METADATASET_CALENDAR;
		case PCENTITY_TYPE_CALENDARPERIOD:				    return METADATASET_CALENDARPERIOD;
		case PCENTITY_TYPE_CALENDARWEEKDAY:				    return METADATASET_CALENDARWEEKDAY;
		case PCENTITY_TYPE_CALENDARHOLIDAY:				    return METADATASET_CALENDARHOLIDAY;
		case PCENTITY_TYPE_GROUPSUBSCRIPTION:			    return METADATASET_GROUPSUBSCRIPTION;
		case PCENTITY_TYPE_GSUBMEMBER:						    return METADATASET_GSUBMEMBER;
	  case PCENTITY_TYPE_CHARGE:						        return METADATASET_CHARGE;
	  case PCENTITY_TYPE_CHARGEPROPERTY:				    return METADATASET_CHARGEPROPERTY;
    case PCENTITY_TYPE_ADJUSTMENTTYPE:				    return METADATASET_ADJUSTMENTTYPE;
    case PCENTITY_TYPE_ADJUSTMENTTYPE_PROP:	      return METADATASET_ADJUSTMENTTYPE_PROP;
    case PCENTITY_TYPE_ADJUSTMENT:	              return METADATASET_ADJUSTMENT;
    case PCENTITY_TYPE_ADJUSTMENT_REASON_CODE:    return METADATASET_ADJUSTMENT_REASON_CODE;
    case PCENTITY_TYPE_ADJUSTMENT_APPLIC_RULE:    return METADATASET_ADJUSTMENT_APPLIC_RULE;
    //case PCENTITY_TYPE_SERVICE_ENDPOINT:      return METADATASET_SERVICE_ENDPOINT;
		default:
			MT_THROW_COM_ERROR("Invalid EntityType: %d", aEntityType);
	}
}


// loads the PropertyMetaData for every kind of product catalog object 
// that supports the Properties interface
void CMTProductCatalogMetaData::LoadPropertyMetaData(VARIANT_BOOL aReturnErrors)
{
	// load extended properties
	// only load for the 6 types that are currently supported
	LoadExtendedPropertyTable(METADATASET_USAGE,MTPRODUCTCATALOGLib::PCENTITY_TYPE_USAGE,aReturnErrors);
	LoadExtendedPropertyTable(METADATASET_AGGREGATE_CHARGE,MTPRODUCTCATALOGLib::PCENTITY_TYPE_AGGREGATE_CHARGE,aReturnErrors);
	LoadExtendedPropertyTable(METADATASET_RECURRING,MTPRODUCTCATALOGLib::PCENTITY_TYPE_RECURRING,aReturnErrors);
	LoadExtendedPropertyTable(METADATASET_NON_RECURRING,MTPRODUCTCATALOGLib::PCENTITY_TYPE_NON_RECURRING,aReturnErrors);
	LoadExtendedPropertyTable(METADATASET_DISCOUNT,MTPRODUCTCATALOGLib::PCENTITY_TYPE_DISCOUNT,aReturnErrors);
	LoadExtendedPropertyTable(METADATASET_PRODUCT_OFFERING,MTPRODUCTCATALOGLib::PCENTITY_TYPE_PRODUCT_OFFERING,aReturnErrors);
  //LoadExtendedPropertyTable(METADATASET_SERVICE_ENDPOINT,MTPRODUCTCATALOGLib::PCENTITY_TYPE_SERVICE_ENDPOINT,aReturnErrors);

	//hard code core properties
	//Counter
	AddPropMetaData (METADATASET_COUNTER, "ID",          "id_prop", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
	AddPropMetaData (METADATASET_COUNTER, "TypeID",      "",        MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
	AddPropMetaData (METADATASET_COUNTER, "Name",        "nm_name", MTPRODUCTCATALOGLib::PROP_TYPE_STRING,  REQUIRED);
	AddPropMetaData (METADATASET_COUNTER, "Description", "nm_desc", MTPRODUCTCATALOGLib::PROP_TYPE_STRING,  NONE);
	AddPropMetaData (METADATASET_COUNTER, "Type",        "",        MTPRODUCTCATALOGLib::PROP_TYPE_SET,     REQUIRED);
	AddPropMetaData (METADATASET_COUNTER, "Alias",       "",        MTPRODUCTCATALOGLib::PROP_TYPE_STRING,  REQUIRED);
	AddPropMetaData (METADATASET_COUNTER, "Formula",     "FormulaTemplate", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	

	//Counter metadata
	AddPropMetaData (METADATASET_COUNTER_META_DATA, "ID", "id_prop", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
	AddPropMetaData (METADATASET_COUNTER_META_DATA, "Name", "nm_name", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData (METADATASET_COUNTER_META_DATA, "Description", "nm_desc", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, NONE);
	AddPropMetaData (METADATASET_COUNTER_META_DATA, "FormulaTemplate", "", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData (METADATASET_COUNTER_META_DATA, "ValidForDistribution", "", MTPRODUCTCATALOGLib::PROP_TYPE_BOOLEAN, REQUIRED);


	//Counter param
	AddPropMetaData (METADATASET_COUNTER_PARAM, "ID", "id_prop", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
	AddPropMetaData (METADATASET_COUNTER_PARAM, "Name", "nm_name", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData (METADATASET_COUNTER_PARAM, "Value", "Value", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData (METADATASET_COUNTER_PARAM, "Kind", "", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);/*enum*/
	AddPropMetaData (METADATASET_COUNTER_PARAM, "DBType", "", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);/*enum*/
	AddPropMetaData (METADATASET_COUNTER_PARAM, "FinalValue", "", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData (METADATASET_COUNTER_PARAM, "Alias", "", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData (METADATASET_COUNTER_PARAM, "ReadOnly",     "", MTPRODUCTCATALOGLib::PROP_TYPE_BOOLEAN, REQUIRED, VARIANT_FALSE);
	AddPropMetaData (METADATASET_COUNTER_PARAM, "ProductViewName",     "", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData (METADATASET_COUNTER_PARAM, "ProductViewPropertyName",     "", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData (METADATASET_COUNTER_PARAM, "ProductViewTableName",     "", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData (METADATASET_COUNTER_PARAM, "ProductViewColumnName",     "", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
  //AddPropMetaData (METADATASET_COUNTER_PARAM, "DisplayName",     "", PROP_TYPE_STRING, NONE);
	//AddPropMetaData (METADATASET_COUNTER_PARAM, "Description",     "", PROP_TYPE_STRING, NONE);
  AddPropMetaData (METADATASET_COUNTER_PARAM, "DisplayName",     "", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData (METADATASET_COUNTER_PARAM, "Description",     "", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);

	//Counter def
	AddPropMetaData (METADATASET_COUNTER_PROPERTY_DEF, "ID", "id_prop", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
	AddPropMetaData (METADATASET_COUNTER_PROPERTY_DEF, "Name", "nm_name", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData (METADATASET_COUNTER_PROPERTY_DEF, "DisplayName", "n_name", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData (METADATASET_COUNTER_PROPERTY_DEF, "PreferredCounterTypeName", "nm_preferredcountertype", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData (METADATASET_COUNTER_PROPERTY_DEF, "ServiceDefProperty", "nm_preferredcountertype", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData (METADATASET_COUNTER_PROPERTY_DEF, "PITypeID", "id_pi", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
	AddPropMetaData (METADATASET_COUNTER_PROPERTY_DEF, "Order", "n_order", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);

	

	// priceableitem type
	AddPropMetaData (METADATASET_PRICEABLE_ITEM_TYPE, "ID", "id_prop", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
	AddPropMetaData (METADATASET_PRICEABLE_ITEM_TYPE, "Kind", "n_kind", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED); //enum
	AddPropMetaData (METADATASET_PRICEABLE_ITEM_TYPE, "Name", "nm_name", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData (METADATASET_PRICEABLE_ITEM_TYPE, "Description", "nm_desc", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, NONE, _variant_t(), 4000);
	AddPropMetaData (METADATASET_PRICEABLE_ITEM_TYPE, "ServiceDefinition", "nm_service_def", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData (METADATASET_PRICEABLE_ITEM_TYPE, "ProductView", "nm_productview", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData (METADATASET_PRICEABLE_ITEM_TYPE, "ParentID", "id_parent", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, NONE, PROPERTIES_BASE_NO_ID);
	AddPropMetaData (METADATASET_PRICEABLE_ITEM_TYPE, "ConstrainSubscriberCycle", "b_constrain_cycle", MTPRODUCTCATALOGLib::PROP_TYPE_BOOLEAN, NONE);


	// usage
	AddPropMetaData (METADATASET_USAGE, "ID", "id_prop", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
	AddPropMetaData (METADATASET_USAGE, "Kind", "n_kind", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED); //enum
	AddPropMetaData (METADATASET_USAGE, "Name", "nm_name", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData (METADATASET_USAGE, "DisplayName", "nm_display_name", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
  AddPropMetaData (METADATASET_USAGE, "DisplayNames", "", MTPRODUCTCATALOGLib::PROP_TYPE_SET, NONE);
  AddPropMetaData (METADATASET_USAGE, "DisplayDescriptions", "", MTPRODUCTCATALOGLib::PROP_TYPE_SET, NONE);
	AddPropMetaData (METADATASET_USAGE, "Description", "nm_desc", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, NONE, _variant_t(), 4000);
	AddPropMetaData (METADATASET_USAGE, "PriceableItemType", "", MTPRODUCTCATALOGLib::PROP_TYPE_SET, REQUIRED);
	AddPropMetaData (METADATASET_USAGE, "ParentID", "id_parent", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, NONE, PROPERTIES_BASE_NO_ID);
	AddPropMetaData (METADATASET_USAGE, "TemplateID", "id_template", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, NONE, PROPERTIES_BASE_NO_ID);
	AddPropMetaData (METADATASET_USAGE, "ProductOfferingID", "id_po", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, NONE, PROPERTIES_BASE_NO_ID);


	// aggregate charge
	AddPropMetaData (METADATASET_AGGREGATE_CHARGE, "ID", "id_prop", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
	AddPropMetaData (METADATASET_AGGREGATE_CHARGE, "Kind", "n_kind", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED); //enum
	AddPropMetaData (METADATASET_AGGREGATE_CHARGE, "Name", "nm_name", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData (METADATASET_AGGREGATE_CHARGE, "DisplayName", "nm_display_name", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
  AddPropMetaData (METADATASET_AGGREGATE_CHARGE, "DisplayNames", "", MTPRODUCTCATALOGLib::PROP_TYPE_SET, NONE);
  AddPropMetaData (METADATASET_AGGREGATE_CHARGE, "DisplayDescriptions", "", MTPRODUCTCATALOGLib::PROP_TYPE_SET, NONE);
	AddPropMetaData (METADATASET_AGGREGATE_CHARGE, "Description", "nm_desc", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, NONE, _variant_t(), 4000);
	AddPropMetaData (METADATASET_AGGREGATE_CHARGE, "PriceableItemType", "", MTPRODUCTCATALOGLib::PROP_TYPE_SET, REQUIRED);
	AddPropMetaData (METADATASET_AGGREGATE_CHARGE, "ParentID", "id_parent", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, NONE, PROPERTIES_BASE_NO_ID);
	AddPropMetaData (METADATASET_AGGREGATE_CHARGE, "TemplateID", "id_template", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, NONE, PROPERTIES_BASE_NO_ID);
	AddPropMetaData (METADATASET_AGGREGATE_CHARGE, "ProductOfferingID", "id_po", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, NONE, PROPERTIES_BASE_NO_ID);
	// aggregate charge specific
	AddPropMetaData (METADATASET_AGGREGATE_CHARGE, "Cycle", "", MTPRODUCTCATALOGLib::PROP_TYPE_SET, REQUIRED);

	// recurring
	AddPropMetaData (METADATASET_RECURRING, "ID", "id_prop", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
	AddPropMetaData (METADATASET_RECURRING, "Kind", "n_kind", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED); //enum
	AddPropMetaData (METADATASET_RECURRING, "Name", "nm_name", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData (METADATASET_RECURRING, "DisplayName", "nm_display_name", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED, _variant_t(), 4000);
	AddPropMetaData (METADATASET_RECURRING, "DisplayNames", "", MTPRODUCTCATALOGLib::PROP_TYPE_SET, NONE);
  AddPropMetaData (METADATASET_RECURRING, "DisplayDescriptions", "", MTPRODUCTCATALOGLib::PROP_TYPE_SET, NONE);
	AddPropMetaData (METADATASET_RECURRING, "Description", "nm_desc", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, NONE, _variant_t(), 4000);
	AddPropMetaData (METADATASET_RECURRING, "PriceableItemType", "", MTPRODUCTCATALOGLib::PROP_TYPE_SET, REQUIRED);
	AddPropMetaData (METADATASET_RECURRING, "ParentID", "id_parent", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, NONE, PROPERTIES_BASE_NO_ID);
	AddPropMetaData (METADATASET_RECURRING, "TemplateID", "id_template", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, NONE, PROPERTIES_BASE_NO_ID);
	AddPropMetaData (METADATASET_RECURRING, "ProductOfferingID", "id_po", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, NONE, PROPERTIES_BASE_NO_ID);
	// recurring charge-specific
	AddPropMetaData (METADATASET_RECURRING, "ChargeInAdvance", "t_recur.b_advance", MTPRODUCTCATALOGLib::PROP_TYPE_BOOLEAN, REQUIRED);
	AddPropMetaData (METADATASET_RECURRING, "ProrateOnActivation", "t_recur.b_prorate_on_activate", MTPRODUCTCATALOGLib::PROP_TYPE_BOOLEAN, REQUIRED);
	AddPropMetaData (METADATASET_RECURRING, "ProrateInstantly", "t_recur.b_prorate_instantly", MTPRODUCTCATALOGLib::PROP_TYPE_BOOLEAN, REQUIRED);
	AddPropMetaData (METADATASET_RECURRING, "ProrateOnDeactivation", "t_recur.b_prorate_on_deactivate", MTPRODUCTCATALOGLib::PROP_TYPE_BOOLEAN, REQUIRED);
	AddPropMetaData (METADATASET_RECURRING, "ProrateOnRateChange", "t_recur.b_prorate_on_rate_change", MTPRODUCTCATALOGLib::PROP_TYPE_BOOLEAN, REQUIRED);
	AddPropMetaData (METADATASET_RECURRING, "FixedProrationLength", "t_recur.b_fixed_proration_length", MTPRODUCTCATALOGLib::PROP_TYPE_BOOLEAN, REQUIRED);
	AddPropMetaData (METADATASET_RECURRING, "ChargePerParticipant", "t_recur.b_charge_per_participant", MTPRODUCTCATALOGLib::PROP_TYPE_BOOLEAN, REQUIRED);
	AddPropMetaData (METADATASET_RECURRING, "UnitName", "t_recur.nm_unit_name", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData (METADATASET_RECURRING, "UnitDisplayName", "t_recur.nm_unit_display_name", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
  AddPropMetaData (METADATASET_RECURRING, "UnitDisplayNames", "", MTPRODUCTCATALOGLib::PROP_TYPE_SET, NONE);
  AddPropMetaData (METADATASET_RECURRING, "IntegerUnitValue", "t_recur.b_integral", MTPRODUCTCATALOGLib::PROP_TYPE_BOOLEAN, REQUIRED);
	AddPropMetaData (METADATASET_RECURRING, "MaxUnitValue", "t_recur.max_unit_value", MTPRODUCTCATALOGLib::PROP_TYPE_DECIMAL, REQUIRED);
	AddPropMetaData (METADATASET_RECURRING, "MinUnitValue", "t_recur.min_unit_value", MTPRODUCTCATALOGLib::PROP_TYPE_DECIMAL, REQUIRED);
	AddPropMetaData (METADATASET_RECURRING, "Cycle", "", MTPRODUCTCATALOGLib::PROP_TYPE_SET, REQUIRED);
	AddPropMetaData (METADATASET_RECURRING, "UnitValueEnumeration", "", MTPRODUCTCATALOGLib::PROP_TYPE_SET, NONE);
	AddPropMetaData (METADATASET_RECURRING, "RatingType", "t_recur.n_rating_type", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);

	// non recurring
	AddPropMetaData (METADATASET_NON_RECURRING, "ID", "id_prop", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
	AddPropMetaData (METADATASET_NON_RECURRING, "Kind", "n_kind", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED); //enum
	AddPropMetaData (METADATASET_NON_RECURRING, "Name", "nm_name", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData (METADATASET_NON_RECURRING, "DisplayName", "nm_display_name", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData (METADATASET_NON_RECURRING, "DisplayNames", "", MTPRODUCTCATALOGLib::PROP_TYPE_SET, NONE);
  AddPropMetaData (METADATASET_NON_RECURRING, "DisplayDescriptions", "", MTPRODUCTCATALOGLib::PROP_TYPE_SET, NONE);
	AddPropMetaData (METADATASET_NON_RECURRING, "Description", "nm_desc", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, NONE, _variant_t(), 4000);
	AddPropMetaData (METADATASET_NON_RECURRING, "PriceableItemType", "", MTPRODUCTCATALOGLib::PROP_TYPE_SET, REQUIRED);
	AddPropMetaData (METADATASET_NON_RECURRING, "ParentID", "id_parent", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, NONE, PROPERTIES_BASE_NO_ID);
	AddPropMetaData (METADATASET_NON_RECURRING, "TemplateID", "id_template", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, NONE, PROPERTIES_BASE_NO_ID);
	AddPropMetaData (METADATASET_NON_RECURRING, "ProductOfferingID", "id_po", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, NONE, PROPERTIES_BASE_NO_ID);
	// non-recurring charge-specific
	AddPropMetaData (METADATASET_NON_RECURRING, "NonRecurringChargeEvent", "t_nonrecur.n_event_type", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);

	// discount
	AddPropMetaData (METADATASET_DISCOUNT, "ID", "id_prop", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
	AddPropMetaData (METADATASET_DISCOUNT, "Kind", "n_kind", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED); //enum
	AddPropMetaData (METADATASET_DISCOUNT, "Name", "nm_name", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData (METADATASET_DISCOUNT, "DisplayName", "nm_display_name", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData (METADATASET_DISCOUNT, "DisplayNames", "", MTPRODUCTCATALOGLib::PROP_TYPE_SET, NONE);
  AddPropMetaData (METADATASET_DISCOUNT, "DisplayDescriptions", "", MTPRODUCTCATALOGLib::PROP_TYPE_SET, NONE);
	AddPropMetaData (METADATASET_DISCOUNT, "Description", "nm_desc", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, NONE, _variant_t(), 4000);
	AddPropMetaData (METADATASET_DISCOUNT, "PriceableItemType", "", MTPRODUCTCATALOGLib::PROP_TYPE_SET, REQUIRED);
	AddPropMetaData (METADATASET_DISCOUNT, "ParentID", "id_parent", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, NONE, PROPERTIES_BASE_NO_ID);
	AddPropMetaData (METADATASET_DISCOUNT, "TemplateID", "id_template", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, NONE, PROPERTIES_BASE_NO_ID);
	AddPropMetaData (METADATASET_DISCOUNT, "ProductOfferingID", "id_po", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, NONE, PROPERTIES_BASE_NO_ID);
	// discount-specific
	AddPropMetaData (METADATASET_DISCOUNT, "Cycle", "", MTPRODUCTCATALOGLib::PROP_TYPE_SET, REQUIRED);
	AddPropMetaData (METADATASET_DISCOUNT, "DistributionCPDID", "t_discount.id_distribution_cpd", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, NONE, PROPERTIES_BASE_NO_ID);


	// product offering
	AddPropMetaData (METADATASET_PRODUCT_OFFERING, "ID", "id_prop", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
	AddPropMetaData (METADATASET_PRODUCT_OFFERING, "Name", "nm_name", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData (METADATASET_PRODUCT_OFFERING, "DisplayName", "nm_display_name", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData (METADATASET_PRODUCT_OFFERING, "DisplayNames", "", MTPRODUCTCATALOGLib::PROP_TYPE_SET, NONE);
  AddPropMetaData (METADATASET_PRODUCT_OFFERING, "DisplayDescriptions", "", MTPRODUCTCATALOGLib::PROP_TYPE_SET, NONE);
	AddPropMetaData (METADATASET_PRODUCT_OFFERING, "Description", "nm_desc", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, NONE, _variant_t(), 4000);
	AddPropMetaData (METADATASET_PRODUCT_OFFERING, "SelfSubscribable", "b_user_subscribe", MTPRODUCTCATALOGLib::PROP_TYPE_BOOLEAN, REQUIRED);
	AddPropMetaData (METADATASET_PRODUCT_OFFERING, "SelfUnsubscribable", "b_user_unsubscribe", MTPRODUCTCATALOGLib::PROP_TYPE_BOOLEAN, REQUIRED);
	AddPropMetaData (METADATASET_PRODUCT_OFFERING, "EffectiveDate", "", MTPRODUCTCATALOGLib::PROP_TYPE_SET, REQUIRED);
	AddPropMetaData (METADATASET_PRODUCT_OFFERING, "AvailabilityDate", "", MTPRODUCTCATALOGLib::PROP_TYPE_SET, REQUIRED);
	AddPropMetaData (METADATASET_PRODUCT_OFFERING, "NonSharedPriceListID", "id_nonshared_pl", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
	AddPropMetaData (METADATASET_PRODUCT_OFFERING, "Hidden", "b_hidden", MTPRODUCTCATALOGLib::PROP_TYPE_BOOLEAN, REQUIRED);
  AddPropMetaData (METADATASET_PRODUCT_OFFERING, "SubscribableAccountTypes", "", MTPRODUCTCATALOGLib::PROP_TYPE_SET, NONE);

	// time span
	AddPropMetaData (METADATASET_TIME_SPAN, "ID", "id_prop", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
	AddPropMetaData (METADATASET_TIME_SPAN, "StartDateType", "n_begintype", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED, (long)PCDATE_TYPE_NULL);
	AddPropMetaData (METADATASET_TIME_SPAN, "StartDate", "dt_start", MTPRODUCTCATALOGLib::PROP_TYPE_DATETIME, NONE);
	AddPropMetaData (METADATASET_TIME_SPAN, "StartOffset", "n_beginoffset", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, NONE);
	AddPropMetaData (METADATASET_TIME_SPAN, "EndDateType", "n_endtype", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED, (long)PCDATE_TYPE_NULL);
	AddPropMetaData (METADATASET_TIME_SPAN, "EndDate", "dt_end", MTPRODUCTCATALOGLib::PROP_TYPE_DATETIME, NONE);
	AddPropMetaData (METADATASET_TIME_SPAN, "EndOffset", "n_endoffset", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, NONE);

	// paramtable definition
	AddPropMetaData (METADATASET_PARAM_TABLE_DEF, "ID", "id_prop", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
	AddPropMetaData (METADATASET_PARAM_TABLE_DEF, "DBTableName", "nm_instance_tablename", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData (METADATASET_PARAM_TABLE_DEF, "HelpURL", "", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData (METADATASET_PARAM_TABLE_DEF, "ActionHeader", "", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData (METADATASET_PARAM_TABLE_DEF, "ConditionHeader", "", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData (METADATASET_PARAM_TABLE_DEF, "Name", "n_name", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData (METADATASET_PARAM_TABLE_DEF, "DisplayName", "", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData (METADATASET_PARAM_TABLE_DEF, "IndexedProperty", "", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);

	// condition meta data
	AddPropMetaData (METADATASET_CONDITION_META_DATA, "PropertyName", "", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData (METADATASET_CONDITION_META_DATA, "ColumnName", "", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData (METADATASET_CONDITION_META_DATA, "DataType", "", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED); // enum?
	AddPropMetaData (METADATASET_CONDITION_META_DATA, "DefaultValue", "", MTPRODUCTCATALOGLib::PROP_TYPE_OPAQUE, REQUIRED);
	AddPropMetaData (METADATASET_CONDITION_META_DATA, "Operator", "", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED); // enum?
	AddPropMetaData (METADATASET_CONDITION_META_DATA, "OperatorPerRule", "", MTPRODUCTCATALOGLib::PROP_TYPE_BOOLEAN, REQUIRED);
	AddPropMetaData (METADATASET_CONDITION_META_DATA, "DisplayOperator", "", MTPRODUCTCATALOGLib::PROP_TYPE_BOOLEAN, REQUIRED);
	AddPropMetaData (METADATASET_CONDITION_META_DATA, "EnumSpace", "", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData (METADATASET_CONDITION_META_DATA, "EnumType", "", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData (METADATASET_CONDITION_META_DATA, "Filterable", "", MTPRODUCTCATALOGLib::PROP_TYPE_BOOLEAN, REQUIRED);
	AddPropMetaData (METADATASET_CONDITION_META_DATA, "Required", "", MTPRODUCTCATALOGLib::PROP_TYPE_BOOLEAN, REQUIRED);
	AddPropMetaData (METADATASET_CONDITION_META_DATA, "DisplayName", "", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData (METADATASET_CONDITION_META_DATA, "Length", "", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);

	// action meta data
	AddPropMetaData (METADATASET_ACTION_META_DATA, "PropertyName", "", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData (METADATASET_ACTION_META_DATA, "ColumnName", "", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData (METADATASET_ACTION_META_DATA, "Kind", "", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
	AddPropMetaData (METADATASET_ACTION_META_DATA, "DataType", "", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED); // enum?
	AddPropMetaData (METADATASET_ACTION_META_DATA, "DefaultValue", "", MTPRODUCTCATALOGLib::PROP_TYPE_OPAQUE, REQUIRED);
	AddPropMetaData (METADATASET_ACTION_META_DATA, "EnumSpace", "", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData (METADATASET_ACTION_META_DATA, "EnumType", "", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData (METADATASET_ACTION_META_DATA, "DisplayName", "", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData (METADATASET_ACTION_META_DATA, "Required", "", MTPRODUCTCATALOGLib::PROP_TYPE_BOOLEAN, REQUIRED);
	AddPropMetaData (METADATASET_ACTION_META_DATA, "Editable", "", MTPRODUCTCATALOGLib::PROP_TYPE_BOOLEAN, REQUIRED);
	AddPropMetaData (METADATASET_ACTION_META_DATA, "Length", "", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);

	// rate schedule
	AddPropMetaData (METADATASET_RATE_SCHEDULE, "Description", "n_desc", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, NONE);
	AddPropMetaData (METADATASET_RATE_SCHEDULE, "ID", "id_prop", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
	AddPropMetaData (METADATASET_RATE_SCHEDULE, "PriceListID", "id_pricelist", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
	AddPropMetaData (METADATASET_RATE_SCHEDULE, "ParameterTableID", "id_pt", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
	AddPropMetaData (METADATASET_RATE_SCHEDULE, "TemplateID", "id_pi_template", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
	AddPropMetaData (METADATASET_RATE_SCHEDULE, "EffectiveDate", "", MTPRODUCTCATALOGLib::PROP_TYPE_SET, REQUIRED);
  AddPropMetaData (METADATASET_RATE_SCHEDULE, "MappingType", "mappingtype", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, NONE);


	// pricelist
	AddPropMetaData (METADATASET_PRICE_LIST, "ID", "id_prop", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
	AddPropMetaData (METADATASET_PRICE_LIST, "Name", "nm_name", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData (METADATASET_PRICE_LIST, "Description", "nm_desc", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, NONE);
	AddPropMetaData (METADATASET_PRICE_LIST, "CurrencyCode", "nm_currency_code", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData (METADATASET_PRICE_LIST, "Type", "n_type", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED); // enum MTPriceListType

	// cycle
	AddPropMetaData (METADATASET_CYCLE, "CycleID", "", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
	AddPropMetaData (METADATASET_CYCLE, "CycleTypeID", "", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
	AddPropMetaData (METADATASET_CYCLE, "Relative", "", MTPRODUCTCATALOGLib::PROP_TYPE_BOOLEAN, NONE);
	AddPropMetaData (METADATASET_CYCLE, "EndDayOfWeek", "", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, NONE);
	AddPropMetaData (METADATASET_CYCLE, "EndDayOfMonth", "", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, NONE);
	AddPropMetaData (METADATASET_CYCLE, "EndDayOfMonth2", "", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, NONE);
	AddPropMetaData (METADATASET_CYCLE, "StartDay", "", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, NONE);
	AddPropMetaData (METADATASET_CYCLE, "StartMonth", "", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, NONE);
	AddPropMetaData (METADATASET_CYCLE, "StartYear", "", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, NONE);
	AddPropMetaData (METADATASET_CYCLE, "AdapterProgID", "", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, NONE);
	AddPropMetaData (METADATASET_CYCLE, "CycleTypeDescription", "", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, NONE);
        AddPropMetaData (METADATASET_CYCLE, "Mode", "", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, NONE);	

	// pricelist map
	AddPropMetaData (METADATASET_PRICE_LIST_MAP, "PriceableItemID", "id_pi_instance", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
	AddPropMetaData (METADATASET_PRICE_LIST_MAP, "ParamTableDefinitionID", "id_paramtable", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
	AddPropMetaData (METADATASET_PRICE_LIST_MAP, "PriceListID", "id_pricelist", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
	AddPropMetaData (METADATASET_PRICE_LIST_MAP, "CanICB", "b_canICB", MTPRODUCTCATALOGLib::PROP_TYPE_BOOLEAN, REQUIRED);
	AddPropMetaData (METADATASET_PRICE_LIST_MAP, "MappingType", "mappingtype", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, NONE);

	// calendar
	AddPropMetaData(METADATASET_CALENDAR,"ID","",MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
	AddPropMetaData(METADATASET_CALENDAR,"Name","",MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData(METADATASET_CALENDAR,"Description","",MTPRODUCTCATALOGLib::PROP_TYPE_STRING, NONE);
	AddPropMetaData(METADATASET_CALENDAR,"TimezoneOffset","",MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
	AddPropMetaData(METADATASET_CALENDAR,"CombinedWeekend","",MTPRODUCTCATALOGLib::PROP_TYPE_BOOLEAN, REQUIRED);
	// calendarperiod
	AddPropMetaData(METADATASET_CALENDARPERIOD,"ID","",MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
	AddPropMetaData(METADATASET_CALENDARPERIOD,"Code","",MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
	AddPropMetaData(METADATASET_CALENDARPERIOD,"StartTime","",MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, NONE);
	AddPropMetaData(METADATASET_CALENDARPERIOD,"EndTime","",MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, NONE);

	// calendarweekday
	AddPropMetaData(METADATASET_CALENDARWEEKDAY,"ID","",MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
	AddPropMetaData(METADATASET_CALENDARWEEKDAY,"DayofWeek","",MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
	AddPropMetaData(METADATASET_CALENDARWEEKDAY,"Code","",MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, NONE);

	// calendarholiday
	AddPropMetaData(METADATASET_CALENDARHOLIDAY,"ID","",MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
	AddPropMetaData(METADATASET_CALENDARHOLIDAY,"Name","",MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData(METADATASET_CALENDARHOLIDAY,"Day","",MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
	AddPropMetaData(METADATASET_CALENDARHOLIDAY,"WeekofMonth","",MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
	AddPropMetaData(METADATASET_CALENDARHOLIDAY,"Month","",MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
	AddPropMetaData(METADATASET_CALENDARHOLIDAY,"Year","",MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
	AddPropMetaData(METADATASET_CALENDARHOLIDAY,"Code","",MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);

		// subscription
	AddPropMetaData(METADATASET_SUBSCRIPTION,"id_sub","id_sub",MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
	AddPropMetaData(METADATASET_SUBSCRIPTION,"po","id_po",MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
	AddPropMetaData(METADATASET_SUBSCRIPTION,"EffectiveDate","",MTPRODUCTCATALOGLib::PROP_TYPE_SET, REQUIRED);
	AddPropMetaData(METADATASET_SUBSCRIPTION,"Cycle","",MTPRODUCTCATALOGLib::PROP_TYPE_SET, NONE);
	AddPropMetaData(METADATASET_SUBSCRIPTION,"ExternalIdentifier","id_sub_ext",MTPRODUCTCATALOGLib::PROP_TYPE_STRING, NONE);
	// special just for individual subscriptions
	AddPropMetaData(METADATASET_SUBSCRIPTION,"accountID","id_acc",MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);


	// group subscription
	AddPropMetaData(METADATASET_GROUPSUBSCRIPTION,"id_sub","id_sub",MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
	AddPropMetaData(METADATASET_GROUPSUBSCRIPTION,"id_group","id_group",MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
	AddPropMetaData(METADATASET_GROUPSUBSCRIPTION,"po","id_po",MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
	AddPropMetaData(METADATASET_GROUPSUBSCRIPTION,"EffectiveDate","",MTPRODUCTCATALOGLib::PROP_TYPE_SET, REQUIRED);
	AddPropMetaData(METADATASET_GROUPSUBSCRIPTION,"Cycle","",MTPRODUCTCATALOGLib::PROP_TYPE_SET, REQUIRED);
	AddPropMetaData(METADATASET_GROUPSUBSCRIPTION,"ExternalIdentifier","id_sub_ext",MTPRODUCTCATALOGLib::PROP_TYPE_STRING, NONE);
	// properties just for group subscription
	AddPropMetaData(METADATASET_GROUPSUBSCRIPTION,"Name","tx_name",MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData(METADATASET_GROUPSUBSCRIPTION,"Description","",MTPRODUCTCATALOGLib::PROP_TYPE_STRING, NONE);
	AddPropMetaData(METADATASET_GROUPSUBSCRIPTION,"CorporateAccount","",MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
	AddPropMetaData(METADATASET_GROUPSUBSCRIPTION,"ProportionalDistribution","",MTPRODUCTCATALOGLib::PROP_TYPE_BOOLEAN, REQUIRED);
	AddPropMetaData(METADATASET_GROUPSUBSCRIPTION,"DistributionAccount","",MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, NONE);
	AddPropMetaData(METADATASET_GROUPSUBSCRIPTION,"supportgroupops","",MTPRODUCTCATALOGLib::PROP_TYPE_BOOLEAN, REQUIRED);
  AddPropMetaData(METADATASET_GROUPSUBSCRIPTION,"hasrecurringcharges","",MTPRODUCTCATALOGLib::PROP_TYPE_BOOLEAN, NONE);
  AddPropMetaData(METADATASET_GROUPSUBSCRIPTION,"hasdiscounts","",MTPRODUCTCATALOGLib::PROP_TYPE_BOOLEAN, NONE);
  AddPropMetaData(METADATASET_GROUPSUBSCRIPTION,"haspersonalrates","",MTPRODUCTCATALOGLib::PROP_TYPE_BOOLEAN, NONE);


	// group subscription members
	AddPropMetaData(METADATASET_GSUBMEMBER,"Account ID","",MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
	AddPropMetaData(METADATASET_GSUBMEMBER,"StartDate","",MTPRODUCTCATALOGLib::PROP_TYPE_DATETIME, REQUIRED);
	AddPropMetaData(METADATASET_GSUBMEMBER,"EndDate","",MTPRODUCTCATALOGLib::PROP_TYPE_DATETIME, NONE);
	AddPropMetaData(METADATASET_GSUBMEMBER,"OldStartDate","",MTPRODUCTCATALOGLib::PROP_TYPE_DATETIME, NONE);
	AddPropMetaData(METADATASET_GSUBMEMBER,"OldEndDate","",MTPRODUCTCATALOGLib::PROP_TYPE_DATETIME, NONE);
	AddPropMetaData(METADATASET_GSUBMEMBER,"AccountName","",MTPRODUCTCATALOGLib::PROP_TYPE_STRING, NONE);

	// charge members
	AddPropMetaData(METADATASET_CHARGE,"ID", "id_charge", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
	AddPropMetaData(METADATASET_CHARGE,"PITypeID", "id_pi", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
	AddPropMetaData(METADATASET_CHARGE,"Name", "nm_name", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData(METADATASET_CHARGE,"DisplayName", "nm_display_name", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData(METADATASET_CHARGE,"AmountPropertyID", "id_amt_prop", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);

	// charge property members
	AddPropMetaData(METADATASET_CHARGEPROPERTY,"ID", "id_charge_prop", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
	AddPropMetaData(METADATASET_CHARGEPROPERTY,"ProductViewPropertyID", "id_prod_view_prop", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
	AddPropMetaData(METADATASET_CHARGEPROPERTY,"ChargeID", "id_charge", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);

  //Adjustment Type
  AddPropMetaData(METADATASET_ADJUSTMENTTYPE,"ID", "id_prop", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
  AddPropMetaData(METADATASET_ADJUSTMENTTYPE,"GUID", "tx_guid", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
  AddPropMetaData(METADATASET_ADJUSTMENTTYPE,"Name", "nm_name", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
  AddPropMetaData(METADATASET_ADJUSTMENTTYPE,"DisplayName", "nm_display_name", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData(METADATASET_ADJUSTMENTTYPE,"Description", "nm_desc", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
  AddPropMetaData(METADATASET_ADJUSTMENTTYPE,"SupportsBulk", "b_SupportsBulk", MTPRODUCTCATALOGLib::PROP_TYPE_BOOLEAN, REQUIRED);
  AddPropMetaData(METADATASET_ADJUSTMENTTYPE,"AdjustmentFormula", "", MTPRODUCTCATALOGLib::PROP_TYPE_SET, REQUIRED);
  AddPropMetaData(METADATASET_ADJUSTMENTTYPE,"Kind", "n_AdjustmentType", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
	// add more....
  AddPropMetaData(METADATASET_ADJUSTMENTTYPE_PROP,"ID", "id_prop", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
  AddPropMetaData(METADATASET_ADJUSTMENTTYPE_PROP,"Name", "nm_name", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
  AddPropMetaData(METADATASET_ADJUSTMENTTYPE_PROP,"DisplayName", "nm_display_name", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData(METADATASET_ADJUSTMENTTYPE_PROP,"Description", "nm_desc", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);

  AddPropMetaData(METADATASET_ADJUSTMENT,  "ID", "id_prop", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
  AddPropMetaData(METADATASET_ADJUSTMENT,  "GUID", "tx_guid", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
  AddPropMetaData(METADATASET_ADJUSTMENT,"Name", "nm_name", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
  AddPropMetaData(METADATASET_ADJUSTMENT,"DisplayName", "nm_display_name", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
  AddPropMetaData(METADATASET_ADJUSTMENT,"DisplayNames", "", MTPRODUCTCATALOGLib::PROP_TYPE_SET, NONE);
	AddPropMetaData(METADATASET_ADJUSTMENT,"Description", "nm_desc", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
  AddPropMetaData(METADATASET_ADJUSTMENT,"PriceableItem", "", MTPRODUCTCATALOGLib::PROP_TYPE_SET, REQUIRED);
  AddPropMetaData(METADATASET_ADJUSTMENT,"AdjustmentType", "", MTPRODUCTCATALOGLib::PROP_TYPE_SET, REQUIRED);

  AddPropMetaData(METADATASET_ADJUSTMENT_REASON_CODE,  "ID", "id_prop", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
  AddPropMetaData(METADATASET_ADJUSTMENT_REASON_CODE,  "GUID", "tx_guid", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
  AddPropMetaData(METADATASET_ADJUSTMENT_REASON_CODE,"Name", "nm_name", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
  AddPropMetaData(METADATASET_ADJUSTMENT_REASON_CODE,"DisplayName", "nm_display_name", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
  AddPropMetaData(METADATASET_ADJUSTMENT_REASON_CODE,"DisplayNames", "", MTPRODUCTCATALOGLib::PROP_TYPE_SET, NONE);
	AddPropMetaData(METADATASET_ADJUSTMENT_REASON_CODE,"Description", "nm_desc", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);

   AddPropMetaData(METADATASET_ADJUSTMENT_APPLIC_RULE,  "ID", "id_prop", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);
  AddPropMetaData(METADATASET_ADJUSTMENT_APPLIC_RULE,  "GUID", "tx_guid", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
  AddPropMetaData(METADATASET_ADJUSTMENT_APPLIC_RULE,"Name", "nm_name", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
  AddPropMetaData(METADATASET_ADJUSTMENT_APPLIC_RULE,"DisplayName", "nm_display_name", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
	AddPropMetaData(METADATASET_ADJUSTMENT_APPLIC_RULE,"Description", "nm_desc", MTPRODUCTCATALOGLib::PROP_TYPE_STRING, REQUIRED);
  AddPropMetaData(METADATASET_ADJUSTMENT_APPLIC_RULE, "Formula", "", MTPRODUCTCATALOGLib::PROP_TYPE_SET, REQUIRED);
 
  //AddPropMetaData(METADATASET_SERVICE_ENDPOINT,"ID", "id_prop", MTPRODUCTCATALOGLib::PROP_TYPE_INTEGER, REQUIRED);


  
}

