	
// MTRange.h : Declaration of the CMTRange

#ifndef __MTRANGE_H_
#define __MTRANGE_H_

#include <comdef.h>
#include "resource.h"       // main symbols

#include "MTCalendarDefs.h"
#include <errobj.h>
#include <NTLogger.h>
#include <loggerconfig.h>

#import <MTConfigLib.tlb>

/////////////////////////////////////////////////////////////////////////////
// CMTRange
class ATL_NO_VTABLE CMTRange : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTRange, &CLSID_MTRange>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTRange, &IID_IMTRange, &LIBID_MTCALENDARLib>,
	public ObjectWithError
{
public:
	CMTRange()
	{
		LoggerConfigReader configReader;
		mLogger.Init(configReader.ReadConfiguration(CALENDAR_STR), 
					 CALENDARLOGGER_TAG);
	}
	
	virtual ~CMTRange()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTRANGE)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CMTRange)
	COM_INTERFACE_ENTRY(IMTRange)
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

// IMTRange
public:
	STDMETHOD(WriteSet)(::IMTConfigPropSet* apPropSet);
	STDMETHOD(Add)(BSTR Code, BSTR StartTime, BSTR EndTime);
	STDMETHOD(get_EndTime)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_EndTime)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_StartTime)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_StartTime)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_Code)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Code)(/*[in]*/ BSTR newVal);

private:
	_bstr_t mCode;
	_bstr_t mStartTime;
	_bstr_t mEndTime;
    NTLogger mLogger;
};

#endif //__MTRANGE_H_
