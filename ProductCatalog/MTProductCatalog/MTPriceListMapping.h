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

#ifndef __MTPRICELISTMAPPING_H_
#define __MTPRICELISTMAPPING_H_

#include "resource.h"       // main symbols

#include "PropertiesBase.h"

/////////////////////////////////////////////////////////////////////////////
// CMTPriceListMapping
class ATL_NO_VTABLE CMTPriceListMapping : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTPriceListMapping, &CLSID_MTPriceListMapping>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTPriceListMapping, &IID_IMTPriceListMapping, &LIBID_MTPRODUCTCATALOGLib>,
	public CMTPCBase,
	public PropertiesBase
{
public:
	CMTPriceListMapping()
	{
		m_pUnkMarshaler = NULL;
	}


DEFINE_MT_PCBASE_METHODS
DEFINE_MT_PROPERTIES_BASE_METHODS

DECLARE_REGISTRY_RESOURCEID(IDR_MTPRICELISTMAPPING)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTPriceListMapping)
	COM_INTERFACE_ENTRY(IMTPriceListMapping)
	COM_INTERFACE_ENTRY(IMTPCBase)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

	HRESULT FinalConstruct();

	void FinalRelease()
	{
		m_pUnkMarshaler.Release();
	}

	CComPtr<IUnknown> m_pUnkMarshaler;

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTPriceListMapping
public:
	STDMETHOD(get_MappingType)(/*[out, retval]*/ MTPriceListMappingType *pVal);
	STDMETHOD(put_MappingType)(/*[in]*/ MTPriceListMappingType newVal);
	STDMETHOD(Save)();
	STDMETHOD(CreateRateSchedule)(/*[out, retval]*/ IMTRateSchedule * * apSchedule);
	STDMETHOD(FindRateSchedulesAsRowset)(/*[in, optional]*/VARIANT aFilter, /*[out, retval]*/IMTRowSet** apRowset);
	STDMETHOD(get_CanICB)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_CanICB)(/*[in]*/ VARIANT_BOOL newVal);
	STDMETHOD(GetPriceList)(/*[out, retval]*/ IMTPriceList * *pVal);
	STDMETHOD(GetParameterTable)(/*[out, retval]*/ IMTParamTableDefinition * *pVal);
	STDMETHOD(GetPriceableItem)(/*[out, retval]*/ IMTPriceableItem * *pVal);
	STDMETHOD(get_PriceListID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_PriceListID)(/*[in]*/ long newVal);
	STDMETHOD(get_ParamTableDefinitionID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_ParamTableDefinitionID)(/*[in]*/ long newVal);
	STDMETHOD(get_PriceableItemID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_PriceableItemID)(/*[in]*/ long newVal);
};

#endif //__MTPRICELISTMAPPING_H_
