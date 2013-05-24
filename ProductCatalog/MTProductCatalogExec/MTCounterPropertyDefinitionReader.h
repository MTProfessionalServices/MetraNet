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


#ifndef __MTCOUNTERPROPERTYDEFINITIONREADER_H_
#define __MTCOUNTERPROPERTYDEFINITIONREADER_H_

#include "resource.h"       // main symbols
#include <comsvcs.h>


#include <pcexecincludes.h>

#define GET_COUNTERPROPDEFS_BY_PIID		"__GET_COUNTER_PROPDEFS_BY_PIID__"
#define GET_FILTERED_COUNTERPROPDEFS	"__GET_FILTERED_COUNTER_PROPDEFS__"
#define GET_COUNTERPROPDEF						"__GET_COUNTER_PROPDEF__"
/////////////////////////////////////////////////////////////////////////////
// CMTCounterPropertyDefinitionReader
class ATL_NO_VTABLE CMTCounterPropertyDefinitionReader : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTCounterPropertyDefinitionReader, &CLSID_MTCounterPropertyDefinitionReader>,
	public ISupportErrorInfo,
	public IObjectControl,
	public IDispatchImpl<IMTCounterPropertyDefinitionReader, &IID_IMTCounterPropertyDefinitionReader, &LIBID_MTPRODUCTCATALOGEXECLib>
{
public:
	CMTCounterPropertyDefinitionReader()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTCOUNTERPROPERTYDEFINITIONREADER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTCounterPropertyDefinitionReader)

BEGIN_COM_MAP(CMTCounterPropertyDefinitionReader)
	COM_INTERFACE_ENTRY(IMTCounterPropertyDefinitionReader)
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
	STDMETHOD(FindAsRowset)(IMTSessionContext* apCtxt, VARIANT aFilter, IMTSQLRowset** apRowset);
	STDMETHOD(Find)(IMTSessionContext* apCtxt, long aDBID, IMTCounterPropertyDefinition** apRowset);
	STDMETHOD(FindByPIType)(IMTSessionContext* apCtxt, long aPITypeDBID, IMTCollection** apRowset);


	CComPtr<IObjectContext> mpObjectContext;

// IMTCounterPropertyDefinitionReader
public:
};

#endif //__MTCOUNTERPROPERTYDEFINITIONREADER_H_
