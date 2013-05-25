// FailureAuditDBWriter.h : Declaration of the CFailureAuditDBWriter

#ifndef __FAILUREAUDITDBWRITER_H_
#define __FAILUREAUDITDBWRITER_H_

#include "resource.h"       // main symbols
#include <mtx.h>

/////////////////////////////////////////////////////////////////////////////
// CFailureAuditDBWriter
class ATL_NO_VTABLE CFailureAuditDBWriter : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CFailureAuditDBWriter, &CLSID_FailureAuditDBWriter>,
	public ISupportErrorInfo,
	public IObjectControl,
	public IDispatchImpl<IFailureAuditDBWriter, &IID_IFailureAuditDBWriter, &LIBID_MTAUDITDBWRITERLib>
{
public:
	CFailureAuditDBWriter();

DECLARE_REGISTRY_RESOURCEID(IDR_FAILUREAUDITDBWRITER)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CFailureAuditDBWriter)

BEGIN_COM_MAP(CFailureAuditDBWriter)
	COM_INTERFACE_ENTRY(IFailureAuditDBWriter)
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

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IObjectControl
public:
	STDMETHOD(Activate)();
	STDMETHOD_(BOOL, CanBePooled)();
	STDMETHOD_(void, Deactivate)();

	CComPtr<IObjectContext> mpObjectContext;

	CComPtr<IUnknown> m_pUnkMarshaler;

// IFailureAuditDBWriter
public:
	STDMETHOD(Write)(IAuditEvent * apAuditEvent);
};

#endif //__FAILUREAUDITDBWRITER_H_
