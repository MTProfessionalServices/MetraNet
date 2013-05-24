/**************************************************************************
* Copyright 1997-2000 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* Created by: Kevin Fitzgerald
* $Header$
* 
***************************************************************************/
	
// COMProductView.h : Declaration of the CCOMProductView

#ifndef __COMPRODUCTVIEW_H_
#define __COMPRODUCTVIEW_H_

#include "resource.h"       // main symbols
#include <ComDataLogging.h>
#include <autologger.h>
#include <DBSQLRowset.h>
#include <MTRowSetImpl.h>
#include <DBViewHierarchy.h>
#include <autoinstance.h>


// forward declarations ...
class DBViewHierarchy ;
class DBProductView ;
class DBSQLRowset ;

/////////////////////////////////////////////////////////////////////////////
// CCOMProductView
class ATL_NO_VTABLE CCOMProductView : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CCOMProductView, &CLSID_COMProductView>,
  public ISupportErrorInfo,
	public MTRowSetImpl<ICOMProductView, &IID_ICOMProductView, &LIBID_COMDBOBJECTSLib>
{
public:
	CCOMProductView();
  virtual ~CCOMProductView() ;

DECLARE_REGISTRY_RESOURCEID(IDR_COMPRODUCTVIEW)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CCOMProductView)
	COM_INTERFACE_ENTRY(ICOMProductView)
	COM_INTERFACE_ENTRY(IMTRowSet)
	COM_INTERFACE_ENTRY2(IDispatch,ICOMProductView)
  COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// ICOMProductView
public:
// The get_PopulatedRecordSet property returnes the underline rowset object.
 	STDMETHOD(get_PopulatedRecordSet)(IDispatch** pDisp);
// The Refresh method refreshes the underline rowset object.
  STDMETHOD(Refresh)();
// The GetProperties method gets the property collection for the specified view id.
  STDMETHOD(GetProperties)(LPDISPATCH *pPropCollection);
// The IntervalID property gets the interval id.
	STDMETHOD(get_IntervalID)(/*[out, retval]*/ long *pVal);
// The IntervalID property sets the interval id.
	STDMETHOD(put_IntervalID)(/*[in]*/ long newVal);
// The GetChildrenSummary gets the summary rowset for the children of the current parent view item.
	STDMETHOD(GetChildrenSummary)(/*[out, retval]*/ LPDISPATCH *pView);
// The ViewID property gets the view id.
	STDMETHOD(get_ViewID)(/*[out, retval]*/ long *pVal);
// The ViewID property sets the view id.
	STDMETHOD(put_ViewID)(/*[in]*/ long newVal);
// The AccountID property gets the account id.
	STDMETHOD(get_AccountID)(/*[out, retval]*/ long *pVal);
// The AccountID property sets the account id.
	STDMETHOD(put_AccountID)(/*[in]*/ long newVal);
// The Init method initializes the product view rowset
	STDMETHOD(Init)(BSTR aLangCode, BSTR pQueryExtension);
	STDMETHOD(Sort)(BSTR aPropertyName, ::MTSortOrder aSortOrder);
	STDMETHOD(get_Value)(VARIANT arIndex, VARIANT * pVal);
private:
  long                    mAcctID ;
  long                    mViewID ;
  long                    mIntervalID ;
  std::wstring               mLangCode ;
	MTAutoSingleton<MTPCHierarchyColl> mVHinstance;
  DBProductView *         mpView ;
	MTAutoInstance<MTAutoLoggerImpl<pComDataAccessorLogTag,pComDataLogDir> >	mLogger;
	std::wstring               mpQueryExtension ;
};

#endif //__COMPRODUCTVIEW_H_
