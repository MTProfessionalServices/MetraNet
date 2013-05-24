	
// IntersectionTimeSlice.h : Declaration of the CIntersectionTimeSlice

#ifndef __INTERSECTIONTIMESLICE_H_
#define __INTERSECTIONTIMESLICE_H_

#include "resource.h"       // main symbols

#import <MTHierarchyReports.tlb> rename("EOF", "EOFHR")

/////////////////////////////////////////////////////////////////////////////
// CIntersectionTimeSlice
class ATL_NO_VTABLE CIntersectionTimeSlice : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CIntersectionTimeSlice, &CLSID_IntersectionTimeSlice>,
	public ISupportErrorInfo,
	public IDispatchImpl<IIntersectionTimeSlice, &IID_IIntersectionTimeSlice, &LIBID_MTHIERARCHYREPORTSLib>
{
public:
	CIntersectionTimeSlice()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_INTERSECTIONTIMESLICE)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CIntersectionTimeSlice)
	COM_INTERFACE_ENTRY(IIntersectionTimeSlice)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(IViewSlice)
	COM_INTERFACE_ENTRY(ITimeSlice)
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

// IIntersectionTimeSlice
public:
	STDMETHOD(get_RHS)(/*[out, retval]*/ ITimeSlice* *pVal);
	STDMETHOD(putref_RHS)(/*[in]*/ ITimeSlice* newVal);
	STDMETHOD(get_LHS)(/*[out, retval]*/ ITimeSlice* *pVal);
	STDMETHOD(putref_LHS)(/*[in]*/ ITimeSlice* newVal);
// IViewSlice
public:
	STDMETHOD(GenerateQueryPredicate)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(ToString)(/*[out, retval]*/ BSTR *pVal);
  STDMETHOD(ToStringUnencrypted)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(FromString)(/*[in]*/ ISliceLexer* apLexer);
  STDMETHOD(Equals)(/*[in]*/ IViewSlice* apSlice, /*[out,retval]*/ VARIANT_BOOL *pVal);
  STDMETHOD(Clone)(/*[out,retval]*/ IViewSlice* *pVal);
// ITimeSlice
public:
	STDMETHOD(GetTimeSpan)(/*[out]*/ DATE * pMinDate, /*[out]*/ DATE * pMaxDate);
private:
	MTHIERARCHYREPORTSLib::ITimeSlicePtr mLHS;
	MTHIERARCHYREPORTSLib::ITimeSlicePtr mRHS;
};

#endif //__INTERSECTIONTIMESLICE_H_
