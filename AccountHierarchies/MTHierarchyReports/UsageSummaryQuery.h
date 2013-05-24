	
// UsageSummaryQuery.h : Declaration of the CUsageSummaryQuery

#ifndef __USAGESUMMARYQUERY_H_
#define __USAGESUMMARYQUERY_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CUsageSummaryQuery
class ATL_NO_VTABLE CUsageSummaryQuery : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CUsageSummaryQuery, &CLSID_UsageSummaryQuery>,
	public ISupportErrorInfo,
	public IDispatchImpl<IUsageSummaryQuery, &IID_IUsageSummaryQuery, &LIBID_MTHIERARCHYREPORTSLib>
{
public:
	CUsageSummaryQuery()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_USAGESUMMARYQUERY)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CUsageSummaryQuery)
	COM_INTERFACE_ENTRY(IUsageSummaryQuery)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

	HRESULT FinalConstruct()
	{
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

// IUsageSummaryQuery
public:
	STDMETHOD(GenerateQueryString)(/*[in]*/ long aLocaleId, /*[in]*/ ITimeSlice* apTimeSlice, /*[in]*/ IAccountSlice* apAccountSlice, /*[in]*/ IViewSlice* apSessionSlice, /*[in]*/ VARIANT_BOOL bUseDatamart, /*[out, retval]*/ BSTR * pQuery);
  STDMETHOD(put_InlineAdjustments)(/*[out, retval]*/ VARIANT_BOOL newVal);
  STDMETHOD(get_InlineAdjustments)(/*[out, retval]*/ VARIANT_BOOL *pVal);
  STDMETHOD(put_InteractiveReport)(/*[out, retval]*/ VARIANT_BOOL newVal);
  STDMETHOD(get_InteractiveReport)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(get_InlineVATTaxes)(/*[out, retval]*/ VARIANT_BOOL *pVal);
	STDMETHOD(put_InlineVATTaxes)(/*[in]*/ VARIANT_BOOL newVal);

private:
  bool mInlineAdjustments;
  bool mInteractiveReport;
	VARIANT_BOOL mbInlineVATTaxes;
};

#endif //__USAGESUMMARYQUERY_H_
