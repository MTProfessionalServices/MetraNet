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


#ifndef __MTPRICEABLEITEMTYPEREADER_H_
#define __MTPRICEABLEITEMTYPEREADER_H_

#include "resource.h"       // main symbols
#include <comsvcs.h>

#import <Rowset.tlb> rename ("EOF", "RowsetEOF") 

/////////////////////////////////////////////////////////////////////////////
// CMTPriceableItemTypeReader
class ATL_NO_VTABLE CMTPriceableItemTypeReader : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTPriceableItemTypeReader, &CLSID_MTPriceableItemTypeReader>,
	public ISupportErrorInfo,
	public IObjectControl,
	public IDispatchImpl<IMTPriceableItemTypeReader, &IID_IMTPriceableItemTypeReader, &LIBID_MTPRODUCTCATALOGEXECLib>
{
public:
	CMTPriceableItemTypeReader();

DECLARE_REGISTRY_RESOURCEID(IDR_MTPRICEABLEITEMTYPEREADER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTPriceableItemTypeReader)

BEGIN_COM_MAP(CMTPriceableItemTypeReader)
	COM_INTERFACE_ENTRY(IMTPriceableItemTypeReader)
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

// IMTPriceableItemTypeReader
public:
	STDMETHOD(FindCharges)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aPrcItemTypeID, /*[out, retval]*/ IMTCollection** apCharges);
	STDMETHOD(FindByName)(/*[in]*/ IMTSessionContext* apCtxt, BSTR aName, IMTPriceableItemType **apType);
	STDMETHOD(FindTemplatesByKind)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/MTPCEntityType aKind, /*[out, retval]*/ IMTCollection** apTemplates);
	STDMETHOD(FindInstancesByKind)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/MTPCEntityType aKind, /*[out, retval]*/ IMTCollection** apInstances);
	STDMETHOD(FindTemplates)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/long aPITypeDBID, /*[out, retval]*/IMTCollection** apColl);
	STDMETHOD(FindParamTableDefinitionsAsRowset)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aPrcItemTypeID, /*[out, retval]*/ IMTSQLRowset** apRowset);
	STDMETHOD(Find)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aID, /*[out, retval]*/ IMTPriceableItemType** apType);
	STDMETHOD(FindByFilter)(/*[in]*/ IMTSessionContext* apCtxt, /*[in, optional]*/ VARIANT aFilter, /*[out, retval]*/ IMTCollection **apColl);
	STDMETHOD(FindParamTableDefinitions)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aID, /*[out, retval]*/ IMTCollection** apParamTblDefs);
	STDMETHOD(FindChildren)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aPrcItemTypeID, /*[out, retval]*/ IMTCollection** apChildTypes);

protected: // internal methods
	void PopulateByRowset(IMTSessionContext* apCtxt, ROWSETLib::IMTSQLRowsetPtr pRowset,IMTPriceableItemType** apType,long aID = 0);

// data
private:
	CComPtr<IObjectContext> mpObjectContext;
	
};

#endif //__MTPRICEABLEITEMTYPEREADER_H_
