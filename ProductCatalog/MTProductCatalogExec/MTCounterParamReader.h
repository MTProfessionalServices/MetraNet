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


#ifndef __MTCOUNTERPARAMREADER_H_
#define __MTCOUNTERPARAMREADER_H_

#include "resource.h"       // main symbols
#include <comsvcs.h>

#include <pcexecincludes.h>

#define GET_PARAM_TYPES			L"__GET_COUNTER_PARAM_TYPES__"
#define GET_PARAMS					L"__GET_COUNTER_PARAMS__"

/////////////////////////////////////////////////////////////////////////////
// CMTCounterParamReader
class ATL_NO_VTABLE CMTCounterParamReader : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTCounterParamReader, &CLSID_MTCounterParamReader>,
	public ISupportErrorInfo,
	public IObjectControl,
	public IDispatchImpl<IMTCounterParamReader, &IID_IMTCounterParamReader, &LIBID_MTPRODUCTCATALOGEXECLib>
{
public:
	CMTCounterParamReader()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTCOUNTERPARAMREADER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTCounterParamReader)

BEGIN_COM_MAP(CMTCounterParamReader)
	COM_INTERFACE_ENTRY(IMTCounterParamReader)
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

// IMTCounterParamReader
public:
	STDMETHOD(Find)(/*[in]*/IMTSessionContext* aCtx, long aDBID, /*[out, retval]*/IMTCounterParameter** apParam);
	STDMETHOD(FindSharedAsRowset)(/*[in]*/IMTSessionContext* aCtx, /*[in]*/VARIANT aDataFilter, /*[out, retval]*/IMTSQLRowset** apRowset);
	STDMETHOD(FindParameters)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/IMTCounter* aCounter, /*[out, retval]*/IMTCollection** apParameters);
	STDMETHOD(FindParameterTypes)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/IMTCounter* aCounter, /*[out, retval]*/IMTCollection** apParamTypes);
};

#endif //__MTCOUNTERPARAMREADER_H_
