/**************************************************************************
* Copyright 1997-2001 by MetraTech
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
* $Header$
* 
***************************************************************************/


#ifndef __MTDDLWRITER_H_
#define __MTDDLWRITER_H_

#include "resource.h"       // main symbols
#include <mtx.h>
#include <comsvcs.h>
#include <ProductViewCollection.h>
#include <MSIXDefinition.h>
#include <pcexecincludes.h>

#include <string>
using namespace std;



#define CREATE_COUNTER_VIEW_SELECT_CLAUSE					"__CREATE_COUNTER_VIEW__"
#define CREATE_COUNTER_USAGE_VIEW_SELECT_CLAUSE		"__CREATE_COUNTER_USAGE_VIEW__"
#define CREATE_COUNTER_UNION_VIEW									"__CREATE_COUNTER_VIEW_UNION__"
#define DROP_COUNTER_UNION_VIEW									"__DROP_COUNTER_VIEW_UNION__"


/////////////////////////////////////////////////////////////////////////////
// CMTDDLWriter
class ATL_NO_VTABLE CMTDDLWriter : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTDDLWriter, &CLSID_MTDDLWriter>,
	public ISupportErrorInfo,
	public IObjectControl,
	public IDispatchImpl<IMTDDLWriter, &IID_IMTDDLWriter, &LIBID_MTPRODUCTCATALOGEXECLib>
{
public:
	CMTDDLWriter()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTDDLWRITER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTDDLWriter)

BEGIN_COM_MAP(CMTDDLWriter)
	COM_INTERFACE_ENTRY(IMTDDLWriter)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY(IObjectControl)
	COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IObjectControl
public:
	STDMETHOD(Activate)();
	STDMETHOD_(BOOL, CanBePooled)();
	STDMETHOD_(void, Deactivate)();

	CComPtr<IObjectContext> mpObjectContext;

// IMTDDLWriter
public:
	STDMETHOD(SyncExtendedPropertyTables)(IMTSessionContext* apCtxt);
	STDMETHOD(SyncParameterTables)(IMTSessionContext* apCtxt);
	STDMETHOD (CreateView) (IMTSessionContext* apCtxt, BSTR aFromProductView,BSTR* apViewName);
	STDMETHOD (CreateUsageView) (IMTSessionContext* apCtxt, BSTR* apViewName);
	STDMETHOD (CreateAllViews) (IMTSessionContext* apCtxt);
	STDMETHOD(RemoveView)(IMTSessionContext* apCtxt, /*[in]*/BSTR aPVName);
	STDMETHOD(SyncAdjustmentTables)(IMTSessionContext* apCtxt);
  STDMETHOD(ExecuteStatement)(BSTR aQuery, VARIANT aQueryDir, IMTSQLRowset **ppRowset);
private:
	_bstr_t GetViewName(BSTR aPVName);
	HRESULT InternalCreateView( BSTR* apViewName = NULL, BSTR aFromProductView = NULL);

};

#endif //__MTDDLWRITER_H_
