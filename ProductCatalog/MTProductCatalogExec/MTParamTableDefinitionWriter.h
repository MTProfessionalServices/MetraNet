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

// MTParamTableDefinitionWriter.h : Declaration of the CMTParamTableDefinitionWriter

#ifndef __MTPARAMTABLEDEFINITIONWRITER_H_
#define __MTPARAMTABLEDEFINITIONWRITER_H_

#include "resource.h"       // main symbols
#include <comsvcs.h>

/////////////////////////////////////////////////////////////////////////////
// CMTParamTableDefinitionWriter
class ATL_NO_VTABLE CMTParamTableDefinitionWriter : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTParamTableDefinitionWriter, &CLSID_MTParamTableDefinitionWriter>,
	public ISupportErrorInfo,
	public IObjectControl,
	public IDispatchImpl<IMTParamTableDefinitionWriter, &IID_IMTParamTableDefinitionWriter, &LIBID_MTPRODUCTCATALOGEXECLib>
{
public:
	CMTParamTableDefinitionWriter();

DECLARE_REGISTRY_RESOURCEID(IDR_MTPARAMTABLEDEFINITIONWRITER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTParamTableDefinitionWriter)

BEGIN_COM_MAP(CMTParamTableDefinitionWriter)
	COM_INTERFACE_ENTRY(IMTParamTableDefinitionWriter)
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


// IMTParamTableDefinitionWriter
public:
	STDMETHOD(Remove)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aParamTblDefID);
	STDMETHOD(Update)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ IMTParamTableDefinition* apParamTblDef);
	STDMETHOD(Create)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ IMTParamTableDefinition* apParamTblDef, /*[out, retval]*/ long* apID);

// data
private:
	CComPtr<IObjectContext> mpObjectContext;

};

#endif //__MTPARAMTABLEDEFINITIONWRITER_H_
