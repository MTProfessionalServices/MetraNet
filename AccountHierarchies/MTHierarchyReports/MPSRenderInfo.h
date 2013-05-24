// MPSRenderInfo.h : Declaration of the CMPSRenderInfo

#ifndef __MPSRENDERINFO_H_
#define __MPSRENDERINFO_H_

#include "resource.h"       // main symbols
#include <comdef.h>

#import <msxml4.dll>

#import <MTHierarchyReports.tlb> rename ("EOF", "EOFHR")

/////////////////////////////////////////////////////////////////////////////
// CMPSRenderInfo
class ATL_NO_VTABLE CMPSRenderInfo : 
	public CComObjectRootEx<CComSingleThreadModel>,
  public ISupportErrorInfo,
	public CComCoClass<CMPSRenderInfo, &CLSID_MPSRenderInfo>,
	public IDispatchImpl<IMPSRenderInfo, &IID_IMPSRenderInfo, &LIBID_MTHIERARCHYREPORTSLib>
{
public:
  CMPSRenderInfo() :
      mIntervalID(-1),
      mLanguageCode(-1),
      mlngAccountID(-1),
      mbUseInterval(VARIANT_FALSE),
      mbEstimate(VARIANT_FALSE),
      msViewType(0)
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_MPSRENDERINFO)

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CMPSRenderInfo)
  COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY(IMPSRenderInfo)
	COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()

	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IMPSRenderInfo
public:
	STDMETHOD(get_AccountID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_AccountID)(/*[in]*/ long newVal);
	STDMETHOD(get_TimeSlice)(/*[out, retval]*/ ITimeSlice* *pVal);
	STDMETHOD(putref_TimeSlice)(/*[in]*/ ITimeSlice* newVal);
	STDMETHOD(get_EndDate)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_EndDate)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_StartDate)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(put_StartDate)(/*[in]*/ BSTR newVal);
	STDMETHOD(get_UseInterval)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_UseInterval)(/*[in]*/ VARIANT_BOOL newVal);
	STDMETHOD(get_ViewType)(/*[out, retval]*/ MPS_VIEW_TYPE *pVal);
	STDMETHOD(put_ViewType)(/*[in]*/ MPS_VIEW_TYPE newVal);
  STDMETHOD(get_LanguageCode)(/*[out, retval]*/ int *pVal);
	STDMETHOD(put_LanguageCode)(/*[in]*/ int newVal);
	STDMETHOD(get_IntervalID)(/*[out, retval]*/ int *pVal);
	STDMETHOD(put_IntervalID)(/*[in]*/ int newVal);
	STDMETHOD(get_Estimate)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_Estimate)(/*[in]*/ VARIANT_BOOL newVal);

private:
  _bstr_t mstrEndDate;
	_bstr_t mstrStartDate;
	VARIANT_BOOL mbUseInterval;
	int mIntervalID;
	int mLanguageCode;
  long mlngAccountID;
	short msViewType;
	MTHIERARCHYREPORTSLib::ITimeSlicePtr mTimeSlice;
	VARIANT_BOOL mbEstimate;
};

#endif //__MPSRENDERINFO_H_
