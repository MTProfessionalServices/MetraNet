// MTAttributeMetaDataSetReader.h : Declaration of the CMTAttributeMetaDataSetReader

#ifndef __MTATTRIBUTEMETADATASETREADER_H_
#define __MTATTRIBUTEMETADATASETREADER_H_

#include "resource.h"       // main symbols
#include <comsvcs.h>

/////////////////////////////////////////////////////////////////////////////
// CMTAttributeMetaDataSetReader
class ATL_NO_VTABLE CMTAttributeMetaDataSetReader : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTAttributeMetaDataSetReader, &CLSID_MTAttributeMetaDataSetReader>,
	public ISupportErrorInfo,
	public IObjectControl,
	public IDispatchImpl<IMTAttributeMetaDataSetReader, &IID_IMTAttributeMetaDataSetReader, &LIBID_MTPRODUCTCATALOGEXECLib>
{
public:
	CMTAttributeMetaDataSetReader()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTATTRIBUTEMETADATASETREADER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTAttributeMetaDataSetReader)

BEGIN_COM_MAP(CMTAttributeMetaDataSetReader)
	COM_INTERFACE_ENTRY(IMTAttributeMetaDataSetReader)
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

// IMTAttributeMetaDataSetReader
public:
	STDMETHOD(Load)(/*[out, retval]*/ IMTAttributeMetaDataSet ** ppSet);
};

#endif //__MTATTRIBUTEMETADATASETREADER_H_
