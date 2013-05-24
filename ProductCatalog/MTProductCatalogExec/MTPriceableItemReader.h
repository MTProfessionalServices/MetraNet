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


#ifndef __MTPRICEABLEITEMREADER_H_
#define __MTPRICEABLEITEMREADER_H_

#include "resource.h"       // main symbols
#include <comsvcs.h>

#import <Rowset.tlb> rename ("EOF", "RowsetEOF") 

/////////////////////////////////////////////////////////////////////////////
// CMTPriceableItemReader
class ATL_NO_VTABLE CMTPriceableItemReader : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CMTPriceableItemReader, &CLSID_MTPriceableItemReader>,
	public IObjectControl,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTPriceableItemReader, &IID_IMTPriceableItemReader, &LIBID_MTPRODUCTCATALOGEXECLib>
{
public:
	CMTPriceableItemReader();

DECLARE_REGISTRY_RESOURCEID(IDR_MTPRICEABLEITEMREADER)

DECLARE_PROTECT_FINAL_CONSTRUCT()

DECLARE_NOT_AGGREGATABLE(CMTPriceableItemReader)

BEGIN_COM_MAP(CMTPriceableItemReader)
	COM_INTERFACE_ENTRY(IMTPriceableItemReader)
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

// IMTPriceableItemReader
public:
	STDMETHOD(FindInstancesOfTemplate)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/long aPITemplateID, /*[out, retval]*/IMTCollection** apInstances);
	STDMETHOD(Find)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aID, /*[out, retval]*/ IMTPriceableItem** apPrcItem);
	STDMETHOD(FindTemplateByName)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ BSTR aName, /*[out, retval]*/ IMTPriceableItem ** apPI);
	STDMETHOD(FindInstanceByName)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ BSTR aName, /*[in]*/ long aProductOfferingID, /*[out, retval]*/ IMTPriceableItem ** apPrcItem);
	STDMETHOD(FindTemplatesAsRowset)(/*[in]*/ IMTSessionContext* apCtxt, /*[in, optional]*/ VARIANT aFilter, /*[out,retval]*/ IMTSQLRowset** apRowset);
	STDMETHOD(FindInstances)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aProdOffID, /*[out, retval]*/ IMTCollection** apPrcItemInstances);
	STDMETHOD(FindInstancesAsRowset)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aProdOffID, /*[out, retval]*/ IMTSQLRowset **apRowset);
	STDMETHOD(FindPriceListMappingsAsRowset)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aPrcItemInstanceID, /*[in]*/ VARIANT_BOOL aIncludeICB, /*[out, retval]*/  IMTSQLRowset **apRowset);
	STDMETHOD(FindChildTemplates)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aPrcItemTmplID, /*[out, retval]*/ IMTCollection** apChildTemplates);
	STDMETHOD(FindChildTemplatesAsRowset)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aPrcItemTmplID, /*[out, retval]*/ IMTSQLRowset **apRowset);
	STDMETHOD(FindChildInstances)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aPrcItemInstID, /*[out, retval]*/ IMTCollection** apChildInstances);
	STDMETHOD(FindChildInstancesAsRowset)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aPrcItemInstID, /*[out, retval]*/ IMTSQLRowset **apRowset);
	STDMETHOD(FindChild)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aParentID, /*[in]*/ long aChildID, /*[out, retval]*/ IMTPriceableItem** apPrcItem);
	STDMETHOD(FindInstancesOfType)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aProdOffID, /*[in]*/ long aPITypeID, /*[out, retval]*/ IMTCollection** apPrcItemInstances);
  STDMETHOD(FindTemplateByInstanceAsRowset)(/*[in]*/ IMTSessionContext* apCtxt, /*[in]*/ long aPrcItemInstID, /*[out, retval]*/ IMTSQLRowset **apRowset);

private:
	// low level method used by Find and FindByName
	// NOTE: throws COM errors
	void PopulatePriceableItem(IMTSessionContext* apCtxt, ROWSETLib::IMTSQLRowsetPtr aRowSet, IMTPriceableItem * * apPI);

	void LoadExtendedProperties(IMTPriceableItem* apPrcItem);

// data
private:
	CComPtr<IObjectContext> mpObjectContext;

};

#endif //__MTPRICEABLEITEMREADER_H_
