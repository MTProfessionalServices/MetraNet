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


#ifndef __MTPCTIMESPANWRITER_H_
#define __MTPCTIMESPANWRITER_H_

#include "resource.h"       // main symbols
#include <comsvcs.h>
#include <comdef.h>

/////////////////////////////////////////////////////////////////////////////
// CMTPCTimeSpanWriter
class ATL_NO_VTABLE CMTPCTimeSpanWriter : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTPCTimeSpanWriter, &CLSID_MTPCTimeSpanWriter>,
	public ISupportErrorInfo,
	public IObjectControl,
	public IDispatchImpl<IMTPCTimeSpanWriter, &IID_IMTPCTimeSpanWriter, &LIBID_MTPRODUCTCATALOGEXECLib>
{
public:
	CMTPCTimeSpanWriter();

DECLARE_REGISTRY_RESOURCEID(IDR_MTPCTIMESPANWRITER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTPCTimeSpanWriter)

BEGIN_COM_MAP(CMTPCTimeSpanWriter)
	COM_INTERFACE_ENTRY(IMTPCTimeSpanWriter)
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

// IMTPCTimeSpanWriter
public:
	STDMETHOD(Create)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ IMTPCTimeSpan* apTimeSpan, /*[out, retval]*/ long* apID);
	STDMETHOD(Update)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ IMTPCTimeSpan* apTimeSpan);
	STDMETHOD(Remove)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aID);
	STDMETHOD(PropagateEndDateChange)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aProdOffID, /*[in]*/ IMTPCTimeSpan* apTimeSpan);

	static _variant_t DateToDBParam(DATE aDate);


// data
private:
	CComPtr<IObjectContext> mpObjectContext;

};

#endif //__MTPCTIMESPANWRITER_H_
