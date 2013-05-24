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

#ifndef __MTYAACREADER_H_
#define __MTYAACREADER_H_

#include <StdAfx.h>
#include "resource.h"       // main symbols
#include <mtx.h>
#include <PCCache.h>

/////////////////////////////////////////////////////////////////////////////
// CMTYAACReader
class ATL_NO_VTABLE CMTYAACReader : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTYAACReader, &CLSID_MTYAACReader>,
	public ISupportErrorInfo,
	public IObjectControl,
	public IDispatchImpl<IMTYAACReader, &IID_IMTYAACReader, &LIBID_MTYAACEXECLib>
{
public:
	CMTYAACReader()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTYAACREADER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTYAACReader)

BEGIN_COM_MAP(CMTYAACReader)
	COM_INTERFACE_ENTRY(IMTYAACReader)
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

// IMTYAACReader
public:
	STDMETHOD(GetYAACByName)(IMTSessionContext* apCtx, BSTR aName, BSTR aNamespace, VARIANT RefDate, IMTYAAC** ppYaac);
  STDMETHOD(GetYAAC)(IMTSessionContext* apCtx, long aAccountID, VARIANT RefDate, IMTYAAC** ppYaac);
  STDMETHOD(GetAvailableGroupSubscriptionsAsRowset)( IMTSessionContext* apCtxt,
                                                                  IMTYAAC* apYAAC,
                                                                  DATE RefDate,
                                                                  VARIANT aFilter,
                                                                  IMTSQLRowset **ppRowset);

};

#endif //__MTYAACREADER_H_
