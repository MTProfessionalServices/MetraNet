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

// MTCalendarWriter.h : Declaration of the CMTCalendarWriter

#ifndef __MTCALENDARWRITER_H_
#define __MTCALENDARWRITER_H_

#include "resource.h"       // main symbols
#include <comsvcs.h>
#include <mtglobal_msg.h>

/////////////////////////////////////////////////////////////////////////////
// CMTCalendarWriter
class ATL_NO_VTABLE CMTCalendarWriter : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTCalendarWriter, &CLSID_MTCalendarWriter>,
	public ISupportErrorInfo,
	public IObjectControl,
	public IDispatchImpl<IMTCalendarWriter, &IID_IMTCalendarWriter, &LIBID_MTPRODUCTCATALOGEXECLib>
{
public:
	CMTCalendarWriter()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTCALENDARWRITER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTCalendarWriter)

BEGIN_COM_MAP(CMTCalendarWriter)
	COM_INTERFACE_ENTRY(IMTCalendarWriter)
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

// IMTCalendarWriter
public:
	STDMETHOD(Save)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ IMTCalendar * apCalendar);
private:
	STDMETHOD(DeleteCalendarConfiguration)(/*[in]*/ IMTCalendar* apCal);
	STDMETHOD(DeleteDayPeriods)(/*[in]*/ long day_id);
	STDMETHOD(InsertCalendarConfiguration)(/*[in]*/ IMTCalendar *apCal);
	//STDMETHOD(InsertDayPeriods)(/*[in]*/ IMTCollection* periodcol, /*[in]*/ long day_id);
	STDMETHOD(InsertDayPeriods)(MTPRODUCTCATALOGLib::IMTCollectionPtr& apCol, long day_id);
};

#endif //__MTCALENDARWRITER_H_
