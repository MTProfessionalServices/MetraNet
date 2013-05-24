// MTCompositeCapabilityWriter.h : Declaration of the CMTCapabilityWriter

#ifndef __MTCAPABILITYWRITER_H_
#define __MTCAPABILITYWRITER_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CMTCapabilityWriter
class ATL_NO_VTABLE CMTCapabilityWriter : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTCapabilityWriter, &CLSID_MTCapabilityWriter>,
	public IObjectControl,
  public ISupportErrorInfo,
	public IDispatchImpl<IMTCapabilityWriter, &IID_IMTCapabilityWriter, &LIBID_MTAUTHEXECLib>
{
public:
	CMTCapabilityWriter()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTCOMPOSITECAPABILITYWRITER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTCapabilityWriter)

BEGIN_COM_MAP(CMTCapabilityWriter)
	COM_INTERFACE_ENTRY(IMTCapabilityWriter)
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

// IMTCompositeCapabilityWriter
public:
	STDMETHOD(RemoveAtomicInstance)(/*[in]*/IMTAtomicCapability* apCap, IMTPrincipalPolicy* aPolicy);
	STDMETHOD(RemoveCompositeInstance)(/*[in]*/IMTCompositeCapability* apCap, IMTPrincipalPolicy* aPolicy);
};

#endif //__MTCAPABILITYWRITER_H_
