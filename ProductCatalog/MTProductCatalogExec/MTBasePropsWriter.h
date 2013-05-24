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

// MTBasePropsWriter.h : Declaration of the CMTBasePropsWriter

#ifndef __MTBASEPROPSWRITER_H_
#define __MTBASEPROPSWRITER_H_

#include "resource.h"       // main symbols
#include <comsvcs.h>

/////////////////////////////////////////////////////////////////////////////
// CMTBasePropsWriter
class ATL_NO_VTABLE CMTBasePropsWriter : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTBasePropsWriter, &CLSID_MTBasePropsWriter>,
	public ISupportErrorInfo,
	public IObjectControl,
	public IDispatchImpl<IMTBasePropsWriter, &IID_IMTBasePropsWriter, &LIBID_MTPRODUCTCATALOGEXECLib>
{
public:
	CMTBasePropsWriter()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTBASEPROPSWRITER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTBasePropsWriter)

BEGIN_COM_MAP(CMTBasePropsWriter)
	COM_INTERFACE_ENTRY(IMTBasePropsWriter)
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

// IMTBasePropsWriter
public:
	STDMETHOD(Create)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aKind, /*[in]*/ BSTR aName, /*[in]*/ BSTR aDescription, /*[out, retval]*/ long* apID);
	STDMETHOD(CreateWithDisplayName)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aKind, /*[in]*/ BSTR aName, /*[in]*/ BSTR aDescription, /*[in]*/ BSTR aDisplayName, /*[out, retval]*/ long* apID);
	STDMETHOD(Update)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ BSTR aName, /*[in]*/ BSTR aDescription, /*[in]*/ long apID);
	STDMETHOD(UpdateWithDisplayName)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ BSTR aName, /*[in]*/ BSTR aDescription, /*[in]*/ BSTR aDisplayName, /*[in]*/ long apID);
	STDMETHOD(Delete)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long apID);
};

#endif //__MTBASEPROPSWRITER_H_
