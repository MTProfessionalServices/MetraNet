	
// PayerSlice.h : Declaration of the CPayerSlice

#ifndef __PAYERSLICE_H_
#define __PAYERSLICE_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CPayerSlice
class ATL_NO_VTABLE CPayerSlice : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CPayerSlice, &CLSID_PayerSlice>,
	public ISupportErrorInfo,
	public IDispatchImpl<IPayerSlice, &IID_IPayerSlice, &LIBID_MTHIERARCHYREPORTSLib>
{
public:
	CPayerSlice()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_PAYERSLICE)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CPayerSlice)
	COM_INTERFACE_ENTRY(IPayerSlice)
	COM_INTERFACE_ENTRY2(IDispatch, IPayerSlice)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
	COM_INTERFACE_ENTRY(IViewSlice)
	COM_INTERFACE_ENTRY(IAccountSlice)
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

// IPayerSlice
public:
	STDMETHOD(get_PayerID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_PayerID)(/*[in]*/ long newVal);
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
	long mPayerID;
};

#endif //__PAYERSLICE_H_
