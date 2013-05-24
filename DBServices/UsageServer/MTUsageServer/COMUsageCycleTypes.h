	
// COMUsageCycleTypes.h : Declaration of the CCOMUsageCycleTypes

#ifndef __COMUSAGECYCLETYPES_H_
#define __COMUSAGECYCLETYPES_H_

#include "resource.h"       // main symbols
#include <NTLogger.h>
#include <MTRowSetImpl.h>

// forward declarations 
struct IMTSQLRowset ;

/////////////////////////////////////////////////////////////////////////////
// CCOMUsageCycleTypes
class ATL_NO_VTABLE CCOMUsageCycleTypes : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CCOMUsageCycleTypes, &CLSID_COMUsageCycleTypes>,
	public ISupportErrorInfo,
	public MTRowSetImpl<ICOMUsageCycleTypes, &IID_ICOMUsageCycleTypes, &LIBID_MTUSAGESERVERLib>
{
public:
	CCOMUsageCycleTypes() ;
  virtual ~CCOMUsageCycleTypes() ;

DECLARE_REGISTRY_RESOURCEID(IDR_COMUSAGECYCLETYPES)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CCOMUsageCycleTypes)
	COM_INTERFACE_ENTRY(ICOMUsageCycleTypes)
	COM_INTERFACE_ENTRY(IMTRowSet)
	COM_INTERFACE_ENTRY2(IDispatch,ICOMUsageCycleTypes)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// ICOMUsageCycleTypes
public:
	STDMETHOD(Init)();
	STDMETHOD(AddAccount)(/*[in]*/ long AccountID, 
    /*[in]*/ ICOMUsageCyclePropertyColl *apPropColl, LPDISPATCH pRowset);
  STDMETHOD(UpdateAccount)(/*[in]*/ long AccountID, 
  /*[in]*/ ICOMUsageCyclePropertyColl *apPropColl);

	STDMETHODIMP AccountNeedsUpdate(long AccountID, 
																	::ICOMUsageCyclePropertyColl *apPropColl,
																	VARIANT_BOOL * apNeedsUpdate);
private:
  NTLogger              mLogger;
};

#endif //__COMUSAGECYCLETYPES_H_
