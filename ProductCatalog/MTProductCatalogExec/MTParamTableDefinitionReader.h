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


#ifndef __MTPARAMTABLEDEFINITIONREADER_H_
#define __MTPARAMTABLEDEFINITIONREADER_H_

#include "resource.h"       // main symbols
#include <comsvcs.h>

#include <pcexecincludes.h>

/////////////////////////////////////////////////////////////////////////////
// CMTParamTableDefinitionReader
class ATL_NO_VTABLE CMTParamTableDefinitionReader : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTParamTableDefinitionReader, &CLSID_MTParamTableDefinitionReader>,
	public IObjectControl,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTParamTableDefinitionReader, &IID_IMTParamTableDefinitionReader, &LIBID_MTPRODUCTCATALOGEXECLib>
{
public:
	CMTParamTableDefinitionReader()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTPARAMTABLEDEFINITIONREADER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTParamTableDefinitionReader)

BEGIN_COM_MAP(CMTParamTableDefinitionReader)
	COM_INTERFACE_ENTRY(IMTParamTableDefinitionReader)
	COM_INTERFACE_ENTRY(IObjectControl)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()

public:
// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IObjectControl
public:
	STDMETHOD(Activate)();
	STDMETHOD_(BOOL, CanBePooled)();
	STDMETHOD_(void, Deactivate)();

	CComPtr<IObjectContext> mpObjectContext;

// IMTParamTableDefinitionReader
public:
	STDMETHOD(FindAsRowset)(/*[in]*/ IMTSessionContext* apCtxt, IMTSQLRowset **apRowset);
	STDMETHOD(FindByID)(/*[in]*/ IMTSessionContext* apCtxt, long id, IMTParamTableDefinition * * table);
	STDMETHOD(FindByName)(/*[in]*/ IMTSessionContext* apCtxt, BSTR name, /*[out, retval]*/ IMTParamTableDefinition * * def);
	STDMETHOD(LoadSecondaryData)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ IMTParamTableDefinition * apParamTblDef);

private:
	void PopulatePrimaryDataByRowset(IMTSessionContext* apCtxt,
																		ROWSETLib::IMTSQLRowsetPtr rowset,
																		IMTParamTableDefinition ** apParamTblDef);

	HRESULT ReadFromFile(IMTParamTableDefinition * def);
};

#endif //__MTPARAMTABLEDEFINITIONREADER_H_
