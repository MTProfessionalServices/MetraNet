	
// MTCalendar.h : Declaration of the CMTCalendar

#ifndef __MTCALENDAR_H_
#define __MTCALENDAR_H_

#include "resource.h"       // main symbols
#include <MTObjectCollection.h>

#include "PropertiesBase.h"
#import <MTEnumConfigLib.tlb>

/////////////////////////////////////////////////////////////////////////////
// CMTCalendar
class ATL_NO_VTABLE CMTCalendar : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTCalendar, &CLSID_MTCalendar>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTCalendar, &IID_IMTCalendar, &LIBID_MTPRODUCTCATALOGLib>,
	public CMTPCBase,
	public PropertiesBase
{
public:
	CMTCalendar();

	DEFINE_MT_PCBASE_METHODS
	DEFINE_MT_PROPERTIES_BASE_METHODS

DECLARE_REGISTRY_RESOURCEID(IDR_MTCALENDAR)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTCalendar)
	COM_INTERFACE_ENTRY(IMTCalendar)
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

// IMTCalendar
public:
	STDMETHOD(get_ID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_ID)(/*[in]*/ long newVal);
	STDMETHOD(get_Name)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Name)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Description)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Description)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_TimezoneOffset)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_TimezoneOffset)(/*[in]*/ long newVal);
	STDMETHOD(get_CombinedWeekend)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_CombinedWeekend)(/*[in]*/ VARIANT_BOOL newVal);
	STDMETHOD(GetWeekday)(/*[in]*/ long newVal, /*[out, retval]*/ IMTCalendarWeekday* *apWeekday);
	STDMETHOD(GetHoliday)(/*[in]*/ BSTR newVal, /*[out, retval]*/ IMTCalendarHoliday* *apHoliday);
	STDMETHOD(CreateWeekday)(/*[in]*/ long newVal, /*[out, retval]*/ IMTCalendarWeekday* *apWeekday);
	STDMETHOD(CreateHoliday)(/*[in]*/ BSTR newVal, /*[out, retval]*/ IMTCalendarHoliday* *apHoliday);
	STDMETHOD(RemoveWeekday)(/*[in]*/ long newVal);
	STDMETHOD(RemoveHoliday)(/*[in]*/ BSTR newVal);
	STDMETHOD(GetWeekdays)(/*[out, retval]*/ IMTCollection* *apWeekdayColl);
	STDMETHOD(GetHolidays)(/*[out, retval]*/ IMTCollection* *apHolidayColl);
	STDMETHOD(GetWeekdayorDefault)(/*[in]*/ long newVal, /*[out, retval]*/ IMTCalendarWeekday* *apWeekday);
	STDMETHOD(Validate)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(Save)();

private:
	MTObjectCollection<IMTCalendarWeekday> mWeekdays;
	MTObjectCollection<IMTCalendarHoliday> mHolidays;
};

#endif //__MTCALENDAR_H_
