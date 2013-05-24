// MTEnumTypeCapabilityWriter.h : Declaration of the CMTEnumTypeCapabilityWriter

#ifndef __MTENUMTYPECAPABILITYWRITER_H_
#define __MTENUMTYPECAPABILITYWRITER_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CMTEnumTypeCapabilityWriter
class ATL_NO_VTABLE CMTEnumTypeCapabilityWriter : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTEnumTypeCapabilityWriter, &CLSID_MTEnumTypeCapabilityWriter>,
	public IObjectControl,
  public ISupportErrorInfo,
	public IDispatchImpl<IMTEnumTypeCapabilityWriter, &IID_IMTEnumTypeCapabilityWriter, &LIBID_MTAUTHEXECLib>
{
public:
	CMTEnumTypeCapabilityWriter()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTENUMTYPECAPABILITYWRITER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTEnumTypeCapabilityWriter)

BEGIN_COM_MAP(CMTEnumTypeCapabilityWriter)
	COM_INTERFACE_ENTRY(IMTEnumTypeCapabilityWriter)
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

// IMTEnumTypeCapabilityWriter
public:
	STDMETHOD(Remove)(/*[in]*/long aInstanceID);
	STDMETHOD(CreateOrUpdate)(/*[in]*/long aInstanceID, /*[in]*/VARIANT aParam);
};

#endif //__MTENUMTYPECAPABILITYWRITER_H_
