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


#ifndef __MTRATESCHEDULEWRITER_H_
#define __MTRATESCHEDULEWRITER_H_

#include "resource.h"       // main symbols
#include <comsvcs.h>
using MTPRODUCTCATALOGLib::IMTRateSchedulePtr;

/////////////////////////////////////////////////////////////////////////////
// CMTRateScheduleWriter
class ATL_NO_VTABLE CMTRateScheduleWriter : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTRateScheduleWriter, &CLSID_MTRateScheduleWriter>,
	public ISupportErrorInfo,
	public IObjectControl,
	public IDispatchImpl<IMTRateScheduleWriter, &IID_IMTRateScheduleWriter, &LIBID_MTPRODUCTCATALOGEXECLib>
{
public:
	CMTRateScheduleWriter()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTRATESCHEDULEWRITER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTRateScheduleWriter)

BEGIN_COM_MAP(CMTRateScheduleWriter)
	COM_INTERFACE_ENTRY(IMTRateScheduleWriter)
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

	CComPtr<IObjectContext> mpObjectContext;

// IMTRateScheduleWriter
public:
	
	STDMETHOD(Create)(/*[in]*/ IMTSessionContext* apCtxt, IMTRateSchedule * schedule, VARIANT_BOOL aSaveRules, /*[out, retval]*/ long * id);
	STDMETHOD(Update)(/*[in]*/ IMTSessionContext* apCtxt, IMTRateSchedule * apSchedule, VARIANT_BOOL aSaveRateSchedule, VARIANT_BOOL aSaveRules);
	STDMETHOD(Remove)(/*[in]*/ IMTSessionContext* apCtxt, long aRateScheduleID);

protected:
	void CheckExisting(IMTRateSchedule *apSchedule,long ExistingID);
  void CheckGroupSubscriptionRules(IMTRateSchedulePtr schedule);
};

#endif //__MTRATESCHEDULEWRITER_H_
