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

#ifndef __MTPCTIMESPAN_H_
#define __MTPCTIMESPAN_H_

#include "resource.h"       // main symbols
#include "PropertiesBase.h"

/////////////////////////////////////////////////////////////////////////////
// CMTPCTimeSpan
class ATL_NO_VTABLE CMTPCTimeSpan : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTPCTimeSpan, &CLSID_MTPCTimeSpan>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTPCTimeSpan, &IID_IMTPCTimeSpan, &LIBID_MTPRODUCTCATALOGLib>,
	public CMTPCBase,
	public PropertiesBase
{
public:
	DEFINE_MT_PCBASE_METHODS
	DEFINE_MT_PROPERTIES_BASE_METHODS

	CMTPCTimeSpan();
	HRESULT FinalConstruct();
	void FinalRelease();

DECLARE_REGISTRY_RESOURCEID(IDR_MTPCTIMESPAN)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTPCTimeSpan)
	COM_INTERFACE_ENTRY(IMTPCTimeSpan)
	COM_INTERFACE_ENTRY(IMTPCBase)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, mUnkMarshalerPtr.p)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTPCTimeSpan
public:
	STDMETHOD(get_ID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_ID)(/*[in]*/ long newVal);
	STDMETHOD(get_StartDateType)(/*[out, retval]*/ MTPCDateType *pVal);
	STDMETHOD(put_StartDateType)(/*[in]*/ MTPCDateType newVal);
	STDMETHOD(get_StartDate)(/*[out, retval]*/ DATE *pVal);
	STDMETHOD(put_StartDate)(/*[in]*/ DATE newVal);
	STDMETHOD(get_StartOffset)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_StartOffset)(/*[in]*/ long newVal);
	STDMETHOD(get_EndDateType)(/*[out, retval]*/ MTPCDateType *pVal);
	STDMETHOD(put_EndDateType)(/*[in]*/ MTPCDateType newVal);
	STDMETHOD(get_EndDate)(/*[out, retval]*/ DATE *pVal);
	STDMETHOD(put_EndDate)(/*[in]*/ DATE newVal);
	STDMETHOD(get_EndOffset)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_EndOffset)(/*[in]*/ long newVal);
	STDMETHOD(SetStartDateNull)();
	STDMETHOD(IsStartDateNull)(/*[out, retval]*/ VARIANT_BOOL* pVal);
	STDMETHOD(SetEndDateNull)();
	STDMETHOD(IsEndDateNull)(/*[out, retval]*/ VARIANT_BOOL* pVal);
	STDMETHOD(IsEndBeforeStart)(/*[out, retval]*/ VARIANT_BOOL* pVal);
	STDMETHOD(Validate)();
	STDMETHOD(Normalize)();
	STDMETHOD(Init)(/*[in]*/ MTPCDateType aStartDateTypeConstraint, /*[in]*/ MTPCDateType aInitialStartDateType,
									/*[in]*/ MTPCDateType aEndDateTypeConstraint,		/*[in]*/ MTPCDateType aInitialEndDateType);


//data
private:
	CComPtr<IUnknown> mUnkMarshalerPtr;

  //constrains to start or end types, PCDATE_TYPE_NO_DATE means unconstrained
	MTPCDateType mStartDateTypeConstraint;
	MTPCDateType mEndDateTypeConstraint;
};

#endif //__MTPCTIMESPAN_H_
