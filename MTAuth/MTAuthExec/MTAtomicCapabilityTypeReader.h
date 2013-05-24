// MTAtomicCapabilityTypeReader.h : Declaration of the CMTAtomicCapabilityTypeReader

#ifndef __MTATOMICCAPABILITYTYPEREADER_H_
#define __MTATOMICCAPABILITYTYPEREADER_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CMTAtomicCapabilityTypeReader
class ATL_NO_VTABLE CMTAtomicCapabilityTypeReader : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTAtomicCapabilityTypeReader, &CLSID_MTAtomicCapabilityTypeReader>,
	public IObjectControl,
  public ISupportErrorInfo,
	public IDispatchImpl<IMTAtomicCapabilityTypeReader, &IID_IMTAtomicCapabilityTypeReader, &LIBID_MTAUTHEXECLib>
{
public:
	CMTAtomicCapabilityTypeReader()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTATOMICCAPABILITYTYPEREADER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTAtomicCapabilityTypeReader)

BEGIN_COM_MAP(CMTAtomicCapabilityTypeReader)
	COM_INTERFACE_ENTRY(IMTAtomicCapabilityTypeReader)
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

// IMTAtomicCapabilityTypeReader
public:
	STDMETHOD(FindInstancesByNameAsRowset)(/*[in]*/BSTR aName, /*[out, retval]*/IMTSQLRowset** apRowset);
	STDMETHOD(FindNameByProgIDAsRowset)(/*[in]*/BSTR aProgID, /*[out, retval]*/IMTSQLRowset** apRowset);
	STDMETHOD(GetByName)(/*[in]*/BSTR aTypeName, /*[out,retval]*/IMTAtomicCapabilityType** apType);
	STDMETHOD(GetTypeIDByInstanceID)(long aInstanceID, /*[out, retval]*/long* apTypeID);
	STDMETHOD(GetTypeIDByName)(/*[in]*/BSTR aTypeName, /*[out, retval]*/long* apTypeID);
	STDMETHOD(GetByInstanceID)(/*[in]*/long aInstanceID, /*[out, retval]*/IMTAtomicCapabilityType** apNewType);
	STDMETHOD(Get)(long aTypeID, /*[out, retval]*/IMTAtomicCapabilityType** apNewType);
	STDMETHOD(FindRecordsByNameAsRowset)(/*[in]*/BSTR aTypeName, IMTSQLRowset** apRowset);
	STDMETHOD(GetByInstanceIDAsRowset)(long aInstanceID, IMTSQLRowset **apRowset);
	STDMETHOD(GetAsRowset)(/*[in]*/long aTypeID, /*[out, retval]*/IMTSQLRowset** apRowset);
};

#endif //__MTATOMICCAPABILITYTYPEREADER_H_
