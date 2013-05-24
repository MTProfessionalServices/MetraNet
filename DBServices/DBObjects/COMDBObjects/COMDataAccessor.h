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
// COMDataAccessor.h : Declaration of the CCOMDataAccessor

#ifndef __COMDATAACCESSOR_H_
#define __COMDATAACCESSOR_H_

#include "resource.h"       // main symbols
#include <NTLogger.h>
#include <ComDataLogging.h>
#include <autologger.h>
#include <DBViewHierarchy.h>
#include <autoinstance.h>

class DBUsageCycleCollection ;

#import <COMDBObjects.tlb> rename( "EOF", "RowsetEOF" )
#import <MetraTech.DataAccess.MaterializedViews.tlb>

/////////////////////////////////////////////////////////////////////////////
// CCOMDataAccessor
class ATL_NO_VTABLE CCOMDataAccessor : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CCOMDataAccessor, &CLSID_COMDataAccessor>,
  public ISupportErrorInfo,
	public IDispatchImpl<ICOMDataAccessor, &IID_ICOMDataAccessor, &LIBID_COMDBOBJECTSLib>
{
public:
	CCOMDataAccessor() ;
  virtual ~CCOMDataAccessor() ;

DECLARE_REGISTRY_RESOURCEID(IDR_COMDATAACCESSOR)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CCOMDataAccessor)
	COM_INTERFACE_ENTRY(ICOMDataAccessor)
	COM_INTERFACE_ENTRY(IDispatch)
  COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// ICOMDataAccessor
public:
// The GetViewCollection gets the view collection.
	STDMETHOD(GetViewCollection)(/*[out,retval]*/ LPDISPATCH *pViewCollection);
// The GetProperties method gets the property collection for the specified view.
	STDMETHOD(GetProperties)(/*[in]*/ long ViewID, LPDISPATCH *pPropCollection);
// The GetUsageInterval method gets the usage intervals for the specified account
	STDMETHOD(GetUsageInterval)(LPDISPATCH *pUsageInterval);
// The GetLocaleTranslator method gets the locale translator for the specified language.
	STDMETHOD(GetLocaleTranslator)(/*[out,retval]*/ LPDISPATCH *pLocale);
// The GetProductViewItem method gets the product view item for the specified session id, view id, account id and interval id
	STDMETHOD(GetProductViewItem)(/*[in]*/ long ViewID, /*[in]*/ long SessionID,/*[out,retval]*/ LPDISPATCH *pView);
// The GetProductView method gets the product view for the specified view id, account id and interval id
	STDMETHOD(GetProductView)(/*[in]*/ long aViewID, BSTR pQueryExtension, /*[out,retval]*/ LPDISPATCH *pView);
// The GetSummaryView method gets the summary view for the specified account id and interval id
	STDMETHOD(GetSummaryView)(BSTR pQueryExtension,/*[out,retval]*/ LPDISPATCH *pView);
// The IntervalID property gets the interval id.
	STDMETHOD(get_IntervalID)(/*[out, retval]*/ long *pVal);
// The IntervalID property sets the interval id.
	STDMETHOD(put_IntervalID)(/*[in]*/ long newVal);
// The AccountID property gets the account id.
	STDMETHOD(get_AccountID)(/*[out, retval]*/ long *pVal);
// The AccountID property sets the account id.
	STDMETHOD(put_AccountID)(/*[in]*/ long newVal);
// The LanguageCode property sets the language code.
  STDMETHOD(put_LanguageCode)(/*[in]*/ BSTR newVal);
// Get the internal product view code
	STDMETHOD(GetInternalPVID)(long viewID,long* InternalPVID);
private:
  int             mAcctID ;
  int             mIntervalID ;
  _bstr_t         mLangCode ;
	MTAutoInstance<MTAutoLoggerImpl<pComDataAccessorLogTag,pComDataLogDir> >	mLogger;
  DBUsageCycleCollection *mpUsageCycle ;
  MTAutoSingleton<MTPCHierarchyColl> mVHinstance;
	COMDBOBJECTSLib::ICOMLocaleTranslatorPtr mLocaleTranslator;
  bool mIsMVSupportEnabled;
};

#endif //__COMDATAACCESSOR_H_
