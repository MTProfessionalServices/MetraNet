// MTPredicateWriter.h : Declaration of the CMTPredicateWriter

#ifndef __MTPREDICATEWRITER_H_
#define __MTPREDICATEWRITER_H_

#include "resource.h"       // main symbols
#include <mtx.h>

/////////////////////////////////////////////////////////////////////////////
// CMTPredicateWriter
class ATL_NO_VTABLE CMTPredicateWriter : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTPredicateWriter, &CLSID_MTPredicateWriter>,
	public IObjectControl,
  public ISupportErrorInfo,
	public IDispatchImpl<IMTPredicateWriter, &IID_IMTPredicateWriter, &LIBID_MTPRODUCTCATALOGEXECLib>
{
public:
	CMTPredicateWriter()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTPREDICATEWRITER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTPredicateWriter)

BEGIN_COM_MAP(CMTPredicateWriter)
	COM_INTERFACE_ENTRY(IMTPredicateWriter)
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

// IMTPredicateWriter
public:
	STDMETHOD(Create)(/*[in]*/IMTSessionContext* aCtx, /*[in]*/IMTCounterParameterPredicate* aPredicate, /*[out, retval]*/long* apID);
};

#endif //__MTPREDICATEWRITER_H_
