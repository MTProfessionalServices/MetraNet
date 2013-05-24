// PayeeAndEndpointSlice.h : Declaration of the CPayeeAndEndpointSlice

#pragma once
#include "resource.h"       // main symbols

#include "MTHierarchyReports.h"


// CPayeeAndEndpointSlice

class ATL_NO_VTABLE CPayeeAndEndpointSlice : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CPayeeAndEndpointSlice, &CLSID_PayeeAndEndpointSlice>,
	public ISupportErrorInfo,
	public IDispatchImpl<IPayeeAndEndpointSlice, &IID_IPayeeAndEndpointSlice, &LIBID_MTHIERARCHYREPORTSLib, /*wMajor =*/ 1, /*wMinor =*/ 0>
{
public:
	CPayeeAndEndpointSlice()
	{
		m_pUnkMarshaler = NULL;
	}

DECLARE_REGISTRY_RESOURCEID(IDR_PAYEEANDENDPOINTSLICE)


BEGIN_COM_MAP(CPayeeAndEndpointSlice)
	COM_INTERFACE_ENTRY(IPayeeAndEndpointSlice)
	COM_INTERFACE_ENTRY(IViewSlice)
	COM_INTERFACE_ENTRY(IAccountSlice)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_AGGREGATE(IID_IMarshal, m_pUnkMarshaler.p)
END_COM_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

	DECLARE_PROTECT_FINAL_CONSTRUCT()
	DECLARE_GET_CONTROLLING_UNKNOWN()

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

public:

	STDMETHOD(get_PayeeID)(long* pVal);
	STDMETHOD(put_PayeeID)(long newVal);
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
	//long mServiceEndpointID;
};

OBJECT_ENTRY_AUTO(__uuidof(PayeeAndEndpointSlice), CPayeeAndEndpointSlice)
