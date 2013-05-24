	
// DescendentPayeeSlice.h : Declaration of the CDescendentPayeeSlice

#ifndef __DESCENDENTPAYEESLICE_H_
#define __DESCENDENTPAYEESLICE_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CDescendentPayeeSlice
class ATL_NO_VTABLE CDescendentPayeeSlice : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CDescendentPayeeSlice, &CLSID_DescendentPayeeSlice>,
	public ISupportErrorInfo,
	public IDispatchImpl<IDescendentPayeeSlice, &IID_IDescendentPayeeSlice, &LIBID_MTHIERARCHYREPORTSLib>
{
public:
	CDescendentPayeeSlice()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_DESCENDENTPAYEESLICE)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CDescendentPayeeSlice)
	COM_INTERFACE_ENTRY(IDescendentPayeeSlice)
	COM_INTERFACE_ENTRY(IViewSlice)
	COM_INTERFACE_ENTRY(IAccountSlice)
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

// IDescendentPayeeSlice
public:
	STDMETHOD(get_AncestorID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_AncestorID)(/*[in]*/ long newVal);
	STDMETHOD(get_End)(/*[out, retval]*/ DATE *pVal);
	STDMETHOD(put_End)(/*[in]*/ DATE newVal);
	STDMETHOD(get_Begin)(/*[out, retval]*/ DATE *pVal);
	STDMETHOD(put_Begin)(/*[in]*/ DATE newVal);
// IViewSlice
public:
	STDMETHOD(GenerateQueryPredicate)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(ToString)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(ToStringUnencrypted)(/*[out, retval]*/ BSTR *pVal);
	STDMETHOD(FromString)(/*[in]*/ ISliceLexer* apLexer);
  STDMETHOD(Equals)(/*[in]*/ IViewSlice* apSlice, /*[out,retval]*/ VARIANT_BOOL *pVal);
  STDMETHOD(Clone)(/*[out,retval]*/ IViewSlice* *pVal);
// IAccountSlice
public:
	STDMETHOD(GenerateFromClause)(/*[out, retval]*/ BSTR *pVal);
private:
	long mAncestorID;
	DATE mBegin;
	DATE mEnd;
};

#endif //__DESCENDENTPAYEESLICE_H_
