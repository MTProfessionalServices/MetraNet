	
// MetraTimeClient.h : Declaration of the CMetraTimeClient

#ifndef __METRATIMECLIENT_H_
#define __METRATIMECLIENT_H_

#include "resource.h"       // main symbols

#include "metratimeipc.h"

/////////////////////////////////////////////////////////////////////////////
// CMetraTimeClient
class ATL_NO_VTABLE CMetraTimeClient : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMetraTimeClient, &CLSID_MetraTimeClient>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMetraTimeClient, &IID_IMetraTimeClient, &LIBID_METRATIMELib>
{
public:
	CMetraTimeClient()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_METRATIMECLIENT)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMetraTimeClient)
	COM_INTERFACE_ENTRY(IMetraTimeClient)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

	HRESULT FinalConstruct();
	void FinalRelease();


	CComPtr<IUnknown> m_pUnkMarshaler;

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMetraTimeClient
public:
	STDMETHOD(get_MinMTOLETime)(/*[out, retval]*/ DATE *pVal);
	STDMETHOD(get_MinDate)(/*[out, retval]*/ long *pVal);
	STDMETHOD(get_MaxMTOLETime)(/*[out, retval]*/ DATE *pVal);
	STDMETHOD(get_MaxDate)(/*[out, retval]*/ long *pVal);
	STDMETHOD(get_IsTimeAdjusted)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(GetMTOLETime)(/*[out, retval]*/ VARIANT * currentTime);
	STDMETHOD(GetMTTime)(/*[out, retval]*/ long * currentTime);
  STDMETHOD (GetMTTimeWithMilliSecAsString)(/*[out, retval]*/ BSTR *pVal);

private:
	MetraTimeIPC mIPC;
};

#endif //__METRATIMECLIENT_H_
