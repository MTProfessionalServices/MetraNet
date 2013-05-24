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

#ifndef __MTPRICELIST_H_
#define __MTPRICELIST_H_

#include "resource.h"       // main symbols

#include "PropertiesBase.h"

/////////////////////////////////////////////////////////////////////////////
// CMTPriceList
class ATL_NO_VTABLE CMTPriceList : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTPriceList, &CLSID_MTPriceList>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTPriceList, &IID_IMTPriceList, &LIBID_MTPRODUCTCATALOGLib>,
	public CMTPCBase,
	public PropertiesBase
{
public:
	CMTPriceList()
	{
		m_pUnkMarshaler = NULL;
	}

DEFINE_MT_PCBASE_METHODS
DEFINE_MT_PROPERTIES_BASE_METHODS

DECLARE_REGISTRY_RESOURCEID(IDR_MTPRICELIST)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTPriceList)
	COM_INTERFACE_ENTRY(IMTPriceList)
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

// IMTPriceList
public:
	STDMETHOD(GetOwnerProductOffering)(/*[out, retval]*/ IMTProductOffering ** pVal);
	STDMETHOD(GetRateScheduleCount)(/*[out, retval]*/ long *pVal);
	STDMETHOD(get_Type)(/*[out, retval]*/ MTPriceListType *pVal);
	STDMETHOD(put_Type)(/*[in]*/ MTPriceListType newVal);
	STDMETHOD(get_Shareable)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_Shareable)(/*[in]*/ VARIANT_BOOL newVal);
	STDMETHOD(Save)();
	STDMETHOD(get_CurrencyCode)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_CurrencyCode)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Description)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Description)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Name)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Name)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_ID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_ID)(/*[in]*/ long newVal);
};

#endif //__MTPRICELIST_H_
