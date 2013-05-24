	
// PayerAndPayeeSlice.h : Declaration of the CPayerAndPayeeSlice

#ifndef __PAYERANDPAYEESLICE_H_
#define __PAYERANDPAYEESLICE_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CPayerAndPayeeSlice
class ATL_NO_VTABLE CPayerAndPayeeSlice : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CPayerAndPayeeSlice, &CLSID_PayerAndPayeeSlice>,
	public ISupportErrorInfo,
	public IDispatchImpl<IPayerAndPayeeSlice, &IID_IPayerAndPayeeSlice, &LIBID_MTHIERARCHYREPORTSLib>
{
public:
	CPayerAndPayeeSlice()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_PAYERANDPAYEESLICE)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CPayerAndPayeeSlice)
	COM_INTERFACE_ENTRY(IPayerAndPayeeSlice)
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

// IPayerAndPayeeSlice
public:
	STDMETHOD(get_PayeeID)(/*[out, retval]*/ long *pVal);
	STDMETHOD(put_PayeeID)(/*[in]*/ long newVal);
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
	long mPayeeID;
	long mPayerID;
};

#endif //__PAYERANDPAYEESLICE_H_
