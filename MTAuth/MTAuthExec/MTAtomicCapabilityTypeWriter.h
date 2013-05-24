// MTAtomicCapabilityTypeWriter.h : Declaration of the CMTAtomicCapabilityTypeWriter

#ifndef __MTATOMICCAPABILITYTYPEWRITER_H_
#define __MTATOMICCAPABILITYTYPEWRITER_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CMTAtomicCapabilityTypeWriter
class ATL_NO_VTABLE CMTAtomicCapabilityTypeWriter : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTAtomicCapabilityTypeWriter, &CLSID_MTAtomicCapabilityTypeWriter>,
	public IObjectControl,
  public ISupportErrorInfo,
	public IDispatchImpl<IMTAtomicCapabilityTypeWriter, &IID_IMTAtomicCapabilityTypeWriter, &LIBID_MTAUTHEXECLib>
{
public:
	CMTAtomicCapabilityTypeWriter()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTATOMICCAPABILITYTYPEWRITER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTAtomicCapabilityTypeWriter)

BEGIN_COM_MAP(CMTAtomicCapabilityTypeWriter)
	COM_INTERFACE_ENTRY(IMTAtomicCapabilityTypeWriter)
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
	STDMETHOD(Create)(IMTAtomicCapabilityType* aType, long* apID);
	STDMETHOD(Update)(IMTAtomicCapabilityType* aType, long* apID);
	

	CComPtr<IObjectContext> m_spObjectContext;

// IMTAtomicCapabilityTypeWriter
public:
};

#endif //__MTATOMICCAPABILITYTYPEWRITER_H_
