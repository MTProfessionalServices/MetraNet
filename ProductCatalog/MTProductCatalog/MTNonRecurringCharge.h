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

#ifndef __MTNONRECURRINGCHARGE_H_
#define __MTNONRECURRINGCHARGE_H_

#include "resource.h"       // main symbols
#include "MTPriceableItem.h"

/////////////////////////////////////////////////////////////////////////////
// CMTNonRecurringCharge
class ATL_NO_VTABLE CMTNonRecurringCharge : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTNonRecurringCharge, &CLSID_MTNonRecurringCharge>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTNonRecurringCharge, &IID_IMTNonRecurringCharge, &LIBID_MTPRODUCTCATALOGLib>,
	public CMTPriceableItem
{
public:
	CMTNonRecurringCharge()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTNONRECURRINGCHARGE)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTNonRecurringCharge)
	COM_INTERFACE_ENTRY(IMTNonRecurringCharge)
	COM_INTERFACE_ENTRY(IMTPriceableItem)
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

// IMTPriceableItem
public:
	DEFINE_MT_PRICABLE_ITEM_METHODS
	virtual void CopyNonBaseMembersTo(IMTPriceableItem* apTarget);

// IMTNonRecurringCharge
public:
	STDMETHOD(get_NonRecurringChargeEvent)(/*[out, retval]*/ MTNonRecurringEventType *pVal);
	STDMETHOD(put_NonRecurringChargeEvent)(/*[in]*/ MTNonRecurringEventType newVal);
};

#endif //__MTNONRECURRINGCHARGE_H_
