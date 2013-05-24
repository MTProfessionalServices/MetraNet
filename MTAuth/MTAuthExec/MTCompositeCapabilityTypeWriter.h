// MTCompositeCapabilityTypeWriter.h : Declaration of the CMTCompositeCapabilityTypeWriter

#ifndef __MTCOMPOSITECAPABILITYTYPEWRITER_H_
#define __MTCOMPOSITECAPABILITYTYPEWRITER_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CMTCompositeCapabilityTypeWriter
class ATL_NO_VTABLE CMTCompositeCapabilityTypeWriter : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTCompositeCapabilityTypeWriter, &CLSID_MTCompositeCapabilityTypeWriter>,
	public IObjectControl,
  public ISupportErrorInfo,
	public IDispatchImpl<IMTCompositeCapabilityTypeWriter, &IID_IMTCompositeCapabilityTypeWriter, &LIBID_MTAUTHEXECLib>
{
public:
	CMTCompositeCapabilityTypeWriter()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTCOMPOSITECAPABILITYTYPEWRITER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTCompositeCapabilityTypeWriter)

BEGIN_COM_MAP(CMTCompositeCapabilityTypeWriter)
	COM_INTERFACE_ENTRY(IMTCompositeCapabilityTypeWriter)
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
	STDMETHOD(Create)(IMTCompositeCapabilityType* aType, long* apID);
	STDMETHOD(Update)(IMTCompositeCapabilityType* aType, long* apID);
	STDMETHOD(InsertCompositorMappings)(IMTCompositeCapabilityType* aType);

	CComPtr<IObjectContext> m_spObjectContext;

// IMTCompositeCapabilityTypeWriter
public:
};

#endif //__MTCOMPOSITECAPABILITYTYPEWRITER_H_
