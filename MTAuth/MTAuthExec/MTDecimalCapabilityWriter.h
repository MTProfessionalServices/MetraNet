// MTDecimalCapabilityWriter.h : Declaration of the CMTDecimalCapabilityWriter

#ifndef __MTDECIMALCAPABILITYWRITER_H_
#define __MTDECIMALCAPABILITYWRITER_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CMTDecimalCapabilityWriter
class ATL_NO_VTABLE CMTDecimalCapabilityWriter : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTDecimalCapabilityWriter, &CLSID_MTDecimalCapabilityWriter>,
	public IObjectControl,
  public ISupportErrorInfo,
	public IDispatchImpl<IMTDecimalCapabilityWriter, &IID_IMTDecimalCapabilityWriter, &LIBID_MTAUTHEXECLib>
{
public:
	CMTDecimalCapabilityWriter()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTDECIMALCAPABILITYWRITER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTDecimalCapabilityWriter)

BEGIN_COM_MAP(CMTDecimalCapabilityWriter)
	COM_INTERFACE_ENTRY(IMTDecimalCapabilityWriter)
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

// IMTDecimalCapabilityWriter
public:
	STDMETHOD(Remove)(/*[in]*/long aInstanceID);
	STDMETHOD(CreateOrUpdate)(/*[in]*/long aInstanceID, /*[in]*/IMTSimpleCondition* aParam);
};

#endif //__MTDECIMALCAPABILITYWRITER_H_
