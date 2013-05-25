// AuditDBWriter.h : Declaration of the CAuditDBWriter

#ifndef __AUDITDBWRITER_H_
#define __AUDITDBWRITER_H_

#include "resource.h"       // main symbols
#include <mtx.h>

/////////////////////////////////////////////////////////////////////////////
// CAuditDBWriter
class ATL_NO_VTABLE CAuditDBWriter : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CAuditDBWriter, &CLSID_AuditDBWriter>,
	public ISupportErrorInfo,
	public IObjectControl,
	public IDispatchImpl<IAuditDBWriter, &IID_IAuditDBWriter, &LIBID_MTAUDITDBWRITERLib>
{
public:
	CAuditDBWriter();

DECLARE_REGISTRY_RESOURCEID(IDR_AUDITDBWRITER)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CAuditDBWriter)

BEGIN_COM_MAP(CAuditDBWriter)
	COM_INTERFACE_ENTRY(IAuditDBWriter)
	COM_INTERFACE_ENTRY(IObjectControl)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

	HRESULT FinalConstruct()
	{
		return CoCreateFreeThreadedMarshaler(
			GetControllingUnknown(), &m_pUnkMarshaler.p);
	}

	void FinalRelease()
	{
		m_pUnkMarshaler.Release();
	}

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IObjectControl
public:
	STDMETHOD(Activate)();
	STDMETHOD_(BOOL, CanBePooled)();
	STDMETHOD_(void, Deactivate)();

	CComPtr<IObjectContext> mpObjectContext;

	CComPtr<IUnknown> m_pUnkMarshaler;

// IAuditDBWriter
public:
	STDMETHOD(Init)();
	STDMETHOD(Write)(/*[in]*/ IAuditEvent* apAuditEvent);
};

#endif //__AUDITDBWRITER_H_
