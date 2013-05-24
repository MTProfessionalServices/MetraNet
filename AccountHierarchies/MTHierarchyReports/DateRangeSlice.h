	
// DateRangeSlice.h : Declaration of the CDateRangeSlice

#ifndef __DATERANGESLICE_H_
#define __DATERANGESLICE_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CDateRangeSlice
class ATL_NO_VTABLE CDateRangeSlice : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CDateRangeSlice, &CLSID_DateRangeSlice>,
	public ISupportErrorInfo,
	public IDispatchImpl<IDateRangeSlice, &IID_IDateRangeSlice, &LIBID_MTHIERARCHYREPORTSLib>
{
public:
	CDateRangeSlice()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_DATERANGESLICE)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CDateRangeSlice)
	COM_INTERFACE_ENTRY(IDateRangeSlice)
	COM_INTERFACE_ENTRY(IViewSlice)
	COM_INTERFACE_ENTRY(ITimeSlice)
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

// IDateRangeSlice
public:
	STDMETHOD(get_End)(/*[out, retval]*/ DATE *pVal);
	STDMETHOD(put_End)(/*[in]*/ DATE newVal);
	STDMETHOD(get_Begin)(/*[out, retval]*/ DATE *pVal);
	STDMETHOD(put_Begin)(/*[in]*/ DATE newVal);
	STDMETHOD(put_IntervalID)(/*[in]*/ long newVal);
// IViewSlice
public:
	STDMETHOD(GenerateQueryPredicate)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(ToString)(/*[out, retval]*/ BSTR *pVal);
  STDMETHOD(ToStringUnencrypted)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(FromString)(/*[in]*/ ISliceLexer* apLexer);
  STDMETHOD(Equals)(/*[in]*/ IViewSlice* apSlice, /*[out,retval]*/ VARIANT_BOOL *pVal);
  STDMETHOD(Clone)(/*[out,retval]*/ IViewSlice* *pVal);
public:
// ITimeSlice
	STDMETHOD(GetTimeSpan)(/*[out]*/ DATE * pMinDate, /*[out]*/ DATE * pMaxDate);
private:
	DATE mEnd;
	DATE mBegin;
};

#endif //__DATERANGESLICE_H_
