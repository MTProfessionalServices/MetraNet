// MTGenericDBWriter.h : Declaration of the CMTGenericDBWriter

#ifndef __MTGENERICDBWRITER_H_
#define __MTGENERICDBWRITER_H_

#include "resource.h"       // main symbols
#include <mtx.h>

/////////////////////////////////////////////////////////////////////////////
// CMTGenericDBWriter
class ATL_NO_VTABLE CMTGenericDBWriter : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTGenericDBWriter, &CLSID_MTGenericDBWriter>,
	public ISupportErrorInfo,
	public IObjectControl,
	public IDispatchImpl<IMTGenericDBWriter, &IID_IMTGenericDBWriter, &LIBID_MTGENERICDBEXECLib>
{
public:
	CMTGenericDBWriter()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTGENERICDBWRITER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTGenericDBWriter)

BEGIN_COM_MAP(CMTGenericDBWriter)
	COM_INTERFACE_ENTRY(IMTGenericDBWriter)
	COM_INTERFACE_ENTRY(IObjectControl)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IObjectControl
public:
	STDMETHOD(Activate)();
	STDMETHOD_(BOOL, CanBePooled)();
	STDMETHOD_(void, Deactivate)();

	CComPtr<IObjectContext> m_spObjectContext;

// IMTGenericDBWriter
public:
	STDMETHOD(ExecuteStatement)(/*[in]*/ BSTR aQuery,/*[in,optional]*/ VARIANT aQueryDir);
};

#endif //__MTGENERICDBWRITER_H_
