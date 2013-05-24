	
// COMDiscountView.h : Declaration of the CCOMDiscountView

#ifndef __COMDISCOUNTVIEW_H_
#define __COMDISCOUNTVIEW_H_

#include "resource.h"       // main symbols
#include <NTLogger.h>

// forward declarations ...
class DBViewHierarchy ;
class DBView ;
class DBRowset ;

/////////////////////////////////////////////////////////////////////////////
// CCOMDiscountView
class ATL_NO_VTABLE CCOMDiscountView : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CCOMDiscountView, &CLSID_COMDiscountView>,
	public ISupportErrorInfo,
	public IDispatchImpl<ICOMDiscountView, &IID_ICOMDiscountView, &LIBID_COMDBOBJECTSLib>
{
public:
  CCOMDiscountView();
  virtual ~CCOMDiscountView() ;

DECLARE_REGISTRY_RESOURCEID(IDR_COMDISCOUNTVIEW)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CCOMDiscountView)
	COM_INTERFACE_ENTRY(ICOMDiscountView)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// ICOMDiscountView
public:
  STDMETHOD(GetProperties)(LPDISPATCH *pPropCollection);
	STDMETHOD(get_IntervalID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_IntervalID)(/*[in]*/ long newVal);
	STDMETHOD(get_CurrentPage)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_CurrentPage)(/*[in]*/ long newVal);
	STDMETHOD(get_PageCount)(/*[out, retval]*/ long *pVal);
	STDMETHOD(get_PageSize)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_PageSize)(/*[in]*/ long newVal);
  STDMETHOD(get_EOF)(/*[out, retval]*/ VARIANT *pVal);
	STDMETHOD(get_RecordCount)(/*[out, retval]*/ long *pVal);
	STDMETHOD(get_Type)(/*[in]*/ VARIANT vtIndex, /*[out, retval]*/ BSTR *pVal);
	STDMETHOD(get_Value)(/*[in]*/ VARIANT vtIndex, /*[out, retval]*/ VARIANT *pVal);
	STDMETHOD(get_Name)(/*[in]*/ VARIANT vtIndex, /*[out, retval]*/ BSTR *pVal);
	STDMETHOD(get_Count)(/*[out, retval]*/ long *pVal);
	STDMETHOD(MoveFirst)();
	STDMETHOD(MoveNext)();
	STDMETHOD(MoveLast)();
	STDMETHOD(get_ViewID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_ViewID)(/*[in]*/ long newVal);
	STDMETHOD(get_AccountID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_AccountID)(/*[in]*/ long newVal);
	STDMETHOD(Init)(BSTR pQueryExtension);
private:
  long                    mAcctID ;
  long                    mViewID ;
  long                    mIntervalID ;
  DBViewHierarchy *       mpDBViewHierarchy ;
  DBView *                mpView ;
  DBRowset *              mpRowset ;
  NTLogger                mLogger ;
};

#endif //__COMDISCOUNTVIEW_H_
