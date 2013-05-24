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

#ifndef __MTPCACCOUNT_H_
#define __MTPCACCOUNT_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CMTPCAccount
class ATL_NO_VTABLE CMTPCAccount : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTPCAccount, &CLSID_MTPCAccount>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTPCAccount, &IID_IMTPCAccount, &LIBID_MTPRODUCTCATALOGLib>,
	public CMTPCBase
{
	DEFINE_MT_PCBASE_METHODS

public:
	CMTPCAccount() : mAccountID(0)
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTPCACCOUNT)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTPCAccount)
	COM_INTERFACE_ENTRY(IMTPCAccount)
	COM_INTERFACE_ENTRY(IMTPCBase)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

	HRESULT FinalConstruct()
	{
		return CoCreateFreeThreadedMarshaler(
			GetControllingUnknown(), &m_pUnkMarshaler.p);
	}

	void FinalRelease()
	{
		m_pUnkMarshaler.Release();
	}

	CComPtr<IUnknown> m_pUnkMarshaler;

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTPCAccount
public:
	STDMETHOD(GetGroupSubscriptionsAsRowset)(/*[out,retval]*/ IMTRowSet** ppRowset);
	STDMETHOD(GetSubscriptionsAsRowset)(/*[out, retval]*/ IMTRowSet** ppRowset);
	STDMETHOD(GetGroupSubscriptions)(/*[out,retval]*/ IMTCollection** ppColl);
	STDMETHOD(GetSubscriptions)(/*[out, retval]*/ IMTCollection** ppColl);
	STDMETHOD(GetSubscription)(/*[in]*/ long sub_id,/*[out,retval]*/ IMTSubscriptionBase** ppSub);
	STDMETHOD(get_AccountID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_AccountID)(/*[in]*/ long newVal);
	STDMETHOD(GetParamTablesAsRowset)(/*[out, retval]*/ IMTRowSet** ppRowset);
	STDMETHOD(GetSubscriptionByPriceableItem)(/*[in]*/ long aPrcItemID,/*[out, retval]*/ IMTSubscription** ppSub);
	STDMETHOD(GetSubscriptionsByPriceableItem)(/*[in]*/ long aPrcItemID,/*[out, retval]*/ IMTCollection** ppSubs);
	STDMETHOD(GetSubscriptionByProductOffering)(/*[in]*/ long prodOffID,/*[out, retval]*/ IMTSubscription** ppSub);
	STDMETHOD(GetSubscriptionsByProductOffering)(/*[in]*/ long prodOffID,/*[out, retval]*/ IMTCollection** ppSubs);
	STDMETHOD(GetPossiblePriceLists)(/*[in]*/ long aPrcItemID,/*[in]*/ long paramTblID,/*[out, retval]*/ IMTCollection** ppCol);
	STDMETHOD(GetInactiveSubscriptionsAsRowset)(/*[out, reval]*/ IMTRowSet** ppRowset);
	STDMETHOD(GetInactivateSubscriptions)(/*[out, retval]*/ IMTCollection** ppCol);
	STDMETHOD(GetActiveSubscriptionsAsRowset)(/*[out, retval]*/ IMTRowSet** ppRowset);
	STDMETHOD(GetActiveSubscriptions)(/*[out, retval]*/ IMTCollection** ppCol);
	STDMETHOD(GetSubscribableProductOfferings)(/*[in,optional]*/ VARIANT aRefDate, /*[out, retval]*/ IMTCollection** ppCol);
	STDMETHOD(FindSubscribableProductOfferingsAsRowset)(/*[in, optional]*/ VARIANT pFilter, /*[in,optional]*/ VARIANT aRefDate, /*[out, retval]*/ IMTRowSet** ppRowset);
	STDMETHOD(RemoveSubscription)(/*[in]*/ long aSubscrID);
	STDMETHOD(Unsubscribe)(/*[in]*/ long aSubscrID,/*[in]*/ VARIANT aEndDate,MTPCDateType aEndType,VARIANT_BOOL* pDateModified);
	STDMETHOD(Subscribe)(/*[in]*/ long aprodOffID, /*[in]*/ IMTPCTimeSpan* pEffDate,VARIANT *apDateModified,/*[out,retval]*/ IMTSubscription** ppSub);
	STDMETHOD(GetDefaultPriceList)(/*[out, retval]*/ IMTPriceList* *pVal);
	STDMETHOD(SetDefaultPriceList)(/*[in]*/ IMTPriceList* newVal);
	STDMETHOD(CanChangeBillingCycles)(/*[out, retval]*/ VARIANT_BOOL * pCanChange);
	STDMETHOD(GetNextBillingIntervalEndDate)(/*[in]*/ DATE datecheck, /*[out, retval]*/ VARIANT *pVal);
	STDMETHOD(CreateSubscription)(/*[in]*/ long aprodOffID, /*[in]*/ IMTPCTimeSpan* pEffDate,/*[out,retval]*/ IMTSubscription** ppSub);
protected:
	long mAccountID;
};

#endif //__MTPCACCOUNT_H_
