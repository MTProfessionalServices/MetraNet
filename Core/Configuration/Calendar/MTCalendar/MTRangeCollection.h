	
// MTRangeCollection.h : Declaration of the CMTRangeCollection

#ifndef __MTRANGECOLLECTION_H_
#define __MTRANGECOLLECTION_H_

#include "resource.h"       // main symbols
#include "MTCalendarDefs.h"
#include <errobj.h>
#include <NTLogger.h>
#include <loggerconfig.h>
#include <vector>

#import <MTCalendar.tlb>

#import <MTConfigLib.tlb>

/////////////////////////////////////////////////////////////////////////////
// CMTRangeCollection
class ATL_NO_VTABLE CMTRangeCollection : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CMTRangeCollection, &CLSID_MTRangeCollection>,
	public ISupportErrorInfo,
	public IDispatchImpl<IMTRangeCollection, &IID_IMTRangeCollection, &LIBID_MTCALENDARLib>,
	public ObjectWithError
{
public:
	CMTRangeCollection()
	{
		mSize = 0;
		mpRange = 0;
		LoggerConfigReader configReader;
		mLogger.Init(configReader.ReadConfiguration(CALENDAR_STR), 
					 CALENDARLOGGER_TAG);
	}
  
	~CMTRangeCollection()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MTRANGECOLLECTION)
DECLARE_GET_CONTROLLING_UNKNOWN()

BEGIN_COM_MAP(CMTRangeCollection)
	COM_INTERFACE_ENTRY(IMTRangeCollection)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

	HRESULT FinalConstruct()
	{
		return S_OK;
	}

	void FinalRelease()
	{
		mRangeList.clear();
	}


// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTRangeCollection
public:
	STDMETHOD(WriteSet)(::IMTConfigPropSet* apPropSet);
	STDMETHOD(Add)(IMTRange* pRange);
	STDMETHOD(get_Item)(long aIndex, /*[out, retval]*/ VARIANT *pVal);
	STDMETHOD(get_Count)(/*[out, retval]*/ long *pVal);
	STDMETHOD(get_Code)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_Code)(/*[in]*/ BSTR newVal);
	STDMETHOD(get__NewEnum)(/*[out, retval]*/ LPUNKNOWN *pVal);

private:
    MTCALENDARLib::IMTRangePtr mpRange;
	  std::vector<CComVariant> mRangeList;
    long mSize;
    _bstr_t mCode;
    NTLogger mLogger;
};

#endif //__MTRANGECOLLECTION_H_
