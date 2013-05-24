// MTAccessTypeCapabilityWriter.h : Declaration of the CMTAccessTypeCapabilityWriter

#ifndef __MTACCESSTYPECAPABILITYWRITER_H_
#define __MTACCESSTYPECAPABILITYWRITER_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CMTAccessTypeCapabilityWriter
class ATL_NO_VTABLE CMTAccessTypeCapabilityWriter : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTAccessTypeCapabilityWriter, &CLSID_MTAccessTypeCapabilityWriter>,
	public IObjectControl,
  public ISupportErrorInfo,
	public IDispatchImpl<IMTAccessTypeCapabilityWriter, &IID_IMTAccessTypeCapabilityWriter, &LIBID_MTAUTHEXECLib>
{
public:
	CMTAccessTypeCapabilityWriter()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTACCESSTYPECAPABILITYWRITER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTAccessTypeCapabilityWriter)

BEGIN_COM_MAP(CMTAccessTypeCapabilityWriter)
	COM_INTERFACE_ENTRY(IMTAccessTypeCapabilityWriter)
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

// IMTAccessTypeCapabilityWriter
public:
	STDMETHOD(Remove)(/*[in]*/long aInstanceID);
	STDMETHOD(CreateOrUpdate)(/*[in]*/long aInstanceID, /*[in]*/BSTR aParam);
};

#endif //__MTACCESSTYPECAPABILITYWRITER_H_
