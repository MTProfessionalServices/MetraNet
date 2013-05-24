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


#ifndef __MTRATESCHEDULEREADER_H_
#define __MTRATESCHEDULEREADER_H_

#include "resource.h"       // main symbols
#include <comsvcs.h>

/////////////////////////////////////////////////////////////////////////////
// CMTRateScheduleReader
class ATL_NO_VTABLE CMTRateScheduleReader : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTRateScheduleReader, &CLSID_MTRateScheduleReader>,
	public ISupportErrorInfo,
	public IObjectControl,
	public IDispatchImpl<IMTRateScheduleReader, &IID_IMTRateScheduleReader, &LIBID_MTPRODUCTCATALOGEXECLib>
{
public:
	CMTRateScheduleReader()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTRATESCHEDULEREADER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTRateScheduleReader)

BEGIN_COM_MAP(CMTRateScheduleReader)
	COM_INTERFACE_ENTRY(IMTRateScheduleReader)
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

// IMTRateScheduleReader
public:
	STDMETHOD(FindForParamTablePriceableItemTypeAsRowset)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aParamTblDefID, /*[in]*/ long aPriceableItemTypeID, /*[in]*/ VARIANT_BOOL aIncludeICB, /*[out, retval]*/ IMTSQLRowset** apRowset);
	STDMETHOD(FindForParamTablePriceListAsRowset)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aParamTblDefID, /*[in]*/ long aPrcListID, /*[in]*/ long aPITemplate, /*[out, retval]*/ IMTSQLRowset** apRowset);
	STDMETHOD(FindForParamTableAsRowset)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aParamTblDefID, /*[in]*/ VARIANT_BOOL aIncludeICB, /*[in, optional]*/ VARIANT_BOOL aIncludeHidden, /*[in, optional]*/ VARIANT aFilter, /*[out, retval]*/ IMTSQLRowset** apRowset);
	STDMETHOD(FindForPriceListMappingAsRowset)(/*[in]*/ IMTSessionContext* apCtxt, IMTPriceListMapping * apMapping, /*[in, optional]*/VARIANT aFilter, /*[out, retval]*/IMTSQLRowset** apRowset);
	STDMETHOD(Find)(/*[in]*/ IMTSessionContext* apCtxt, long ID, /*[out, retval]*/ IMTRateSchedule * * apSchedule);
	STDMETHOD(FindAsRowset)(/*[in]*/ IMTSessionContext* apCtxt, /*[in, optional]*/ VARIANT aFilter, /*[out, retval]*/ IMTSQLRowset** apRowset);
	STDMETHOD(GetCountByPriceList)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aPriceListID, /*[out, retval]*/ long *pCount);
};

#endif //__MTRATESCHEDULEREADER_H_
