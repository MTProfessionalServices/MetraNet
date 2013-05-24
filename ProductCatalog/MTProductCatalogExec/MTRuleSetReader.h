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


#ifndef __MTRULESETREADER_H_
#define __MTRULESETREADER_H_

#include "resource.h"       // main symbols
#include <comsvcs.h>

/////////////////////////////////////////////////////////////////////////////
// CMTRuleSetReader
class ATL_NO_VTABLE CMTRuleSetReader : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTRuleSetReader, &CLSID_MTRuleSetReader>,
	public ISupportErrorInfo,
	public IObjectControl,
	public IDispatchImpl<IMTRuleSetReader, &IID_IMTRuleSetReader, &LIBID_MTPRODUCTCATALOGEXECLib>
{
public:
	CMTRuleSetReader()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTRULESETREADER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTRuleSetReader)

BEGIN_COM_MAP(CMTRuleSetReader)
	COM_INTERFACE_ENTRY(IMTRuleSetReader)
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

// IMTRuleSetReader
public:
	STDMETHOD(CreateRuleSet)(/*[in]*/ IMTSessionContext* apCtxt, /*[out, retval]*/ IMTRuleSet * * apRuleset);
	STDMETHOD(FindWithID)(/*[in]*/ IMTSessionContext* apCtxt, 
												long aRateSchedID,
												IMTParamTableDefinition * apParamTable,
												IMTRuleSet * apRuleSet,
                        /*[in, optional]*/ VARIANT aRefDate);
};

#endif //__MTRULESETREADER_H_
