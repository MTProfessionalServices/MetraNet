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
// MTNonRecurringChargeReader.h : Declaration of the CMTNonRecurringChargeReader

#ifndef __MTNONRECURRINGCHARGEREADER_H_
#define __MTNONRECURRINGCHARGEREADER_H_

#include "resource.h"       // main symbols
#include <comsvcs.h>

/////////////////////////////////////////////////////////////////////////////
// CMTNonRecurringChargeReader
class ATL_NO_VTABLE CMTNonRecurringChargeReader : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTNonRecurringChargeReader, &CLSID_MTNonRecurringChargeReader>,
	public ISupportErrorInfo,
	public IObjectControl,
	public IDispatchImpl<IMTNonRecurringChargeReader, &IID_IMTNonRecurringChargeReader, &LIBID_MTPRODUCTCATALOGEXECLib>
{
public:
	CMTNonRecurringChargeReader()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTNONRECURRINGCHARGEREADER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTNonRecurringChargeReader)

BEGIN_COM_MAP(CMTNonRecurringChargeReader)
	COM_INTERFACE_ENTRY(IMTNonRecurringChargeReader)
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

	CComPtr<IObjectContext> m_spObjectContext;

// IMTNonRecurringChargeReader
public:
	STDMETHOD(PopulateNRCProperties)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ IMTNonRecurringCharge* piNRC);
};

#endif //__MTNONRECURRINGCHARGEREADER_H_
