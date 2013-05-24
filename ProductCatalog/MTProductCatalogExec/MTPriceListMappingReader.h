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

// MTPriceListMappingReader.h : Declaration of the CMTPriceListMappingReader

#ifndef __MTPRICELISTMAPPINGREADER_H_
#define __MTPRICELISTMAPPINGREADER_H_

#include "resource.h"       // main symbols
#include <comsvcs.h>

#import <Rowset.tlb> rename ("EOF", "RowsetEOF") 

/////////////////////////////////////////////////////////////////////////////
// CMTPriceListMappingReader
class ATL_NO_VTABLE CMTPriceListMappingReader : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTPriceListMappingReader, &CLSID_MTPriceListMappingReader>,
	public ISupportErrorInfo,
	public IObjectControl,
	public IDispatchImpl<IMTPriceListMappingReader, &IID_IMTPriceListMappingReader, &LIBID_MTPRODUCTCATALOGEXECLib>
{
public:
	CMTPriceListMappingReader();

DECLARE_REGISTRY_RESOURCEID(IDR_MTPRICELISTMAPPINGREADER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTPriceListMappingReader)

BEGIN_COM_MAP(CMTPriceListMappingReader)
	COM_INTERFACE_ENTRY(IMTPriceListMappingReader)
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

// IMTPriceListMappingReader
public:
	STDMETHOD(FindICB_ByInstance)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aPrcItemInstID,/*[in]*/ long aParamTblDefID,/*[in]*/ long id_sub,/*[out, retval]*/ IMTPriceListMapping** ppMapping);
	STDMETHOD(FindByInstance)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aPrcItemInstID, /*[in]*/ long aParamTblDefID, /*[out, retval]*/ IMTPriceListMapping** apPrcLstMap);
	STDMETHOD(GetCountOfTypeByPO)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aProductOfferingID, /*[in]*/ long aNonSharedPLID, /*[in]*/ MTPriceListMappingType aType, /*[in]*/ long *apCount);
protected:
	HRESULT PopulatePriceListMapping(IMTSessionContext* apCtxt,long,long,ROWSETLib::IMTSQLRowsetPtr,IMTPriceListMapping **);

//data
private:
	CComPtr<IObjectContext> mpObjectContext;

};

#endif //__MTPRICELISTMAPPINGREADER_H_
