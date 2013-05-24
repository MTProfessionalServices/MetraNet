	
// MTCalendarWeekday.h : Declaration of the CMTCalendarWeekday

#ifndef __MTCALENDARWEEKDAY_H_
#define __MTCALENDARWEEKDAY_H_

#include "resource.h"       // main symbols

#include "MTCalendarDay.h"

/////////////////////////////////////////////////////////////////////////////
// CMTCalendarWeekday
class ATL_NO_VTABLE CMTCalendarWeekday : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTCalendarWeekday, &CLSID_MTCalendarWeekday>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTCalendarWeekday, &IID_IMTCalendarWeekday, &LIBID_MTPRODUCTCATALOGLib>,
	public CMTCalendarDay

{
public:
	//DEFINE_MT_PCBASE_METHODS // These 2 are already defined in DEFINE_MT_CALENDARDAY_METHODS
	//DEFINE_MT_PROPERTIES_BASE_METHODS

	CMTCalendarWeekday()
	{
		m_pUnkMarshaler = NULL;
	}
	
	
DECLARE_REGISTRY_RESOURCEID(IDR_MTCALENDARWEEKDAY)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTCalendarWeekday)
	COM_INTERFACE_ENTRY(IMTCalendarDay)
	COM_INTERFACE_ENTRY(IMTCalendarWeekday)
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

// IMTCalendarWeekday
public:
	DEFINE_MT_CALENDARDAY_METHODS
	STDMETHOD(get_DayofWeek)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_DayofWeek)(/*[in]*/ long newVal);
	STDMETHOD(GetDayofWeekAsString)(/*[out, retval]*/ BSTR* pVal);
};

#endif //__MTCALENDARWEEKDAY_H_
