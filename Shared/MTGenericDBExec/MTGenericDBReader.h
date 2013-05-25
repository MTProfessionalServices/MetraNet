// MTGenericDBReader.h : Declaration of the CMTGenericDBReader

#ifndef __MTGENERICDBREADER_H_
#define __MTGENERICDBREADER_H_

#include "resource.h"       // main symbols
#include <mtx.h>

/////////////////////////////////////////////////////////////////////////////
// CMTGenericDBReader
class ATL_NO_VTABLE CMTGenericDBReader : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTGenericDBReader, &CLSID_MTGenericDBReader>,
	public ISupportErrorInfo,
	public IObjectControl,
	public IDispatchImpl<IMTGenericDBReader, &IID_IMTGenericDBReader, &LIBID_MTGENERICDBEXECLib>
{
public:
	CMTGenericDBReader()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTGENERICDBREADER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTGenericDBReader)

BEGIN_COM_MAP(CMTGenericDBReader)
	COM_INTERFACE_ENTRY(IMTGenericDBReader)
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

// IMTGenericDBReader
public:
	STDMETHOD(ExecuteStatement)(/*[in]*/ BSTR aQuery,/*[in, optional]*/ VARIANT aQueryDir,/*[out, retval]*/ IMTSQLRowset** ppRowset);
};

#endif //__MTGENERICDBREADER_H_
