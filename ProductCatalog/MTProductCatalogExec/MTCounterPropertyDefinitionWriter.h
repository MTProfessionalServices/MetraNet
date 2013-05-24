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
* $Header: 
* 
***************************************************************************/


#ifndef __MTCounterPropertyDefinitionWriter_H_
#define __MTCounterPropertyDefinitionWriter_H_

#include "resource.h"       // main symbols
#include <comsvcs.h>


#include <pcexecincludes.h>

#define SP_CREATE_COUNTER_PROPDEF "__CREATE_COUNTER_PROPDEF_SP__"
#define SP_UPDATE_COUNTER_PROPDEF "__UPDATE_COUNTER_PROPDEF_SP__"
#define SP_REMOVE_COUNTER_PROPDEF "__REMOVE_COUNTER_PROPDEF_SP__"

/////////////////////////////////////////////////////////////////////////////
// CMTCounterPropertyDefinitionWriter
class ATL_NO_VTABLE CMTCounterPropertyDefinitionWriter : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTCounterPropertyDefinitionWriter, &CLSID_MTCounterPropertyDefinitionWriter>,
	public ISupportErrorInfo,
	public IObjectControl,
	public IDispatchImpl<IMTCounterPropertyDefinitionWriter, &IID_IMTCounterPropertyDefinitionWriter, &LIBID_MTPRODUCTCATALOGEXECLib>
{
public:
	CMTCounterPropertyDefinitionWriter()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTCOUNTERPROPERTYDEFINITIONWRITER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTCounterPropertyDefinitionWriter)

BEGIN_COM_MAP(CMTCounterPropertyDefinitionWriter)
	COM_INTERFACE_ENTRY(IMTCounterPropertyDefinitionWriter)
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

// IMTCounterPropertyDefinitionWriter
public:
	STDMETHOD(Create)(IMTSessionContext* apCtxt, IMTCounterPropertyDefinition* apCPD, long* aDBID);
	STDMETHOD(Remove)(IMTSessionContext* apCtxt, /*[in]*/long aDBID);
	STDMETHOD(Update)(IMTSessionContext* apCtxt, /*[in]*/IMTCounterPropertyDefinition* apCPD);
};
#endif 
