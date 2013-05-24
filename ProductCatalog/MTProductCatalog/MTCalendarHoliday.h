	
// MTCalendarHoliday.h : Declaration of the CMTCalendarHoliday

#ifndef __MTCALENDARHOLIDAY_H_
#define __MTCALENDARHOLIDAY_H_

#include "resource.h"       // main symbols

#include "MTCalendarDay.h"

/////////////////////////////////////////////////////////////////////////////
// CMTCalendarHoliday
class ATL_NO_VTABLE CMTCalendarHoliday : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTCalendarHoliday, &CLSID_MTCalendarHoliday>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTCalendarHoliday, &IID_IMTCalendarHoliday, &LIBID_MTPRODUCTCATALOGLib>,
	public CMTCalendarDay
{
public:
	//DEFINE_MT_PCBASE_METHODS - already defined in DEFINE_MT_CALENDARDAY_METHODS
	//DEFINE_MT_PROPERTIES_BASE_METHODS

	CMTCalendarHoliday()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTCALENDARHOLIDAY)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTCalendarHoliday)
	COM_INTERFACE_ENTRY(IMTCalendarDay)
	COM_INTERFACE_ENTRY(IMTCalendarHoliday)
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

// IMTCalendarHoliday
public:
	DEFINE_MT_CALENDARDAY_METHODS
	STDMETHOD(get_Name)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Name)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Day)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_Day)(/*[in]*/ long newVal);
	STDMETHOD(get_WeekofMonth)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_WeekofMonth)(/*[in]*/ long newVal);
	STDMETHOD(get_Month)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_Month)(/*[in]*/ long newVal);
	STDMETHOD(get_Year)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_Year)(/*[in]*/ long newVal);
	STDMETHOD(get_Date)(/*[out, retval]*/ DATE *pVal);
	STDMETHOD(put_Date)(/*[in]*/ DATE newVal);

};

#endif //__MTCALENDARHOLIDAY_H_
