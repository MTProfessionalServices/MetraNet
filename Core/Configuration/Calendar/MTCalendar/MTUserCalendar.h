	
// MTUserCalendar.h : Declaration of the CMTUserCalendar

#ifndef __MTUSERCALENDAR_H_
#define __MTUSERCALENDAR_H_

#include "resource.h"       // main symbols
#include "MTCalendarDefs.h"
#include <mtprogids.h>
#include <errobj.h>
#include <NTLogger.h>
#include <loggerconfig.h>
#include <vector>

#import <MTCalendar.tlb>

// import the configloader tlb file
#import <MTCLoader.tlb>
#import <MTConfigLib.tlb>

/////////////////////////////////////////////////////////////////////////////
// CMTUserCalendar
class ATL_NO_VTABLE CMTUserCalendar : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTUserCalendar, &CLSID_MTUserCalendar>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTUserCalendar, &IID_IMTUserCalendar, &LIBID_MTCALENDARLib>,
	public ObjectWithError
{
public:
	CMTUserCalendar()
	{
		mSize = 0;
		mpMonday = 0;
		mpTuesday = 0;
		mpWednesday = 0;
		mpThursday = 0;
		mpFriday = 0;
		mpSaturday = 0;
		mpSunday = 0;
		mpDefaultWeekday = 0;
		mpDefaultWeekend = 0;
		mpTimezone = 0;
		put_Monday(NULL);
		put_Tuesday(NULL);
		put_Wednesday(NULL);
		put_Thursday(NULL);
		put_Friday(NULL);
		put_Saturday(NULL);
		put_Sunday(NULL);
		put_DefaultWeekday(NULL);
		put_DefaultWeekend(NULL);
		LoggerConfigReader configReader;
		mLogger.Init(configReader.ReadConfiguration(CALENDAR_STR), 
					 CALENDARLOGGER_TAG);
	}

    ~CMTUserCalendar()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTUSERCALENDAR)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CMTUserCalendar)
	COM_INTERFACE_ENTRY(IMTUserCalendar)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

	HRESULT FinalConstruct()
	{
		return S_OK;
	}

	void FinalRelease()
	{
		mDateList.clear();
	}

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTUserCalendar
public:
	STDMETHOD(get_DefaultWeekend)(/*[out, retval]*/ IMTRangeCollection* *pVal);
	STDMETHOD(put_DefaultWeekend)(/*[in]*/ IMTRangeCollection* newVal);
	STDMETHOD(Write)(BSTR aRelativePath, BSTR aFileName);
	STDMETHOD(Read)(BSTR aRelativePath, BSTR aFileName);
	STDMETHOD(get_DefaultWeekday)(/*[out, retval]*/ IMTRangeCollection* *pVal);
	STDMETHOD(put_DefaultWeekday)(/*[in]*/ IMTRangeCollection* newVal);
	STDMETHOD(Remove)(DATE aDate);
	STDMETHOD(Add)(IMTCalendarDate* pDate);
	STDMETHOD(get_Item)(long aIndex, /*[out, retval]*/ VARIANT *pVal);
	STDMETHOD(get_Count)(/*[out, retval]*/ long *pVal);
	STDMETHOD(get_Sunday)(/*[out, retval]*/ IMTRangeCollection* *pVal);
	STDMETHOD(put_Sunday)(/*[in]*/ IMTRangeCollection* newVal);
	STDMETHOD(get_Saturday)(/*[out, retval]*/ IMTRangeCollection* *pVal);
	STDMETHOD(put_Saturday)(/*[in]*/ IMTRangeCollection* newVal);
	STDMETHOD(get_Friday)(/*[out, retval]*/ IMTRangeCollection* *pVal);
	STDMETHOD(put_Friday)(/*[in]*/ IMTRangeCollection* newVal);
	STDMETHOD(get_Thursday)(/*[out, retval]*/ IMTRangeCollection* *pVal);
	STDMETHOD(put_Thursday)(/*[in]*/ IMTRangeCollection* newVal);
	STDMETHOD(get_Wednesday)(/*[out, retval]*/ IMTRangeCollection* *pVal);
	STDMETHOD(put_Wednesday)(/*[in]*/ IMTRangeCollection* newVal);
	STDMETHOD(get_Tuesday)(/*[out, retval]*/ IMTRangeCollection* *pVal);
	STDMETHOD(put_Tuesday)(/*[in]*/ IMTRangeCollection* newVal);
	STDMETHOD(get_Monday)(/*[out, retval]*/ IMTRangeCollection* *pVal);
	STDMETHOD(put_Monday)(/*[in]*/ IMTRangeCollection* newVal);
	STDMETHOD(get__NewEnum)(/*[out, retval]*/ LPUNKNOWN *pVal);
	STDMETHOD(Initialize)(BSTR aHostName);
	STDMETHOD(ReadFromHost)(BSTR aHostName, BSTR aRelativePath, BSTR aFileName);
	STDMETHOD(WriteToHost)(BSTR aHostName, BSTR aRelativePath, BSTR aFileName);
	STDMETHOD(get_Timezone)(/*[out, retval]*/ IMTTimezone** pVal);
	STDMETHOD(put_Timezone)(/*[in]*/ IMTTimezone* newVal);
	STDMETHOD(GMTToLocalTime)(/*[in]*/ VARIANT aGMTDatetime, /*[in]*/ long aMTZoneCode, /*[out, retval]*/ VARIANT* pLocalDatetime);
	STDMETHOD(LocalTimeToGMT)(/*[in]*/ VARIANT aLocalDatetime, /*[in]*/ long aMTZoneCode, /*[out, retval]*/ VARIANT* pGMTDatetime);

private:
    MTCALENDARLib::IMTRangeCollectionPtr mpMonday;
    MTCALENDARLib::IMTRangeCollectionPtr mpTuesday;
    MTCALENDARLib::IMTRangeCollectionPtr mpWednesday;
    MTCALENDARLib::IMTRangeCollectionPtr mpThursday;
    MTCALENDARLib::IMTRangeCollectionPtr mpFriday;
    MTCALENDARLib::IMTRangeCollectionPtr mpSaturday;
    MTCALENDARLib::IMTRangeCollectionPtr mpSunday;
    MTCALENDARLib::IMTRangeCollectionPtr mpDefaultWeekday;
    MTCALENDARLib::IMTRangeCollectionPtr mpDefaultWeekend;
    MTCALENDARLib::IMTTimezonePtr mpTimezone;

    std::vector<CComVariant> mDateList;
    long mSize;
    _bstr_t mFileName;
    _bstr_t mHostName;
    NTLogger mLogger;

protected:
    BOOL ProcessModuleFile(CONFIGLOADERLib::IMTConfigPropSetPtr& propSet);
    BOOL ProcessModuleFile(MTConfigLib::IMTConfigPropSetPtr& propSet);
    BOOL ProcessReadingRangeCollection(CONFIGLOADERLib::IMTConfigPropSetPtr& propSet, 
									   BOOL abParseWeekdayFlag);
    BOOL ProcessReadingRangeCollection(MTConfigLib::IMTConfigPropSetPtr& propSet, 
									   BOOL abParseWeekdayFlag);
    BOOL ProcessReadingHolidays(CONFIGLOADERLib::IMTConfigPropSetPtr& propSet);
    BOOL ProcessReadingHolidays(MTConfigLib::IMTConfigPropSetPtr& propSet);
    BOOL WriteModuleFile(MTConfigLib::IMTConfigPropSetPtr& propSet);
    time_t ParseVariantDate(VARIANT aDate);
};

#endif //__MTUSERCALENDAR_H_
