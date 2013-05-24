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
	
// COMProductViewItem.h : Declaration of the CCOMProductViewItem

#ifndef __COMPRODUCTVIEWITEM_H_
#define __COMPRODUCTVIEWITEM_H_

#include "resource.h"       // main symbols
#include <NTLogger.h>
#include <ComDataLogging.h>
#include <autologger.h>
#include <MTRowSetImpl.h>
#include <DBViewHierarchy.h>
#include <autoinstance.h>


// forward declarations ...
class DBViewHierarchy ;
class DBProductView ;
class DBSQLRowset ;

/////////////////////////////////////////////////////////////////////////////
// CCOMProductViewItem
class ATL_NO_VTABLE CCOMProductViewItem : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CCOMProductViewItem, &CLSID_COMProductViewItem>,
  public ISupportErrorInfo,
	public MTRowSetImpl<ICOMProductViewItem, &IID_ICOMProductViewItem, &LIBID_COMDBOBJECTSLib>
{
public:
	CCOMProductViewItem() ;
  virtual ~CCOMProductViewItem() ;

DECLARE_REGISTRY_RESOURCEID(IDR_COMPRODUCTVIEWITEM)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CCOMProductViewItem)
	COM_INTERFACE_ENTRY(ICOMProductViewItem)
	COM_INTERFACE_ENTRY(IMTRowSet)
	COM_INTERFACE_ENTRY2(IDispatch,ICOMProductViewItem)
  COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// ICOMProductViewItem
public:
// The IntervalID property gets the interval id.
	STDMETHOD(get_IntervalID)(/*[out, retval]*/ long *pVal);
// The IntervalID property sets the interval id.
	STDMETHOD(put_IntervalID)(/*[in]*/ long newVal);
// The Value property gets the value for the specified column.
	STDMETHOD(get_Value)(/*[in]*/ VARIANT vtIndex, /*[out, retval]*/ VARIANT *pVal);
// The GetChildrenSummary gets the summary rowset for the children of the current parent view item.
	STDMETHOD(GetChildrenSummary)(/*[out,retval]*/ LPDISPATCH *pView);
// The SessionID property gets the session id.
	STDMETHOD(get_SessionID)(/*[out, retval]*/ long  *pVal);
// The SessionID property sets the session id.
	STDMETHOD(put_SessionID)(/*[in]*/ long  newVal);
// The ViewID property gets the view id.
	STDMETHOD(get_ViewID)(/*[out, retval]*/ long *pVal);
// The ViewID property sets the view id.
	STDMETHOD(put_ViewID)(/*[in]*/ long newVal);
// The AccountID property gets the account id.
	STDMETHOD(get_AccountID)(/*[out, retval]*/ long *pVal);
// The AccountID property sets the account id.
	STDMETHOD(put_AccountID)(/*[in]*/ long newVal);
// The Init method initializes the rowset for the specified session id, account id, view id and interval id.
	STDMETHOD(Init)(BSTR aLangCode);
private:
  long                    mAcctID ;
  long                    mViewID ;
  long                    mIntervalID ;
  long                    mSessionID ;
  std::wstring               mLangCode ;
  MTAutoSingleton<MTPCHierarchyColl> mVHinstance;
  DBProductView *         mpView ;
  MTAutoInstance<MTAutoLoggerImpl<pComDataAccessorLogTag,pComDataLogDir> >	mLogger;
};

#endif //__COMPRODUCTVIEWITEM_H_
