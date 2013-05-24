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
	
// COMProductViewSummary.h : Declaration of the CCOMProductViewSummary

#ifndef __COMPRODUCTVIEWSUMMARY_H_
#define __COMPRODUCTVIEWSUMMARY_H_

#include "resource.h"       // main symbols
#include <ComDataLogging.h>
#include <autologger.h>
#include <MTRowSetImpl.h>
#include <DBViewHierarchy.h>
#include <autoinstance.h>

// forward declarations ...
class DBViewHierarchy ;
class DBSQLRowset ;
class DBProductView ;

/////////////////////////////////////////////////////////////////////////////
// CCOMProductViewSummary
class ATL_NO_VTABLE CCOMProductViewSummary : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CCOMProductViewSummary, &CLSID_COMProductViewSummary>,
  public ISupportErrorInfo,
	public MTRowSetImpl<ICOMProductViewSummary, &IID_ICOMProductViewSummary, &LIBID_COMDBOBJECTSLib>
{
public:
	CCOMProductViewSummary() ;
  virtual ~CCOMProductViewSummary() ;

DECLARE_REGISTRY_RESOURCEID(IDR_COMPRODUCTVIEWSUMMARY)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CCOMProductViewSummary)
	COM_INTERFACE_ENTRY(ICOMProductViewSummary)
	COM_INTERFACE_ENTRY(IMTRowSet)
	COM_INTERFACE_ENTRY2(IDispatch,ICOMProductViewSummary)
  COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// ICOMProductViewSummary
public:
// The IntervalID property gets the interval id.
	STDMETHOD(get_IntervalID)(/*[out, retval]*/ long *pVal);
// The IntervalID property sets the interval id.
	STDMETHOD(put_IntervalID)(/*[in]*/ long newVal);
// The SessionID property gets the session id.
	STDMETHOD(get_SessionID)(/*[out, retval]*/ long *pVal);
// The SessionID property sets the session id.
	STDMETHOD(put_SessionID)(/*[in]*/ long newVal);
// The Value property gets the value for the specified column.
	STDMETHOD(get_Value)(/*[in]*/ VARIANT vtIndex, /*[out, retval]*/ VARIANT *pVal);
// The GetContents method get the product view item rowset for the specified account id, interval id, view id and session id.
	STDMETHOD(GetContents)(BSTR pQueryExtension, /*[out,retval]*/ LPDISPATCH *pView);
// The ViewID property gets the view id.
	STDMETHOD(get_ViewID)(/*[out, retval]*/ long *pVal);
// The ViewID property sets the view id.
	STDMETHOD(put_ViewID)(/*[in]*/ long newVal);
// The AccountID property gets the account id.
	STDMETHOD(get_AccountID)(/*[out, retval]*/ long *pVal);
// The AccountID property sets the account id.
	STDMETHOD(put_AccountID)(/*[in]*/ long newVal);
// The Init method initializes the product view summary rowset for the specified account id, interval id, view id and session id.
	STDMETHOD(Init)(BSTR aLangCode);
private:
  long                    mAcctID ;
  long                    mIntervalID ;
  long                    mViewID ;
  long                    mSessionID ;
  std::wstring               mLangCode ;
  MTAutoSingleton<MTPCHierarchyColl> mVHinstance;
  DBProductView *         mpView ;
  MTAutoInstance<MTAutoLoggerImpl<pComDataAccessorLogTag,pComDataLogDir> >	mLogger;
};

#endif //__COMPRODUCTVIEWSUMMARY_H_
