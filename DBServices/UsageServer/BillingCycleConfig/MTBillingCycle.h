/**************************************************************************
* Copyright 1997-2000 by MetraTech
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
* Created by: Travis Gebhardt
* $Header$
* 
***************************************************************************/

#ifndef __MTBILLINGCYCLE_H_
#define __MTBILLINGCYCLE_H_

#include "resource.h"       // main symbols
#include <comdef.h>

//STL includes
#include <vector>

typedef std::vector<CComVariant> TimePointColl;

/////////////////////////////////////////////////////////////////////////////
// CMTBillingCycle
class ATL_NO_VTABLE CMTBillingCycle : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTBillingCycle, &CLSID_MTBillingCycle>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTBillingCycle, &IID_IMTBillingCycle, &LIBID_BILLINGCYCLECONFIGLib>
{
public:
	CMTBillingCycle()
	{
	}
	~CMTBillingCycle()
	{
		mCollection.clear();
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTBILLINGCYCLE)

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTBillingCycle)
	COM_INTERFACE_ENTRY(IMTBillingCycle)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTBillingCycle
public:
	STDMETHOD(get_Item)(long aIndex, /*[out, retval]*/ VARIANT *pVal);
	STDMETHOD(get_Count)(/*[out, retval]*/ long *pVal);
	STDMETHOD(get__NewEnum)(/*[out, retval]*/ LPUNKNOWN *pVal);
	STDMETHOD(Add)(/*[in]*/ IMTTimePoint* apTimePoint);

	STDMETHOD(get_CycleType)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_CycleType)(/*[in]*/ BSTR newVal);

	STDMETHOD(CalculateClosestInterval)(/*[in]*/  IMTTimePoint* apTimePoint,
																			/*[in]*/  VARIANT arToday,
																			/*[out]*/ VARIANT* apStartDate,
																			/*[out]*/ VARIANT* apEndDate);
private:
	_bstr_t mCycleType;
	TimePointColl mCollection;
};

#endif //__MTBILLINGCYCLE_H_
