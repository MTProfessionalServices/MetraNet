	
// COMUsageCycleColl.h : Declaration of the CCOMUsageCycleColl

#ifndef __COMUSAGECYCLECOLL_H_
#define __COMUSAGECYCLECOLL_H_

#include "resource.h"       // main symbols
#include <NTLogger.h>
#include <MTRowSetImpl.h>

// forward declarations 
struct IMTSQLRowset ;

/////////////////////////////////////////////////////////////////////////////
// CCOMUsageCycleColl
class ATL_NO_VTABLE CCOMUsageCycleColl : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CCOMUsageCycleColl, &CLSID_COMUsageCycleColl>,
	public ISupportErrorInfo,
	public MTRowSetImpl<ICOMUsageCycleColl, &IID_ICOMUsageCycleColl, &LIBID_MTUSAGESERVERLib>
{
public:
	CCOMUsageCycleColl() ;
  virtual ~CCOMUsageCycleColl() ;

DECLARE_REGISTRY_RESOURCEID(IDR_COMUSAGECYCLECOLL)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CCOMUsageCycleColl)
	COM_INTERFACE_ENTRY(ICOMUsageCycleColl)
	COM_INTERFACE_ENTRY2(IDispatch,ICOMUsageCycleColl)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// ICOMUsageCycleColl
public:
	STDMETHOD(CreateInterval)(/*[in]*/ VARIANT aDate);
	STDMETHOD(Init)();

private:
  NTLogger              mLogger;
};

#endif //__COMUSAGECYCLECOLL_H_
