	
// AuditEventHandler.h : Declaration of the CAuditEventHandler

#ifndef __AUDITEVENTHANDLER_H_
#define __AUDITEVENTHANDLER_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CAuditEventHandler
class ATL_NO_VTABLE CAuditEventHandler : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CAuditEventHandler, &CLSID_AuditEventHandler>,
	public IDispatchImpl<IAuditEventHandler, &IID_IAuditEventHandler, &LIBID_MTAUDITEVENTSLib>
{
public:
	CAuditEventHandler()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_AUDITEVENTHANDLER)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CAuditEventHandler)
	COM_INTERFACE_ENTRY(IAuditEventHandler)
	COM_INTERFACE_ENTRY(IDispatch)
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

	CComPtr<IUnknown> m_pUnkMarshaler;

// IAuditEventHandler
public:
	STDMETHOD(HandleEvent)(/*[in]*/ IAuditEvent* apAuditEvent);
};

#endif //__AUDITEVENTHANDLER_H_
