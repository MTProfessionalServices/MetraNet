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

#ifndef __MTUSAGECHARGE_H_
#define __MTUSAGECHARGE_H_

#include "resource.h"       // main symbols
#include "MTPriceableItem.h"

/////////////////////////////////////////////////////////////////////////////
// CMTUsageCharge
class ATL_NO_VTABLE CMTUsageCharge : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTUsageCharge, &CLSID_MTUsageCharge>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTUsageCharge, &IID_IMTUsageCharge, &LIBID_MTPRODUCTCATALOGLib>,
	public CMTPriceableItem
{
public:
	CMTUsageCharge();
	HRESULT FinalConstruct();
	void FinalRelease();

DECLARE_REGISTRY_RESOURCEID(IDR_MTUSAGECHARGE)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTUsageCharge)
	COM_INTERFACE_ENTRY(IMTUsageCharge)
	COM_INTERFACE_ENTRY(IMTPriceableItem)
	COM_INTERFACE_ENTRY(IMTPCBase)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, mpUnkMarshaler.p)
END_COM_MAP()



// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTPriceableItem
public:
	DEFINE_MT_PRICABLE_ITEM_METHODS

// IMTUsageCharge
public:

//data
private:
	CComPtr<IUnknown> mpUnkMarshaler;

};

#endif //__MTUSAGECHARGE_H_
