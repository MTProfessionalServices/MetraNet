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

// MTRecurringChargeWriter.h : Declaration of the CMTRecurringChargeWriter

#ifndef __MTRECURRINGCHARGEWRITER_H_
#define __MTRECURRINGCHARGEWRITER_H_

#include "resource.h"       // main symbols
#include <comsvcs.h>

/////////////////////////////////////////////////////////////////////////////
// CMTRecurringChargeWriter
class ATL_NO_VTABLE CMTRecurringChargeWriter : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTRecurringChargeWriter, &CLSID_MTRecurringChargeWriter>,
	public ISupportErrorInfo,
	public IObjectControl,
	public IDispatchImpl<IMTRecurringChargeWriter, &IID_IMTRecurringChargeWriter, &LIBID_MTPRODUCTCATALOGEXECLib>
{
public:
	CMTRecurringChargeWriter()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTRECURRINGCHARGEWRITER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTRecurringChargeWriter)

BEGIN_COM_MAP(CMTRecurringChargeWriter)
	COM_INTERFACE_ENTRY(IMTRecurringChargeWriter)
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

// IMTRecurringChargeWriter
public:
	STDMETHOD(RemoveProperties)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long lDBID);
	STDMETHOD(UpdateProperties)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ IMTRecurringCharge* apRC);
	STDMETHOD(CreateProperties)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ IMTRecurringCharge* apRC);
private:
	HRESULT RunDBInsertOrUpdateQuery(IMTSessionContext* apCtxt, IMTRecurringCharge* apRC, LPCSTR lpQueryName);
};

#endif //__MTRECURRINGCHARGEWRITER_H_
