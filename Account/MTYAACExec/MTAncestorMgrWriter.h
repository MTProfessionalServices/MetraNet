/**************************************************************************
* Copyright 1997-2002 by MetraTech
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
***************************************************************************/

#ifndef __MTANCESTORMGRWRITER_H_
#define __MTANCESTORMGRWRITER_H_

#include <StdAfx.h>
#include "resource.h"       // main symbols
#include <mtx.h>

// Import Materialized View type libs.
#import <MetraTech.DataAccess.MaterializedViews.tlb>

/////////////////////////////////////////////////////////////////////////////
// CMTAncestorMgrWriter
class ATL_NO_VTABLE CMTAncestorMgrWriter : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTAncestorMgrWriter, &CLSID_MTAncestorMgrWriter>,
	public ISupportErrorInfo,
	public IObjectControl,
	public IDispatchImpl<IMTAncestorMgrWriter, &IID_IMTAncestorMgrWriter, &LIBID_MTYAACEXECLib>
{
public:
	CMTAncestorMgrWriter()
    : mIsMVSupportEnabled(false),
      mBaseTableName("t_dm_account"),
      mMVMPtr(NULL)
	{
    /* Do nothing here */
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTANCESTORMGRWRITER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTAncestorMgrWriter)

BEGIN_COM_MAP(CMTAncestorMgrWriter)
	COM_INTERFACE_ENTRY(IMTAncestorMgrWriter)
	COM_INTERFACE_ENTRY(IObjectControl)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IObjectControl
public:
	STDMETHOD(Activate)();
	STDMETHOD_(BOOL, CanBePooled)();
	STDMETHOD_(void, Deactivate)();

	CComPtr<IObjectContext> m_spObjectContext;

// IMTAncestorMgrWriter
public:
	STDMETHOD(MoveAccountBatch)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aAncestor,/*[in]*/ IMTCollection* pCol,/*[in]*/ IMTProgress* pProgress,/*[in]*/ DATE aStartDate,/*[out,retval]*/ IMTRowSet** ppErrors);
	STDMETHOD(AddToHierarchy)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aAncestor,/*[in]*/ long aDescendent,/*[in]*/ DATE aStartDate,/*[in]*/ DATE aEndDate);
	STDMETHOD(MoveAccount)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aAncestor,/*[in]*/ long aDescendent,/*[in]*/ DATE StartDate);

private:
  bool mIsMVSupportEnabled;
  MetraTech_DataAccess_MaterializedViews::IManagerPtr mMVMPtr;
  string mBaseTableName;
  string mInsertDeltaTableName;
  string mDeleteDeltaTableName;
};

#endif //__MTANCESTORMGRWRITER_H_
