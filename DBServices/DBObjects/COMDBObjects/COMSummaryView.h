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
	
// COMSummaryView.h : Declaration of the CCOMSummaryView

#ifndef __COMSUMMARYVIEW_H_
#define __COMSUMMARYVIEW_H_

#include "resource.h"       // main symbols
#include <ComDataLogging.h>
#include <autologger.h>
#include <MTRowSetImpl.h>
#include <DBViewHierarchy.h>
#include <autoinstance.h>

// forward declarations ...
class DBViewHierarchy ;
class DBView ;
class DBSQLRowset ;

/////////////////////////////////////////////////////////////////////////////
// CCOMSummaryView
class ATL_NO_VTABLE CCOMSummaryView : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CCOMSummaryView, &CLSID_COMSummaryView>,
  public ISupportErrorInfo,
	public MTRowSetImpl<ICOMSummaryView, &IID_ICOMSummaryView, &LIBID_COMDBOBJECTSLib>
{
public:
	CCOMSummaryView();
  virtual ~CCOMSummaryView();

DECLARE_REGISTRY_RESOURCEID(IDR_COMSUMMARYVIEW)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CCOMSummaryView)
	COM_INTERFACE_ENTRY(ICOMSummaryView)
	COM_INTERFACE_ENTRY(IMTRowSet)
	COM_INTERFACE_ENTRY2(IDispatch,ICOMSummaryView)
  COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// ICOMSummaryView
public:
// The IntervalID property gets the interval id.
	STDMETHOD(get_IntervalID)(/*[out, retval]*/ long *pVal);
// The IntervalID property sets the interval id.
	STDMETHOD(put_IntervalID)(/*[in]*/ long newVal);
// The GetContents method gets the detailed rowset for the current rowset.
	STDMETHOD(GetContents)(/*[out,retval]*/ LPDISPATCH *pView);
// The ViewID property gets the view id.
	STDMETHOD(get_ViewID)(/*[out, retval]*/ long *pVal);
// The ViewID property sets the view id.
	STDMETHOD(put_ViewID)(/*[in]*/ long newVal);
// The AccountID property gets the account id.
	STDMETHOD(get_AccountID)(/*[out, retval]*/ long *pVal);
// The AccountID property sets the account id.
	STDMETHOD(put_AccountID)(/*[in]*/ long newVal);
// The Init method initializes the summary view rowset.
	STDMETHOD(Init)(BSTR aLangCode, BSTR pQueryExtension);
	STDMETHOD(get_Value)(VARIANT arIndex, VARIANT * pVal);
private:
  long                    mAcctID ;
  long                    mViewID ;
  long                    mIntervalID ;
  std::wstring               mLangCode ;
	MTAutoSingleton<MTPCHierarchyColl> mVHinstance;
  DBView *                mpView ;
  MTAutoInstance<MTAutoLoggerImpl<pComDataAccessorLogTag,pComDataLogDir> >	mLogger;
  std::wstring               mQueryExtension ;
};

#endif //__COMSUMMARYVIEW_H_
