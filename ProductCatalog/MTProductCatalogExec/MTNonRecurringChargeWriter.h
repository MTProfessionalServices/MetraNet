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
// MTNonRecurringChargeWriter.h : Declaration of the CMTNonRecurringChargeWriter

#ifndef __MTNONRECURRINGCHARGEWRITER_H_
#define __MTNONRECURRINGCHARGEWRITER_H_

#include "resource.h"       // main symbols
#include <comsvcs.h>

/////////////////////////////////////////////////////////////////////////////
// CMTNonRecurringChargeWriter
class ATL_NO_VTABLE CMTNonRecurringChargeWriter : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTNonRecurringChargeWriter, &CLSID_MTNonRecurringChargeWriter>,
	public ISupportErrorInfo,
	public IObjectControl,
	public IDispatchImpl<IMTNonRecurringChargeWriter, &IID_IMTNonRecurringChargeWriter, &LIBID_MTPRODUCTCATALOGEXECLib>
{
public:
	CMTNonRecurringChargeWriter()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTNONRECURRINGCHARGEWRITER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTNonRecurringChargeWriter)

BEGIN_COM_MAP(CMTNonRecurringChargeWriter)
	COM_INTERFACE_ENTRY(IMTNonRecurringChargeWriter)
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

// IMTNonRecurringChargeWriter
public:
	STDMETHOD(RemoveProperties)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long lDBID);
	STDMETHOD(UpdateProperties)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ IMTNonRecurringCharge* apNRC);
	STDMETHOD(CreateProperties)(/*[in]*/ IMTSessionContext* apCtxt, IMTNonRecurringCharge* apNRC);

private:
	HRESULT RunDBInsertOrUpdateQuery(IMTNonRecurringCharge* apNRC, LPCSTR lpQueryName);

};

#endif //__MTNONRECURRINGCHARGEWRITER_H_
