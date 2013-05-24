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

#ifndef __MTBATCHAUTHCHECKREADER_H_
#define __MTBATCHAUTHCHECKREADER_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CMTBatchAuthCheckReader
class ATL_NO_VTABLE CMTBatchAuthCheckReader : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTBatchAuthCheckReader, &CLSID_MTBatchAuthCheckReader>,
	public IObjectControl,
  public ISupportErrorInfo,
	public IDispatchImpl<IMTBatchAuthCheckReader, &IID_IMTBatchAuthCheckReader, &LIBID_MTAUTHEXECLib>
{
public:
	CMTBatchAuthCheckReader()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTBATCHAUTHCHECKREADER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTBatchAuthCheckReader)

BEGIN_COM_MAP(CMTBatchAuthCheckReader)
	COM_INTERFACE_ENTRY(IMTBatchAuthCheckReader)
	COM_INTERFACE_ENTRY(IObjectControl)
	COM_INTERFACE_ENTRY(IDispatch)
  COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);


// IObjectControl
public:
	STDMETHOD(Activate)();
	STDMETHOD_(BOOL, CanBePooled)();
	STDMETHOD_(void, Deactivate)();

	CComPtr<IObjectContext> m_spObjectContext;

// IMTBatchAuthCheckReader
public:
	STDMETHOD(BatchUmbrellaCheck)(/*[in]*/ IMTSessionContext* apCtx,/*[in]*/ IMTCollectionEx* pCol,DATE RefDate,/*[out, retval]*/ IMTRowSet** ppRowset);
};

#endif //__MTBATCHAUTHCHECKREADER_H_
