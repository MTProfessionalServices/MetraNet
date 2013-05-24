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

// MTCalendarReader.h : Declaration of the CMTCalendarReader

#ifndef __MTCALENDARREADER_H_
#define __MTCALENDARREADER_H_

#include "resource.h"       // main symbols
#include <comsvcs.h>

/////////////////////////////////////////////////////////////////////////////
// CMTCalendarReader
class ATL_NO_VTABLE CMTCalendarReader : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTCalendarReader, &CLSID_MTCalendarReader>,
	public ISupportErrorInfo,
	public IObjectControl,
	public IDispatchImpl<IMTCalendarReader, &IID_IMTCalendarReader, &LIBID_MTPRODUCTCATALOGEXECLib>
{
public:
	CMTCalendarReader()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTCALENDARREADER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTCalendarReader)

BEGIN_COM_MAP(CMTCalendarReader)
	COM_INTERFACE_ENTRY(IMTCalendarReader)
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

// IMTCalendarReader
public:
	STDMETHOD(GetCalendar)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aID, /*[out, retval]*/ IMTCalendar ** apCalendar);
	STDMETHOD(GetCalendarByName)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ BSTR aName, /*[out, retval]*/ IMTCalendar ** apCalendar);
	STDMETHOD(GetCalendarsAsRowset)(/*[in]*/ IMTSessionContext* apCtxt, /*[out, retval]*/ IMTSQLRowset ** apRowset);
};

#endif //__MTCALENDARREADER_H_
