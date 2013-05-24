/**************************************************************************
* Copyright 1997-2002 by MetraTech
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
***************************************************************************/

#ifndef __MTPAYMENTMGR_H_
#define __MTPAYMENTMGR_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CMTPaymentMgr
class ATL_NO_VTABLE CMTPaymentMgr : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTPaymentMgr, &CLSID_MTPaymentMgr>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTPaymentMgr, &IID_IMTPaymentMgr, &LIBID_MTYAACLib>
{
public:
	CMTPaymentMgr()
	{
		mbBillable = false;
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTPAYMENTMGR)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTPaymentMgr)
	COM_INTERFACE_ENTRY(IMTPaymentMgr)
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

// IMTPaymentMgr
public:
	STDMETHOD(BitemporalPaymentHistory)(/*[out,retval]*/ IMTRowSet** ppRowset);
	STDMETHOD(PaymentHistory)(/*[out,retval]*/ IMTRowSet** ppRowset);
	STDMETHOD(AllPayees)(/*[out, retval]*/ IMTPaymentSlice** ppSlice);
	STDMETHOD(SetAccountAsNonBillable)();
	STDMETHOD(SetAccountAsBillable)();
	STDMETHOD(get_AccountIsBillable)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(PaymentSliceAtSystemDate)(/*[in]*/ DATE RefDate,/*[in]*/ DATE SystemDate,/*[out, retval]*/ IMTPaymentSlice** ppSlice);
	STDMETHOD(PaymentSlice)(/*[in]*/ DATE RefDate,/*[out, retval]*/ IMTPaymentSlice** ppSlice);
	STDMETHOD(PaymentSliceNow)(/*[out, retval]*/ IMTPaymentSlice** ppSlice);
	STDMETHOD(PayForAccountBatch)(IMTCollectionEx *pCol,
	IMTProgress* pProgress,
	DATE StartDate,
	VARIANT EndDate,
	IMTRowSet** ppRowset);
	STDMETHOD(ChangePaymentEffectiveDate)(/*[in]*/ long aAccount,/*[in]*/ DATE OldStartDate,/*[in]*/ DATE OldEndDate,/*[in]*/ DATE StartDate,/*[in]*/ DATE EndDate);
	STDMETHOD(PayForAccount)(/*[in]*/ long aAccount,/*[in]*/ DATE StartDate,/*[in,optional]*/ VARIANT EndDate);
	STDMETHOD(Initialize)(/*[in]*/ IMTSessionContext* pCTX, /*[in]*/ VARIANT_BOOL aBillable,/*[in]*/ IMTYAAC* pPayer);
protected:
	void CheckBillableAuth();
  void PaymentAuthChecks(DATE PaymentStartDate,GENERICCOLLECTIONLib::IMTCollectionExPtr pCol);

protected:
	MTAUTHLib::IMTSessionContextPtr mCTX;
	MTYAACLib::IMTYAACPtr mPayerYAAC;
	bool mbBillable;
  MTAUTHLib::IMTSecurityPtr mSecPtr;

};

#endif //__MTPAYMENTMGR_H_
