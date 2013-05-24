	
// MTCalendar.h : Declaration of the CMTCalendar

#ifndef __MTCALENDARPERIOD_H_
#define __MTCALENDARPERIOD_H_

#include "resource.h"       // main symbols
#include "PropertiesBase.h"
#include <MTUtil.h>

/////////////////////////////////////////////////////////////////////////////
// CMTCalendar
class ATL_NO_VTABLE CMTCalendarPeriod : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTCalendarPeriod, &CLSID_MTCalendarPeriod>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTCalendarPeriod, &IID_IMTCalendarPeriod, &LIBID_MTPRODUCTCATALOGLib>,
	public CMTPCBase,
	public PropertiesBase,
	public IMTSortProperty
{
public:
	DEFINE_MT_PCBASE_METHODS
	DEFINE_MT_PROPERTIES_BASE_METHODS

	CMTCalendarPeriod()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTCALENDARPERIOD)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMTCalendarPeriod)
	COM_INTERFACE_ENTRY(IMTCalendarPeriod)
	COM_INTERFACE_ENTRY(IMTSortProperty)
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

// IMTCalendarPeriod
public:
	STDMETHOD(get_ID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_ID)(/*[in]*/ long newVal);
	STDMETHOD(get_Code)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_Code)(/*[in]*/ long newVal);		
	STDMETHOD(get_StartTime)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_StartTime)(/*[in]*/ long newVal);		
	STDMETHOD(get_EndTime)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_EndTime)(/*[in]*/ long newVal);
	STDMETHOD(get_StartTimeAsString)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_StartTimeAsString)(/*[in]*/ BSTR newVal);		
	STDMETHOD(get_EndTimeAsString)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_EndTimeAsString)(/*[in]*/ BSTR newVal);
	STDMETHOD(Compare)(/*[in]*/ IUnknown* pUnk, /*[out, retval]*/ VARIANT_BOOL *apGreaterThan);
	STDMETHOD(GetCodeAsString)(/*[out, retval]*/ BSTR* newVal);
		
private:

};

#endif //__MTCALENDARPERIOD_H_
