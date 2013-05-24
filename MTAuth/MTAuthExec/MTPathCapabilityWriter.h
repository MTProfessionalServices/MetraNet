// MTPathCapabilityWriter.h : Declaration of the CMTPathCapabilityWriter

#ifndef __MTPATHCAPABILITYWRITER_H_
#define __MTPATHCAPABILITYWRITER_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CMTPathCapabilityWriter
class ATL_NO_VTABLE CMTPathCapabilityWriter : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTPathCapabilityWriter, &CLSID_MTPathCapabilityWriter>,
	public IObjectControl,
  public ISupportErrorInfo,
	public IDispatchImpl<IMTPathCapabilityWriter, &IID_IMTPathCapabilityWriter, &LIBID_MTAUTHEXECLib>
{
public:
	CMTPathCapabilityWriter()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTPATHCAPABILITYWRITER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTPathCapabilityWriter)

BEGIN_COM_MAP(CMTPathCapabilityWriter)
	COM_INTERFACE_ENTRY(IMTPathCapabilityWriter)
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

// IMTPathCapabilityWriter
public:
	STDMETHOD(Remove)(/*[in]*/long aInstanceID);
	STDMETHOD(CreateOrUpdate)(/*[in]*/long aInstanceID, /*[in]*/BSTR aParam);
};

#endif //__MTPATHCAPABILITYWRITER_H_
