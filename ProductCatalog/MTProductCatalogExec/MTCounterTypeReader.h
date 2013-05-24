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


#ifndef __MTCOUNTERTYPEREADER_H_
#define __MTCOUNTERTYPEREADER_H_

#include "resource.h"       // main symbols
#include <comsvcs.h>
#include <GenericCollection.h>




#define GET_ALL_TYPES				"__GET_ALL_COUNTER_TYPES__"
#define GET_TYPE						"__GET_COUNTER_TYPE__"
#define GET_TYPE_BY_NAME		"__GET_COUNTER_TYPE_BY_NAME__"


/////////////////////////////////////////////////////////////////////////////
// CMTCounterTypeReader
class ATL_NO_VTABLE CMTCounterTypeReader : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTCounterTypeReader, &CLSID_MTCounterTypeReader>,
	public ISupportErrorInfo,
	public IObjectControl,
	public IDispatchImpl<IMTCounterTypeReader, &IID_IMTCounterTypeReader, &LIBID_MTPRODUCTCATALOGEXECLib>
{
public:
	CMTCounterTypeReader()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTCOUNTERTYPEREADER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTCounterTypeReader)

BEGIN_COM_MAP(CMTCounterTypeReader)
	COM_INTERFACE_ENTRY(IMTCounterTypeReader)
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

// IMTCounterTypeReader
public:
	STDMETHOD(FindByName)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/BSTR aName, /*[out, retval]*/IMTCounterType** apType);
	STDMETHOD(Find)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/long aDBID, /*[out, retval]*/IMTCounterType** apType);
	STDMETHOD(GetAllTypes)(/*[in]*/ IMTSessionContext* apCtxt, /*[out, retval]*/IMTCollection** apTypes);
};

#endif //__MTCOUNTERTYPEREADER_H_
