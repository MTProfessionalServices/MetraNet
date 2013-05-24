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


#ifndef __MTCOUNTERWRITER_H_
#define __MTCOUNTERWRITER_H_

#include "resource.h"       // main symbols
#include <comsvcs.h>



#define SP_ADD_COUNTER						L"AddCounterInstance"
#define SP_ADD_COUNTER_PARAM			L"AddCounterParam"
#define SP_UPDATE_COUNTER					L"UpdateCounterInstance"
#define SP_UPDATE_COUNTER_PARAM		L"UpdateCounterParamInstance"
#define SP_DELETE_COUNTER_PARAMS	L"DeleteCounterParamInstances"
#define SP_REMOVE_COUNTER					L"RemoveCounterInstance"



/////////////////////////////////////////////////////////////////////////////
// CMTCounterWriter
class ATL_NO_VTABLE CMTCounterWriter : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTCounterWriter, &CLSID_MTCounterWriter>,
	public IObjectControl,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTCounterWriter, &IID_IMTCounterWriter, &LIBID_MTPRODUCTCATALOGEXECLib>
{
public:
	CMTCounterWriter()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTCOUNTERWRITER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTCounterWriter)

BEGIN_COM_MAP(CMTCounterWriter)
	COM_INTERFACE_ENTRY(IMTCounterWriter)
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

// IMTCounterWriter
public:
	STDMETHOD(Update)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/IMTCounter* apCounter);
	STDMETHOD(Remove)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/long aDBID);
	STDMETHOD(Create)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/IMTCounter* apCounter, /*[out, retval]*/long* apDBID);
  STDMETHOD(CreateParameterMapping)(/*[in]*/IMTSessionContext* apCtx, /*[in]*/long aCounterID, /*[in]*/IMTCounterParameter* apParam);
};

#endif //__MTCOUNTERWRITER_H_
