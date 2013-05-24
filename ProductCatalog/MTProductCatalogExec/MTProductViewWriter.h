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

// MTProductViewWriter.h : Declaration of the CMTProductViewWriter

#ifndef __MTPRODUCTVIEWWRITER_H_
#define __MTPRODUCTVIEWWRITER_H_

#include "resource.h"       // main symbols
#include <comsvcs.h>
#include <pcexecincludes.h>

/////////////////////////////////////////////////////////////////////////////
// CMTProductViewWriter
class ATL_NO_VTABLE CMTProductViewWriter : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTProductViewWriter, &CLSID_MTProductViewWriter>,
	public ISupportErrorInfo,
	public IObjectControl,
	public IDispatchImpl<IMTProductViewWriter, &IID_IMTProductViewWriter, &LIBID_MTPRODUCTCATALOGEXECLib>
{
public:
	CMTProductViewWriter()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTPRODUCTVIEWWRITER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTProductViewWriter)

BEGIN_COM_MAP(CMTProductViewWriter)
	COM_INTERFACE_ENTRY(IMTProductViewWriter)
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

// IMTProductViewWriter
public:
	STDMETHOD(RemoveProductViewRecords)(/*[in]*/ IMTSessionContext* apCtxt, 
																			/*[in]*/ BSTR aPVTable,
																			/*[in]*/ long aPITemplateID,
																			/*[in]*/ long aIntervalID,
																			/*[in]*/ long aViewID);

	STDMETHOD(RemoveProductViewRecordsForAccount)(/*[in]*/ IMTSessionContext* apCtxt, 
																								/*[in]*/BSTR aPVTable,
																								/*[in]*/ long aPITemplateID,
																								/*[in]*/ long aIntervalID,
																								/*[in]*/ long aViewID,
																								/*[in]*/ long aAccountID);

	STDMETHOD(RemoveProductViewRecordsForService)(/*[in]*/ IMTSessionContext* apCtxt, 
                                                /*[in]*/ BSTR aPVTable,
                                                /*[in]*/ long aPITemplateID,
                                                /*[in]*/ long aIntervalID,
                                                /*[in]*/ long aViewID,
                                                /*[in]*/ long aSvcID);

	STDMETHOD(RemoveProductViewRecordsForServiceForAccount)(/*[in]*/ IMTSessionContext* apCtxt, 
                                                          /*[in]*/BSTR aPVTable,
                                                          /*[in]*/ long aPITemplateID,
                                                          /*[in]*/ long aIntervalID,
                                                          /*[in]*/ long aViewID,
                                                          /*[in]*/ long aSvcID,
                                                          /*[in]*/ long aAccountID);
};

#endif //__MTPRODUCTVIEWWRITER_H_
