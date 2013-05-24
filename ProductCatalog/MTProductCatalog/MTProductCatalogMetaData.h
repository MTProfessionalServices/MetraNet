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
	
// MTProductCatalogMetaData.h : Declaration of the CMTProductCatalogMetaData

#ifndef __MTPRODUCTCATALOGMETADATA_H_
#define __MTPRODUCTCATALOGMETADATA_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CMTProductCatalogMetaData
class ATL_NO_VTABLE CMTProductCatalogMetaData : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTProductCatalogMetaData, &CLSID_MTProductCatalogMetaData>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTProductCatalogMetaData, &IID_IMTProductCatalogMetaData, &LIBID_MTPRODUCTCATALOGLib>
{
public:
	CMTProductCatalogMetaData();
	HRESULT FinalConstruct();
	void FinalRelease();

DECLARE_REGISTRY_RESOURCEID(IDR_MTPRODUCTCATALOGMETADATA)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTProductCatalogMetaData)
	COM_INTERFACE_ENTRY(IMTProductCatalogMetaData)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, mpUnkMarshaler.p)
END_COM_MAP()


// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTProductCatalogMetaData
public:
	STDMETHOD(Load)(/*[in]*/ VARIANT_BOOL aReturnErrors);
	STDMETHOD(SetAttributeValue)(/*[in]*/ MTPCEntityType aEntityType, /*[in]*/ BSTR aPropertyName, /*[in]*/ BSTR aAttributeName, /*[in]*/ BSTR aValue);
	STDMETHOD(GetAttributeMetaDataSet)(/*[out, retval]*/ IMTAttributeMetaDataSet** apMetaDataSet);
	STDMETHOD(GetPropertyMetaDataSet)(/*[in]*/ MTPCEntityType aEntityType, /*[out, retval]*/ IMTPropertyMetaDataSet** apMetaDataSet);

private:
	// enum for array index
	enum MetaDataSetIndexType
	{ METADATASET_PRICEABLE_ITEM_TYPE   = 0,
		METADATASET_USAGE,
		METADATASET_AGGREGATE_CHARGE,
		METADATASET_RECURRING,
		METADATASET_NON_RECURRING,
		METADATASET_DISCOUNT,
		METADATASET_PRODUCT_OFFERING,
		METADATASET_TIME_SPAN,
		METADATASET_PARAM_TABLE_DEF,
		METADATASET_CONDITION_META_DATA,
		METADATASET_ACTION_META_DATA,
		METADATASET_RATE_SCHEDULE,
		METADATASET_PRICE_LIST,
		METADATASET_CYCLE,
		METADATASET_PRICE_LIST_MAP,
		METADATASET_SUBSCRIPTION,
		METADATASET_COUNTER,
		METADATASET_COUNTER_META_DATA,
		METADATASET_COUNTER_PARAM,
		METADATASET_COUNTER_PROPERTY_DEF,
		METADATASET_CALENDAR,
		METADATASET_CALENDARPERIOD,
		METADATASET_CALENDARWEEKDAY,
		METADATASET_CALENDARHOLIDAY,
		METADATASET_GROUPSUBSCRIPTION,
		METADATASET_GSUBMEMBER,
		METADATASET_CHARGE,
		METADATASET_CHARGEPROPERTY,
    METADATASET_ADJUSTMENTTYPE,
    METADATASET_ADJUSTMENTTYPE_PROP,
    METADATASET_ADJUSTMENT,
    METADATASET_ADJUSTMENT_REASON_CODE,
    METADATASET_ADJUSTMENT_APPLIC_RULE,
    //METADATASET_SERVICE_ENDPOINT,
    METADATASET_SIZE                //this has to be the last entry!

	};

	MetaDataSetIndexType EntityTypeToIndex(MTPCEntityType aEntityType);

	enum PropertyFlags
		{	NONE          = 0,
		  REQUIRED      = 1
		};

	void AddPropMetaData (MetaDataSetIndexType aIdx,
												 char* aPropertyName,
												 char* aTableAndColumn, //format: "table.column" or "column"
												 MTPRODUCTCATALOGLib::PropValType aDataType,
												 int aFlags,            //bitfield of PropertyFlags
												 _variant_t aDefaultValue = _variant_t(),
                         int stringLength = 256);
	
	MTPRODUCTCATALOGLib::IMTAttributesPtr CreateDefaultAttributes();
	void SetAttributeValueByIdx(MetaDataSetIndexType aIdx, const _bstr_t& aPropertyName, const _bstr_t& aAttributeName, const _bstr_t& aValue);


	void LoadAttributeMetaData();
	void LoadPropertyMetaData(VARIANT_BOOL aReturnErrors);
	void LoadAttributeValues();
	void LoadExtendedPropertyTable(MetaDataSetIndexType aCacheType,
														MTPRODUCTCATALOGLib::MTPCEntityType aEntityType,
														VARIANT_BOOL aReturnErrors);

//data
	CComPtr<IUnknown> mpUnkMarshaler; 	// free threaded marshaller

	MTPRODUCTCATALOGLib::IMTAttributeMetaDataSetPtr mAttrMetaDataSet;
	MTPRODUCTCATALOGLib::IMTPropertyMetaDataSetPtr mPropMetaDataSet[METADATASET_SIZE];
};

#endif //__MTPRODUCTCATALOGMETADATA_H_
