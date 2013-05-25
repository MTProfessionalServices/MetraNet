	
// MetraTimeControl.h : Declaration of the CMetraTimeControl

#ifndef __METRATIMECONTROL_H_
#define __METRATIMECONTROL_H_

#include "resource.h"       // main symbols

#include "metratimeipc.h"

/////////////////////////////////////////////////////////////////////////////
// CMetraTimeControl
class ATL_NO_VTABLE CMetraTimeControl : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMetraTimeControl, &CLSID_MetraTimeControl>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMetraTimeControl, &IID_IMetraTimeControl, &LIBID_METRATIMELib>
{
public:
	CMetraTimeControl()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_METRATIMECONTROL)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMetraTimeControl)
	COM_INTERFACE_ENTRY(IMetraTimeControl)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

	HRESULT FinalConstruct();

	void FinalRelease();

	CComPtr<IUnknown> m_pUnkMarshaler;

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMetraTimeControl
public:
	STDMETHOD(GetSimulatedTimeOffset)(/*[out, retval]*/ long * offset);
	STDMETHOD(SetSimulatedTimeOffset)(long offset);
	STDMETHOD(StartSimulatedTime)();
	STDMETHOD(StopSimulatedTime)();
	STDMETHOD(SetSimulatedOLETime)(VARIANT simTime);
	STDMETHOD(SetSimulatedTime)(long simTime);

private:
	MetraTimeIPC mIPC;
};

#endif //__METRATIMECONTROL_H_
