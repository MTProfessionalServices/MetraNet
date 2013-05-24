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

#ifndef __MTPCCYCLE_H_
#define __MTPCCYCLE_H_

#include "resource.h"       // main symbols
#include <NTLogger.h>
#include "PropertiesBase.h"


//using namespace MTUSAGECYCLELib;

//forward declaration
//struct ICOMUsageCyclePropertyCollPtr;

/////////////////////////////////////////////////////////////////////////////
// CMTPCCycle
class ATL_NO_VTABLE CMTPCCycle : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTPCCycle, &CLSID_MTPCCycle>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTPCCycle, &IID_IMTPCCycle, &LIBID_MTPRODUCTCATALOGLib>,
	public CMTPCBase,
	public PropertiesBase
{
public:
	CMTPCCycle()
	{
		m_pUnkMarshaler = NULL;
		mRelativeAmbiguity = false;
	}

DEFINE_MT_PCBASE_METHODS
DEFINE_MT_PROPERTIES_BASE_METHODS

DECLARE_REGISTRY_RESOURCEID(IDR_MTPCCYCLE)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTPCCycle)
	COM_INTERFACE_ENTRY(IMTPCCycle)
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

// IMTPCCycle
public:
	STDMETHOD(GetDescriptionFromCycleType)(/*[in]*/ MTUsageCycleType aCycleType,/*[out,retval]*/ BSTR* pCycleTypeDesc);
  STDMETHOD(Equals)(/*[in]*/ IMTPCCycle* pOtherCycle, /*[out, retval]*/VARIANT_BOOL* apResult);
  STDMETHOD(CopyTo)(/*[in]*/ IMTPCCycle* pTarget);
	STDMETHOD(ComputePropertiesFromCycleID)();
	STDMETHOD(ComputeCycleIDFromProperties)();
	STDMETHOD(CreateAbsoluteCycle)(/*[in]*/ DATE aReference, /*[out, retval]*/ IMTPCCycle** );
	STDMETHOD(GetTimeSpans)(/*[in]*/ DATE aStartDate,
													/*[in]*/ DATE aEndDate,
													/*[out, retval]*/ IMTCollection** apColl);
	STDMETHOD(GetTimeSpan)(/*[in]*/  DATE aReference,
												 /*[out, retval]*/ IMTPCTimeSpan** apTimeSpan);
	STDMETHOD(Clone)(/*[out, retval]*/ IMTPCCycle** apClone);

	STDMETHOD(get_StartYear)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_StartYear)(/*[in]*/ long newVal);
	STDMETHOD(get_StartMonth)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_StartMonth)(/*[in]*/ long newVal);
	STDMETHOD(get_StartDay)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_StartDay)(/*[in]*/ long newVal);
	STDMETHOD(get_EndDayOfMonth2)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_EndDayOfMonth2)(/*[in]*/ long newVal);
	STDMETHOD(get_EndDayOfMonth)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_EndDayOfMonth)(/*[in]*/ long newVal);
	STDMETHOD(get_EndDayOfWeek)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_EndDayOfWeek)(/*[in]*/ long newVal);

	// obsolete - use the Mode property
	STDMETHOD(get_Relative)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_Relative)(/*[in]*/ VARIANT_BOOL newVal);

	STDMETHOD(get_CycleTypeID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_CycleTypeID)(/*[in]*/ long newVal);
	STDMETHOD(get_CycleID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_CycleID)(/*[in]*/ long newVal);
	STDMETHOD(get_AdapterProgID)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(get_CycleTypeDescription)(/*[out, retval]*/ BSTR *pVal);

	STDMETHOD(get_Mode)(/*[out, retval]*/ MTCycleMode *pVal);
	STDMETHOD(put_Mode)(/*[in]*/ MTCycleMode newVal);

  STDMETHOD(IsMutuallyExclusive)(/*[in]*/ IMTPCCycle* pOtherCycle, /*[out, retval]*/VARIANT_BOOL* apResult);

private:
	HRESULT ExportToLegacyPropColl(MTUSAGESERVERLib::ICOMUsageCyclePropertyCollPtr& legacyProps);
	HRESULT ImportFromLegacyPropColl(MTUSAGESERVERLib::ICOMUsageCyclePropertyCollPtr& legacyProps);

  NTLogger mLogger;	

	enum CycleType {
		MONTHLY = 1,
		DAILY = 3,
		WEEKLY,
		BIWEEKLY,
		SEMIMONTHLY,
		QUARTERLY,
		ANNUALLY,
    SEMIANNUALLY
	};

	bool mRelativeAmbiguity;
};

#endif //__MTPCCYCLE_H_
