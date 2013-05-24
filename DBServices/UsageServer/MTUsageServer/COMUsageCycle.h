	
// COMUsageCycle.h : Declaration of the CCOMUsageCycle

#ifndef __COMUSAGECYCLE_H_
#define __COMUSAGECYCLE_H_

#include "resource.h"       // main symbols
#include <NTLogger.h>
#include <UsageCycle.h>

/////////////////////////////////////////////////////////////////////////////
// CCOMUsageCycle
class ATL_NO_VTABLE CCOMUsageCycle : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CCOMUsageCycle, &CLSID_COMUsageCycle>,
	public ISupportErrorInfo,
	public IDispatchImpl<ICOMUsageCycle, &IID_ICOMUsageCycle, &LIBID_MTUSAGESERVERLib>
{
public:
	CCOMUsageCycle() ;
  virtual ~CCOMUsageCycle() ;

DECLARE_REGISTRY_RESOURCEID(IDR_COMUSAGECYCLE)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CCOMUsageCycle)
	COM_INTERFACE_ENTRY(ICOMUsageCycle)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// ICOMUsageCycle
public:
	STDMETHOD(Init)(/*[in]*/ long aCycleType, /*[in]*/ ICOMUsageCyclePropertyColl *apPropColl);
	STDMETHOD(AddAccount)(/*[in]*/ BSTR apStartDate, /*[in]*/ BSTR apEndDate,
    /*[in]*/ long aAccountID, LPDISPATCH pRowset);
  STDMETHOD(UpdateAccount)(BSTR apStartDate, /*[in]*/ BSTR apEndDate, 
  /*[in]*/ long aAccountID, VARIANT aCurrentIntervalEndDate);
  STDMETHOD(CreateInterval)(/*[in]*/ BSTR apStartDate, /*[in]*/ BSTR apEndDate);
private:
  NTLogger              mLogger ;
  MTUsageCycle          mUsageCycle ;
};

#endif //__COMUSAGECYCLE_H_
