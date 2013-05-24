	
// MTLog.h : Declaration of the CMTLog

#ifndef __MTLOG_H_
#define __MTLOG_H_

#include "resource.h"       // main symbols

#include <NTLogger.h>

#include "comsingleton.h"

/////////////////////////////////////////////////////////////////////////////
// CMTLog
class ATL_NO_VTABLE CMTLog : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTLog, &CLSID_MTLog>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTLog, &IID_IMTLog, &LIBID_SYSCONTEXTLib>
{
public:
	CMTLog()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTLOG)
DECLARE_GET_CONTROLLING_UNKNOWN()

// NOTE: don't use DECLARE_CLASSFACTORY_SINGLETON in DLLs!
//DECLARE_CLASSFACTORY_EX(CMTSingletonFactory<CMTLog>)

BEGIN_COM_MAP(CMTLog)
	COM_INTERFACE_ENTRY(IMTLog)
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

// IMTLog
public:
	STDMETHOD(LogString)(PlugInLogLevel aLevel, BSTR aString);

	STDMETHOD(OKToLog)(PlugInLogLevel aLevel, VARIANT_BOOL * apWouldLog);

	STDMETHOD(Init)(BSTR configPath, BSTR appTag);

	STDMETHOD(get_ApplicationTag)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_ApplicationTag)(/*[in]*/ BSTR newVal);

private:
	NTLogger mLogger;

	BOOL MTFromPlugInLogLevel(PlugInLogLevel aLevel, MTLogLevel & arMTLevel);
};

#endif //__MTLOG_H_
