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

#ifndef __MTTIMEPOINT_H_
#define __MTTIMEPOINT_H_

#include "resource.h"       // main symbols
#include <comdef.h>

/////////////////////////////////////////////////////////////////////////////
// CMTTimePoint
class ATL_NO_VTABLE CMTTimePoint : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTTimePoint, &CLSID_MTTimePoint>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTTimePoint, &IID_IMTTimePoint, &LIBID_BILLINGCYCLECONFIGLib>
{
public:
	CMTTimePoint() : mDay(-1), mSecondDay(-1), mYear(-1), mMonthIndex(-1)
	{		
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTTIMEPOINT)

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTTimePoint)
	COM_INTERFACE_ENTRY(IMTTimePoint)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTTimePoint
public:

	STDMETHOD(get_Month)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Month)(/*[in]*/ BSTR newVal);

	STDMETHOD(get_MonthIndex)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_MonthIndex)(/*[in]*/ long newVal);
	
	STDMETHOD(get_Day)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_Day)(/*[in]*/ long newVal);

	STDMETHOD(get_NamedDay)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_NamedDay)(/*[in]*/ BSTR newVal);

	STDMETHOD(get_SecondDay)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_SecondDay)(/*[in]*/ long newVal);

	STDMETHOD(get_Year)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_Year)(/*[in]*/ long newVal);

	STDMETHOD(get_Label)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Label)(/*[in]*/ BSTR newVal);


private:
	_bstr_t mNamedDay;
	long mDay;
	long mSecondDay;
	long mYear;
	long mMonthIndex;
	_bstr_t mMonth;
	_bstr_t mLabel;
};

#endif //__MTTIMEPOINT_H_
