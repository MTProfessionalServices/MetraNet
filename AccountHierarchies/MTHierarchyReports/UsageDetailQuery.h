	
// UsageDetailQuery.h : Declaration of the CUsageDetailQuery

#ifndef __USAGEDETAILQUERY_H_
#define __USAGEDETAILQUERY_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CUsageDetailQuery
class ATL_NO_VTABLE CUsageDetailQuery : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CUsageDetailQuery, &CLSID_UsageDetailQuery>,
	public ISupportErrorInfo,
	public IDispatchImpl<IUsageDetailQuery, &IID_IUsageDetailQuery, &LIBID_MTHIERARCHYREPORTSLib>
{
public:
	CUsageDetailQuery()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_USAGEDETAILQUERY)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CUsageDetailQuery)
	COM_INTERFACE_ENTRY(IUsageDetailQuery)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

	HRESULT FinalConstruct()
	{
    mInlineAdjustments = false;
    mInteractiveReport = false;
		return CoCreateFreeThreadedMarshaler(
			GetControllingUnknown(), &m_pUnkMarshaler.p);
	}

	void FinalRelease()
	{
		m_pUnkMarshaler.Release();
	}

	CComPtr<IUnknown> m_pUnkMarshaler;

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IUsageDetailQuery
public:
  STDMETHOD(GenerateQueryString)(/*[in]*/ long aLocaleId, /*[in]*/ IQueryParams* pQueryParams, /*[out, retval]*/ BSTR * pQuery);
	STDMETHOD(GenerateQueryStringFinder)(/*[in]*/ long aLocaleId, /*[in]*/ ITimeSlice* apTimeSlice, /*[in]*/ IAccountSlice* apAccountSlice, /*[in]*/ ISingleProductSlice* apProductSlice, /*[in]*/ IViewSlice* apSessionSlice, /*[in]*/ BSTR aExtension, /*[out, retval]*/ BSTR * pQuery);
  STDMETHOD(GenerateAdjustmentQueryString)(/*[in]*/ long aLocaleId, /*[in]*/ ITimeSlice* apTimeSlice, /*[in]*/ IAccountSlice* apAccountSlice, /*[in]*/ ISingleProductSlice* apProductSlice, /*[in]*/ IViewSlice* apSessionSlice, /*[in]*/ BSTR aExtension, /*[out, retval]*/ BSTR * pQuery);
  STDMETHOD(GenerateBaseAdjustmentQueryString)(/*[in]*/ long aLocaleId, /*[in]*/ ITimeSlice* apTimeSlice, /*[in]*/ IAccountSlice* apAccountSlice, /*[in]*/ IViewSlice* apSessionSlice, /*[in]*/ BSTR aExtension, /*[in]*/ VARIANT_BOOL aIsPostbill, /*[out, retval]*/ BSTR * pQuery);
	STDMETHOD(get_AccountSlice)(/*[out, retval]*/ IAccountSlice* *pVal);
	STDMETHOD(putref_AccountSlice)(/*[in]*/ IAccountSlice* newVal);
	STDMETHOD(get_TimeSlice)(/*[out, retval]*/ IViewSlice* *pVal);
	STDMETHOD(putref_TimeSlice)(/*[in]*/ IViewSlice* newVal);
  STDMETHOD(put_InlineAdjustments)(/*[out, retval]*/ VARIANT_BOOL newVal);
  STDMETHOD(get_InlineAdjustments)(/*[out, retval]*/ VARIANT_BOOL *pVal);
  STDMETHOD(put_InteractiveReport)(/*[out, retval]*/ VARIANT_BOOL newVal);
  STDMETHOD(get_InteractiveReport)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(get_InlineVATTaxes)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_InlineVATTaxes)(/*[in]*/ VARIANT_BOOL newVal);


private:
  _bstr_t GenerateQueryStringInternal(long aLocaleId, ITimeSlice *apTimeSlice, IAccountSlice *apAccountSlice, ISingleProductSlice* apProductSlice, IViewSlice *apSessionSlice, BSTR aExtension, char* aTag, long lTopRows = -1 /* value not provided */);
	bool mInlineAdjustments;
  bool mInteractiveReport;
	VARIANT_BOOL mbInlineVATTaxes;

};

#endif //__USAGEDETAILQUERY_H_
