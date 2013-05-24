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

// MTCounterMapReader.h : Declaration of the CMTCounterMapReader

#ifndef __MTCOUNTERMAPREADER_H_
#define __MTCOUNTERMAPREADER_H_

#include "resource.h"       // main symbols
#include <comsvcs.h>


#include <pcexecincludes.h>

#define  GET_COUNTER_MAPPING "__GET_COUNTER_MAPPING_BY_PIID__"
#define  GET_EXTENDED_COUNTER_MAPPING "__GET_COUNTER_EXTENDED_MAPPING__"
/////////////////////////////////////////////////////////////////////////////
// CMTCounterMapReader
class ATL_NO_VTABLE CMTCounterMapReader : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTCounterMapReader, &CLSID_MTCounterMapReader>,
	public ISupportErrorInfo,
	public IObjectControl,
	public IDispatchImpl<IMTCounterMapReader, &IID_IMTCounterMapReader, &LIBID_MTPRODUCTCATALOGEXECLib>
{
public:
	CMTCounterMapReader()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTCOUNTERMAPREADER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTCounterMapReader)

BEGIN_COM_MAP(CMTCounterMapReader)
	COM_INTERFACE_ENTRY(IMTCounterMapReader)
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

// IMTCounterMapReader
public:
	STDMETHOD(GetPIMappingsAsRowset)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/long aPIDBID, /*[out, retval]*/IMTSQLRowset** apRowset);
	STDMETHOD(GetExtendedPIMappingsAsRowset)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/long aPIDBID,/*[in]*/long aPITypeDBID,/*[out, retval]*/IMTSQLRowset** apRowset);
};

#endif //__MTCOUNTERMAPREADER_H_
