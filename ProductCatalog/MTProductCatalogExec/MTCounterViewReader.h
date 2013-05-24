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

// MTCounterViewReader.h : Declaration of the CMTCounterViewReader

#ifndef __MTCOUNTERVIEWREADER_H_
#define __MTCOUNTERVIEWREADER_H_

#include "resource.h"       // main symbols
#include <comsvcs.h>
#include <pcexecincludes.h>

#define CHECK_COUNTER_UNION_VIEW									"__CHECK_COUNTER_VIEW_UNION__"
/////////////////////////////////////////////////////////////////////////////
// CMTCounterViewReader
class ATL_NO_VTABLE CMTCounterViewReader : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTCounterViewReader, &CLSID_MTCounterViewReader>,
	public ISupportErrorInfo,
	public IObjectControl,
	public IDispatchImpl<IMTCounterViewReader, &IID_IMTCounterViewReader, &LIBID_MTPRODUCTCATALOGEXECLib>
{
public:
	CMTCounterViewReader()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTCOUNTERVIEWREADER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTCounterViewReader)

BEGIN_COM_MAP(CMTCounterViewReader)
	COM_INTERFACE_ENTRY(IMTCounterViewReader)
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

// IMTCounterViewReader
public:
	STDMETHOD(ViewExists)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/BSTR aViewName, /*[out, retval]*/VARIANT_BOOL* abFlag);
};

#endif //__MTCOUNTERVIEWREADER_H_
