// MTGenDbWriter.h : Declaration of the CMTGenDbWriter

#ifndef __MTGENDBWRITER_H_
#define __MTGENDBWRITER_H_

#include <StdAfx.h>
#include "resource.h"       // main symbols
#include <mtx.h>

/////////////////////////////////////////////////////////////////////////////
// CMTGenDbWriter
class ATL_NO_VTABLE CMTGenDbWriter : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTGenDbWriter, &CLSID_MTGenDbWriter>,
	public ISupportErrorInfo,
	public IObjectControl,
	public IDispatchImpl<IMTGenDbWriter, &IID_IMTGenDbWriter, &LIBID_MTYAACEXECLib>
{
public:
	CMTGenDbWriter()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTGENDBWRITER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTGenDbWriter)

BEGIN_COM_MAP(CMTGenDbWriter)
	COM_INTERFACE_ENTRY(IMTGenDbWriter)
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

// IMTGenDbWriter
public:
		STDMETHOD(ExecuteStatement)(BSTR aQuery,VARIANT aQueryDir);
};

#endif //__MTGENDBWRITER_H_
