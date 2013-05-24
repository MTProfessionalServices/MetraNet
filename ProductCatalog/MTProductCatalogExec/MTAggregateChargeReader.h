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

// MTAggregateChargeReader.h : Declaration of the CMTAggregateChargeReader

#ifndef __MTAGGREGATECHARGEREADER_H_
#define __MTAGGREGATECHARGEREADER_H_

#include "resource.h"       // main symbols
#include <comsvcs.h>


/////////////////////////////////////////////////////////////////////////////
// CMTAggregateChargeReader
class ATL_NO_VTABLE CMTAggregateChargeReader : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTAggregateChargeReader, &CLSID_MTAggregateChargeReader>,
	public ISupportErrorInfo,
	public IObjectControl,
	public IDispatchImpl<IMTAggregateChargeReader, &IID_IMTAggregateChargeReader, &LIBID_MTPRODUCTCATALOGEXECLib>
{
public:
	CMTAggregateChargeReader() {}

DECLARE_REGISTRY_RESOURCEID(IDR_MTAGGREGATECHARGEREADER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTAggregateChargeReader)

BEGIN_COM_MAP(CMTAggregateChargeReader)
	COM_INTERFACE_ENTRY(IMTAggregateChargeReader)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY(IObjectControl)
	COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()


// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

//IObjectControl
public:
	STDMETHOD(Activate)();
	STDMETHOD_(BOOL, CanBePooled)();
	STDMETHOD_(void, Deactivate)();

	CComPtr<IObjectContext> m_spObjectContext;
	

//IMTAggregateChargeReader
public:
	STDMETHOD(Populate)(IMTSessionContext* apCtxt, /*[in]*/ IMTAggregateCharge* pAggCharge);
	STDMETHOD(FindCountersAsRowset)(IMTSessionContext* apCtxt, /*[in]*/long aAggChargeDBID, /*[out, retval]*/IMTSQLRowset** apRowset);

private:
	void LoadCounters(IMTSessionContext* apCtxt, IMTAggregateCharge *pAggCharge);

};

#endif //__MTAGGREGATECHARGEREADER_H_
