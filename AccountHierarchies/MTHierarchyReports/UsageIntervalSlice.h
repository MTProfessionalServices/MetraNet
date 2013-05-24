// UsageIntervalSlice.h : Declaration of the CUsageIntervalSlice

#ifndef __USAGEINTERVALSLICE_H_
#define __USAGEINTERVALSLICE_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CUsageIntervalSlice
class ATL_NO_VTABLE CUsageIntervalSlice : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CUsageIntervalSlice, &CLSID_UsageIntervalSlice>,
	public ISupportErrorInfo,
	public IDispatchImpl<IUsageIntervalSlice, &IID_IUsageIntervalSlice, &LIBID_MTHIERARCHYREPORTSLib>
{
public:
	CUsageIntervalSlice()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_USAGEINTERVALSLICE)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CUsageIntervalSlice)
	COM_INTERFACE_ENTRY(IUsageIntervalSlice)
//DEL 	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
	COM_INTERFACE_ENTRY2(IDispatch, IUsageIntervalSlice)
	COM_INTERFACE_ENTRY(IViewSlice)
	COM_INTERFACE_ENTRY(ITimeSlice)
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

// IUsageIntervalSlice
public:
	STDMETHOD(get_IntervalID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_IntervalID)(/*[in]*/ long newVal);
// IViewSlice
	STDMETHOD(GenerateQueryPredicate)(BSTR * pVal);
	STDMETHOD(ToString)(/*[out, retval]*/ BSTR *pVal);
  STDMETHOD(ToStringUnencrypted)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(FromString)(/*[in]*/ ISliceLexer* apLexer);
  STDMETHOD(Equals)(/*[in]*/ IViewSlice* apSlice, /*[out,retval]*/ VARIANT_BOOL *pVal);
  STDMETHOD(Clone)(/*[out,retval]*/ IViewSlice* *pVal);
// ITimeSlice
	STDMETHOD(GetTimeSpan)(/*[out]*/ DATE * pMinDate, /*[out]*/ DATE * pMaxDate);
private:
	long mIntervalID;
};

#endif //__USAGEINTERVALSLICE_H_
