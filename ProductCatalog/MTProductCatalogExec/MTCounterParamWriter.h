// MTCounterParamWriter.h : Declaration of the CMTCounterParamWriter

#ifndef __MTCOUNTERPARAMWRITER_H_
#define __MTCOUNTERPARAMWRITER_H_

#include "resource.h"       // main symbols
#include <mtx.h>

/////////////////////////////////////////////////////////////////////////////
// CMTCounterParamWriter
class ATL_NO_VTABLE CMTCounterParamWriter : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTCounterParamWriter, &CLSID_MTCounterParamWriter>,
	public IObjectControl,
  public ISupportErrorInfo,
	public IDispatchImpl<IMTCounterParamWriter, &IID_IMTCounterParamWriter, &LIBID_MTPRODUCTCATALOGEXECLib>
{
public:
	CMTCounterParamWriter()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTCOUNTERPARAMWRITER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTCounterParamWriter)

BEGIN_COM_MAP(CMTCounterParamWriter)
	COM_INTERFACE_ENTRY(IMTCounterParamWriter)
  COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY(IObjectControl)
	COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()

// IObjectControl
public:
	STDMETHOD(Activate)();
	STDMETHOD_(BOOL, CanBePooled)();
	STDMETHOD_(void, Deactivate)();

	CComPtr<IObjectContext> m_spObjectContext;

  // ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);


// IMTCounterParamWriter
public:
	
	STDMETHOD(Remove)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/IMTCounterParameter* apParam);
	STDMETHOD(Update)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/IMTCounterParameter* apParam);
	STDMETHOD(Create)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/long aCounterID,  /*[in]*/IMTCounterParameter* apParam,  /*[out, retval]*/long* aDBID);
};

#endif //__MTCOUNTERPARAMWRITER_H_
