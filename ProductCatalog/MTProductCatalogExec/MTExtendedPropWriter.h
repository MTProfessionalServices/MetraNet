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

#ifndef __MTEXTENDEDPROPWRITER_H_
#define __MTEXTENDEDPROPWRITER_H_

#include "resource.h"       // main symbols
#include <comsvcs.h>

/////////////////////////////////////////////////////////////////////////////
// CMTExtendedPropWriter
class ATL_NO_VTABLE CMTExtendedPropWriter : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTExtendedPropWriter, &CLSID_MTExtendedPropWriter>,
	public ISupportErrorInfo,
	public IObjectControl,
	public IDispatchImpl<IMTExtendedPropWriter, &IID_IMTExtendedPropWriter, &LIBID_MTPRODUCTCATALOGEXECLib>
{
public:
	CMTExtendedPropWriter()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTEXTENDEDPROPWRITER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTExtendedPropWriter)

BEGIN_COM_MAP(CMTExtendedPropWriter)
	COM_INTERFACE_ENTRY(IMTExtendedPropWriter)
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

	CComPtr<IObjectContext> m_spObjectContext;

// IMTExtendedPropWriter
public:
	STDMETHOD(RemoveFromExtendedPropertyTable)(/*[in]*/ IMTSessionContext* apCtxt, BSTR aTableName, long aID);
	STDMETHOD(UpsertExtendedPropertyTable)(/*[in]*/ IMTSessionContext* apCtxt, BSTR tableName,BSTR aUpdateList,BSTR aInsertList,BSTR aColumnList,long aID);
	STDMETHOD(PropagateProperties)(/*[in]*/ IMTSessionContext* apCtxt, BSTR tableName, BSTR aUpdateList, BSTR aInsertList, BSTR aColumnList, long aTemplateID);
};

#endif //__MTEXTENDEDPROPWRITER_H_
