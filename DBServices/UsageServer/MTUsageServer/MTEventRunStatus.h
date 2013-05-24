	
// MTEventRunStatus.h : Declaration of the CMTEventRunStatus

#ifndef __MTEVENTRUNSTATUS_H_
#define __MTEVENTRUNSTATUS_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CMTEventRunStatus
class ATL_NO_VTABLE CMTEventRunStatus : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTEventRunStatus, &CLSID_MTEventRunStatus>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTEventRunStatus, &IID_IMTEventRunStatus, &LIBID_MTUSAGESERVERLib>
{
public:
	CMTEventRunStatus()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTEVENTRUNSTATUS)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTEventRunStatus)
	COM_INTERFACE_ENTRY(IMTEventRunStatus)
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

	CComPtr<IUnknown> m_pUnkMarshaler;

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTEventRunStatus
public:
	STDMETHOD(End)(/*[in]*/ long aRunId, /*[in]*/ long aStatus, /*[in]*/ BSTR aStatusMessage);
	STDMETHOD(Start)(/*[in]*/ long aIntervalId, /*[in]*/ BSTR aName, /*[in]*/ BSTR aProgId, /*[in]*/ BSTR aConfigFile, /*[out, retval]*/ long * apRunId);
};

#endif //__MTEVENTRUNSTATUS_H_
