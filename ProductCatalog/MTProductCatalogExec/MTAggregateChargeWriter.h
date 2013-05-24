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

// MTAggregateChargeWriter.h : Declaration of the CMTAggregateChargeWriter

#ifndef __MTAGGREGATECHARGEWRITER_H_
#define __MTAGGREGATECHARGEWRITER_H_

#include "resource.h"       // main symbols
#include <comsvcs.h>

/////////////////////////////////////////////////////////////////////////////
// CMTAggregateChargeWriter
class ATL_NO_VTABLE CMTAggregateChargeWriter : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTAggregateChargeWriter, &CLSID_MTAggregateChargeWriter>,
	public ISupportErrorInfo,
	public IObjectControl,
	public IDispatchImpl<IMTAggregateChargeWriter, &IID_IMTAggregateChargeWriter, &LIBID_MTPRODUCTCATALOGEXECLib>
{
public:
	CMTAggregateChargeWriter()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTAGGREGATECHARGEWRITER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTAggregateChargeWriter)

BEGIN_COM_MAP(CMTAggregateChargeWriter)
	COM_INTERFACE_ENTRY(IMTAggregateChargeWriter)
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

// IMTAggregateChargeWriter
public:
	STDMETHOD(Remove)(IMTSessionContext* apCtxt, /*[in]*/ long aID);
	STDMETHOD(Update)(IMTSessionContext* apCtxt, /*[in]*/ IMTAggregateCharge *apAggCharge);
	STDMETHOD(Create)(IMTSessionContext* apCtxt, IMTAggregateCharge *apAggCharge);

private:
	void SaveCounterAndMapping(IMTSessionContext* apCtxt, IMTAggregateCharge* apAggregateCharge, long lCPDID);
	HRESULT RunDBInsertOrUpdateQuery(IMTSessionContext* apCtxt, IMTAggregateCharge* apAggregateCharge, LPCSTR lpQueryName);
	void SaveCounters(IMTSessionContext* apCtxt, IMTAggregateCharge *piAggregateCharge);

	void RemoveCounters(IMTSessionContext* apCtxt, long lPIID);
};

#endif //__MTAGGREGATECHARGEWRITER_H_
