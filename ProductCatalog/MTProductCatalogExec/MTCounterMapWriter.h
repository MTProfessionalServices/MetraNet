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

// MTCounterMapWriter.h : Declaration of the CMTCounterMapWriter

#ifndef __MTCOUNTERMAPWRITER_H_
#define __MTCOUNTERMAPWRITER_H_

#include "resource.h"       // main symbols
#include <comsvcs.h>

#include <pcexecincludes.h>


#define ADD_COUNTER_MAPPING			"__ADD_COUNTER_MAPPING__"
#define REMOVE_COUNTER_MAPPING	"__REMOVE_COUNTER_MAPPING__"

/////////////////////////////////////////////////////////////////////////////
// CMTCounterMapWriter
class ATL_NO_VTABLE CMTCounterMapWriter : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTCounterMapWriter, &CLSID_MTCounterMapWriter>,
	public ISupportErrorInfo,
	public IObjectControl,
	public IDispatchImpl<IMTCounterMapWriter, &IID_IMTCounterMapWriter, &LIBID_MTPRODUCTCATALOGEXECLib>
{
public:
	CMTCounterMapWriter()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTCOUNTERMAPWRITER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTCounterMapWriter)

BEGIN_COM_MAP(CMTCounterMapWriter)
	COM_INTERFACE_ENTRY(IMTCounterMapWriter)
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

// IMTCounterMapWriter
public:
	STDMETHOD(RemoveMappingByPIDBID)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aPIDBID);
	STDMETHOD(AddMapping)(/*[in]*/ IMTSessionContext* apCtxt, long aCounterDBID, long aPIDBID, long aCPDDBID);
	STDMETHOD(RemoveMapping)(/*[in]*/ IMTSessionContext* apCtxt, long aPIDBID, long aCounterDBID);

};

#endif //__MTCOUNTERMAPWRITER_H_
