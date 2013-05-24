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
	
// COMProductViewChild.h : Declaration of the CCOMProductViewChild

#ifndef __COMPRODUCTVIEWCHILD_H_
#define __COMPRODUCTVIEWCHILD_H_

#include "resource.h"       // main symbols
#include <ComDataLogging.h>
#include <autologger.h>
#include <MTRowSetImpl.h>
#include <DBViewHierarchy.h>
#include <autoinstance.h>

// foward declarations 
class DBViewHierarchy ;
class DBProductView ;
class DBSQLRowset ;

/////////////////////////////////////////////////////////////////////////////
// CCOMProductViewChild
class ATL_NO_VTABLE CCOMProductViewChild : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CCOMProductViewChild, &CLSID_COMProductViewChild>,
  public ISupportErrorInfo,
	public MTRowSetImpl<ICOMProductViewChild, &IID_ICOMProductViewChild, &LIBID_COMDBOBJECTSLib>
{
public:
	CCOMProductViewChild() ;
  virtual ~CCOMProductViewChild() ;

DECLARE_REGISTRY_RESOURCEID(IDR_COMPRODUCTVIEWCHILD)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CCOMProductViewChild)
	COM_INTERFACE_ENTRY(ICOMProductViewChild)
	COM_INTERFACE_ENTRY(IMTRowSet)
	COM_INTERFACE_ENTRY2(IDispatch,ICOMProductViewChild)
  COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// ICOMProductViewChild
public:

// The PopulatedRecordSet property returnes the underline rowset object.
 	STDMETHOD(get_PopulatedRecordSet)(IDispatch** pDisp);
// The Refresh method refreshes the underline rowset object.
  STDMETHOD(Refresh)();
// The GetProperties method gets the property collection for the specified view id.
  STDMETHOD(GetProperties)(LPDISPATCH *pPropCollection);
// The Sort method sorts the current rowset.
	STDMETHOD(Sort)(BSTR aPropertyName, ::MTSortOrder aSortOrder);
// The IntervalID property gets the interval id.
	STDMETHOD(get_IntervalID)(/*[out, retval]*/ long *pVal);
// The IntervalID property sets the interval id.
	STDMETHOD(put_IntervalID)(/*[in]*/ long newVal);
// The Value property gets the value for the specified column.
	STDMETHOD(get_Value)(/*[in]*/ VARIANT vtIndex, /*[out, retval]*/ VARIANT *pVal);
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
// The Init method initializes the product view child rowset with the specified account id, view id, interval id and session id.
	STDMETHOD(Init)(BSTR aLangCode, BSTR pQueryExtension);
private:
  long                    mAcctID ;
  long                    mIntervalID ;
  long                    mViewID ;
  long                    mSessionID ;
  std::wstring               mLangCode ;
  MTAutoSingleton<MTPCHierarchyColl> mVHinstance;
  DBProductView *         mpView ;
  MTAutoInstance<MTAutoLoggerImpl<pComDataAccessorLogTag,pComDataLogDir> >	mLogger;
  std::wstring               mpQueryExtension ;
};

#endif //__COMPRODUCTVIEWCHILD_H_
