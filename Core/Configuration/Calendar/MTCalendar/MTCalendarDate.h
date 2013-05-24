	
// MTCalendarDate.h : Declaration of the CMTCalendarDate

#ifndef __MTCALENDARDATE_H_
#define __MTCALENDARDATE_H_

#include <comdef.h>
#include "resource.h"       // main symbols
#include "MTRangeCollection.h"
#include <errobj.h>
#include <NTLogger.h>
#include <loggerconfig.h>

#import <MTCalendar.tlb>

/////////////////////////////////////////////////////////////////////////////
// CMTCalendarDate
class ATL_NO_VTABLE CMTCalendarDate : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTCalendarDate, &CLSID_MTCalendarDate>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTCalendarDate, &IID_IMTCalendarDate, &LIBID_MTCALENDARLib>,
	public ObjectWithError
{
public:
	CMTCalendarDate()
	{
		mpRangeCollection = 0;
		LoggerConfigReader configReader;
		mLogger.Init(configReader.ReadConfiguration(CALENDAR_STR), 
					 CALENDARLOGGER_TAG);
	}
	
	virtual ~CMTCalendarDate()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTCALENDARDATE)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CMTCalendarDate)
	COM_INTERFACE_ENTRY(IMTCalendarDate)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

	HRESULT FinalConstruct()
	{
		return S_OK;
	}

	void FinalRelease()
	{
	}


// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTCalendarDate
public:
	STDMETHOD(WriteDateSet)(::IMTConfigPropSet* apPropSet);
	STDMETHOD(WriteSet)(::IMTConfigPropSet* apPropSet);
	STDMETHOD(get_RangeCollection)(/*[out, retval]*/ IMTRangeCollection** pVal);
	STDMETHOD(put_RangeCollection)(/*[in]*/ IMTRangeCollection* newVal);
	STDMETHOD(Add)(DATE aDate, BSTR aNotes);
	STDMETHOD(get_Notes)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Notes)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Date)(/*[out, retval]*/ DATE *pVal);
	STDMETHOD(put_Date)(/*[in]*/ DATE newVal);


private:
	DATE mDate;
	_bstr_t mNotes;
    NTLogger mLogger;
	MTCALENDARLib::IMTRangeCollectionPtr mpRangeCollection;

};

#endif //__MTCALENDARDATE_H_
