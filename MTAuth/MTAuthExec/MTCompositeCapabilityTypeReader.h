// MTCompositeCapabilityTypeReader.h : Declaration of the CMTCompositeCapabilityTypeReader

#ifndef __MTCOMPOSITECAPABILITYTYPEREADER_H_
#define __MTCOMPOSITECAPABILITYTYPEREADER_H_

#include "resource.h"       // main symbols
/////////////////////////////////////////////////////////////////////////////
// CMTCompositeCapabilityTypeReader
class ATL_NO_VTABLE CMTCompositeCapabilityTypeReader : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTCompositeCapabilityTypeReader, &CLSID_MTCompositeCapabilityTypeReader>,
	public IObjectControl,
  public ISupportErrorInfo,
	public IDispatchImpl<IMTCompositeCapabilityTypeReader, &IID_IMTCompositeCapabilityTypeReader, &LIBID_MTAUTHEXECLib>
{
public:
	CMTCompositeCapabilityTypeReader()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTCOMPOSITECAPABILITYTYPEREADER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTCompositeCapabilityTypeReader)

BEGIN_COM_MAP(CMTCompositeCapabilityTypeReader)
	COM_INTERFACE_ENTRY(IMTCompositeCapabilityTypeReader)
	COM_INTERFACE_ENTRY(IObjectControl)
	COM_INTERFACE_ENTRY(IDispatch)
  COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);


// IObjectControl
public:
	STDMETHOD(Activate)();
	STDMETHOD_(BOOL, CanBePooled)();
	STDMETHOD_(void, Deactivate)();

	CComPtr<IObjectContext> m_spObjectContext;

// IMTCompositeCapabilityTypeReader
public:
	STDMETHOD(GetAllAsRowset)(/*[in]*/IMTSessionContext* aCtx, /*[out, retval]*/IMTSQLRowset** apRowset);
	STDMETHOD(FindInstancesByNameAsRowset)(/*[in]*/BSTR aName, /*[out, retval]*/IMTSQLRowset** apRowset);
	STDMETHOD(FindNameByProgIDAsRowset)(/*[in]*/BSTR aProgID, /*[out, retval]*/IMTSQLRowset** apRowset);
	STDMETHOD(GetByName)(/*[in]*/BSTR aTypeName, /*[out,retval]*/IMTCompositeCapabilityType** apType);
	STDMETHOD(GetTypeIDByInstanceID)(long aInstanceID, /*[out, retval]*/long* apTypeID);
	STDMETHOD(GetTypeIDByName)(/*[in]*/BSTR aTypeName, /*[out, retval]*/long* apTypeID);
	STDMETHOD(GetByInstanceIDAsRowset)(long aInstanceID, IMTSQLRowset **apRowset);
	STDMETHOD(GetAsRowset)(/*[in]*/long aTypeID, /*[out, retval]*/IMTSQLRowset** apRowset);
	STDMETHOD(GetByInstanceID)(/*[in]*/long aInstanceID, /*[out, retval]*/IMTCompositeCapabilityType** apNewType);
	STDMETHOD(Get)(long aTypeID, /*[out, retval]*/IMTCompositeCapabilityType** apNewType);
	STDMETHOD(FindRecordsByNameAsRowset)(/*[in]*/BSTR aTypeName, IMTSQLRowset** apRowset);
};

#endif //__MTCOMPOSITECAPABILITYTYPEREADER_H_
