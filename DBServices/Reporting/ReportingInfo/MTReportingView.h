	
// MTReportingView.h : Declaration of the CMTReportingView

#ifndef __MTREPORTINGVIEW_H_
#define __MTREPORTINGVIEW_H_

#include "resource.h"       // main symbols
#include <comdef.h>
#include <NTLogger.h>
#include <string>


/////////////////////////////////////////////////////////////////////////////
// CMTReportingView
class ATL_NO_VTABLE CMTReportingView : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTReportingView, &CLSID_MTReportingView>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTReportingView, &IID_IMTReportingView, &LIBID_REPORTINGINFOLib>
{
public:
	CMTReportingView() ;
	virtual ~CMTReportingView() ;
	

DECLARE_REGISTRY_RESOURCEID(IDR_MTREPORTINGVIEW)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTReportingView)
	COM_INTERFACE_ENTRY(IMTReportingView)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTReportingView
public:
	STDMETHOD(Remove)();
	STDMETHOD(Add)();
private:
  void TearDown() ;
  void GetViewName (wstring &arViewName) ;

  NTLogger mLogger ;
};

#endif //__MTREPORTINGVIEW_H_
