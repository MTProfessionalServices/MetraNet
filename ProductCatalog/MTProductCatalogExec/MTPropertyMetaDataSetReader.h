// MTPropertyMetaDataSetReader.h : Declaration of the CMTPropertyMetaDataSetReader

#ifndef __MTPROPERTYMETADATASETREADER_H_
#define __MTPROPERTYMETADATASETREADER_H_

#include "resource.h"       // main symbols
#include <comsvcs.h>

/////////////////////////////////////////////////////////////////////////////
// CMTPropertyMetaDataSetReader
class ATL_NO_VTABLE CMTPropertyMetaDataSetReader : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTPropertyMetaDataSetReader, &CLSID_MTPropertyMetaDataSetReader>,
	public ISupportErrorInfo,
	public IObjectControl,
	public IDispatchImpl<IMTPropertyMetaDataSetReader, &IID_IMTPropertyMetaDataSetReader, &LIBID_MTPRODUCTCATALOGEXECLib>
{
public:
	CMTPropertyMetaDataSetReader()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTPROPERTYMETADATASETREADER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTPropertyMetaDataSetReader)

BEGIN_COM_MAP(CMTPropertyMetaDataSetReader)
	COM_INTERFACE_ENTRY(IMTPropertyMetaDataSetReader)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY(IObjectControl)
	COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IObjectControl
public:
	STDMETHOD(Activate)();
	STDMETHOD_(BOOL, CanBePooled)();
	STDMETHOD_(void, Deactivate)();

	CComPtr<IObjectContext> m_spObjectContext;

// IMTPropertyMetaDataSetReader
public:
	STDMETHOD(Find)(MTPCEntityType aType, /*[in]*/ IMTAttributeMetaDataSet* apSet, /*[in]*/ VARIANT_BOOL aReturnErrors, /*[out,retval]*/ IMTPropertyMetaDataSet ** pVal);
	STDMETHOD(GetAll)(/*[out,retval]*/ IMTPropertyMetaDataSet ** pVal);
	STDMETHOD(LoadAttributeValues)(/*[in]*/ IMTProductCatalogMetaData* apMetadata);
};

#endif //__MTPROPERTYMETADATASETREADER_H_
