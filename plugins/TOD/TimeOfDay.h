// TimeOfDay.h : Declaration of the CTimeOfDay

#ifndef __TIMEOFDAY_H_
#define __TIMEOFDAY_H_

#include "resource.h"       // main symbols

// import the type library of the plug in interfaces
// so we can use generated smart pointers
#import "MTPipelineLib.tlb" rename ("EOF", "RowsetEOF")

/////////////////////////////////////////////////////////////////////////////
// CTimeOfDay
class ATL_NO_VTABLE CTimeOfDay : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CTimeOfDay, &CLSID_TimeOfDay>,
	public ISupportErrorInfo,
	// implement the IMTPipelineProcessor interface
	public IMTPipelinePlugIn
{
public:
	CTimeOfDay()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_TIMEOFDAY)
DECLARE_NOT_AGGREGATABLE(CTimeOfDay)

BEGIN_COM_MAP(CTimeOfDay)
	// implement the IMTPipelinePlugIn interface
	COM_INTERFACE_ENTRY(IMTPipelinePlugIn)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMTPipelinePlugIn
public:
	// Initialize the processor, looking up any necessary property IDs.
	// The processor can also use this time to do any other necessary initialization.
	// NOTE: This method can be called any number of times in order to
	//  refresh the initialization of the processor.
	STDMETHOD(Configure)(
		/* [in] */ IUnknown * systemContext,
		/* [in] */ IMTConfigPropSet * propSet);

	// Shutdown the processor.  The processor can release any resources
	// it no longer needs.
	STDMETHOD(Shutdown)();

	// Return information about this processor.
	// combination of 
	//    MTPROC_FREETHREADED
	//    MTPROC_PASSIVE
	//    MTPROC_STAGECHANGER
	STDMETHOD(get_ProcessorInfo)(/* [out] */ long * info);

	STDMETHOD(ProcessSessions)(/* [in] */ IMTSessionSet * sessions);


private:

	// property ID of the property that holds the date/time value
	long mDateTimeID;

	// property ID of the property that will be set to the time
	// of day (seconds since midnight)
	long mTimeOfDayID;

	// interface to the logging system
	MTPipelineLib::IMTLogPtr mLogger;
};

#endif //__TIMEOFDAY_H_
