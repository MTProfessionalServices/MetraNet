/**************************************************************************
* Copyright 1997-2002 by MetraTech
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
***************************************************************************/

#ifndef __MTGENDBREADER_H_
#define __MTGENDBREADER_H_

#include <StdAfx.h>
#include "resource.h"       // main symbols
#include <mtx.h>

/////////////////////////////////////////////////////////////////////////////
// CMTGenDBReader
class ATL_NO_VTABLE CMTGenDBReader : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTGenDBReader, &CLSID_MTGenDBReader>,
	public ISupportErrorInfo,
	public IObjectControl,
	public IDispatchImpl<IMTGenDBReader, &IID_IMTGenDBReader, &LIBID_MTYAACEXECLib>
{
public:
	CMTGenDBReader()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTGENDBREADER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTGenDBReader)

BEGIN_COM_MAP(CMTGenDBReader)
	COM_INTERFACE_ENTRY(IMTGenDBReader)
	COM_INTERFACE_ENTRY(IObjectControl)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IObjectControl
public:
	STDMETHOD(Activate)();
	STDMETHOD_(BOOL, CanBePooled)();
	STDMETHOD_(void, Deactivate)();

	CComPtr<IObjectContext> m_spObjectContext;

// IMTGenDBReader
public:
	STDMETHOD(ExecuteStatement)(/*[in]*/ BSTR aQuery,VARIANT aQueryDir,/*[out, retval]*/ IMTSQLRowset** ppRowset);
};

#endif //__MTGENDBREADER_H_
