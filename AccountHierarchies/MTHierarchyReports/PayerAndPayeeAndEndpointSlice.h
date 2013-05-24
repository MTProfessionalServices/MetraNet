// PayerAndPayeeAndEndpointSlice.h : Declaration of the CPayerAndPayeeAndEndpointSlice

#pragma once
#include "resource.h"       // main symbols

#include "MTHierarchyReports.h"


// CPayerAndPayeeAndEndpointSlice

class ATL_NO_VTABLE CPayerAndPayeeAndEndpointSlice : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CPayerAndPayeeAndEndpointSlice, &CLSID_PayerAndPayeeAndEndpointSlice>,
	public ISupportErrorInfo,
	public IDispatchImpl<IPayerAndPayeeAndEndpointSlice, &IID_IPayerAndPayeeAndEndpointSlice, &LIBID_MTHIERARCHYREPORTSLib, /*wMajor =*/ 1, /*wMinor =*/ 0>
{
public:
	CPayerAndPayeeAndEndpointSlice()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_PAYERANDPAYEEANDENDPOINTSLICE)
DECLARE_GET_CONTROLLING_UNKNOWN()

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CPayerAndPayeeAndEndpointSlice)
	COM_INTERFACE_ENTRY(IPayerAndPayeeAndEndpointSlice)
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

public:

	STDMETHOD(get_PayeeID)(long* pVal);
	STDMETHOD(put_PayeeID)(long newVal);
	STDMETHOD(get_PayerID)(long* pVal);
	STDMETHOD(put_PayerID)(long newVal);
	//STDMETHOD(get_ServiceEndpointID)(long* pVal);
	//STDMETHOD(put_ServiceEndpointID)(long newVal);
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
	//long mServiceEndpointID;
};

OBJECT_ENTRY_AUTO(__uuidof(PayerAndPayeeAndEndpointSlice), CPayerAndPayeeAndEndpointSlice)
