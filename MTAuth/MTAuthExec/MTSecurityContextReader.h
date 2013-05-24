	
// MTSecurityContextReader.h : Declaration of the CMTSecurityContextReader

#ifndef __MTSECURITYCONTEXTREADER_H_
#define __MTSECURITYCONTEXTREADER_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CMTSecurityContextReader
class ATL_NO_VTABLE CMTSecurityContextReader : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTSecurityContextReader, &CLSID_MTSecurityContextReader>,
	public ISupportErrorInfo,
  public IDispatchImpl<IMTSecurityContextReader, &IID_IMTSecurityContextReader, &LIBID_MTAUTHEXECLib>
{
public:
	CMTSecurityContextReader()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTSECURITYCONTEXTREADER)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTSecurityContextReader)
	COM_INTERFACE_ENTRY(IMTSecurityContextReader)
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

// IMTSecurityContextReader
public:
};

#endif //__MTSECURITYCONTEXTREADER_H_
