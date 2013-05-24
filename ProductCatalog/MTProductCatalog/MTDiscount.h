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

#ifndef __MTDISCOUNT_H_
#define __MTDISCOUNT_H_

#include "resource.h"       // main symbols
#include "MTPriceableItem.h"

#include <map>
#include <list>

/////////////////////////////////////////////////////////////////////////////
// CMTDiscount
class ATL_NO_VTABLE CMTDiscount : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTDiscount, &CLSID_MTDiscount>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTDiscount, &IID_IMTDiscount, &LIBID_MTPRODUCTCATALOGLib>,
	public CMTPriceableItem
{
public:
	CMTDiscount()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTDISCOUNT)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTDiscount)
	COM_INTERFACE_ENTRY(IMTDiscount)
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
	virtual void CheckConfigurationForDerived(IMTCollection* apErrors);

// IMTDiscount
public:
  bool IsValidCounterPropertyDefinitionID(long lCounterPropertyDefinitionID);
	STDMETHOD(get_RemovedCounters)(/*[out, retval]*/ IMTCollection* *pVal);
	STDMETHOD(RemoveCounter)(long lCounterPropertyDefinitionID);
	STDMETHOD(GetCountersAsRowset)(/*[out, retval]*/IMTRowSet** apRowset);
	STDMETHOD(GetCounter)(/*[in]*/ long lCounterPropertyDefinitionID, /*[out, retval]*/ IMTCounter** ppCounter);
	STDMETHOD(SetCounter)(/*[in]*/ long lCounterPropertyDefinitionID, /*[in]*/ IMTCounter* pCounter);
	STDMETHOD(get_Cycle)(/*[out, retval]*/ IMTPCCycle* *pVal);
	STDMETHOD(get_DistributionCPDID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_DistributionCPDID)(/*[in]*/ long newVal);
	STDMETHOD(GetDistributionCounter)(/*[out, retval]*/ IMTCounter** apCounter);
	STDMETHOD(SetDistributionCounter)(/*[in]*/ IMTCounter* apCounter);

//CMTPCBase override
	virtual void OnSetSessionContext(IMTSessionContext* apSessionContext);

private:

	typedef std::map<long, MTPRODUCTCATALOGLib::IMTCounterPtr> mapCounterPropertyDefIDtoCounter;
	typedef std::list<long> listCountersID;

	// map of counters, associated with the discount
	mapCounterPropertyDefIDtoCounter m_mapCounters;
	// list of counters, that WERE associated with the discount, but were updated,
	// and have to be removed on 'Save'
	listCountersID m_listOldCounters;
};

#endif //__MTDISCOUNT_H_
