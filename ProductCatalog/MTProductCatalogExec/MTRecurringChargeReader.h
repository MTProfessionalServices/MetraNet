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

// MTRecurringChargeReader.h : Declaration of the CMTRecurringChargeReader

#ifndef __MTRECURRINGCHARGEREADER_H_
#define __MTRECURRINGCHARGEREADER_H_

#include "resource.h"       // main symbols
#include <comsvcs.h>

/////////////////////////////////////////////////////////////////////////////
// CMTRecurringChargeReader
class ATL_NO_VTABLE CMTRecurringChargeReader : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTRecurringChargeReader, &CLSID_MTRecurringChargeReader>,
	public ISupportErrorInfo,
	public IObjectControl,
	public IDispatchImpl<IMTRecurringChargeReader, &IID_IMTRecurringChargeReader, &LIBID_MTPRODUCTCATALOGEXECLib>
{
public:
	CMTRecurringChargeReader()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTRECURRINGCHARGEREADER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTRecurringChargeReader)

BEGIN_COM_MAP(CMTRecurringChargeReader)
	COM_INTERFACE_ENTRY(IMTRecurringChargeReader)
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

// IMTRecurringChargeReader
public:
	STDMETHOD(PopulateProperties)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ IMTRecurringCharge* apRC);
};

#endif //__MTRECURRINGCHARGEREADER_H_
